
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 07                	push   $0x7
  800044:	53                   	push   %ebx
  800045:	56                   	push   %esi
  800046:	e8 99 0c 00 00       	call   800ce4 <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 4a                	js     80009c <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800052:	83 ec 0c             	sub    $0xc,%esp
  800055:	6a 07                	push   $0x7
  800057:	68 00 00 40 00       	push   $0x400000
  80005c:	6a 00                	push   $0x0
  80005e:	53                   	push   %ebx
  80005f:	56                   	push   %esi
  800060:	e8 c2 0c 00 00       	call   800d27 <sys_page_map>
  800065:	83 c4 20             	add    $0x20,%esp
  800068:	85 c0                	test   %eax,%eax
  80006a:	78 42                	js     8000ae <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 10 00 00       	push   $0x1000
  800074:	53                   	push   %ebx
  800075:	68 00 00 40 00       	push   $0x400000
  80007a:	e8 13 0a 00 00       	call   800a92 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007f:	83 c4 08             	add    $0x8,%esp
  800082:	68 00 00 40 00       	push   $0x400000
  800087:	6a 00                	push   $0x0
  800089:	e8 db 0c 00 00       	call   800d69 <sys_page_unmap>
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	85 c0                	test   %eax,%eax
  800093:	78 2b                	js     8000c0 <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    
{
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 a0 10 80 00       	push   $0x8010a0
  8000a2:	6a 20                	push   $0x20
  8000a4:	68 b3 10 80 00       	push   $0x8010b3
  8000a9:	e8 8e 01 00 00       	call   80023c <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  8000ae:	50                   	push   %eax
  8000af:	68 c3 10 80 00       	push   $0x8010c3
  8000b4:	6a 22                	push   $0x22
  8000b6:	68 b3 10 80 00       	push   $0x8010b3
  8000bb:	e8 7c 01 00 00       	call   80023c <_panic>
	memmove(UTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		panic("sys_page_unmap: %e", r);
  8000c0:	50                   	push   %eax
  8000c1:	68 d4 10 80 00       	push   $0x8010d4
  8000c6:	6a 25                	push   $0x25
  8000c8:	68 b3 10 80 00       	push   $0x8010b3
  8000cd:	e8 6a 01 00 00       	call   80023c <_panic>

008000d2 <dumbfork>:
}

envid_t
dumbfork(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000da:	b8 07 00 00 00       	mov    $0x7,%eax
  8000df:	cd 30                	int    $0x30
  8000e1:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	78 0f                	js     8000f6 <dumbfork+0x24>
  8000e7:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	74 1b                	je     800108 <dumbfork+0x36>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000ed:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f4:	eb 45                	jmp    80013b <dumbfork+0x69>
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
  8000f6:	50                   	push   %eax
  8000f7:	68 e7 10 80 00       	push   $0x8010e7
  8000fc:	6a 37                	push   $0x37
  8000fe:	68 b3 10 80 00       	push   $0x8010b3
  800103:	e8 34 01 00 00       	call   80023c <_panic>
	if (envid == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800108:	e8 99 0b 00 00       	call   800ca6 <sys_getenvid>
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	89 c2                	mov    %eax,%edx
  800114:	c1 e2 05             	shl    $0x5,%edx
  800117:	29 c2                	sub    %eax,%edx
  800119:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800125:	eb 43                	jmp    80016a <dumbfork+0x98>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
		duppage(envid, addr);
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	52                   	push   %edx
  80012b:	56                   	push   %esi
  80012c:	e8 03 ff ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800131:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013e:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800144:	72 e1                	jb     800127 <dumbfork+0x55>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800146:	83 ec 08             	sub    $0x8,%esp
  800149:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800151:	50                   	push   %eax
  800152:	53                   	push   %ebx
  800153:	e8 dc fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	6a 02                	push   $0x2
  80015d:	53                   	push   %ebx
  80015e:	e8 48 0c 00 00       	call   800dab <sys_env_set_status>
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	85 c0                	test   %eax,%eax
  800168:	78 09                	js     800173 <dumbfork+0xa1>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80016a:	89 d8                	mov    %ebx,%eax
  80016c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);
  800173:	50                   	push   %eax
  800174:	68 f7 10 80 00       	push   $0x8010f7
  800179:	6a 4c                	push   $0x4c
  80017b:	68 b3 10 80 00       	push   $0x8010b3
  800180:	e8 b7 00 00 00       	call   80023c <_panic>

00800185 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018e:	e8 3f ff ff ff       	call   8000d2 <dumbfork>
  800193:	89 c7                	mov    %eax,%edi
  800195:	85 c0                	test   %eax,%eax
  800197:	74 0c                	je     8001a5 <umain+0x20>
  800199:	be 0e 11 80 00       	mov    $0x80110e,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80019e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a3:	eb 24                	jmp    8001c9 <umain+0x44>
  8001a5:	be 15 11 80 00       	mov    $0x801115,%esi
  8001aa:	eb f2                	jmp    80019e <umain+0x19>
  8001ac:	83 fb 13             	cmp    $0x13,%ebx
  8001af:	7f 21                	jg     8001d2 <umain+0x4d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b1:	83 ec 04             	sub    $0x4,%esp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	68 1b 11 80 00       	push   $0x80111b
  8001bb:	e8 58 01 00 00       	call   800318 <cprintf>
		sys_yield();
  8001c0:	e8 00 0b 00 00       	call   800cc5 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c5:	43                   	inc    %ebx
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	85 ff                	test   %edi,%edi
  8001cb:	74 df                	je     8001ac <umain+0x27>
  8001cd:	83 fb 09             	cmp    $0x9,%ebx
  8001d0:	7e df                	jle    8001b1 <umain+0x2c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    
	...

008001dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e7:	e8 ba 0a 00 00       	call   800ca6 <sys_getenvid>
  8001ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f1:	89 c2                	mov    %eax,%edx
  8001f3:	c1 e2 05             	shl    $0x5,%edx
  8001f6:	29 c2                	sub    %eax,%edx
  8001f8:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8001ff:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800204:	85 db                	test   %ebx,%ebx
  800206:	7e 07                	jle    80020f <libmain+0x33>
		binaryname = argv[0];
  800208:	8b 06                	mov    (%esi),%eax
  80020a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	e8 6c ff ff ff       	call   800185 <umain>

	// exit gracefully
	exit();
  800219:	e8 0a 00 00 00       	call   800228 <exit>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80022e:	6a 00                	push   $0x0
  800230:	e8 30 0a 00 00       	call   800c65 <sys_env_destroy>
}
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	c9                   	leave  
  800239:	c3                   	ret    
	...

0080023c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800241:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800244:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80024a:	e8 57 0a 00 00       	call   800ca6 <sys_getenvid>
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	ff 75 0c             	pushl  0xc(%ebp)
  800255:	ff 75 08             	pushl  0x8(%ebp)
  800258:	56                   	push   %esi
  800259:	50                   	push   %eax
  80025a:	68 38 11 80 00       	push   $0x801138
  80025f:	e8 b4 00 00 00       	call   800318 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	53                   	push   %ebx
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	e8 57 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800270:	c7 04 24 2b 11 80 00 	movl   $0x80112b,(%esp)
  800277:	e8 9c 00 00 00       	call   800318 <cprintf>
  80027c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027f:	cc                   	int3   
  800280:	eb fd                	jmp    80027f <_panic+0x43>
	...

00800284 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028e:	8b 13                	mov    (%ebx),%edx
  800290:	8d 42 01             	lea    0x1(%edx),%eax
  800293:	89 03                	mov    %eax,(%ebx)
  800295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800298:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80029c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a1:	74 08                	je     8002ab <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002a3:	ff 43 04             	incl   0x4(%ebx)
}
  8002a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	68 ff 00 00 00       	push   $0xff
  8002b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b6:	50                   	push   %eax
  8002b7:	e8 6c 09 00 00       	call   800c28 <sys_cputs>
		b->idx = 0;
  8002bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	eb dc                	jmp    8002a3 <putch+0x1f>

008002c7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	ff 75 0c             	pushl  0xc(%ebp)
  8002e7:	ff 75 08             	pushl  0x8(%ebp)
  8002ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f0:	50                   	push   %eax
  8002f1:	68 84 02 80 00       	push   $0x800284
  8002f6:	e8 17 01 00 00       	call   800412 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002fb:	83 c4 08             	add    $0x8,%esp
  8002fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800304:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 18 09 00 00       	call   800c28 <sys_cputs>

	return b.cnt;
}
  800310:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 9d ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 1c             	sub    $0x1c,%esp
  800335:	89 c7                	mov    %eax,%edi
  800337:	89 d6                	mov    %edx,%esi
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800342:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800345:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800348:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800350:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800353:	39 d3                	cmp    %edx,%ebx
  800355:	72 05                	jb     80035c <printnum+0x30>
  800357:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035a:	77 78                	ja     8003d4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	ff 75 18             	pushl  0x18(%ebp)
  800362:	8b 45 14             	mov    0x14(%ebp),%eax
  800365:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800372:	ff 75 e0             	pushl  -0x20(%ebp)
  800375:	ff 75 dc             	pushl  -0x24(%ebp)
  800378:	ff 75 d8             	pushl  -0x28(%ebp)
  80037b:	e8 14 0b 00 00       	call   800e94 <__udivdi3>
  800380:	83 c4 18             	add    $0x18,%esp
  800383:	52                   	push   %edx
  800384:	50                   	push   %eax
  800385:	89 f2                	mov    %esi,%edx
  800387:	89 f8                	mov    %edi,%eax
  800389:	e8 9e ff ff ff       	call   80032c <printnum>
  80038e:	83 c4 20             	add    $0x20,%esp
  800391:	eb 11                	jmp    8003a4 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	56                   	push   %esi
  800397:	ff 75 18             	pushl  0x18(%ebp)
  80039a:	ff d7                	call   *%edi
  80039c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039f:	4b                   	dec    %ebx
  8003a0:	85 db                	test   %ebx,%ebx
  8003a2:	7f ef                	jg     800393 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	56                   	push   %esi
  8003a8:	83 ec 04             	sub    $0x4,%esp
  8003ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b7:	e8 d8 0b 00 00       	call   800f94 <__umoddi3>
  8003bc:	83 c4 14             	add    $0x14,%esp
  8003bf:	0f be 80 5c 11 80 00 	movsbl 0x80115c(%eax),%eax
  8003c6:	50                   	push   %eax
  8003c7:	ff d7                	call   *%edi
}
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cf:	5b                   	pop    %ebx
  8003d0:	5e                   	pop    %esi
  8003d1:	5f                   	pop    %edi
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    
  8003d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d7:	eb c6                	jmp    80039f <printnum+0x73>

008003d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003df:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e7:	73 0a                	jae    8003f3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003e9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ec:	89 08                	mov    %ecx,(%eax)
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	88 02                	mov    %al,(%edx)
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fe:	50                   	push   %eax
  8003ff:	ff 75 10             	pushl  0x10(%ebp)
  800402:	ff 75 0c             	pushl  0xc(%ebp)
  800405:	ff 75 08             	pushl  0x8(%ebp)
  800408:	e8 05 00 00 00       	call   800412 <vprintfmt>
	va_end(ap);
}
  80040d:	83 c4 10             	add    $0x10,%esp
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	83 ec 2c             	sub    $0x2c,%esp
  80041b:	8b 75 08             	mov    0x8(%ebp),%esi
  80041e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800421:	8b 7d 10             	mov    0x10(%ebp),%edi
  800424:	e9 ac 03 00 00       	jmp    8007d5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800429:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80042d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800434:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80043b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800442:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8d 47 01             	lea    0x1(%edi),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	8a 17                	mov    (%edi),%dl
  80044f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800452:	3c 55                	cmp    $0x55,%al
  800454:	0f 87 fc 03 00 00    	ja     800856 <vprintfmt+0x444>
  80045a:	0f b6 c0             	movzbl %al,%eax
  80045d:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800467:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80046b:	eb da                	jmp    800447 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800470:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800474:	eb d1                	jmp    800447 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	0f b6 d2             	movzbl %dl,%edx
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800484:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800487:	01 c0                	add    %eax,%eax
  800489:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80048d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800490:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800493:	83 f9 09             	cmp    $0x9,%ecx
  800496:	77 52                	ja     8004ea <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800498:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800499:	eb e9                	jmp    800484 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 40 04             	lea    0x4(%eax),%eax
  8004a9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	79 92                	jns    800447 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c2:	eb 83                	jmp    800447 <vprintfmt+0x35>
  8004c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c8:	78 08                	js     8004d2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cd:	e9 75 ff ff ff       	jmp    800447 <vprintfmt+0x35>
  8004d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004d9:	eb ef                	jmp    8004ca <vprintfmt+0xb8>
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e5:	e9 5d ff ff ff       	jmp    800447 <vprintfmt+0x35>
  8004ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f0:	eb bd                	jmp    8004af <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f6:	e9 4c ff ff ff       	jmp    800447 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 78 04             	lea    0x4(%eax),%edi
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	ff 30                	pushl  (%eax)
  800507:	ff d6                	call   *%esi
			break;
  800509:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80050f:	e9 be 02 00 00       	jmp    8007d2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 78 04             	lea    0x4(%eax),%edi
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 2a                	js     80054a <vprintfmt+0x138>
  800520:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800522:	83 f8 08             	cmp    $0x8,%eax
  800525:	7f 27                	jg     80054e <vprintfmt+0x13c>
  800527:	8b 04 85 80 13 80 00 	mov    0x801380(,%eax,4),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 1c                	je     80054e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800532:	50                   	push   %eax
  800533:	68 7d 11 80 00       	push   $0x80117d
  800538:	53                   	push   %ebx
  800539:	56                   	push   %esi
  80053a:	e8 b6 fe ff ff       	call   8003f5 <printfmt>
  80053f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	89 7d 14             	mov    %edi,0x14(%ebp)
  800545:	e9 88 02 00 00       	jmp    8007d2 <vprintfmt+0x3c0>
  80054a:	f7 d8                	neg    %eax
  80054c:	eb d2                	jmp    800520 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054e:	52                   	push   %edx
  80054f:	68 74 11 80 00       	push   $0x801174
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 9a fe ff ff       	call   8003f5 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800561:	e9 6c 02 00 00       	jmp    8007d2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	83 c0 04             	add    $0x4,%eax
  80056c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 38                	mov    (%eax),%edi
  800574:	85 ff                	test   %edi,%edi
  800576:	74 18                	je     800590 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800578:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057c:	0f 8e b7 00 00 00    	jle    800639 <vprintfmt+0x227>
  800582:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800586:	75 0f                	jne    800597 <vprintfmt+0x185>
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80058e:	eb 75                	jmp    800605 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800590:	bf 6d 11 80 00       	mov    $0x80116d,%edi
  800595:	eb e1                	jmp    800578 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	ff 75 d0             	pushl  -0x30(%ebp)
  80059d:	57                   	push   %edi
  80059e:	e8 5f 03 00 00       	call   800902 <strnlen>
  8005a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ba:	eb 0d                	jmp    8005c9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	4f                   	dec    %edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ef                	jg     8005bc <vprintfmt+0x1aa>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	89 c8                	mov    %ecx,%eax
  8005d5:	85 c9                	test   %ecx,%ecx
  8005d7:	78 10                	js     8005e9 <vprintfmt+0x1d7>
  8005d9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005dc:	29 c1                	sub    %eax,%ecx
  8005de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e7:	eb 1c                	jmp    800605 <vprintfmt+0x1f3>
  8005e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ee:	eb e9                	jmp    8005d9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f4:	75 29                	jne    80061f <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	ff 75 0c             	pushl  0xc(%ebp)
  8005fc:	50                   	push   %eax
  8005fd:	ff d6                	call   *%esi
  8005ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800602:	ff 4d e0             	decl   -0x20(%ebp)
  800605:	47                   	inc    %edi
  800606:	8a 57 ff             	mov    -0x1(%edi),%dl
  800609:	0f be c2             	movsbl %dl,%eax
  80060c:	85 c0                	test   %eax,%eax
  80060e:	74 4c                	je     80065c <vprintfmt+0x24a>
  800610:	85 db                	test   %ebx,%ebx
  800612:	78 dc                	js     8005f0 <vprintfmt+0x1de>
  800614:	4b                   	dec    %ebx
  800615:	79 d9                	jns    8005f0 <vprintfmt+0x1de>
  800617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80061d:	eb 2e                	jmp    80064d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  80061f:	0f be d2             	movsbl %dl,%edx
  800622:	83 ea 20             	sub    $0x20,%edx
  800625:	83 fa 5e             	cmp    $0x5e,%edx
  800628:	76 cc                	jbe    8005f6 <vprintfmt+0x1e4>
					putch('?', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	ff 75 0c             	pushl  0xc(%ebp)
  800630:	6a 3f                	push   $0x3f
  800632:	ff d6                	call   *%esi
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb c9                	jmp    800602 <vprintfmt+0x1f0>
  800639:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80063f:	eb c4                	jmp    800605 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 20                	push   $0x20
  800647:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800649:	4f                   	dec    %edi
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 ff                	test   %edi,%edi
  80064f:	7f f0                	jg     800641 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800651:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)
  800657:	e9 76 01 00 00       	jmp    8007d2 <vprintfmt+0x3c0>
  80065c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80065f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800662:	eb e9                	jmp    80064d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800664:	83 f9 01             	cmp    $0x1,%ecx
  800667:	7e 3f                	jle    8006a8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 50 04             	mov    0x4(%eax),%edx
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 40 08             	lea    0x8(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	79 5c                	jns    8006e2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 2d                	push   $0x2d
  80068c:	ff d6                	call   *%esi
				num = -(long long) num;
  80068e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800691:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800694:	f7 da                	neg    %edx
  800696:	83 d1 00             	adc    $0x0,%ecx
  800699:	f7 d9                	neg    %ecx
  80069b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 10 01 00 00       	jmp    8007b8 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	75 1b                	jne    8006c7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 c1                	mov    %eax,%ecx
  8006b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c5:	eb b9                	jmp    800680 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cf:	89 c1                	mov    %eax,%ecx
  8006d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e0:	eb 9e                	jmp    800680 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ed:	e9 c6 00 00 00       	jmp    8007b8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f2:	83 f9 01             	cmp    $0x1,%ecx
  8006f5:	7e 18                	jle    80070f <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ff:	8d 40 08             	lea    0x8(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070a:	e9 a9 00 00 00       	jmp    8007b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	75 1a                	jne    80072d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071d:	8d 40 04             	lea    0x4(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
  800728:	e9 8b 00 00 00       	jmp    8007b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8b 10                	mov    (%eax),%edx
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	8d 40 04             	lea    0x4(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 74                	jmp    8007b8 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800744:	83 f9 01             	cmp    $0x1,%ecx
  800747:	7e 15                	jle    80075e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8b 48 04             	mov    0x4(%eax),%ecx
  800751:	8d 40 08             	lea    0x8(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800757:	b8 08 00 00 00       	mov    $0x8,%eax
  80075c:	eb 5a                	jmp    8007b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075e:	85 c9                	test   %ecx,%ecx
  800760:	75 17                	jne    800779 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800772:	b8 08 00 00 00       	mov    $0x8,%eax
  800777:	eb 3f                	jmp    8007b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8b 10                	mov    (%eax),%edx
  80077e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800783:	8d 40 04             	lea    0x4(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800789:	b8 08 00 00 00       	mov    $0x8,%eax
  80078e:	eb 28                	jmp    8007b8 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 30                	push   $0x30
  800796:	ff d6                	call   *%esi
			putch('x', putdat);
  800798:	83 c4 08             	add    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 78                	push   $0x78
  80079e:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007aa:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b3:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	83 ec 0c             	sub    $0xc,%esp
  8007bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007bf:	57                   	push   %edi
  8007c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c3:	50                   	push   %eax
  8007c4:	51                   	push   %ecx
  8007c5:	52                   	push   %edx
  8007c6:	89 da                	mov    %ebx,%edx
  8007c8:	89 f0                	mov    %esi,%eax
  8007ca:	e8 5d fb ff ff       	call   80032c <printnum>
			break;
  8007cf:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d5:	47                   	inc    %edi
  8007d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007da:	83 f8 25             	cmp    $0x25,%eax
  8007dd:	0f 84 46 fc ff ff    	je     800429 <vprintfmt+0x17>
			if (ch == '\0')
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	0f 84 89 00 00 00    	je     800874 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	50                   	push   %eax
  8007f0:	ff d6                	call   *%esi
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb de                	jmp    8007d5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f7:	83 f9 01             	cmp    $0x1,%ecx
  8007fa:	7e 15                	jle    800811 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	8b 48 04             	mov    0x4(%eax),%ecx
  800804:	8d 40 08             	lea    0x8(%eax),%eax
  800807:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080a:	b8 10 00 00 00       	mov    $0x10,%eax
  80080f:	eb a7                	jmp    8007b8 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800811:	85 c9                	test   %ecx,%ecx
  800813:	75 17                	jne    80082c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081f:	8d 40 04             	lea    0x4(%eax),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800825:	b8 10 00 00 00       	mov    $0x10,%eax
  80082a:	eb 8c                	jmp    8007b8 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80083c:	b8 10 00 00 00       	mov    $0x10,%eax
  800841:	e9 72 ff ff ff       	jmp    8007b8 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	53                   	push   %ebx
  80084a:	6a 25                	push   $0x25
  80084c:	ff d6                	call   *%esi
			break;
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	e9 7c ff ff ff       	jmp    8007d2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	6a 25                	push   $0x25
  80085c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	89 f8                	mov    %edi,%eax
  800863:	eb 01                	jmp    800866 <vprintfmt+0x454>
  800865:	48                   	dec    %eax
  800866:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80086a:	75 f9                	jne    800865 <vprintfmt+0x453>
  80086c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086f:	e9 5e ff ff ff       	jmp    8007d2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800874:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 18             	sub    $0x18,%esp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800888:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800892:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800899:	85 c0                	test   %eax,%eax
  80089b:	74 26                	je     8008c3 <vsnprintf+0x47>
  80089d:	85 d2                	test   %edx,%edx
  80089f:	7e 29                	jle    8008ca <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a1:	ff 75 14             	pushl  0x14(%ebp)
  8008a4:	ff 75 10             	pushl  0x10(%ebp)
  8008a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	68 d9 03 80 00       	push   $0x8003d9
  8008b0:	e8 5d fb ff ff       	call   800412 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 c4 10             	add    $0x10,%esp
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c8:	eb f7                	jmp    8008c1 <vsnprintf+0x45>
  8008ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cf:	eb f0                	jmp    8008c1 <vsnprintf+0x45>

008008d1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	50                   	push   %eax
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	ff 75 0c             	pushl  0xc(%ebp)
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 93 ff ff ff       	call   80087c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    
	...

008008ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	eb 01                	jmp    8008fa <strlen+0xe>
		n++;
  8008f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fe:	75 f9                	jne    8008f9 <strlen+0xd>
		n++;
	return n;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 01                	jmp    800913 <strnlen+0x11>
		n++;
  800912:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 d0                	cmp    %edx,%eax
  800915:	74 06                	je     80091d <strnlen+0x1b>
  800917:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80091b:	75 f5                	jne    800912 <strnlen+0x10>
		n++;
	return n;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800929:	89 c2                	mov    %eax,%edx
  80092b:	41                   	inc    %ecx
  80092c:	42                   	inc    %edx
  80092d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800930:	88 5a ff             	mov    %bl,-0x1(%edx)
  800933:	84 db                	test   %bl,%bl
  800935:	75 f4                	jne    80092b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800941:	53                   	push   %ebx
  800942:	e8 a5 ff ff ff       	call   8008ec <strlen>
  800947:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80094a:	ff 75 0c             	pushl  0xc(%ebp)
  80094d:	01 d8                	add    %ebx,%eax
  80094f:	50                   	push   %eax
  800950:	e8 ca ff ff ff       	call   80091f <strcpy>
	return dst;
}
  800955:	89 d8                	mov    %ebx,%eax
  800957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 75 08             	mov    0x8(%ebp),%esi
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800967:	89 f3                	mov    %esi,%ebx
  800969:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096c:	89 f2                	mov    %esi,%edx
  80096e:	39 da                	cmp    %ebx,%edx
  800970:	74 0e                	je     800980 <strncpy+0x24>
		*dst++ = *src;
  800972:	42                   	inc    %edx
  800973:	8a 01                	mov    (%ecx),%al
  800975:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800978:	80 39 00             	cmpb   $0x0,(%ecx)
  80097b:	74 f1                	je     80096e <strncpy+0x12>
			src++;
  80097d:	41                   	inc    %ecx
  80097e:	eb ee                	jmp    80096e <strncpy+0x12>
	}
	return ret;
}
  800980:	89 f0                	mov    %esi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 75 08             	mov    0x8(%ebp),%esi
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800994:	85 c0                	test   %eax,%eax
  800996:	74 20                	je     8009b8 <strlcpy+0x32>
  800998:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80099c:	89 f0                	mov    %esi,%eax
  80099e:	eb 05                	jmp    8009a5 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a0:	42                   	inc    %edx
  8009a1:	40                   	inc    %eax
  8009a2:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a5:	39 d8                	cmp    %ebx,%eax
  8009a7:	74 06                	je     8009af <strlcpy+0x29>
  8009a9:	8a 0a                	mov    (%edx),%cl
  8009ab:	84 c9                	test   %cl,%cl
  8009ad:	75 f1                	jne    8009a0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b2:	29 f0                	sub    %esi,%eax
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    
  8009b8:	89 f0                	mov    %esi,%eax
  8009ba:	eb f6                	jmp    8009b2 <strlcpy+0x2c>

008009bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c5:	eb 02                	jmp    8009c9 <strcmp+0xd>
		p++, q++;
  8009c7:	41                   	inc    %ecx
  8009c8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c9:	8a 01                	mov    (%ecx),%al
  8009cb:	84 c0                	test   %al,%al
  8009cd:	74 04                	je     8009d3 <strcmp+0x17>
  8009cf:	3a 02                	cmp    (%edx),%al
  8009d1:	74 f4                	je     8009c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 c0             	movzbl %al,%eax
  8009d6:	0f b6 12             	movzbl (%edx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e7:	89 c3                	mov    %eax,%ebx
  8009e9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ec:	eb 02                	jmp    8009f0 <strncmp+0x13>
		n--, p++, q++;
  8009ee:	40                   	inc    %eax
  8009ef:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f0:	39 d8                	cmp    %ebx,%eax
  8009f2:	74 15                	je     800a09 <strncmp+0x2c>
  8009f4:	8a 08                	mov    (%eax),%cl
  8009f6:	84 c9                	test   %cl,%cl
  8009f8:	74 04                	je     8009fe <strncmp+0x21>
  8009fa:	3a 0a                	cmp    (%edx),%cl
  8009fc:	74 f0                	je     8009ee <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fe:	0f b6 00             	movzbl (%eax),%eax
  800a01:	0f b6 12             	movzbl (%edx),%edx
  800a04:	29 d0                	sub    %edx,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	eb f6                	jmp    800a06 <strncmp+0x29>

00800a10 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a19:	8a 10                	mov    (%eax),%dl
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	74 07                	je     800a26 <strchr+0x16>
		if (*s == c)
  800a1f:	38 ca                	cmp    %cl,%dl
  800a21:	74 08                	je     800a2b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a23:	40                   	inc    %eax
  800a24:	eb f3                	jmp    800a19 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a36:	8a 10                	mov    (%eax),%dl
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 07                	je     800a43 <strfind+0x16>
		if (*s == c)
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	74 03                	je     800a43 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a40:	40                   	inc    %eax
  800a41:	eb f3                	jmp    800a36 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	74 13                	je     800a68 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 05                	jne    800a62 <memset+0x1d>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	74 0d                	je     800a6f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	fc                   	cld    
  800a66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a68:	89 f8                	mov    %edi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800a6f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a73:	89 d3                	mov    %edx,%ebx
  800a75:	c1 e3 08             	shl    $0x8,%ebx
  800a78:	89 d0                	mov    %edx,%eax
  800a7a:	c1 e0 18             	shl    $0x18,%eax
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	c1 e6 10             	shl    $0x10,%esi
  800a82:	09 f0                	or     %esi,%eax
  800a84:	09 c2                	or     %eax,%edx
  800a86:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a88:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	fc                   	cld    
  800a8e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a90:	eb d6                	jmp    800a68 <memset+0x23>

00800a92 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa0:	39 c6                	cmp    %eax,%esi
  800aa2:	73 33                	jae    800ad7 <memmove+0x45>
  800aa4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa7:	39 c2                	cmp    %eax,%edx
  800aa9:	76 2c                	jbe    800ad7 <memmove+0x45>
		s += n;
		d += n;
  800aab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	89 d6                	mov    %edx,%esi
  800ab0:	09 fe                	or     %edi,%esi
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	74 0a                	je     800ac4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aba:	4f                   	dec    %edi
  800abb:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800abe:	fd                   	std    
  800abf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac1:	fc                   	cld    
  800ac2:	eb 21                	jmp    800ae5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 f1                	jne    800aba <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac9:	83 ef 04             	sub    $0x4,%edi
  800acc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ad2:	fd                   	std    
  800ad3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad5:	eb ea                	jmp    800ac1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	89 f2                	mov    %esi,%edx
  800ad9:	09 c2                	or     %eax,%edx
  800adb:	f6 c2 03             	test   $0x3,%dl
  800ade:	74 09                	je     800ae9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae9:	f6 c1 03             	test   $0x3,%cl
  800aec:	75 f2                	jne    800ae0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aee:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	fc                   	cld    
  800af4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af6:	eb ed                	jmp    800ae5 <memmove+0x53>

00800af8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afb:	ff 75 10             	pushl  0x10(%ebp)
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	ff 75 08             	pushl  0x8(%ebp)
  800b04:	e8 89 ff ff ff       	call   800a92 <memmove>
}
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b16:	89 c6                	mov    %eax,%esi
  800b18:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1b:	39 f0                	cmp    %esi,%eax
  800b1d:	74 16                	je     800b35 <memcmp+0x2a>
		if (*s1 != *s2)
  800b1f:	8a 08                	mov    (%eax),%cl
  800b21:	8a 1a                	mov    (%edx),%bl
  800b23:	38 d9                	cmp    %bl,%cl
  800b25:	75 04                	jne    800b2b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b27:	40                   	inc    %eax
  800b28:	42                   	inc    %edx
  800b29:	eb f0                	jmp    800b1b <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800b2b:	0f b6 c1             	movzbl %cl,%eax
  800b2e:	0f b6 db             	movzbl %bl,%ebx
  800b31:	29 d8                	sub    %ebx,%eax
  800b33:	eb 05                	jmp    800b3a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 07                	jae    800b57 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b50:	38 08                	cmp    %cl,(%eax)
  800b52:	74 03                	je     800b57 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b54:	40                   	inc    %eax
  800b55:	eb f5                	jmp    800b4c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b62:	eb 01                	jmp    800b65 <strtol+0xc>
		s++;
  800b64:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b65:	8a 01                	mov    (%ecx),%al
  800b67:	3c 20                	cmp    $0x20,%al
  800b69:	74 f9                	je     800b64 <strtol+0xb>
  800b6b:	3c 09                	cmp    $0x9,%al
  800b6d:	74 f5                	je     800b64 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b6f:	3c 2b                	cmp    $0x2b,%al
  800b71:	74 2b                	je     800b9e <strtol+0x45>
		s++;
	else if (*s == '-')
  800b73:	3c 2d                	cmp    $0x2d,%al
  800b75:	74 2f                	je     800ba6 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800b83:	75 12                	jne    800b97 <strtol+0x3e>
  800b85:	80 39 30             	cmpb   $0x30,(%ecx)
  800b88:	74 24                	je     800bae <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b8e:	75 07                	jne    800b97 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b90:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	eb 4e                	jmp    800bec <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800b9e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba4:	eb d6                	jmp    800b7c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800ba6:	41                   	inc    %ecx
  800ba7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bac:	eb ce                	jmp    800b7c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb2:	74 10                	je     800bc4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bb8:	75 dd                	jne    800b97 <strtol+0x3e>
		s++, base = 8;
  800bba:	41                   	inc    %ecx
  800bbb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800bc2:	eb d3                	jmp    800b97 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800bc4:	83 c1 02             	add    $0x2,%ecx
  800bc7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800bce:	eb c7                	jmp    800b97 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bd0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd3:	89 f3                	mov    %esi,%ebx
  800bd5:	80 fb 19             	cmp    $0x19,%bl
  800bd8:	77 24                	ja     800bfe <strtol+0xa5>
			dig = *s - 'a' + 10;
  800bda:	0f be d2             	movsbl %dl,%edx
  800bdd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800be3:	7e 2b                	jle    800c10 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800be5:	41                   	inc    %ecx
  800be6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bea:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bec:	8a 11                	mov    (%ecx),%dl
  800bee:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800bf1:	80 fb 09             	cmp    $0x9,%bl
  800bf4:	77 da                	ja     800bd0 <strtol+0x77>
			dig = *s - '0';
  800bf6:	0f be d2             	movsbl %dl,%edx
  800bf9:	83 ea 30             	sub    $0x30,%edx
  800bfc:	eb e2                	jmp    800be0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c01:	89 f3                	mov    %esi,%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 08                	ja     800c10 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800c08:	0f be d2             	movsbl %dl,%edx
  800c0b:	83 ea 37             	sub    $0x37,%edx
  800c0e:	eb d0                	jmp    800be0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xc2>
		*endptr = (char *) s;
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1b:	85 ff                	test   %edi,%edi
  800c1d:	74 02                	je     800c21 <strtol+0xc8>
  800c1f:	f7 d8                	neg    %eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
	...

00800c28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	89 c3                	mov    %eax,%ebx
  800c3b:	89 c7                	mov    %eax,%edi
  800c3d:	89 c6                	mov    %eax,%esi
  800c3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c51:	b8 01 00 00 00       	mov    $0x1,%eax
  800c56:	89 d1                	mov    %edx,%ecx
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	89 d7                	mov    %edx,%edi
  800c5c:	89 d6                	mov    %edx,%esi
  800c5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7b:	89 cb                	mov    %ecx,%ebx
  800c7d:	89 cf                	mov    %ecx,%edi
  800c7f:	89 ce                	mov    %ecx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7f 08                	jg     800c8f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 03                	push   $0x3
  800c95:	68 a4 13 80 00       	push   $0x8013a4
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 c1 13 80 00       	push   $0x8013c1
  800ca1:	e8 96 f5 ff ff       	call   80023c <_panic>

00800ca6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_yield>:

void
sys_yield(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	be 00 00 00 00       	mov    $0x0,%esi
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	89 f7                	mov    %esi,%edi
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 04                	push   $0x4
  800d16:	68 a4 13 80 00       	push   $0x8013a4
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 c1 13 80 00       	push   $0x8013c1
  800d22:	e8 15 f5 ff ff       	call   80023c <_panic>

00800d27 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d41:	8b 75 18             	mov    0x18(%ebp),%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 05                	push   $0x5
  800d58:	68 a4 13 80 00       	push   $0x8013a4
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 c1 13 80 00       	push   $0x8013c1
  800d64:	e8 d3 f4 ff ff       	call   80023c <_panic>

00800d69 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7f 08                	jg     800d94 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 06                	push   $0x6
  800d9a:	68 a4 13 80 00       	push   $0x8013a4
  800d9f:	6a 23                	push   $0x23
  800da1:	68 c1 13 80 00       	push   $0x8013c1
  800da6:	e8 91 f4 ff ff       	call   80023c <_panic>

00800dab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7f 08                	jg     800dd6 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	50                   	push   %eax
  800dda:	6a 08                	push   $0x8
  800ddc:	68 a4 13 80 00       	push   $0x8013a4
  800de1:	6a 23                	push   $0x23
  800de3:	68 c1 13 80 00       	push   $0x8013c1
  800de8:	e8 4f f4 ff ff       	call   80023c <_panic>

00800ded <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	b8 09 00 00 00       	mov    $0x9,%eax
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7f 08                	jg     800e18 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 09                	push   $0x9
  800e1e:	68 a4 13 80 00       	push   $0x8013a4
  800e23:	6a 23                	push   $0x23
  800e25:	68 c1 13 80 00       	push   $0x8013c1
  800e2a:	e8 0d f4 ff ff       	call   80023c <_panic>

00800e2f <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e40:	be 00 00 00 00       	mov    $0x0,%esi
  800e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e48:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e68:	89 cb                	mov    %ecx,%ebx
  800e6a:	89 cf                	mov    %ecx,%edi
  800e6c:	89 ce                	mov    %ecx,%esi
  800e6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7f 08                	jg     800e7c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	50                   	push   %eax
  800e80:	6a 0c                	push   $0xc
  800e82:	68 a4 13 80 00       	push   $0x8013a4
  800e87:	6a 23                	push   $0x23
  800e89:	68 c1 13 80 00       	push   $0x8013c1
  800e8e:	e8 a9 f3 ff ff       	call   80023c <_panic>
	...

00800e94 <__udivdi3>:
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 1c             	sub    $0x1c,%esp
  800e9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eab:	85 d2                	test   %edx,%edx
  800ead:	75 2d                	jne    800edc <__udivdi3+0x48>
  800eaf:	39 f7                	cmp    %esi,%edi
  800eb1:	77 59                	ja     800f0c <__udivdi3+0x78>
  800eb3:	89 f9                	mov    %edi,%ecx
  800eb5:	85 ff                	test   %edi,%edi
  800eb7:	75 0b                	jne    800ec4 <__udivdi3+0x30>
  800eb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebe:	31 d2                	xor    %edx,%edx
  800ec0:	f7 f7                	div    %edi
  800ec2:	89 c1                	mov    %eax,%ecx
  800ec4:	31 d2                	xor    %edx,%edx
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	f7 f1                	div    %ecx
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 e8                	mov    %ebp,%eax
  800ece:	f7 f1                	div    %ecx
  800ed0:	89 da                	mov    %ebx,%edx
  800ed2:	83 c4 1c             	add    $0x1c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	39 f2                	cmp    %esi,%edx
  800ede:	77 1c                	ja     800efc <__udivdi3+0x68>
  800ee0:	0f bd da             	bsr    %edx,%ebx
  800ee3:	83 f3 1f             	xor    $0x1f,%ebx
  800ee6:	75 38                	jne    800f20 <__udivdi3+0x8c>
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 08                	jb     800ef4 <__udivdi3+0x60>
  800eec:	39 ef                	cmp    %ebp,%edi
  800eee:	0f 87 98 00 00 00    	ja     800f8c <__udivdi3+0xf8>
  800ef4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef9:	eb 05                	jmp    800f00 <__udivdi3+0x6c>
  800efb:	90                   	nop
  800efc:	31 db                	xor    %ebx,%ebx
  800efe:	31 c0                	xor    %eax,%eax
  800f00:	89 da                	mov    %ebx,%edx
  800f02:	83 c4 1c             	add    $0x1c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	89 e8                	mov    %ebp,%eax
  800f0e:	89 f2                	mov    %esi,%edx
  800f10:	f7 f7                	div    %edi
  800f12:	31 db                	xor    %ebx,%ebx
  800f14:	89 da                	mov    %ebx,%edx
  800f16:	83 c4 1c             	add    $0x1c,%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    
  800f1e:	66 90                	xchg   %ax,%ax
  800f20:	b8 20 00 00 00       	mov    $0x20,%eax
  800f25:	29 d8                	sub    %ebx,%eax
  800f27:	88 d9                	mov    %bl,%cl
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f2f:	89 fa                	mov    %edi,%edx
  800f31:	88 c1                	mov    %al,%cl
  800f33:	d3 ea                	shr    %cl,%edx
  800f35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f39:	09 d1                	or     %edx,%ecx
  800f3b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f3f:	88 d9                	mov    %bl,%cl
  800f41:	d3 e7                	shl    %cl,%edi
  800f43:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f47:	89 f7                	mov    %esi,%edi
  800f49:	88 c1                	mov    %al,%cl
  800f4b:	d3 ef                	shr    %cl,%edi
  800f4d:	88 d9                	mov    %bl,%cl
  800f4f:	d3 e6                	shl    %cl,%esi
  800f51:	89 ea                	mov    %ebp,%edx
  800f53:	88 c1                	mov    %al,%cl
  800f55:	d3 ea                	shr    %cl,%edx
  800f57:	09 d6                	or     %edx,%esi
  800f59:	89 f0                	mov    %esi,%eax
  800f5b:	89 fa                	mov    %edi,%edx
  800f5d:	f7 74 24 08          	divl   0x8(%esp)
  800f61:	89 d7                	mov    %edx,%edi
  800f63:	89 c6                	mov    %eax,%esi
  800f65:	f7 64 24 0c          	mull   0xc(%esp)
  800f69:	39 d7                	cmp    %edx,%edi
  800f6b:	72 13                	jb     800f80 <__udivdi3+0xec>
  800f6d:	74 09                	je     800f78 <__udivdi3+0xe4>
  800f6f:	89 f0                	mov    %esi,%eax
  800f71:	31 db                	xor    %ebx,%ebx
  800f73:	eb 8b                	jmp    800f00 <__udivdi3+0x6c>
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	88 d9                	mov    %bl,%cl
  800f7a:	d3 e5                	shl    %cl,%ebp
  800f7c:	39 c5                	cmp    %eax,%ebp
  800f7e:	73 ef                	jae    800f6f <__udivdi3+0xdb>
  800f80:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f83:	31 db                	xor    %ebx,%ebx
  800f85:	e9 76 ff ff ff       	jmp    800f00 <__udivdi3+0x6c>
  800f8a:	66 90                	xchg   %ax,%ax
  800f8c:	31 c0                	xor    %eax,%eax
  800f8e:	e9 6d ff ff ff       	jmp    800f00 <__udivdi3+0x6c>
	...

00800f94 <__umoddi3>:
  800f94:	55                   	push   %ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 1c             	sub    $0x1c,%esp
  800f9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fa7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	89 da                	mov    %ebx,%edx
  800faf:	85 ed                	test   %ebp,%ebp
  800fb1:	75 15                	jne    800fc8 <__umoddi3+0x34>
  800fb3:	39 df                	cmp    %ebx,%edi
  800fb5:	76 39                	jbe    800ff0 <__umoddi3+0x5c>
  800fb7:	f7 f7                	div    %edi
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 1c             	add    $0x1c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	39 dd                	cmp    %ebx,%ebp
  800fca:	77 f1                	ja     800fbd <__umoddi3+0x29>
  800fcc:	0f bd cd             	bsr    %ebp,%ecx
  800fcf:	83 f1 1f             	xor    $0x1f,%ecx
  800fd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fd6:	75 38                	jne    801010 <__umoddi3+0x7c>
  800fd8:	39 dd                	cmp    %ebx,%ebp
  800fda:	72 04                	jb     800fe0 <__umoddi3+0x4c>
  800fdc:	39 f7                	cmp    %esi,%edi
  800fde:	77 dd                	ja     800fbd <__umoddi3+0x29>
  800fe0:	89 da                	mov    %ebx,%edx
  800fe2:	89 f0                	mov    %esi,%eax
  800fe4:	29 f8                	sub    %edi,%eax
  800fe6:	19 ea                	sbb    %ebp,%edx
  800fe8:	83 c4 1c             	add    $0x1c,%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    
  800ff0:	89 f9                	mov    %edi,%ecx
  800ff2:	85 ff                	test   %edi,%edi
  800ff4:	75 0b                	jne    801001 <__umoddi3+0x6d>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f7                	div    %edi
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 d8                	mov    %ebx,%eax
  801003:	31 d2                	xor    %edx,%edx
  801005:	f7 f1                	div    %ecx
  801007:	89 f0                	mov    %esi,%eax
  801009:	f7 f1                	div    %ecx
  80100b:	eb ac                	jmp    800fb9 <__umoddi3+0x25>
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	b8 20 00 00 00       	mov    $0x20,%eax
  801015:	89 c2                	mov    %eax,%edx
  801017:	8b 44 24 04          	mov    0x4(%esp),%eax
  80101b:	29 c2                	sub    %eax,%edx
  80101d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801021:	88 c1                	mov    %al,%cl
  801023:	d3 e5                	shl    %cl,%ebp
  801025:	89 f8                	mov    %edi,%eax
  801027:	88 d1                	mov    %dl,%cl
  801029:	d3 e8                	shr    %cl,%eax
  80102b:	09 c5                	or     %eax,%ebp
  80102d:	8b 44 24 04          	mov    0x4(%esp),%eax
  801031:	88 c1                	mov    %al,%cl
  801033:	d3 e7                	shl    %cl,%edi
  801035:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801039:	89 df                	mov    %ebx,%edi
  80103b:	88 d1                	mov    %dl,%cl
  80103d:	d3 ef                	shr    %cl,%edi
  80103f:	88 c1                	mov    %al,%cl
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f0                	mov    %esi,%eax
  801045:	88 d1                	mov    %dl,%cl
  801047:	d3 e8                	shr    %cl,%eax
  801049:	09 d8                	or     %ebx,%eax
  80104b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80104f:	d3 e6                	shl    %cl,%esi
  801051:	89 fa                	mov    %edi,%edx
  801053:	f7 f5                	div    %ebp
  801055:	89 d1                	mov    %edx,%ecx
  801057:	f7 64 24 08          	mull   0x8(%esp)
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	89 d7                	mov    %edx,%edi
  80105f:	39 d1                	cmp    %edx,%ecx
  801061:	72 29                	jb     80108c <__umoddi3+0xf8>
  801063:	74 23                	je     801088 <__umoddi3+0xf4>
  801065:	89 ca                	mov    %ecx,%edx
  801067:	29 de                	sub    %ebx,%esi
  801069:	19 fa                	sbb    %edi,%edx
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801071:	d3 e0                	shl    %cl,%eax
  801073:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801077:	88 d9                	mov    %bl,%cl
  801079:	d3 ee                	shr    %cl,%esi
  80107b:	09 f0                	or     %esi,%eax
  80107d:	d3 ea                	shr    %cl,%edx
  80107f:	83 c4 1c             	add    $0x1c,%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	39 c6                	cmp    %eax,%esi
  80108a:	73 d9                	jae    801065 <__umoddi3+0xd1>
  80108c:	2b 44 24 08          	sub    0x8(%esp),%eax
  801090:	19 ea                	sbb    %ebp,%edx
  801092:	89 d7                	mov    %edx,%edi
  801094:	89 c3                	mov    %eax,%ebx
  801096:	eb cd                	jmp    801065 <__umoddi3+0xd1>
