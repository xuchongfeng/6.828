
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004f:	e8 ce 00 00 00       	call   800122 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 14 00             	lea    (%eax,%eax,1),%edx
  80005c:	01 d0                	add    %edx,%eax
  80005e:	c1 e0 05             	shl    $0x5,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 db                	test   %ebx,%ebx
  80006d:	7e 07                	jle    800076 <libmain+0x32>
		binaryname = argv[0];
  80006f:	8b 06                	mov    (%esi),%eax
  800071:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	56                   	push   %esi
  80007a:	53                   	push   %ebx
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 44 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7f 08                	jg     80010b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 3e 0d 80 00       	push   $0x800d3e
  800116:	6a 23                	push   $0x23
  800118:	68 5b 0d 80 00       	push   $0x800d5b
  80011d:	e8 22 00 00 00       	call   800144 <_panic>

00800122 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 02 00 00 00       	mov    $0x2,%eax
  800132:	89 d1                	mov    %edx,%ecx
  800134:	89 d3                	mov    %edx,%ebx
  800136:	89 d7                	mov    %edx,%edi
  800138:	89 d6                	mov    %edx,%esi
  80013a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5f                   	pop    %edi
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800152:	e8 cb ff ff ff       	call   800122 <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	56                   	push   %esi
  800161:	50                   	push   %eax
  800162:	68 6c 0d 80 00       	push   $0x800d6c
  800167:	e8 b4 00 00 00       	call   800220 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	53                   	push   %ebx
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 57 00 00 00       	call   8001cf <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 90 0d 80 00 	movl   $0x800d90,(%esp)
  80017f:	e8 9c 00 00 00       	call   800220 <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x43>
	...

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	74 08                	je     8001b3 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ab:	ff 43 04             	incl   0x4(%ebx)
}
  8001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	68 ff 00 00 00       	push   $0xff
  8001bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 e0 fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	eb dc                	jmp    8001ab <putch+0x1f>

008001cf <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ec:	ff 75 0c             	pushl  0xc(%ebp)
  8001ef:	ff 75 08             	pushl  0x8(%ebp)
  8001f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	68 8c 01 80 00       	push   $0x80018c
  8001fe:	e8 17 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800203:	83 c4 08             	add    $0x8,%esp
  800206:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	e8 8c fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800218:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800226:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 08             	pushl  0x8(%ebp)
  80022d:	e8 9d ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 1c             	sub    $0x1c,%esp
  80023d:	89 c7                	mov    %eax,%edi
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800250:	bb 00 00 00 00       	mov    $0x0,%ebx
  800255:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800258:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025b:	39 d3                	cmp    %edx,%ebx
  80025d:	72 05                	jb     800264 <printnum+0x30>
  80025f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800262:	77 78                	ja     8002dc <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	ff 75 18             	pushl  0x18(%ebp)
  80026a:	8b 45 14             	mov    0x14(%ebp),%eax
  80026d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800270:	53                   	push   %ebx
  800271:	ff 75 10             	pushl  0x10(%ebp)
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027a:	ff 75 e0             	pushl  -0x20(%ebp)
  80027d:	ff 75 dc             	pushl  -0x24(%ebp)
  800280:	ff 75 d8             	pushl  -0x28(%ebp)
  800283:	e8 a8 08 00 00       	call   800b30 <__udivdi3>
  800288:	83 c4 18             	add    $0x18,%esp
  80028b:	52                   	push   %edx
  80028c:	50                   	push   %eax
  80028d:	89 f2                	mov    %esi,%edx
  80028f:	89 f8                	mov    %edi,%eax
  800291:	e8 9e ff ff ff       	call   800234 <printnum>
  800296:	83 c4 20             	add    $0x20,%esp
  800299:	eb 11                	jmp    8002ac <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	ff 75 18             	pushl  0x18(%ebp)
  8002a2:	ff d7                	call   *%edi
  8002a4:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f ef                	jg     80029b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bf:	e8 6c 09 00 00       	call   800c30 <__umoddi3>
  8002c4:	83 c4 14             	add    $0x14,%esp
  8002c7:	0f be 80 92 0d 80 00 	movsbl 0x800d92(%eax),%eax
  8002ce:	50                   	push   %eax
  8002cf:	ff d7                	call   *%edi
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
  8002dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002df:	eb c6                	jmp    8002a7 <printnum+0x73>

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ef:	73 0a                	jae    8002fb <sprintputch+0x1a>
		*b->buf++ = ch;
  8002f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	88 02                	mov    %al,(%edx)
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800303:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800306:	50                   	push   %eax
  800307:	ff 75 10             	pushl  0x10(%ebp)
  80030a:	ff 75 0c             	pushl  0xc(%ebp)
  80030d:	ff 75 08             	pushl  0x8(%ebp)
  800310:	e8 05 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 2c             	sub    $0x2c,%esp
  800323:	8b 75 08             	mov    0x8(%ebp),%esi
  800326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800329:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032c:	e9 ac 03 00 00       	jmp    8006dd <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800331:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800335:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  80033c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800343:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80034a:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8d 47 01             	lea    0x1(%edi),%eax
  800352:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800355:	8a 17                	mov    (%edi),%dl
  800357:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035a:	3c 55                	cmp    $0x55,%al
  80035c:	0f 87 fc 03 00 00    	ja     80075e <vprintfmt+0x444>
  800362:	0f b6 c0             	movzbl %al,%eax
  800365:	ff 24 85 20 0e 80 00 	jmp    *0x800e20(,%eax,4)
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800373:	eb da                	jmp    80034f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037c:	eb d1                	jmp    80034f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	0f b6 d2             	movzbl %dl,%edx
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800384:	b8 00 00 00 00       	mov    $0x0,%eax
  800389:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80038c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038f:	01 c0                	add    %eax,%eax
  800391:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 52                	ja     8003f2 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003a1:	eb e9                	jmp    80038c <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 40 04             	lea    0x4(%eax),%eax
  8003b1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bb:	79 92                	jns    80034f <vprintfmt+0x35>
				width = precision, precision = -1;
  8003bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ca:	eb 83                	jmp    80034f <vprintfmt+0x35>
  8003cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d0:	78 08                	js     8003da <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d5:	e9 75 ff ff ff       	jmp    80034f <vprintfmt+0x35>
  8003da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e1:	eb ef                	jmp    8003d2 <vprintfmt+0xb8>
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ed:	e9 5d ff ff ff       	jmp    80034f <vprintfmt+0x35>
  8003f2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f8:	eb bd                	jmp    8003b7 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fa:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fe:	e9 4c ff ff ff       	jmp    80034f <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 78 04             	lea    0x4(%eax),%edi
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff d6                	call   *%esi
			break;
  800411:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800417:	e9 be 02 00 00       	jmp    8006da <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	8b 00                	mov    (%eax),%eax
  800424:	85 c0                	test   %eax,%eax
  800426:	78 2a                	js     800452 <vprintfmt+0x138>
  800428:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042a:	83 f8 06             	cmp    $0x6,%eax
  80042d:	7f 27                	jg     800456 <vprintfmt+0x13c>
  80042f:	8b 04 85 78 0f 80 00 	mov    0x800f78(,%eax,4),%eax
  800436:	85 c0                	test   %eax,%eax
  800438:	74 1c                	je     800456 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80043a:	50                   	push   %eax
  80043b:	68 b3 0d 80 00       	push   $0x800db3
  800440:	53                   	push   %ebx
  800441:	56                   	push   %esi
  800442:	e8 b6 fe ff ff       	call   8002fd <printfmt>
  800447:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044d:	e9 88 02 00 00       	jmp    8006da <vprintfmt+0x3c0>
  800452:	f7 d8                	neg    %eax
  800454:	eb d2                	jmp    800428 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800456:	52                   	push   %edx
  800457:	68 aa 0d 80 00       	push   $0x800daa
  80045c:	53                   	push   %ebx
  80045d:	56                   	push   %esi
  80045e:	e8 9a fe ff ff       	call   8002fd <printfmt>
  800463:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800469:	e9 6c 02 00 00       	jmp    8006da <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	83 c0 04             	add    $0x4,%eax
  800474:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8b 38                	mov    (%eax),%edi
  80047c:	85 ff                	test   %edi,%edi
  80047e:	74 18                	je     800498 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800480:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800484:	0f 8e b7 00 00 00    	jle    800541 <vprintfmt+0x227>
  80048a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048e:	75 0f                	jne    80049f <vprintfmt+0x185>
  800490:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800493:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800496:	eb 75                	jmp    80050d <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800498:	bf a3 0d 80 00       	mov    $0x800da3,%edi
  80049d:	eb e1                	jmp    800480 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a5:	57                   	push   %edi
  8004a6:	e8 5f 03 00 00       	call   80080a <strnlen>
  8004ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	eb 0d                	jmp    8004d1 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	4f                   	dec    %edi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	7f ef                	jg     8004c4 <vprintfmt+0x1aa>
  8004d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004db:	89 c8                	mov    %ecx,%eax
  8004dd:	85 c9                	test   %ecx,%ecx
  8004df:	78 10                	js     8004f1 <vprintfmt+0x1d7>
  8004e1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ef:	eb 1c                	jmp    80050d <vprintfmt+0x1f3>
  8004f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f6:	eb e9                	jmp    8004e1 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fc:	75 29                	jne    800527 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	50                   	push   %eax
  800505:	ff d6                	call   *%esi
  800507:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	ff 4d e0             	decl   -0x20(%ebp)
  80050d:	47                   	inc    %edi
  80050e:	8a 57 ff             	mov    -0x1(%edi),%dl
  800511:	0f be c2             	movsbl %dl,%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	74 4c                	je     800564 <vprintfmt+0x24a>
  800518:	85 db                	test   %ebx,%ebx
  80051a:	78 dc                	js     8004f8 <vprintfmt+0x1de>
  80051c:	4b                   	dec    %ebx
  80051d:	79 d9                	jns    8004f8 <vprintfmt+0x1de>
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800525:	eb 2e                	jmp    800555 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800527:	0f be d2             	movsbl %dl,%edx
  80052a:	83 ea 20             	sub    $0x20,%edx
  80052d:	83 fa 5e             	cmp    $0x5e,%edx
  800530:	76 cc                	jbe    8004fe <vprintfmt+0x1e4>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff d6                	call   *%esi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb c9                	jmp    80050a <vprintfmt+0x1f0>
  800541:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800544:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800547:	eb c4                	jmp    80050d <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	6a 20                	push   $0x20
  80054f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800551:	4f                   	dec    %edi
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 ff                	test   %edi,%edi
  800557:	7f f0                	jg     800549 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
  80055f:	e9 76 01 00 00       	jmp    8006da <vprintfmt+0x3c0>
  800564:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb e9                	jmp    800555 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7e 3f                	jle    8005b0 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 50 04             	mov    0x4(%eax),%edx
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 40 08             	lea    0x8(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	79 5c                	jns    8005ea <vprintfmt+0x2d0>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059c:	f7 da                	neg    %edx
  80059e:	83 d1 00             	adc    $0x0,%ecx
  8005a1:	f7 d9                	neg    %ecx
  8005a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 10 01 00 00       	jmp    8006c0 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	75 1b                	jne    8005cf <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 c1                	mov    %eax,%ecx
  8005be:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cd:	eb b9                	jmp    800588 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb 9e                	jmp    800588 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f5:	e9 c6 00 00 00       	jmp    8006c0 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7e 18                	jle    800617 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	e9 a9 00 00 00       	jmp    8006c0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	75 1a                	jne    800635 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80062b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800630:	e9 8b 00 00 00       	jmp    8006c0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063f:	8d 40 04             	lea    0x4(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064a:	eb 74                	jmp    8006c0 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064c:	83 f9 01             	cmp    $0x1,%ecx
  80064f:	7e 15                	jle    800666 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	8b 48 04             	mov    0x4(%eax),%ecx
  800659:	8d 40 08             	lea    0x8(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80065f:	b8 08 00 00 00       	mov    $0x8,%eax
  800664:	eb 5a                	jmp    8006c0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 17                	jne    800681 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
  80067f:	eb 3f                	jmp    8006c0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800691:	b8 08 00 00 00       	mov    $0x8,%eax
  800696:	eb 28                	jmp    8006c0 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 30                	push   $0x30
  80069e:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a0:	83 c4 08             	add    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 78                	push   $0x78
  8006a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	50                   	push   %eax
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 5d fb ff ff       	call   800234 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006dd:	47                   	inc    %edi
  8006de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e2:	83 f8 25             	cmp    $0x25,%eax
  8006e5:	0f 84 46 fc ff ff    	je     800331 <vprintfmt+0x17>
			if (ch == '\0')
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	0f 84 89 00 00 00    	je     80077c <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	50                   	push   %eax
  8006f8:	ff d6                	call   *%esi
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb de                	jmp    8006dd <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 15                	jle    800719 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
  800717:	eb a7                	jmp    8006c0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	75 17                	jne    800734 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
  800732:	eb 8c                	jmp    8006c0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
  800749:	e9 72 ff ff ff       	jmp    8006c0 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			break;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	e9 7c ff ff ff       	jmp    8006da <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	89 f8                	mov    %edi,%eax
  80076b:	eb 01                	jmp    80076e <vprintfmt+0x454>
  80076d:	48                   	dec    %eax
  80076e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800772:	75 f9                	jne    80076d <vprintfmt+0x453>
  800774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800777:	e9 5e ff ff ff       	jmp    8006da <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  80077c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 18             	sub    $0x18,%esp
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800790:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800793:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800797:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	74 26                	je     8007cb <vsnprintf+0x47>
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	7e 29                	jle    8007d2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a9:	ff 75 14             	pushl  0x14(%ebp)
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	68 e1 02 80 00       	push   $0x8002e1
  8007b8:	e8 5d fb ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c6:	83 c4 10             	add    $0x10,%esp
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d0:	eb f7                	jmp    8007c9 <vsnprintf+0x45>
  8007d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d7:	eb f0                	jmp    8007c9 <vsnprintf+0x45>

008007d9 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e2:	50                   	push   %eax
  8007e3:	ff 75 10             	pushl  0x10(%ebp)
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	ff 75 08             	pushl  0x8(%ebp)
  8007ec:	e8 93 ff ff ff       	call   800784 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    
	...

008007f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	eb 01                	jmp    800802 <strlen+0xe>
		n++;
  800801:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800806:	75 f9                	jne    800801 <strlen+0xd>
		n++;
	return n;
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	eb 01                	jmp    80081b <strnlen+0x11>
		n++;
  80081a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1b>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f5                	jne    80081a <strnlen+0x10>
		n++;
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	89 c2                	mov    %eax,%edx
  800833:	41                   	inc    %ecx
  800834:	42                   	inc    %edx
  800835:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800838:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 f4                	jne    800833 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083f:	5b                   	pop    %ebx
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800849:	53                   	push   %ebx
  80084a:	e8 a5 ff ff ff       	call   8007f4 <strlen>
  80084f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	01 d8                	add    %ebx,%eax
  800857:	50                   	push   %eax
  800858:	e8 ca ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80085d:	89 d8                	mov    %ebx,%eax
  80085f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	89 f3                	mov    %esi,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	89 f2                	mov    %esi,%edx
  800876:	39 da                	cmp    %ebx,%edx
  800878:	74 0e                	je     800888 <strncpy+0x24>
		*dst++ = *src;
  80087a:	42                   	inc    %edx
  80087b:	8a 01                	mov    (%ecx),%al
  80087d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800880:	80 39 00             	cmpb   $0x0,(%ecx)
  800883:	74 f1                	je     800876 <strncpy+0x12>
			src++;
  800885:	41                   	inc    %ecx
  800886:	eb ee                	jmp    800876 <strncpy+0x12>
	}
	return ret;
}
  800888:	89 f0                	mov    %esi,%eax
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	8b 75 08             	mov    0x8(%ebp),%esi
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
  800899:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 20                	je     8008c0 <strlcpy+0x32>
  8008a0:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	eb 05                	jmp    8008ad <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a8:	42                   	inc    %edx
  8008a9:	40                   	inc    %eax
  8008aa:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ad:	39 d8                	cmp    %ebx,%eax
  8008af:	74 06                	je     8008b7 <strlcpy+0x29>
  8008b1:	8a 0a                	mov    (%edx),%cl
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	75 f1                	jne    8008a8 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ba:	29 f0                	sub    %esi,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	eb f6                	jmp    8008ba <strlcpy+0x2c>

008008c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cd:	eb 02                	jmp    8008d1 <strcmp+0xd>
		p++, q++;
  8008cf:	41                   	inc    %ecx
  8008d0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d1:	8a 01                	mov    (%ecx),%al
  8008d3:	84 c0                	test   %al,%al
  8008d5:	74 04                	je     8008db <strcmp+0x17>
  8008d7:	3a 02                	cmp    (%edx),%al
  8008d9:	74 f4                	je     8008cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 c0             	movzbl %al,%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f4:	eb 02                	jmp    8008f8 <strncmp+0x13>
		n--, p++, q++;
  8008f6:	40                   	inc    %eax
  8008f7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x2c>
  8008fc:	8a 08                	mov    (%eax),%cl
  8008fe:	84 c9                	test   %cl,%cl
  800900:	74 04                	je     800906 <strncmp+0x21>
  800902:	3a 0a                	cmp    (%edx),%cl
  800904:	74 f0                	je     8008f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb f6                	jmp    80090e <strncmp+0x29>

00800918 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	74 07                	je     80092e <strchr+0x16>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 08                	je     800933 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092b:	40                   	inc    %eax
  80092c:	eb f3                	jmp    800921 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	74 07                	je     80094b <strfind+0x16>
		if (*s == c)
  800944:	38 ca                	cmp    %cl,%dl
  800946:	74 03                	je     80094b <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800948:	40                   	inc    %eax
  800949:	eb f3                	jmp    80093e <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 7d 08             	mov    0x8(%ebp),%edi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 13                	je     800970 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 05                	jne    80096a <memset+0x1d>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	74 0d                	je     800977 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	fc                   	cld    
  80096e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800970:	89 f8                	mov    %edi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800977:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097b:	89 d3                	mov    %edx,%ebx
  80097d:	c1 e3 08             	shl    $0x8,%ebx
  800980:	89 d0                	mov    %edx,%eax
  800982:	c1 e0 18             	shl    $0x18,%eax
  800985:	89 d6                	mov    %edx,%esi
  800987:	c1 e6 10             	shl    $0x10,%esi
  80098a:	09 f0                	or     %esi,%eax
  80098c:	09 c2                	or     %eax,%edx
  80098e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800990:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800993:	89 d0                	mov    %edx,%eax
  800995:	fc                   	cld    
  800996:	f3 ab                	rep stos %eax,%es:(%edi)
  800998:	eb d6                	jmp    800970 <memset+0x23>

0080099a <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a8:	39 c6                	cmp    %eax,%esi
  8009aa:	73 33                	jae    8009df <memmove+0x45>
  8009ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009af:	39 c2                	cmp    %eax,%edx
  8009b1:	76 2c                	jbe    8009df <memmove+0x45>
		s += n;
		d += n;
  8009b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	89 d6                	mov    %edx,%esi
  8009b8:	09 fe                	or     %edi,%esi
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	74 0a                	je     8009cc <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c2:	4f                   	dec    %edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 21                	jmp    8009ed <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 f1                	jne    8009c2 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d1:	83 ef 04             	sub    $0x4,%edi
  8009d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009da:	fd                   	std    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb ea                	jmp    8009c9 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009df:	89 f2                	mov    %esi,%edx
  8009e1:	09 c2                	or     %eax,%edx
  8009e3:	f6 c2 03             	test   $0x3,%dl
  8009e6:	74 09                	je     8009f1 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 f2                	jne    8009e8 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb ed                	jmp    8009ed <memmove+0x53>

00800a00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a03:	ff 75 10             	pushl  0x10(%ebp)
  800a06:	ff 75 0c             	pushl  0xc(%ebp)
  800a09:	ff 75 08             	pushl  0x8(%ebp)
  800a0c:	e8 89 ff ff ff       	call   80099a <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1e:	89 c6                	mov    %eax,%esi
  800a20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 f0                	cmp    %esi,%eax
  800a25:	74 16                	je     800a3d <memcmp+0x2a>
		if (*s1 != *s2)
  800a27:	8a 08                	mov    (%eax),%cl
  800a29:	8a 1a                	mov    (%edx),%bl
  800a2b:	38 d9                	cmp    %bl,%cl
  800a2d:	75 04                	jne    800a33 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2f:	40                   	inc    %eax
  800a30:	42                   	inc    %edx
  800a31:	eb f0                	jmp    800a23 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800a33:	0f b6 c1             	movzbl %cl,%eax
  800a36:	0f b6 db             	movzbl %bl,%ebx
  800a39:	29 d8                	sub    %ebx,%eax
  800a3b:	eb 05                	jmp    800a42 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 07                	jae    800a5f <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a58:	38 08                	cmp    %cl,(%eax)
  800a5a:	74 03                	je     800a5f <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5c:	40                   	inc    %eax
  800a5d:	eb f5                	jmp    800a54 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 01                	jmp    800a6d <strtol+0xc>
		s++;
  800a6c:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	8a 01                	mov    (%ecx),%al
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f9                	je     800a6c <strtol+0xb>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f5                	je     800a6c <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	74 2b                	je     800aa6 <strtol+0x45>
		s++;
	else if (*s == '-')
  800a7b:	3c 2d                	cmp    $0x2d,%al
  800a7d:	74 2f                	je     800aae <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800a8b:	75 12                	jne    800a9f <strtol+0x3e>
  800a8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a90:	74 24                	je     800ab6 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a96:	75 07                	jne    800a9f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	eb 4e                	jmp    800af4 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800aa6:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	eb d6                	jmp    800a84 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800aae:	41                   	inc    %ecx
  800aaf:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab4:	eb ce                	jmp    800a84 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aba:	74 10                	je     800acc <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac0:	75 dd                	jne    800a9f <strtol+0x3e>
		s++, base = 8;
  800ac2:	41                   	inc    %ecx
  800ac3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800aca:	eb d3                	jmp    800a9f <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ad6:	eb c7                	jmp    800a9f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 24                	ja     800b06 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae8:	39 55 10             	cmp    %edx,0x10(%ebp)
  800aeb:	7e 2b                	jle    800b18 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800aed:	41                   	inc    %ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	8a 11                	mov    (%ecx),%dl
  800af6:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800af9:	80 fb 09             	cmp    $0x9,%bl
  800afc:	77 da                	ja     800ad8 <strtol+0x77>
			dig = *s - '0';
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 30             	sub    $0x30,%edx
  800b04:	eb e2                	jmp    800ae8 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 37             	sub    $0x37,%edx
  800b16:	eb d0                	jmp    800ae8 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 05                	je     800b23 <strtol+0xc2>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b23:	85 ff                	test   %edi,%edi
  800b25:	74 02                	je     800b29 <strtol+0xc8>
  800b27:	f7 d8                	neg    %eax
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
	...

00800b30 <__udivdi3>:
  800b30:	55                   	push   %ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	83 ec 1c             	sub    $0x1c,%esp
  800b37:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b3b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b3f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b43:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b47:	85 d2                	test   %edx,%edx
  800b49:	75 2d                	jne    800b78 <__udivdi3+0x48>
  800b4b:	39 f7                	cmp    %esi,%edi
  800b4d:	77 59                	ja     800ba8 <__udivdi3+0x78>
  800b4f:	89 f9                	mov    %edi,%ecx
  800b51:	85 ff                	test   %edi,%edi
  800b53:	75 0b                	jne    800b60 <__udivdi3+0x30>
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	31 d2                	xor    %edx,%edx
  800b5c:	f7 f7                	div    %edi
  800b5e:	89 c1                	mov    %eax,%ecx
  800b60:	31 d2                	xor    %edx,%edx
  800b62:	89 f0                	mov    %esi,%eax
  800b64:	f7 f1                	div    %ecx
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 e8                	mov    %ebp,%eax
  800b6a:	f7 f1                	div    %ecx
  800b6c:	89 da                	mov    %ebx,%edx
  800b6e:	83 c4 1c             	add    $0x1c,%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
  800b76:	66 90                	xchg   %ax,%ax
  800b78:	39 f2                	cmp    %esi,%edx
  800b7a:	77 1c                	ja     800b98 <__udivdi3+0x68>
  800b7c:	0f bd da             	bsr    %edx,%ebx
  800b7f:	83 f3 1f             	xor    $0x1f,%ebx
  800b82:	75 38                	jne    800bbc <__udivdi3+0x8c>
  800b84:	39 f2                	cmp    %esi,%edx
  800b86:	72 08                	jb     800b90 <__udivdi3+0x60>
  800b88:	39 ef                	cmp    %ebp,%edi
  800b8a:	0f 87 98 00 00 00    	ja     800c28 <__udivdi3+0xf8>
  800b90:	b8 01 00 00 00       	mov    $0x1,%eax
  800b95:	eb 05                	jmp    800b9c <__udivdi3+0x6c>
  800b97:	90                   	nop
  800b98:	31 db                	xor    %ebx,%ebx
  800b9a:	31 c0                	xor    %eax,%eax
  800b9c:	89 da                	mov    %ebx,%edx
  800b9e:	83 c4 1c             	add    $0x1c,%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    
  800ba6:	66 90                	xchg   %ax,%ax
  800ba8:	89 e8                	mov    %ebp,%eax
  800baa:	89 f2                	mov    %esi,%edx
  800bac:	f7 f7                	div    %edi
  800bae:	31 db                	xor    %ebx,%ebx
  800bb0:	89 da                	mov    %ebx,%edx
  800bb2:	83 c4 1c             	add    $0x1c,%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    
  800bba:	66 90                	xchg   %ax,%ax
  800bbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800bc1:	29 d8                	sub    %ebx,%eax
  800bc3:	88 d9                	mov    %bl,%cl
  800bc5:	d3 e2                	shl    %cl,%edx
  800bc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bcb:	89 fa                	mov    %edi,%edx
  800bcd:	88 c1                	mov    %al,%cl
  800bcf:	d3 ea                	shr    %cl,%edx
  800bd1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bd5:	09 d1                	or     %edx,%ecx
  800bd7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bdb:	88 d9                	mov    %bl,%cl
  800bdd:	d3 e7                	shl    %cl,%edi
  800bdf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800be3:	89 f7                	mov    %esi,%edi
  800be5:	88 c1                	mov    %al,%cl
  800be7:	d3 ef                	shr    %cl,%edi
  800be9:	88 d9                	mov    %bl,%cl
  800beb:	d3 e6                	shl    %cl,%esi
  800bed:	89 ea                	mov    %ebp,%edx
  800bef:	88 c1                	mov    %al,%cl
  800bf1:	d3 ea                	shr    %cl,%edx
  800bf3:	09 d6                	or     %edx,%esi
  800bf5:	89 f0                	mov    %esi,%eax
  800bf7:	89 fa                	mov    %edi,%edx
  800bf9:	f7 74 24 08          	divl   0x8(%esp)
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	f7 64 24 0c          	mull   0xc(%esp)
  800c05:	39 d7                	cmp    %edx,%edi
  800c07:	72 13                	jb     800c1c <__udivdi3+0xec>
  800c09:	74 09                	je     800c14 <__udivdi3+0xe4>
  800c0b:	89 f0                	mov    %esi,%eax
  800c0d:	31 db                	xor    %ebx,%ebx
  800c0f:	eb 8b                	jmp    800b9c <__udivdi3+0x6c>
  800c11:	8d 76 00             	lea    0x0(%esi),%esi
  800c14:	88 d9                	mov    %bl,%cl
  800c16:	d3 e5                	shl    %cl,%ebp
  800c18:	39 c5                	cmp    %eax,%ebp
  800c1a:	73 ef                	jae    800c0b <__udivdi3+0xdb>
  800c1c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c1f:	31 db                	xor    %ebx,%ebx
  800c21:	e9 76 ff ff ff       	jmp    800b9c <__udivdi3+0x6c>
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	31 c0                	xor    %eax,%eax
  800c2a:	e9 6d ff ff ff       	jmp    800b9c <__udivdi3+0x6c>
	...

00800c30 <__umoddi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c3b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c3f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c43:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c47:	89 f0                	mov    %esi,%eax
  800c49:	89 da                	mov    %ebx,%edx
  800c4b:	85 ed                	test   %ebp,%ebp
  800c4d:	75 15                	jne    800c64 <__umoddi3+0x34>
  800c4f:	39 df                	cmp    %ebx,%edi
  800c51:	76 39                	jbe    800c8c <__umoddi3+0x5c>
  800c53:	f7 f7                	div    %edi
  800c55:	89 d0                	mov    %edx,%eax
  800c57:	31 d2                	xor    %edx,%edx
  800c59:	83 c4 1c             	add    $0x1c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    
  800c61:	8d 76 00             	lea    0x0(%esi),%esi
  800c64:	39 dd                	cmp    %ebx,%ebp
  800c66:	77 f1                	ja     800c59 <__umoddi3+0x29>
  800c68:	0f bd cd             	bsr    %ebp,%ecx
  800c6b:	83 f1 1f             	xor    $0x1f,%ecx
  800c6e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c72:	75 38                	jne    800cac <__umoddi3+0x7c>
  800c74:	39 dd                	cmp    %ebx,%ebp
  800c76:	72 04                	jb     800c7c <__umoddi3+0x4c>
  800c78:	39 f7                	cmp    %esi,%edi
  800c7a:	77 dd                	ja     800c59 <__umoddi3+0x29>
  800c7c:	89 da                	mov    %ebx,%edx
  800c7e:	89 f0                	mov    %esi,%eax
  800c80:	29 f8                	sub    %edi,%eax
  800c82:	19 ea                	sbb    %ebp,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	89 f9                	mov    %edi,%ecx
  800c8e:	85 ff                	test   %edi,%edi
  800c90:	75 0b                	jne    800c9d <__umoddi3+0x6d>
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	31 d2                	xor    %edx,%edx
  800c99:	f7 f7                	div    %edi
  800c9b:	89 c1                	mov    %eax,%ecx
  800c9d:	89 d8                	mov    %ebx,%eax
  800c9f:	31 d2                	xor    %edx,%edx
  800ca1:	f7 f1                	div    %ecx
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	f7 f1                	div    %ecx
  800ca7:	eb ac                	jmp    800c55 <__umoddi3+0x25>
  800ca9:	8d 76 00             	lea    0x0(%esi),%esi
  800cac:	b8 20 00 00 00       	mov    $0x20,%eax
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cb7:	29 c2                	sub    %eax,%edx
  800cb9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cbd:	88 c1                	mov    %al,%cl
  800cbf:	d3 e5                	shl    %cl,%ebp
  800cc1:	89 f8                	mov    %edi,%eax
  800cc3:	88 d1                	mov    %dl,%cl
  800cc5:	d3 e8                	shr    %cl,%eax
  800cc7:	09 c5                	or     %eax,%ebp
  800cc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ccd:	88 c1                	mov    %al,%cl
  800ccf:	d3 e7                	shl    %cl,%edi
  800cd1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	88 d1                	mov    %dl,%cl
  800cd9:	d3 ef                	shr    %cl,%edi
  800cdb:	88 c1                	mov    %al,%cl
  800cdd:	d3 e3                	shl    %cl,%ebx
  800cdf:	89 f0                	mov    %esi,%eax
  800ce1:	88 d1                	mov    %dl,%cl
  800ce3:	d3 e8                	shr    %cl,%eax
  800ce5:	09 d8                	or     %ebx,%eax
  800ce7:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ceb:	d3 e6                	shl    %cl,%esi
  800ced:	89 fa                	mov    %edi,%edx
  800cef:	f7 f5                	div    %ebp
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	f7 64 24 08          	mull   0x8(%esp)
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	39 d1                	cmp    %edx,%ecx
  800cfd:	72 29                	jb     800d28 <__umoddi3+0xf8>
  800cff:	74 23                	je     800d24 <__umoddi3+0xf4>
  800d01:	89 ca                	mov    %ecx,%edx
  800d03:	29 de                	sub    %ebx,%esi
  800d05:	19 fa                	sbb    %edi,%edx
  800d07:	89 d0                	mov    %edx,%eax
  800d09:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800d0d:	d3 e0                	shl    %cl,%eax
  800d0f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800d13:	88 d9                	mov    %bl,%cl
  800d15:	d3 ee                	shr    %cl,%esi
  800d17:	09 f0                	or     %esi,%eax
  800d19:	d3 ea                	shr    %cl,%edx
  800d1b:	83 c4 1c             	add    $0x1c,%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    
  800d23:	90                   	nop
  800d24:	39 c6                	cmp    %eax,%esi
  800d26:	73 d9                	jae    800d01 <__umoddi3+0xd1>
  800d28:	2b 44 24 08          	sub    0x8(%esp),%eax
  800d2c:	19 ea                	sbb    %ebp,%edx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	eb cd                	jmp    800d01 <__umoddi3+0xd1>
