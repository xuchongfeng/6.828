
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	68 24 03 80 00       	push   $0x800324
  80003f:	6a 00                	push   $0x0
  800041:	e8 37 02 00 00       	call   80027d <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800046:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004d:	00 00 00 
}
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	c9                   	leave  
  800054:	c3                   	ret    
  800055:	00 00                	add    %al,(%eax)
	...

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	56                   	push   %esi
  80005c:	53                   	push   %ebx
  80005d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800060:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800063:	e8 ce 00 00 00       	call   800136 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	89 c2                	mov    %eax,%edx
  80006f:	c1 e2 05             	shl    $0x5,%edx
  800072:	29 c2                	sub    %eax,%edx
  800074:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x33>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 44 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	b8 03 00 00 00       	mov    $0x3,%eax
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7f 08                	jg     80011f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	50                   	push   %eax
  800123:	6a 03                	push   $0x3
  800125:	68 6a 0f 80 00       	push   $0x800f6a
  80012a:	6a 23                	push   $0x23
  80012c:	68 87 0f 80 00       	push   $0x800f87
  800131:	e8 fa 01 00 00       	call   800330 <_panic>

00800136 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_yield>:

void
sys_yield(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 0a 00 00 00       	mov    $0xa,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017d:	be 00 00 00 00       	mov    $0x0,%esi
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
  800185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800188:	b8 04 00 00 00       	mov    $0x4,%eax
  80018d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800190:	89 f7                	mov    %esi,%edi
  800192:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800194:	85 c0                	test   %eax,%eax
  800196:	7f 08                	jg     8001a0 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	50                   	push   %eax
  8001a4:	6a 04                	push   $0x4
  8001a6:	68 6a 0f 80 00       	push   $0x800f6a
  8001ab:	6a 23                	push   $0x23
  8001ad:	68 87 0f 80 00       	push   $0x800f87
  8001b2:	e8 79 01 00 00       	call   800330 <_panic>

008001b7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7f 08                	jg     8001e2 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5e                   	pop    %esi
  8001df:	5f                   	pop    %edi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	50                   	push   %eax
  8001e6:	6a 05                	push   $0x5
  8001e8:	68 6a 0f 80 00       	push   $0x800f6a
  8001ed:	6a 23                	push   $0x23
  8001ef:	68 87 0f 80 00       	push   $0x800f87
  8001f4:	e8 37 01 00 00       	call   800330 <_panic>

008001f9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800202:	bb 00 00 00 00       	mov    $0x0,%ebx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	89 df                	mov    %ebx,%edi
  800214:	89 de                	mov    %ebx,%esi
  800216:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800218:	85 c0                	test   %eax,%eax
  80021a:	7f 08                	jg     800224 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800224:	83 ec 0c             	sub    $0xc,%esp
  800227:	50                   	push   %eax
  800228:	6a 06                	push   $0x6
  80022a:	68 6a 0f 80 00       	push   $0x800f6a
  80022f:	6a 23                	push   $0x23
  800231:	68 87 0f 80 00       	push   $0x800f87
  800236:	e8 f5 00 00 00       	call   800330 <_panic>

0080023b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	b8 08 00 00 00       	mov    $0x8,%eax
  800254:	89 df                	mov    %ebx,%edi
  800256:	89 de                	mov    %ebx,%esi
  800258:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025a:	85 c0                	test   %eax,%eax
  80025c:	7f 08                	jg     800266 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	50                   	push   %eax
  80026a:	6a 08                	push   $0x8
  80026c:	68 6a 0f 80 00       	push   $0x800f6a
  800271:	6a 23                	push   $0x23
  800273:	68 87 0f 80 00       	push   $0x800f87
  800278:	e8 b3 00 00 00       	call   800330 <_panic>

0080027d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	b8 09 00 00 00       	mov    $0x9,%eax
  800296:	89 df                	mov    %ebx,%edi
  800298:	89 de                	mov    %ebx,%esi
  80029a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029c:	85 c0                	test   %eax,%eax
  80029e:	7f 08                	jg     8002a8 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a3:	5b                   	pop    %ebx
  8002a4:	5e                   	pop    %esi
  8002a5:	5f                   	pop    %edi
  8002a6:	5d                   	pop    %ebp
  8002a7:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	50                   	push   %eax
  8002ac:	6a 09                	push   $0x9
  8002ae:	68 6a 0f 80 00       	push   $0x800f6a
  8002b3:	6a 23                	push   $0x23
  8002b5:	68 87 0f 80 00       	push   $0x800f87
  8002ba:	e8 71 00 00 00       	call   800330 <_panic>

008002bf <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d0:	be 00 00 00 00       	mov    $0x0,%esi
  8002d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002db:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f8:	89 cb                	mov    %ecx,%ebx
  8002fa:	89 cf                	mov    %ecx,%edi
  8002fc:	89 ce                	mov    %ecx,%esi
  8002fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800300:	85 c0                	test   %eax,%eax
  800302:	7f 08                	jg     80030c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800307:	5b                   	pop    %ebx
  800308:	5e                   	pop    %esi
  800309:	5f                   	pop    %edi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	50                   	push   %eax
  800310:	6a 0c                	push   $0xc
  800312:	68 6a 0f 80 00       	push   $0x800f6a
  800317:	6a 23                	push   $0x23
  800319:	68 87 0f 80 00       	push   $0x800f87
  80031e:	e8 0d 00 00 00       	call   800330 <_panic>
	...

00800324 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800324:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800325:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80032a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80032c:	83 c4 04             	add    $0x4,%esp
	...

00800330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800338:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80033e:	e8 f3 fd ff ff       	call   800136 <sys_getenvid>
  800343:	83 ec 0c             	sub    $0xc,%esp
  800346:	ff 75 0c             	pushl  0xc(%ebp)
  800349:	ff 75 08             	pushl  0x8(%ebp)
  80034c:	56                   	push   %esi
  80034d:	50                   	push   %eax
  80034e:	68 98 0f 80 00       	push   $0x800f98
  800353:	e8 b4 00 00 00       	call   80040c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800358:	83 c4 18             	add    $0x18,%esp
  80035b:	53                   	push   %ebx
  80035c:	ff 75 10             	pushl  0x10(%ebp)
  80035f:	e8 57 00 00 00       	call   8003bb <vcprintf>
	cprintf("\n");
  800364:	c7 04 24 bb 0f 80 00 	movl   $0x800fbb,(%esp)
  80036b:	e8 9c 00 00 00       	call   80040c <cprintf>
  800370:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800373:	cc                   	int3   
  800374:	eb fd                	jmp    800373 <_panic+0x43>
	...

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	74 08                	je     80039f <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800397:	ff 43 04             	incl   0x4(%ebx)
}
  80039a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	68 ff 00 00 00       	push   $0xff
  8003a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003aa:	50                   	push   %eax
  8003ab:	e8 08 fd ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8003b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	eb dc                	jmp    800397 <putch+0x1f>

008003bb <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cb:	00 00 00 
	b.cnt = 0;
  8003ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e4:	50                   	push   %eax
  8003e5:	68 78 03 80 00       	push   $0x800378
  8003ea:	e8 17 01 00 00       	call   800506 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ef:	83 c4 08             	add    $0x8,%esp
  8003f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003fe:	50                   	push   %eax
  8003ff:	e8 b4 fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800404:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800412:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800415:	50                   	push   %eax
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 9d ff ff ff       	call   8003bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 1c             	sub    $0x1c,%esp
  800429:	89 c7                	mov    %eax,%edi
  80042b:	89 d6                	mov    %edx,%esi
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800436:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800439:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800441:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800444:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800447:	39 d3                	cmp    %edx,%ebx
  800449:	72 05                	jb     800450 <printnum+0x30>
  80044b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80044e:	77 78                	ja     8004c8 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800450:	83 ec 0c             	sub    $0xc,%esp
  800453:	ff 75 18             	pushl  0x18(%ebp)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045c:	53                   	push   %ebx
  80045d:	ff 75 10             	pushl  0x10(%ebp)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 e4             	pushl  -0x1c(%ebp)
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff 75 dc             	pushl  -0x24(%ebp)
  80046c:	ff 75 d8             	pushl  -0x28(%ebp)
  80046f:	e8 d8 08 00 00       	call   800d4c <__udivdi3>
  800474:	83 c4 18             	add    $0x18,%esp
  800477:	52                   	push   %edx
  800478:	50                   	push   %eax
  800479:	89 f2                	mov    %esi,%edx
  80047b:	89 f8                	mov    %edi,%eax
  80047d:	e8 9e ff ff ff       	call   800420 <printnum>
  800482:	83 c4 20             	add    $0x20,%esp
  800485:	eb 11                	jmp    800498 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	56                   	push   %esi
  80048b:	ff 75 18             	pushl  0x18(%ebp)
  80048e:	ff d7                	call   *%edi
  800490:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800493:	4b                   	dec    %ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7f ef                	jg     800487 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	56                   	push   %esi
  80049c:	83 ec 04             	sub    $0x4,%esp
  80049f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ab:	e8 9c 09 00 00       	call   800e4c <__umoddi3>
  8004b0:	83 c4 14             	add    $0x14,%esp
  8004b3:	0f be 80 bd 0f 80 00 	movsbl 0x800fbd(%eax),%eax
  8004ba:	50                   	push   %eax
  8004bb:	ff d7                	call   *%edi
}
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c3:	5b                   	pop    %ebx
  8004c4:	5e                   	pop    %esi
  8004c5:	5f                   	pop    %edi
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    
  8004c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004cb:	eb c6                	jmp    800493 <printnum+0x73>

008004cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004db:	73 0a                	jae    8004e7 <sprintputch+0x1a>
		*b->buf++ = ch;
  8004dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e0:	89 08                	mov    %ecx,(%eax)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	88 02                	mov    %al,(%edx)
}
  8004e7:	5d                   	pop    %ebp
  8004e8:	c3                   	ret    

008004e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f2:	50                   	push   %eax
  8004f3:	ff 75 10             	pushl  0x10(%ebp)
  8004f6:	ff 75 0c             	pushl  0xc(%ebp)
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 05 00 00 00       	call   800506 <vprintfmt>
	va_end(ap);
}
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	c9                   	leave  
  800505:	c3                   	ret    

00800506 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	53                   	push   %ebx
  80050c:	83 ec 2c             	sub    $0x2c,%esp
  80050f:	8b 75 08             	mov    0x8(%ebp),%esi
  800512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800515:	8b 7d 10             	mov    0x10(%ebp),%edi
  800518:	e9 ac 03 00 00       	jmp    8008c9 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80051d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800521:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800528:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80052f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800536:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8d 47 01             	lea    0x1(%edi),%eax
  80053e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800541:	8a 17                	mov    (%edi),%dl
  800543:	8d 42 dd             	lea    -0x23(%edx),%eax
  800546:	3c 55                	cmp    $0x55,%al
  800548:	0f 87 fc 03 00 00    	ja     80094a <vprintfmt+0x444>
  80054e:	0f b6 c0             	movzbl %al,%eax
  800551:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80055f:	eb da                	jmp    80053b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800564:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800568:	eb d1                	jmp    80053b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	0f b6 d2             	movzbl %dl,%edx
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800578:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057b:	01 c0                	add    %eax,%eax
  80057d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800581:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800584:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800587:	83 f9 09             	cmp    $0x9,%ecx
  80058a:	77 52                	ja     8005de <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80058d:	eb e9                	jmp    800578 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a7:	79 92                	jns    80053b <vprintfmt+0x35>
				width = precision, precision = -1;
  8005a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b6:	eb 83                	jmp    80053b <vprintfmt+0x35>
  8005b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bc:	78 08                	js     8005c6 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 75 ff ff ff       	jmp    80053b <vprintfmt+0x35>
  8005c6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005cd:	eb ef                	jmp    8005be <vprintfmt+0xb8>
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d9:	e9 5d ff ff ff       	jmp    80053b <vprintfmt+0x35>
  8005de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e4:	eb bd                	jmp    8005a3 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ea:	e9 4c ff ff ff       	jmp    80053b <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 78 04             	lea    0x4(%eax),%edi
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	ff 30                	pushl  (%eax)
  8005fb:	ff d6                	call   *%esi
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800600:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800603:	e9 be 02 00 00       	jmp    8008c6 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 78 04             	lea    0x4(%eax),%edi
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	85 c0                	test   %eax,%eax
  800612:	78 2a                	js     80063e <vprintfmt+0x138>
  800614:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800616:	83 f8 08             	cmp    $0x8,%eax
  800619:	7f 27                	jg     800642 <vprintfmt+0x13c>
  80061b:	8b 04 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%eax
  800622:	85 c0                	test   %eax,%eax
  800624:	74 1c                	je     800642 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800626:	50                   	push   %eax
  800627:	68 de 0f 80 00       	push   $0x800fde
  80062c:	53                   	push   %ebx
  80062d:	56                   	push   %esi
  80062e:	e8 b6 fe ff ff       	call   8004e9 <printfmt>
  800633:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800636:	89 7d 14             	mov    %edi,0x14(%ebp)
  800639:	e9 88 02 00 00       	jmp    8008c6 <vprintfmt+0x3c0>
  80063e:	f7 d8                	neg    %eax
  800640:	eb d2                	jmp    800614 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800642:	52                   	push   %edx
  800643:	68 d5 0f 80 00       	push   $0x800fd5
  800648:	53                   	push   %ebx
  800649:	56                   	push   %esi
  80064a:	e8 9a fe ff ff       	call   8004e9 <printfmt>
  80064f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800652:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800655:	e9 6c 02 00 00       	jmp    8008c6 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	83 c0 04             	add    $0x4,%eax
  800660:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 38                	mov    (%eax),%edi
  800668:	85 ff                	test   %edi,%edi
  80066a:	74 18                	je     800684 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  80066c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800670:	0f 8e b7 00 00 00    	jle    80072d <vprintfmt+0x227>
  800676:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80067a:	75 0f                	jne    80068b <vprintfmt+0x185>
  80067c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800682:	eb 75                	jmp    8006f9 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800684:	bf ce 0f 80 00       	mov    $0x800fce,%edi
  800689:	eb e1                	jmp    80066c <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	ff 75 d0             	pushl  -0x30(%ebp)
  800691:	57                   	push   %edi
  800692:	e8 5f 03 00 00       	call   8009f6 <strnlen>
  800697:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069a:	29 c1                	sub    %eax,%ecx
  80069c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80069f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ac:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ae:	eb 0d                	jmp    8006bd <vprintfmt+0x1b7>
					putch(padc, putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	4f                   	dec    %edi
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	7f ef                	jg     8006b0 <vprintfmt+0x1aa>
  8006c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006c7:	89 c8                	mov    %ecx,%eax
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	78 10                	js     8006dd <vprintfmt+0x1d7>
  8006cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d0:	29 c1                	sub    %eax,%ecx
  8006d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006db:	eb 1c                	jmp    8006f9 <vprintfmt+0x1f3>
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e2:	eb e9                	jmp    8006cd <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e8:	75 29                	jne    800713 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	ff 75 0c             	pushl  0xc(%ebp)
  8006f0:	50                   	push   %eax
  8006f1:	ff d6                	call   *%esi
  8006f3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f6:	ff 4d e0             	decl   -0x20(%ebp)
  8006f9:	47                   	inc    %edi
  8006fa:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006fd:	0f be c2             	movsbl %dl,%eax
  800700:	85 c0                	test   %eax,%eax
  800702:	74 4c                	je     800750 <vprintfmt+0x24a>
  800704:	85 db                	test   %ebx,%ebx
  800706:	78 dc                	js     8006e4 <vprintfmt+0x1de>
  800708:	4b                   	dec    %ebx
  800709:	79 d9                	jns    8006e4 <vprintfmt+0x1de>
  80070b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800711:	eb 2e                	jmp    800741 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800713:	0f be d2             	movsbl %dl,%edx
  800716:	83 ea 20             	sub    $0x20,%edx
  800719:	83 fa 5e             	cmp    $0x5e,%edx
  80071c:	76 cc                	jbe    8006ea <vprintfmt+0x1e4>
					putch('?', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 0c             	pushl  0xc(%ebp)
  800724:	6a 3f                	push   $0x3f
  800726:	ff d6                	call   *%esi
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb c9                	jmp    8006f6 <vprintfmt+0x1f0>
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800733:	eb c4                	jmp    8006f9 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	6a 20                	push   $0x20
  80073b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073d:	4f                   	dec    %edi
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	85 ff                	test   %edi,%edi
  800743:	7f f0                	jg     800735 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800745:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
  80074b:	e9 76 01 00 00       	jmp    8008c6 <vprintfmt+0x3c0>
  800750:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800756:	eb e9                	jmp    800741 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800758:	83 f9 01             	cmp    $0x1,%ecx
  80075b:	7e 3f                	jle    80079c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 50 04             	mov    0x4(%eax),%edx
  800763:	8b 00                	mov    (%eax),%eax
  800765:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800768:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 40 08             	lea    0x8(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800774:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800778:	79 5c                	jns    8007d6 <vprintfmt+0x2d0>
				putch('-', putdat);
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	53                   	push   %ebx
  80077e:	6a 2d                	push   $0x2d
  800780:	ff d6                	call   *%esi
				num = -(long long) num;
  800782:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800785:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800788:	f7 da                	neg    %edx
  80078a:	83 d1 00             	adc    $0x0,%ecx
  80078d:	f7 d9                	neg    %ecx
  80078f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800792:	b8 0a 00 00 00       	mov    $0xa,%eax
  800797:	e9 10 01 00 00       	jmp    8008ac <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	75 1b                	jne    8007bb <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb b9                	jmp    800774 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d4:	eb 9e                	jmp    800774 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 c6 00 00 00       	jmp    8008ac <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e6:	83 f9 01             	cmp    $0x1,%ecx
  8007e9:	7e 18                	jle    800803 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8b 10                	mov    (%eax),%edx
  8007f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f3:	8d 40 08             	lea    0x8(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fe:	e9 a9 00 00 00       	jmp    8008ac <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	75 1a                	jne    800821 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081c:	e9 8b 00 00 00       	jmp    8008ac <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
  800836:	eb 74                	jmp    8008ac <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800838:	83 f9 01             	cmp    $0x1,%ecx
  80083b:	7e 15                	jle    800852 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 10                	mov    (%eax),%edx
  800842:	8b 48 04             	mov    0x4(%eax),%ecx
  800845:	8d 40 08             	lea    0x8(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80084b:	b8 08 00 00 00       	mov    $0x8,%eax
  800850:	eb 5a                	jmp    8008ac <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800852:	85 c9                	test   %ecx,%ecx
  800854:	75 17                	jne    80086d <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8b 10                	mov    (%eax),%edx
  80085b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800860:	8d 40 04             	lea    0x4(%eax),%eax
  800863:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800866:	b8 08 00 00 00       	mov    $0x8,%eax
  80086b:	eb 3f                	jmp    8008ac <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80087d:	b8 08 00 00 00       	mov    $0x8,%eax
  800882:	eb 28                	jmp    8008ac <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 30                	push   $0x30
  80088a:	ff d6                	call   *%esi
			putch('x', putdat);
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 78                	push   $0x78
  800892:	ff d6                	call   *%esi
			num = (unsigned long long)
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a1:	8d 40 04             	lea    0x4(%eax),%eax
  8008a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a7:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b3:	57                   	push   %edi
  8008b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b7:	50                   	push   %eax
  8008b8:	51                   	push   %ecx
  8008b9:	52                   	push   %edx
  8008ba:	89 da                	mov    %ebx,%edx
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	e8 5d fb ff ff       	call   800420 <printnum>
			break;
  8008c3:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c9:	47                   	inc    %edi
  8008ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ce:	83 f8 25             	cmp    $0x25,%eax
  8008d1:	0f 84 46 fc ff ff    	je     80051d <vprintfmt+0x17>
			if (ch == '\0')
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	0f 84 89 00 00 00    	je     800968 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	50                   	push   %eax
  8008e4:	ff d6                	call   *%esi
  8008e6:	83 c4 10             	add    $0x10,%esp
  8008e9:	eb de                	jmp    8008c9 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008eb:	83 f9 01             	cmp    $0x1,%ecx
  8008ee:	7e 15                	jle    800905 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	8b 10                	mov    (%eax),%edx
  8008f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f8:	8d 40 08             	lea    0x8(%eax),%eax
  8008fb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800903:	eb a7                	jmp    8008ac <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	75 17                	jne    800920 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8b 10                	mov    (%eax),%edx
  80090e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800913:	8d 40 04             	lea    0x4(%eax),%eax
  800916:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800919:	b8 10 00 00 00       	mov    $0x10,%eax
  80091e:	eb 8c                	jmp    8008ac <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8b 10                	mov    (%eax),%edx
  800925:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092a:	8d 40 04             	lea    0x4(%eax),%eax
  80092d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800930:	b8 10 00 00 00       	mov    $0x10,%eax
  800935:	e9 72 ff ff ff       	jmp    8008ac <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	6a 25                	push   $0x25
  800940:	ff d6                	call   *%esi
			break;
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	e9 7c ff ff ff       	jmp    8008c6 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094a:	83 ec 08             	sub    $0x8,%esp
  80094d:	53                   	push   %ebx
  80094e:	6a 25                	push   $0x25
  800950:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	89 f8                	mov    %edi,%eax
  800957:	eb 01                	jmp    80095a <vprintfmt+0x454>
  800959:	48                   	dec    %eax
  80095a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095e:	75 f9                	jne    800959 <vprintfmt+0x453>
  800960:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800963:	e9 5e ff ff ff       	jmp    8008c6 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800968:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 18             	sub    $0x18,%esp
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800983:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098d:	85 c0                	test   %eax,%eax
  80098f:	74 26                	je     8009b7 <vsnprintf+0x47>
  800991:	85 d2                	test   %edx,%edx
  800993:	7e 29                	jle    8009be <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800995:	ff 75 14             	pushl  0x14(%ebp)
  800998:	ff 75 10             	pushl  0x10(%ebp)
  80099b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099e:	50                   	push   %eax
  80099f:	68 cd 04 80 00       	push   $0x8004cd
  8009a4:	e8 5d fb ff ff       	call   800506 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b2:	83 c4 10             	add    $0x10,%esp
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009bc:	eb f7                	jmp    8009b5 <vsnprintf+0x45>
  8009be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c3:	eb f0                	jmp    8009b5 <vsnprintf+0x45>

008009c5 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ce:	50                   	push   %eax
  8009cf:	ff 75 10             	pushl  0x10(%ebp)
  8009d2:	ff 75 0c             	pushl  0xc(%ebp)
  8009d5:	ff 75 08             	pushl  0x8(%ebp)
  8009d8:	e8 93 ff ff ff       	call   800970 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    
	...

008009e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 01                	jmp    8009ee <strlen+0xe>
		n++;
  8009ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f2:	75 f9                	jne    8009ed <strlen+0xd>
		n++;
	return n;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 01                	jmp    800a07 <strnlen+0x11>
		n++;
  800a06:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a07:	39 d0                	cmp    %edx,%eax
  800a09:	74 06                	je     800a11 <strnlen+0x1b>
  800a0b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a0f:	75 f5                	jne    800a06 <strnlen+0x10>
		n++;
	return n;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	53                   	push   %ebx
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	41                   	inc    %ecx
  800a20:	42                   	inc    %edx
  800a21:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a24:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a27:	84 db                	test   %bl,%bl
  800a29:	75 f4                	jne    800a1f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	53                   	push   %ebx
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a35:	53                   	push   %ebx
  800a36:	e8 a5 ff ff ff       	call   8009e0 <strlen>
  800a3b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	01 d8                	add    %ebx,%eax
  800a43:	50                   	push   %eax
  800a44:	e8 ca ff ff ff       	call   800a13 <strcpy>
	return dst;
}
  800a49:	89 d8                	mov    %ebx,%eax
  800a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 75 08             	mov    0x8(%ebp),%esi
  800a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a60:	89 f2                	mov    %esi,%edx
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 0e                	je     800a74 <strncpy+0x24>
		*dst++ = *src;
  800a66:	42                   	inc    %edx
  800a67:	8a 01                	mov    (%ecx),%al
  800a69:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a6c:	80 39 00             	cmpb   $0x0,(%ecx)
  800a6f:	74 f1                	je     800a62 <strncpy+0x12>
			src++;
  800a71:	41                   	inc    %ecx
  800a72:	eb ee                	jmp    800a62 <strncpy+0x12>
	}
	return ret;
}
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a85:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	74 20                	je     800aac <strlcpy+0x32>
  800a8c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a90:	89 f0                	mov    %esi,%eax
  800a92:	eb 05                	jmp    800a99 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a94:	42                   	inc    %edx
  800a95:	40                   	inc    %eax
  800a96:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a99:	39 d8                	cmp    %ebx,%eax
  800a9b:	74 06                	je     800aa3 <strlcpy+0x29>
  800a9d:	8a 0a                	mov    (%edx),%cl
  800a9f:	84 c9                	test   %cl,%cl
  800aa1:	75 f1                	jne    800a94 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800aa3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa6:	29 f0                	sub    %esi,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    
  800aac:	89 f0                	mov    %esi,%eax
  800aae:	eb f6                	jmp    800aa6 <strlcpy+0x2c>

00800ab0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab9:	eb 02                	jmp    800abd <strcmp+0xd>
		p++, q++;
  800abb:	41                   	inc    %ecx
  800abc:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800abd:	8a 01                	mov    (%ecx),%al
  800abf:	84 c0                	test   %al,%al
  800ac1:	74 04                	je     800ac7 <strcmp+0x17>
  800ac3:	3a 02                	cmp    (%edx),%al
  800ac5:	74 f4                	je     800abb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 c0             	movzbl %al,%eax
  800aca:	0f b6 12             	movzbl (%edx),%edx
  800acd:	29 d0                	sub    %edx,%eax
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	53                   	push   %ebx
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae0:	eb 02                	jmp    800ae4 <strncmp+0x13>
		n--, p++, q++;
  800ae2:	40                   	inc    %eax
  800ae3:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae4:	39 d8                	cmp    %ebx,%eax
  800ae6:	74 15                	je     800afd <strncmp+0x2c>
  800ae8:	8a 08                	mov    (%eax),%cl
  800aea:	84 c9                	test   %cl,%cl
  800aec:	74 04                	je     800af2 <strncmp+0x21>
  800aee:	3a 0a                	cmp    (%edx),%cl
  800af0:	74 f0                	je     800ae2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	0f b6 12             	movzbl (%edx),%edx
  800af8:	29 d0                	sub    %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	eb f6                	jmp    800afa <strncmp+0x29>

00800b04 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b0d:	8a 10                	mov    (%eax),%dl
  800b0f:	84 d2                	test   %dl,%dl
  800b11:	74 07                	je     800b1a <strchr+0x16>
		if (*s == c)
  800b13:	38 ca                	cmp    %cl,%dl
  800b15:	74 08                	je     800b1f <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b17:	40                   	inc    %eax
  800b18:	eb f3                	jmp    800b0d <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2a:	8a 10                	mov    (%eax),%dl
  800b2c:	84 d2                	test   %dl,%dl
  800b2e:	74 07                	je     800b37 <strfind+0x16>
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 03                	je     800b37 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b34:	40                   	inc    %eax
  800b35:	eb f3                	jmp    800b2a <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b45:	85 c9                	test   %ecx,%ecx
  800b47:	74 13                	je     800b5c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4f:	75 05                	jne    800b56 <memset+0x1d>
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	74 0d                	je     800b63 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	fc                   	cld    
  800b5a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5c:	89 f8                	mov    %edi,%eax
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b63:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	c1 e3 08             	shl    $0x8,%ebx
  800b6c:	89 d0                	mov    %edx,%eax
  800b6e:	c1 e0 18             	shl    $0x18,%eax
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	c1 e6 10             	shl    $0x10,%esi
  800b76:	09 f0                	or     %esi,%eax
  800b78:	09 c2                	or     %eax,%edx
  800b7a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b7c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	fc                   	cld    
  800b82:	f3 ab                	rep stos %eax,%es:(%edi)
  800b84:	eb d6                	jmp    800b5c <memset+0x23>

00800b86 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b94:	39 c6                	cmp    %eax,%esi
  800b96:	73 33                	jae    800bcb <memmove+0x45>
  800b98:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9b:	39 c2                	cmp    %eax,%edx
  800b9d:	76 2c                	jbe    800bcb <memmove+0x45>
		s += n;
		d += n;
  800b9f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	09 fe                	or     %edi,%esi
  800ba6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bac:	74 0a                	je     800bb8 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bae:	4f                   	dec    %edi
  800baf:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb2:	fd                   	std    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb5:	fc                   	cld    
  800bb6:	eb 21                	jmp    800bd9 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	f6 c1 03             	test   $0x3,%cl
  800bbb:	75 f1                	jne    800bae <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbd:	83 ef 04             	sub    $0x4,%edi
  800bc0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bc6:	fd                   	std    
  800bc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc9:	eb ea                	jmp    800bb5 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	89 f2                	mov    %esi,%edx
  800bcd:	09 c2                	or     %eax,%edx
  800bcf:	f6 c2 03             	test   $0x3,%dl
  800bd2:	74 09                	je     800bdd <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd4:	89 c7                	mov    %eax,%edi
  800bd6:	fc                   	cld    
  800bd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 f2                	jne    800bd4 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800be5:	89 c7                	mov    %eax,%edi
  800be7:	fc                   	cld    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb ed                	jmp    800bd9 <memmove+0x53>

00800bec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bef:	ff 75 10             	pushl  0x10(%ebp)
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	ff 75 08             	pushl  0x8(%ebp)
  800bf8:	e8 89 ff ff ff       	call   800b86 <memmove>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	89 c6                	mov    %eax,%esi
  800c0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0f:	39 f0                	cmp    %esi,%eax
  800c11:	74 16                	je     800c29 <memcmp+0x2a>
		if (*s1 != *s2)
  800c13:	8a 08                	mov    (%eax),%cl
  800c15:	8a 1a                	mov    (%edx),%bl
  800c17:	38 d9                	cmp    %bl,%cl
  800c19:	75 04                	jne    800c1f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c1b:	40                   	inc    %eax
  800c1c:	42                   	inc    %edx
  800c1d:	eb f0                	jmp    800c0f <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800c1f:	0f b6 c1             	movzbl %cl,%eax
  800c22:	0f b6 db             	movzbl %bl,%ebx
  800c25:	29 d8                	sub    %ebx,%eax
  800c27:	eb 05                	jmp    800c2e <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c40:	39 d0                	cmp    %edx,%eax
  800c42:	73 07                	jae    800c4b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c44:	38 08                	cmp    %cl,(%eax)
  800c46:	74 03                	je     800c4b <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c48:	40                   	inc    %eax
  800c49:	eb f5                	jmp    800c40 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c56:	eb 01                	jmp    800c59 <strtol+0xc>
		s++;
  800c58:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c59:	8a 01                	mov    (%ecx),%al
  800c5b:	3c 20                	cmp    $0x20,%al
  800c5d:	74 f9                	je     800c58 <strtol+0xb>
  800c5f:	3c 09                	cmp    $0x9,%al
  800c61:	74 f5                	je     800c58 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c63:	3c 2b                	cmp    $0x2b,%al
  800c65:	74 2b                	je     800c92 <strtol+0x45>
		s++;
	else if (*s == '-')
  800c67:	3c 2d                	cmp    $0x2d,%al
  800c69:	74 2f                	je     800c9a <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c77:	75 12                	jne    800c8b <strtol+0x3e>
  800c79:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7c:	74 24                	je     800ca2 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c82:	75 07                	jne    800c8b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c84:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	eb 4e                	jmp    800ce0 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c92:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
  800c98:	eb d6                	jmp    800c70 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c9a:	41                   	inc    %ecx
  800c9b:	bf 01 00 00 00       	mov    $0x1,%edi
  800ca0:	eb ce                	jmp    800c70 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca6:	74 10                	je     800cb8 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cac:	75 dd                	jne    800c8b <strtol+0x3e>
		s++, base = 8;
  800cae:	41                   	inc    %ecx
  800caf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cb6:	eb d3                	jmp    800c8b <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800cb8:	83 c1 02             	add    $0x2,%ecx
  800cbb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cc2:	eb c7                	jmp    800c8b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc7:	89 f3                	mov    %esi,%ebx
  800cc9:	80 fb 19             	cmp    $0x19,%bl
  800ccc:	77 24                	ja     800cf2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cce:	0f be d2             	movsbl %dl,%edx
  800cd1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd4:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cd7:	7e 2b                	jle    800d04 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cd9:	41                   	inc    %ecx
  800cda:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cde:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce0:	8a 11                	mov    (%ecx),%dl
  800ce2:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ce5:	80 fb 09             	cmp    $0x9,%bl
  800ce8:	77 da                	ja     800cc4 <strtol+0x77>
			dig = *s - '0';
  800cea:	0f be d2             	movsbl %dl,%edx
  800ced:	83 ea 30             	sub    $0x30,%edx
  800cf0:	eb e2                	jmp    800cd4 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cf2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf5:	89 f3                	mov    %esi,%ebx
  800cf7:	80 fb 19             	cmp    $0x19,%bl
  800cfa:	77 08                	ja     800d04 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800cfc:	0f be d2             	movsbl %dl,%edx
  800cff:	83 ea 37             	sub    $0x37,%edx
  800d02:	eb d0                	jmp    800cd4 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d08:	74 05                	je     800d0f <strtol+0xc2>
		*endptr = (char *) s;
  800d0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d0f:	85 ff                	test   %edi,%edi
  800d11:	74 02                	je     800d15 <strtol+0xc8>
  800d13:	f7 d8                	neg    %eax
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
	...

00800d1c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d22:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d29:	74 0a                	je     800d35 <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d35:	83 ec 04             	sub    $0x4,%esp
  800d38:	68 04 12 80 00       	push   $0x801204
  800d3d:	6a 20                	push   $0x20
  800d3f:	68 28 12 80 00       	push   $0x801228
  800d44:	e8 e7 f5 ff ff       	call   800330 <_panic>
  800d49:	00 00                	add    %al,(%eax)
	...

00800d4c <__udivdi3>:
  800d4c:	55                   	push   %ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 1c             	sub    $0x1c,%esp
  800d53:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d57:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d5b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d5f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 2d                	jne    800d94 <__udivdi3+0x48>
  800d67:	39 f7                	cmp    %esi,%edi
  800d69:	77 59                	ja     800dc4 <__udivdi3+0x78>
  800d6b:	89 f9                	mov    %edi,%ecx
  800d6d:	85 ff                	test   %edi,%edi
  800d6f:	75 0b                	jne    800d7c <__udivdi3+0x30>
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	31 d2                	xor    %edx,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	89 c1                	mov    %eax,%ecx
  800d7c:	31 d2                	xor    %edx,%edx
  800d7e:	89 f0                	mov    %esi,%eax
  800d80:	f7 f1                	div    %ecx
  800d82:	89 c3                	mov    %eax,%ebx
  800d84:	89 e8                	mov    %ebp,%eax
  800d86:	f7 f1                	div    %ecx
  800d88:	89 da                	mov    %ebx,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	66 90                	xchg   %ax,%ax
  800d94:	39 f2                	cmp    %esi,%edx
  800d96:	77 1c                	ja     800db4 <__udivdi3+0x68>
  800d98:	0f bd da             	bsr    %edx,%ebx
  800d9b:	83 f3 1f             	xor    $0x1f,%ebx
  800d9e:	75 38                	jne    800dd8 <__udivdi3+0x8c>
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	72 08                	jb     800dac <__udivdi3+0x60>
  800da4:	39 ef                	cmp    %ebp,%edi
  800da6:	0f 87 98 00 00 00    	ja     800e44 <__udivdi3+0xf8>
  800dac:	b8 01 00 00 00       	mov    $0x1,%eax
  800db1:	eb 05                	jmp    800db8 <__udivdi3+0x6c>
  800db3:	90                   	nop
  800db4:	31 db                	xor    %ebx,%ebx
  800db6:	31 c0                	xor    %eax,%eax
  800db8:	89 da                	mov    %ebx,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	66 90                	xchg   %ax,%ax
  800dc4:	89 e8                	mov    %ebp,%eax
  800dc6:	89 f2                	mov    %esi,%edx
  800dc8:	f7 f7                	div    %edi
  800dca:	31 db                	xor    %ebx,%ebx
  800dcc:	89 da                	mov    %ebx,%edx
  800dce:	83 c4 1c             	add    $0x1c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ddd:	29 d8                	sub    %ebx,%eax
  800ddf:	88 d9                	mov    %bl,%cl
  800de1:	d3 e2                	shl    %cl,%edx
  800de3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800de7:	89 fa                	mov    %edi,%edx
  800de9:	88 c1                	mov    %al,%cl
  800deb:	d3 ea                	shr    %cl,%edx
  800ded:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800df1:	09 d1                	or     %edx,%ecx
  800df3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df7:	88 d9                	mov    %bl,%cl
  800df9:	d3 e7                	shl    %cl,%edi
  800dfb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dff:	89 f7                	mov    %esi,%edi
  800e01:	88 c1                	mov    %al,%cl
  800e03:	d3 ef                	shr    %cl,%edi
  800e05:	88 d9                	mov    %bl,%cl
  800e07:	d3 e6                	shl    %cl,%esi
  800e09:	89 ea                	mov    %ebp,%edx
  800e0b:	88 c1                	mov    %al,%cl
  800e0d:	d3 ea                	shr    %cl,%edx
  800e0f:	09 d6                	or     %edx,%esi
  800e11:	89 f0                	mov    %esi,%eax
  800e13:	89 fa                	mov    %edi,%edx
  800e15:	f7 74 24 08          	divl   0x8(%esp)
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 c6                	mov    %eax,%esi
  800e1d:	f7 64 24 0c          	mull   0xc(%esp)
  800e21:	39 d7                	cmp    %edx,%edi
  800e23:	72 13                	jb     800e38 <__udivdi3+0xec>
  800e25:	74 09                	je     800e30 <__udivdi3+0xe4>
  800e27:	89 f0                	mov    %esi,%eax
  800e29:	31 db                	xor    %ebx,%ebx
  800e2b:	eb 8b                	jmp    800db8 <__udivdi3+0x6c>
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	88 d9                	mov    %bl,%cl
  800e32:	d3 e5                	shl    %cl,%ebp
  800e34:	39 c5                	cmp    %eax,%ebp
  800e36:	73 ef                	jae    800e27 <__udivdi3+0xdb>
  800e38:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e3b:	31 db                	xor    %ebx,%ebx
  800e3d:	e9 76 ff ff ff       	jmp    800db8 <__udivdi3+0x6c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	31 c0                	xor    %eax,%eax
  800e46:	e9 6d ff ff ff       	jmp    800db8 <__udivdi3+0x6c>
	...

00800e4c <__umoddi3>:
  800e4c:	55                   	push   %ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 1c             	sub    $0x1c,%esp
  800e53:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e57:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e5b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e5f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e63:	89 f0                	mov    %esi,%eax
  800e65:	89 da                	mov    %ebx,%edx
  800e67:	85 ed                	test   %ebp,%ebp
  800e69:	75 15                	jne    800e80 <__umoddi3+0x34>
  800e6b:	39 df                	cmp    %ebx,%edi
  800e6d:	76 39                	jbe    800ea8 <__umoddi3+0x5c>
  800e6f:	f7 f7                	div    %edi
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	83 c4 1c             	add    $0x1c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
  800e80:	39 dd                	cmp    %ebx,%ebp
  800e82:	77 f1                	ja     800e75 <__umoddi3+0x29>
  800e84:	0f bd cd             	bsr    %ebp,%ecx
  800e87:	83 f1 1f             	xor    $0x1f,%ecx
  800e8a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e8e:	75 38                	jne    800ec8 <__umoddi3+0x7c>
  800e90:	39 dd                	cmp    %ebx,%ebp
  800e92:	72 04                	jb     800e98 <__umoddi3+0x4c>
  800e94:	39 f7                	cmp    %esi,%edi
  800e96:	77 dd                	ja     800e75 <__umoddi3+0x29>
  800e98:	89 da                	mov    %ebx,%edx
  800e9a:	89 f0                	mov    %esi,%eax
  800e9c:	29 f8                	sub    %edi,%eax
  800e9e:	19 ea                	sbb    %ebp,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	89 f9                	mov    %edi,%ecx
  800eaa:	85 ff                	test   %edi,%edi
  800eac:	75 0b                	jne    800eb9 <__umoddi3+0x6d>
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f7                	div    %edi
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	f7 f1                	div    %ecx
  800ec3:	eb ac                	jmp    800e71 <__umoddi3+0x25>
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed3:	29 c2                	sub    %eax,%edx
  800ed5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed9:	88 c1                	mov    %al,%cl
  800edb:	d3 e5                	shl    %cl,%ebp
  800edd:	89 f8                	mov    %edi,%eax
  800edf:	88 d1                	mov    %dl,%cl
  800ee1:	d3 e8                	shr    %cl,%eax
  800ee3:	09 c5                	or     %eax,%ebp
  800ee5:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee9:	88 c1                	mov    %al,%cl
  800eeb:	d3 e7                	shl    %cl,%edi
  800eed:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef1:	89 df                	mov    %ebx,%edi
  800ef3:	88 d1                	mov    %dl,%cl
  800ef5:	d3 ef                	shr    %cl,%edi
  800ef7:	88 c1                	mov    %al,%cl
  800ef9:	d3 e3                	shl    %cl,%ebx
  800efb:	89 f0                	mov    %esi,%eax
  800efd:	88 d1                	mov    %dl,%cl
  800eff:	d3 e8                	shr    %cl,%eax
  800f01:	09 d8                	or     %ebx,%eax
  800f03:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800f07:	d3 e6                	shl    %cl,%esi
  800f09:	89 fa                	mov    %edi,%edx
  800f0b:	f7 f5                	div    %ebp
  800f0d:	89 d1                	mov    %edx,%ecx
  800f0f:	f7 64 24 08          	mull   0x8(%esp)
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	89 d7                	mov    %edx,%edi
  800f17:	39 d1                	cmp    %edx,%ecx
  800f19:	72 29                	jb     800f44 <__umoddi3+0xf8>
  800f1b:	74 23                	je     800f40 <__umoddi3+0xf4>
  800f1d:	89 ca                	mov    %ecx,%edx
  800f1f:	29 de                	sub    %ebx,%esi
  800f21:	19 fa                	sbb    %edi,%edx
  800f23:	89 d0                	mov    %edx,%eax
  800f25:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800f29:	d3 e0                	shl    %cl,%eax
  800f2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f2f:	88 d9                	mov    %bl,%cl
  800f31:	d3 ee                	shr    %cl,%esi
  800f33:	09 f0                	or     %esi,%eax
  800f35:	d3 ea                	shr    %cl,%edx
  800f37:	83 c4 1c             	add    $0x1c,%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    
  800f3f:	90                   	nop
  800f40:	39 c6                	cmp    %eax,%esi
  800f42:	73 d9                	jae    800f1d <__umoddi3+0xd1>
  800f44:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f48:	19 ea                	sbb    %ebp,%edx
  800f4a:	89 d7                	mov    %edx,%edi
  800f4c:	89 c3                	mov    %eax,%ebx
  800f4e:	eb cd                	jmp    800f1d <__umoddi3+0xd1>
