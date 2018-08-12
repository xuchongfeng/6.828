
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	6a 07                	push   $0x7
  80003c:	68 00 f0 bf ee       	push   $0xeebff000
  800041:	6a 00                	push   $0x0
  800043:	e8 3c 01 00 00       	call   800184 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 ef be ad de       	push   $0xdeadbeef
  800050:	6a 00                	push   $0x0
  800052:	e8 36 02 00 00       	call   80028d <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800057:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005e:	00 00 00 
}
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	c9                   	leave  
  800065:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800073:	e8 ce 00 00 00       	call   800146 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	89 c2                	mov    %eax,%edx
  80007f:	c1 e2 05             	shl    $0x5,%edx
  800082:	29 c2                	sub    %eax,%edx
  800084:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80008b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800090:	85 db                	test   %ebx,%ebx
  800092:	7e 07                	jle    80009b <libmain+0x33>
		binaryname = argv[0];
  800094:	8b 06                	mov    (%esi),%eax
  800096:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009b:	83 ec 08             	sub    $0x8,%esp
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b0:	5b                   	pop    %ebx
  8000b1:	5e                   	pop    %esi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 44 00 00 00       	call   800105 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    
	...

008000c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	89 c3                	mov    %eax,%ebx
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	89 c6                	mov    %eax,%esi
  8000df:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	8b 55 08             	mov    0x8(%ebp),%edx
  800116:	b8 03 00 00 00       	mov    $0x3,%eax
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7f 08                	jg     80012f <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	50                   	push   %eax
  800133:	6a 03                	push   $0x3
  800135:	68 4a 0f 80 00       	push   $0x800f4a
  80013a:	6a 23                	push   $0x23
  80013c:	68 67 0f 80 00       	push   $0x800f67
  800141:	e8 ee 01 00 00       	call   800334 <_panic>

00800146 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_yield>:

void
sys_yield(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 0a 00 00 00       	mov    $0xa,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018d:	be 00 00 00 00       	mov    $0x0,%esi
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a0:	89 f7                	mov    %esi,%edi
  8001a2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 08                	jg     8001b0 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	50                   	push   %eax
  8001b4:	6a 04                	push   $0x4
  8001b6:	68 4a 0f 80 00       	push   $0x800f4a
  8001bb:	6a 23                	push   $0x23
  8001bd:	68 67 0f 80 00       	push   $0x800f67
  8001c2:	e8 6d 01 00 00       	call   800334 <_panic>

008001c7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7f 08                	jg     8001f2 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	50                   	push   %eax
  8001f6:	6a 05                	push   $0x5
  8001f8:	68 4a 0f 80 00       	push   $0x800f4a
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 67 0f 80 00       	push   $0x800f67
  800204:	e8 2b 01 00 00       	call   800334 <_panic>

00800209 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7f 08                	jg     800234 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	50                   	push   %eax
  800238:	6a 06                	push   $0x6
  80023a:	68 4a 0f 80 00       	push   $0x800f4a
  80023f:	6a 23                	push   $0x23
  800241:	68 67 0f 80 00       	push   $0x800f67
  800246:	e8 e9 00 00 00       	call   800334 <_panic>

0080024b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	8b 55 08             	mov    0x8(%ebp),%edx
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	89 df                	mov    %ebx,%edi
  800266:	89 de                	mov    %ebx,%esi
  800268:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026a:	85 c0                	test   %eax,%eax
  80026c:	7f 08                	jg     800276 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	50                   	push   %eax
  80027a:	6a 08                	push   $0x8
  80027c:	68 4a 0f 80 00       	push   $0x800f4a
  800281:	6a 23                	push   $0x23
  800283:	68 67 0f 80 00       	push   $0x800f67
  800288:	e8 a7 00 00 00       	call   800334 <_panic>

0080028d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a6:	89 df                	mov    %ebx,%edi
  8002a8:	89 de                	mov    %ebx,%esi
  8002aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	7f 08                	jg     8002b8 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	50                   	push   %eax
  8002bc:	6a 09                	push   $0x9
  8002be:	68 4a 0f 80 00       	push   $0x800f4a
  8002c3:	6a 23                	push   $0x23
  8002c5:	68 67 0f 80 00       	push   $0x800f67
  8002ca:	e8 65 00 00 00       	call   800334 <_panic>

008002cf <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e0:	be 00 00 00 00       	mov    $0x0,%esi
  8002e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002eb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	b8 0c 00 00 00       	mov    $0xc,%eax
  800308:	89 cb                	mov    %ecx,%ebx
  80030a:	89 cf                	mov    %ecx,%edi
  80030c:	89 ce                	mov    %ecx,%esi
  80030e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800310:	85 c0                	test   %eax,%eax
  800312:	7f 08                	jg     80031c <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800314:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5f                   	pop    %edi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	50                   	push   %eax
  800320:	6a 0c                	push   $0xc
  800322:	68 4a 0f 80 00       	push   $0x800f4a
  800327:	6a 23                	push   $0x23
  800329:	68 67 0f 80 00       	push   $0x800f67
  80032e:	e8 01 00 00 00       	call   800334 <_panic>
	...

00800334 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	56                   	push   %esi
  800338:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800339:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800342:	e8 ff fd ff ff       	call   800146 <sys_getenvid>
  800347:	83 ec 0c             	sub    $0xc,%esp
  80034a:	ff 75 0c             	pushl  0xc(%ebp)
  80034d:	ff 75 08             	pushl  0x8(%ebp)
  800350:	56                   	push   %esi
  800351:	50                   	push   %eax
  800352:	68 78 0f 80 00       	push   $0x800f78
  800357:	e8 b4 00 00 00       	call   800410 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035c:	83 c4 18             	add    $0x18,%esp
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	e8 57 00 00 00       	call   8003bf <vcprintf>
	cprintf("\n");
  800368:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  80036f:	e8 9c 00 00 00       	call   800410 <cprintf>
  800374:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800377:	cc                   	int3   
  800378:	eb fd                	jmp    800377 <_panic+0x43>
	...

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	74 08                	je     8003a3 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039b:	ff 43 04             	incl   0x4(%ebx)
}
  80039e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	68 ff 00 00 00       	push   $0xff
  8003ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ae:	50                   	push   %eax
  8003af:	e8 14 fd ff ff       	call   8000c8 <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	eb dc                	jmp    80039b <putch+0x1f>

008003bf <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cf:	00 00 00 
	b.cnt = 0;
  8003d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e8:	50                   	push   %eax
  8003e9:	68 7c 03 80 00       	push   $0x80037c
  8003ee:	e8 17 01 00 00       	call   80050a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f3:	83 c4 08             	add    $0x8,%esp
  8003f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800402:	50                   	push   %eax
  800403:	e8 c0 fc ff ff       	call   8000c8 <sys_cputs>

	return b.cnt;
}
  800408:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800416:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800419:	50                   	push   %eax
  80041a:	ff 75 08             	pushl  0x8(%ebp)
  80041d:	e8 9d ff ff ff       	call   8003bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 1c             	sub    $0x1c,%esp
  80042d:	89 c7                	mov    %eax,%edi
  80042f:	89 d6                	mov    %edx,%esi
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	8b 55 0c             	mov    0xc(%ebp),%edx
  800437:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800440:	bb 00 00 00 00       	mov    $0x0,%ebx
  800445:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800448:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044b:	39 d3                	cmp    %edx,%ebx
  80044d:	72 05                	jb     800454 <printnum+0x30>
  80044f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800452:	77 78                	ja     8004cc <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800454:	83 ec 0c             	sub    $0xc,%esp
  800457:	ff 75 18             	pushl  0x18(%ebp)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800460:	53                   	push   %ebx
  800461:	ff 75 10             	pushl  0x10(%ebp)
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046a:	ff 75 e0             	pushl  -0x20(%ebp)
  80046d:	ff 75 dc             	pushl  -0x24(%ebp)
  800470:	ff 75 d8             	pushl  -0x28(%ebp)
  800473:	e8 a8 08 00 00       	call   800d20 <__udivdi3>
  800478:	83 c4 18             	add    $0x18,%esp
  80047b:	52                   	push   %edx
  80047c:	50                   	push   %eax
  80047d:	89 f2                	mov    %esi,%edx
  80047f:	89 f8                	mov    %edi,%eax
  800481:	e8 9e ff ff ff       	call   800424 <printnum>
  800486:	83 c4 20             	add    $0x20,%esp
  800489:	eb 11                	jmp    80049c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	56                   	push   %esi
  80048f:	ff 75 18             	pushl  0x18(%ebp)
  800492:	ff d7                	call   *%edi
  800494:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7f ef                	jg     80048b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	56                   	push   %esi
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8004af:	e8 6c 09 00 00       	call   800e20 <__umoddi3>
  8004b4:	83 c4 14             	add    $0x14,%esp
  8004b7:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  8004be:	50                   	push   %eax
  8004bf:	ff d7                	call   *%edi
}
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c7:	5b                   	pop    %ebx
  8004c8:	5e                   	pop    %esi
  8004c9:	5f                   	pop    %edi
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    
  8004cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004cf:	eb c6                	jmp    800497 <printnum+0x73>

008004d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004df:	73 0a                	jae    8004eb <sprintputch+0x1a>
		*b->buf++ = ch;
  8004e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	88 02                	mov    %al,(%edx)
}
  8004eb:	5d                   	pop    %ebp
  8004ec:	c3                   	ret    

008004ed <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f6:	50                   	push   %eax
  8004f7:	ff 75 10             	pushl  0x10(%ebp)
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	e8 05 00 00 00       	call   80050a <vprintfmt>
	va_end(ap);
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	53                   	push   %ebx
  800510:	83 ec 2c             	sub    $0x2c,%esp
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051c:	e9 ac 03 00 00       	jmp    8008cd <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800521:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800525:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  80052c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800533:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80053a:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8d 47 01             	lea    0x1(%edi),%eax
  800542:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800545:	8a 17                	mov    (%edi),%dl
  800547:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054a:	3c 55                	cmp    $0x55,%al
  80054c:	0f 87 fc 03 00 00    	ja     80094e <vprintfmt+0x444>
  800552:	0f b6 c0             	movzbl %al,%eax
  800555:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800563:	eb da                	jmp    80053f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80056c:	eb d1                	jmp    80053f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	0f b6 d2             	movzbl %dl,%edx
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80057c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057f:	01 c0                	add    %eax,%eax
  800581:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800585:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800588:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80058b:	83 f9 09             	cmp    $0x9,%ecx
  80058e:	77 52                	ja     8005e2 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800590:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800591:	eb e9                	jmp    80057c <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ab:	79 92                	jns    80053f <vprintfmt+0x35>
				width = precision, precision = -1;
  8005ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ba:	eb 83                	jmp    80053f <vprintfmt+0x35>
  8005bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c0:	78 08                	js     8005ca <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c5:	e9 75 ff ff ff       	jmp    80053f <vprintfmt+0x35>
  8005ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005d1:	eb ef                	jmp    8005c2 <vprintfmt+0xb8>
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005dd:	e9 5d ff ff ff       	jmp    80053f <vprintfmt+0x35>
  8005e2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e8:	eb bd                	jmp    8005a7 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ea:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ee:	e9 4c ff ff ff       	jmp    80053f <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 78 04             	lea    0x4(%eax),%edi
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	53                   	push   %ebx
  8005fd:	ff 30                	pushl  (%eax)
  8005ff:	ff d6                	call   *%esi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800604:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800607:	e9 be 02 00 00       	jmp    8008ca <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 78 04             	lea    0x4(%eax),%edi
  800612:	8b 00                	mov    (%eax),%eax
  800614:	85 c0                	test   %eax,%eax
  800616:	78 2a                	js     800642 <vprintfmt+0x138>
  800618:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061a:	83 f8 08             	cmp    $0x8,%eax
  80061d:	7f 27                	jg     800646 <vprintfmt+0x13c>
  80061f:	8b 04 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 1c                	je     800646 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80062a:	50                   	push   %eax
  80062b:	68 bf 0f 80 00       	push   $0x800fbf
  800630:	53                   	push   %ebx
  800631:	56                   	push   %esi
  800632:	e8 b6 fe ff ff       	call   8004ed <printfmt>
  800637:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80063d:	e9 88 02 00 00       	jmp    8008ca <vprintfmt+0x3c0>
  800642:	f7 d8                	neg    %eax
  800644:	eb d2                	jmp    800618 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800646:	52                   	push   %edx
  800647:	68 b6 0f 80 00       	push   $0x800fb6
  80064c:	53                   	push   %ebx
  80064d:	56                   	push   %esi
  80064e:	e8 9a fe ff ff       	call   8004ed <printfmt>
  800653:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800659:	e9 6c 02 00 00       	jmp    8008ca <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	83 c0 04             	add    $0x4,%eax
  800664:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 38                	mov    (%eax),%edi
  80066c:	85 ff                	test   %edi,%edi
  80066e:	74 18                	je     800688 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800670:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800674:	0f 8e b7 00 00 00    	jle    800731 <vprintfmt+0x227>
  80067a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80067e:	75 0f                	jne    80068f <vprintfmt+0x185>
  800680:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800683:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800686:	eb 75                	jmp    8006fd <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800688:	bf af 0f 80 00       	mov    $0x800faf,%edi
  80068d:	eb e1                	jmp    800670 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 5f 03 00 00       	call   8009fa <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0d                	jmp    8006c1 <vprintfmt+0x1b7>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	4f                   	dec    %edi
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	85 ff                	test   %edi,%edi
  8006c3:	7f ef                	jg     8006b4 <vprintfmt+0x1aa>
  8006c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cb:	89 c8                	mov    %ecx,%eax
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	78 10                	js     8006e1 <vprintfmt+0x1d7>
  8006d1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d4:	29 c1                	sub    %eax,%ecx
  8006d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006df:	eb 1c                	jmp    8006fd <vprintfmt+0x1f3>
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	eb e9                	jmp    8006d1 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ec:	75 29                	jne    800717 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	50                   	push   %eax
  8006f5:	ff d6                	call   *%esi
  8006f7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fa:	ff 4d e0             	decl   -0x20(%ebp)
  8006fd:	47                   	inc    %edi
  8006fe:	8a 57 ff             	mov    -0x1(%edi),%dl
  800701:	0f be c2             	movsbl %dl,%eax
  800704:	85 c0                	test   %eax,%eax
  800706:	74 4c                	je     800754 <vprintfmt+0x24a>
  800708:	85 db                	test   %ebx,%ebx
  80070a:	78 dc                	js     8006e8 <vprintfmt+0x1de>
  80070c:	4b                   	dec    %ebx
  80070d:	79 d9                	jns    8006e8 <vprintfmt+0x1de>
  80070f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800712:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800715:	eb 2e                	jmp    800745 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	0f be d2             	movsbl %dl,%edx
  80071a:	83 ea 20             	sub    $0x20,%edx
  80071d:	83 fa 5e             	cmp    $0x5e,%edx
  800720:	76 cc                	jbe    8006ee <vprintfmt+0x1e4>
					putch('?', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 3f                	push   $0x3f
  80072a:	ff d6                	call   *%esi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb c9                	jmp    8006fa <vprintfmt+0x1f0>
  800731:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800734:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800737:	eb c4                	jmp    8006fd <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 20                	push   $0x20
  80073f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800741:	4f                   	dec    %edi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	85 ff                	test   %edi,%edi
  800747:	7f f0                	jg     800739 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800749:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
  80074f:	e9 76 01 00 00       	jmp    8008ca <vprintfmt+0x3c0>
  800754:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075a:	eb e9                	jmp    800745 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7e 3f                	jle    8007a0 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 50 04             	mov    0x4(%eax),%edx
  800767:	8b 00                	mov    (%eax),%eax
  800769:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 40 08             	lea    0x8(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800778:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077c:	79 5c                	jns    8007da <vprintfmt+0x2d0>
				putch('-', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	6a 2d                	push   $0x2d
  800784:	ff d6                	call   *%esi
				num = -(long long) num;
  800786:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800789:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078c:	f7 da                	neg    %edx
  80078e:	83 d1 00             	adc    $0x0,%ecx
  800791:	f7 d9                	neg    %ecx
  800793:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079b:	e9 10 01 00 00       	jmp    8008b0 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  8007a0:	85 c9                	test   %ecx,%ecx
  8007a2:	75 1b                	jne    8007bf <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ac:	89 c1                	mov    %eax,%ecx
  8007ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bd:	eb b9                	jmp    800778 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c7:	89 c1                	mov    %eax,%ecx
  8007c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d8:	eb 9e                	jmp    800778 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e5:	e9 c6 00 00 00       	jmp    8008b0 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ea:	83 f9 01             	cmp    $0x1,%ecx
  8007ed:	7e 18                	jle    800807 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f7:	8d 40 08             	lea    0x8(%eax),%eax
  8007fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800802:	e9 a9 00 00 00       	jmp    8008b0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800807:	85 c9                	test   %ecx,%ecx
  800809:	75 1a                	jne    800825 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	8d 40 04             	lea    0x4(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800820:	e9 8b 00 00 00       	jmp    8008b0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083a:	eb 74                	jmp    8008b0 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083c:	83 f9 01             	cmp    $0x1,%ecx
  80083f:	7e 15                	jle    800856 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 10                	mov    (%eax),%edx
  800846:	8b 48 04             	mov    0x4(%eax),%ecx
  800849:	8d 40 08             	lea    0x8(%eax),%eax
  80084c:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80084f:	b8 08 00 00 00       	mov    $0x8,%eax
  800854:	eb 5a                	jmp    8008b0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800856:	85 c9                	test   %ecx,%ecx
  800858:	75 17                	jne    800871 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800864:	8d 40 04             	lea    0x4(%eax),%eax
  800867:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80086a:	b8 08 00 00 00       	mov    $0x8,%eax
  80086f:	eb 3f                	jmp    8008b0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8b 10                	mov    (%eax),%edx
  800876:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087b:	8d 40 04             	lea    0x4(%eax),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800881:	b8 08 00 00 00       	mov    $0x8,%eax
  800886:	eb 28                	jmp    8008b0 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	53                   	push   %ebx
  80088c:	6a 30                	push   $0x30
  80088e:	ff d6                	call   *%esi
			putch('x', putdat);
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	53                   	push   %ebx
  800894:	6a 78                	push   $0x78
  800896:	ff d6                	call   *%esi
			num = (unsigned long long)
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8b 10                	mov    (%eax),%edx
  80089d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a5:	8d 40 04             	lea    0x4(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b0:	83 ec 0c             	sub    $0xc,%esp
  8008b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b7:	57                   	push   %edi
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	50                   	push   %eax
  8008bc:	51                   	push   %ecx
  8008bd:	52                   	push   %edx
  8008be:	89 da                	mov    %ebx,%edx
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	e8 5d fb ff ff       	call   800424 <printnum>
			break;
  8008c7:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008cd:	47                   	inc    %edi
  8008ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d2:	83 f8 25             	cmp    $0x25,%eax
  8008d5:	0f 84 46 fc ff ff    	je     800521 <vprintfmt+0x17>
			if (ch == '\0')
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	0f 84 89 00 00 00    	je     80096c <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	50                   	push   %eax
  8008e8:	ff d6                	call   *%esi
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb de                	jmp    8008cd <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ef:	83 f9 01             	cmp    $0x1,%ecx
  8008f2:	7e 15                	jle    800909 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8b 10                	mov    (%eax),%edx
  8008f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008fc:	8d 40 08             	lea    0x8(%eax),%eax
  8008ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800902:	b8 10 00 00 00       	mov    $0x10,%eax
  800907:	eb a7                	jmp    8008b0 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	75 17                	jne    800924 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8b 10                	mov    (%eax),%edx
  800912:	b9 00 00 00 00       	mov    $0x0,%ecx
  800917:	8d 40 04             	lea    0x4(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
  800922:	eb 8c                	jmp    8008b0 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800924:	8b 45 14             	mov    0x14(%ebp),%eax
  800927:	8b 10                	mov    (%eax),%edx
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	8d 40 04             	lea    0x4(%eax),%eax
  800931:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800934:	b8 10 00 00 00       	mov    $0x10,%eax
  800939:	e9 72 ff ff ff       	jmp    8008b0 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	6a 25                	push   $0x25
  800944:	ff d6                	call   *%esi
			break;
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	e9 7c ff ff ff       	jmp    8008ca <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 25                	push   $0x25
  800954:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	89 f8                	mov    %edi,%eax
  80095b:	eb 01                	jmp    80095e <vprintfmt+0x454>
  80095d:	48                   	dec    %eax
  80095e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800962:	75 f9                	jne    80095d <vprintfmt+0x453>
  800964:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800967:	e9 5e ff ff ff       	jmp    8008ca <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  80096c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 18             	sub    $0x18,%esp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800980:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800983:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800987:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800991:	85 c0                	test   %eax,%eax
  800993:	74 26                	je     8009bb <vsnprintf+0x47>
  800995:	85 d2                	test   %edx,%edx
  800997:	7e 29                	jle    8009c2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800999:	ff 75 14             	pushl  0x14(%ebp)
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a2:	50                   	push   %eax
  8009a3:	68 d1 04 80 00       	push   $0x8004d1
  8009a8:	e8 5d fb ff ff       	call   80050a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b6:	83 c4 10             	add    $0x10,%esp
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c0:	eb f7                	jmp    8009b9 <vsnprintf+0x45>
  8009c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c7:	eb f0                	jmp    8009b9 <vsnprintf+0x45>

008009c9 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d2:	50                   	push   %eax
  8009d3:	ff 75 10             	pushl  0x10(%ebp)
  8009d6:	ff 75 0c             	pushl  0xc(%ebp)
  8009d9:	ff 75 08             	pushl  0x8(%ebp)
  8009dc:	e8 93 ff ff ff       	call   800974 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    
	...

008009e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 01                	jmp    8009f2 <strlen+0xe>
		n++;
  8009f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f6:	75 f9                	jne    8009f1 <strlen+0xd>
		n++;
	return n;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 01                	jmp    800a0b <strnlen+0x11>
		n++;
  800a0a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0b:	39 d0                	cmp    %edx,%eax
  800a0d:	74 06                	je     800a15 <strnlen+0x1b>
  800a0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a13:	75 f5                	jne    800a0a <strnlen+0x10>
		n++;
	return n;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a21:	89 c2                	mov    %eax,%edx
  800a23:	41                   	inc    %ecx
  800a24:	42                   	inc    %edx
  800a25:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	75 f4                	jne    800a23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a39:	53                   	push   %ebx
  800a3a:	e8 a5 ff ff ff       	call   8009e4 <strlen>
  800a3f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a42:	ff 75 0c             	pushl  0xc(%ebp)
  800a45:	01 d8                	add    %ebx,%eax
  800a47:	50                   	push   %eax
  800a48:	e8 ca ff ff ff       	call   800a17 <strcpy>
	return dst;
}
  800a4d:	89 d8                	mov    %ebx,%eax
  800a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	89 f2                	mov    %esi,%edx
  800a66:	39 da                	cmp    %ebx,%edx
  800a68:	74 0e                	je     800a78 <strncpy+0x24>
		*dst++ = *src;
  800a6a:	42                   	inc    %edx
  800a6b:	8a 01                	mov    (%ecx),%al
  800a6d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a70:	80 39 00             	cmpb   $0x0,(%ecx)
  800a73:	74 f1                	je     800a66 <strncpy+0x12>
			src++;
  800a75:	41                   	inc    %ecx
  800a76:	eb ee                	jmp    800a66 <strncpy+0x12>
	}
	return ret;
}
  800a78:	89 f0                	mov    %esi,%eax
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 75 08             	mov    0x8(%ebp),%esi
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	74 20                	je     800ab0 <strlcpy+0x32>
  800a90:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	eb 05                	jmp    800a9d <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a98:	42                   	inc    %edx
  800a99:	40                   	inc    %eax
  800a9a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a9d:	39 d8                	cmp    %ebx,%eax
  800a9f:	74 06                	je     800aa7 <strlcpy+0x29>
  800aa1:	8a 0a                	mov    (%edx),%cl
  800aa3:	84 c9                	test   %cl,%cl
  800aa5:	75 f1                	jne    800a98 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800aa7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aaa:	29 f0                	sub    %esi,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    
  800ab0:	89 f0                	mov    %esi,%eax
  800ab2:	eb f6                	jmp    800aaa <strlcpy+0x2c>

00800ab4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800abd:	eb 02                	jmp    800ac1 <strcmp+0xd>
		p++, q++;
  800abf:	41                   	inc    %ecx
  800ac0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ac1:	8a 01                	mov    (%ecx),%al
  800ac3:	84 c0                	test   %al,%al
  800ac5:	74 04                	je     800acb <strcmp+0x17>
  800ac7:	3a 02                	cmp    (%edx),%al
  800ac9:	74 f4                	je     800abf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800acb:	0f b6 c0             	movzbl %al,%eax
  800ace:	0f b6 12             	movzbl (%edx),%edx
  800ad1:	29 d0                	sub    %edx,%eax
}
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	53                   	push   %ebx
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	89 c3                	mov    %eax,%ebx
  800ae1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae4:	eb 02                	jmp    800ae8 <strncmp+0x13>
		n--, p++, q++;
  800ae6:	40                   	inc    %eax
  800ae7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae8:	39 d8                	cmp    %ebx,%eax
  800aea:	74 15                	je     800b01 <strncmp+0x2c>
  800aec:	8a 08                	mov    (%eax),%cl
  800aee:	84 c9                	test   %cl,%cl
  800af0:	74 04                	je     800af6 <strncmp+0x21>
  800af2:	3a 0a                	cmp    (%edx),%cl
  800af4:	74 f0                	je     800ae6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af6:	0f b6 00             	movzbl (%eax),%eax
  800af9:	0f b6 12             	movzbl (%edx),%edx
  800afc:	29 d0                	sub    %edx,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	eb f6                	jmp    800afe <strncmp+0x29>

00800b08 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b11:	8a 10                	mov    (%eax),%dl
  800b13:	84 d2                	test   %dl,%dl
  800b15:	74 07                	je     800b1e <strchr+0x16>
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	74 08                	je     800b23 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1b:	40                   	inc    %eax
  800b1c:	eb f3                	jmp    800b11 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2e:	8a 10                	mov    (%eax),%dl
  800b30:	84 d2                	test   %dl,%dl
  800b32:	74 07                	je     800b3b <strfind+0x16>
		if (*s == c)
  800b34:	38 ca                	cmp    %cl,%dl
  800b36:	74 03                	je     800b3b <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b38:	40                   	inc    %eax
  800b39:	eb f3                	jmp    800b2e <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 13                	je     800b60 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b53:	75 05                	jne    800b5a <memset+0x1d>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	74 0d                	je     800b67 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	fc                   	cld    
  800b5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b60:	89 f8                	mov    %edi,%eax
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b67:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	c1 e3 08             	shl    $0x8,%ebx
  800b70:	89 d0                	mov    %edx,%eax
  800b72:	c1 e0 18             	shl    $0x18,%eax
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	c1 e6 10             	shl    $0x10,%esi
  800b7a:	09 f0                	or     %esi,%eax
  800b7c:	09 c2                	or     %eax,%edx
  800b7e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b80:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b83:	89 d0                	mov    %edx,%eax
  800b85:	fc                   	cld    
  800b86:	f3 ab                	rep stos %eax,%es:(%edi)
  800b88:	eb d6                	jmp    800b60 <memset+0x23>

00800b8a <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b98:	39 c6                	cmp    %eax,%esi
  800b9a:	73 33                	jae    800bcf <memmove+0x45>
  800b9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9f:	39 c2                	cmp    %eax,%edx
  800ba1:	76 2c                	jbe    800bcf <memmove+0x45>
		s += n;
		d += n;
  800ba3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	09 fe                	or     %edi,%esi
  800baa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb0:	74 0a                	je     800bbc <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb2:	4f                   	dec    %edi
  800bb3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb6:	fd                   	std    
  800bb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb9:	fc                   	cld    
  800bba:	eb 21                	jmp    800bdd <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 f1                	jne    800bb2 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc1:	83 ef 04             	sub    $0x4,%edi
  800bc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bca:	fd                   	std    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb ea                	jmp    800bb9 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcf:	89 f2                	mov    %esi,%edx
  800bd1:	09 c2                	or     %eax,%edx
  800bd3:	f6 c2 03             	test   $0x3,%dl
  800bd6:	74 09                	je     800be1 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd8:	89 c7                	mov    %eax,%edi
  800bda:	fc                   	cld    
  800bdb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 f2                	jne    800bd8 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	fc                   	cld    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb ed                	jmp    800bdd <memmove+0x53>

00800bf0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf3:	ff 75 10             	pushl  0x10(%ebp)
  800bf6:	ff 75 0c             	pushl  0xc(%ebp)
  800bf9:	ff 75 08             	pushl  0x8(%ebp)
  800bfc:	e8 89 ff ff ff       	call   800b8a <memmove>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0e:	89 c6                	mov    %eax,%esi
  800c10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c13:	39 f0                	cmp    %esi,%eax
  800c15:	74 16                	je     800c2d <memcmp+0x2a>
		if (*s1 != *s2)
  800c17:	8a 08                	mov    (%eax),%cl
  800c19:	8a 1a                	mov    (%edx),%bl
  800c1b:	38 d9                	cmp    %bl,%cl
  800c1d:	75 04                	jne    800c23 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c1f:	40                   	inc    %eax
  800c20:	42                   	inc    %edx
  800c21:	eb f0                	jmp    800c13 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800c23:	0f b6 c1             	movzbl %cl,%eax
  800c26:	0f b6 db             	movzbl %bl,%ebx
  800c29:	29 d8                	sub    %ebx,%eax
  800c2b:	eb 05                	jmp    800c32 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c44:	39 d0                	cmp    %edx,%eax
  800c46:	73 07                	jae    800c4f <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c48:	38 08                	cmp    %cl,(%eax)
  800c4a:	74 03                	je     800c4f <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4c:	40                   	inc    %eax
  800c4d:	eb f5                	jmp    800c44 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5a:	eb 01                	jmp    800c5d <strtol+0xc>
		s++;
  800c5c:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5d:	8a 01                	mov    (%ecx),%al
  800c5f:	3c 20                	cmp    $0x20,%al
  800c61:	74 f9                	je     800c5c <strtol+0xb>
  800c63:	3c 09                	cmp    $0x9,%al
  800c65:	74 f5                	je     800c5c <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c67:	3c 2b                	cmp    $0x2b,%al
  800c69:	74 2b                	je     800c96 <strtol+0x45>
		s++;
	else if (*s == '-')
  800c6b:	3c 2d                	cmp    $0x2d,%al
  800c6d:	74 2f                	je     800c9e <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c74:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c7b:	75 12                	jne    800c8f <strtol+0x3e>
  800c7d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c80:	74 24                	je     800ca6 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c86:	75 07                	jne    800c8f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c88:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	eb 4e                	jmp    800ce4 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c96:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c97:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9c:	eb d6                	jmp    800c74 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c9e:	41                   	inc    %ecx
  800c9f:	bf 01 00 00 00       	mov    $0x1,%edi
  800ca4:	eb ce                	jmp    800c74 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800caa:	74 10                	je     800cbc <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb0:	75 dd                	jne    800c8f <strtol+0x3e>
		s++, base = 8;
  800cb2:	41                   	inc    %ecx
  800cb3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cba:	eb d3                	jmp    800c8f <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800cbc:	83 c1 02             	add    $0x2,%ecx
  800cbf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cc6:	eb c7                	jmp    800c8f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ccb:	89 f3                	mov    %esi,%ebx
  800ccd:	80 fb 19             	cmp    $0x19,%bl
  800cd0:	77 24                	ja     800cf6 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cd2:	0f be d2             	movsbl %dl,%edx
  800cd5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd8:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cdb:	7e 2b                	jle    800d08 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cdd:	41                   	inc    %ecx
  800cde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ce2:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce4:	8a 11                	mov    (%ecx),%dl
  800ce6:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ce9:	80 fb 09             	cmp    $0x9,%bl
  800cec:	77 da                	ja     800cc8 <strtol+0x77>
			dig = *s - '0';
  800cee:	0f be d2             	movsbl %dl,%edx
  800cf1:	83 ea 30             	sub    $0x30,%edx
  800cf4:	eb e2                	jmp    800cd8 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cf6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf9:	89 f3                	mov    %esi,%ebx
  800cfb:	80 fb 19             	cmp    $0x19,%bl
  800cfe:	77 08                	ja     800d08 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800d00:	0f be d2             	movsbl %dl,%edx
  800d03:	83 ea 37             	sub    $0x37,%edx
  800d06:	eb d0                	jmp    800cd8 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d0c:	74 05                	je     800d13 <strtol+0xc2>
		*endptr = (char *) s;
  800d0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d13:	85 ff                	test   %edi,%edi
  800d15:	74 02                	je     800d19 <strtol+0xc8>
  800d17:	f7 d8                	neg    %eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
	...

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d2b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d2f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d33:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d37:	85 d2                	test   %edx,%edx
  800d39:	75 2d                	jne    800d68 <__udivdi3+0x48>
  800d3b:	39 f7                	cmp    %esi,%edi
  800d3d:	77 59                	ja     800d98 <__udivdi3+0x78>
  800d3f:	89 f9                	mov    %edi,%ecx
  800d41:	85 ff                	test   %edi,%edi
  800d43:	75 0b                	jne    800d50 <__udivdi3+0x30>
  800d45:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4a:	31 d2                	xor    %edx,%edx
  800d4c:	f7 f7                	div    %edi
  800d4e:	89 c1                	mov    %eax,%ecx
  800d50:	31 d2                	xor    %edx,%edx
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	f7 f1                	div    %ecx
  800d56:	89 c3                	mov    %eax,%ebx
  800d58:	89 e8                	mov    %ebp,%eax
  800d5a:	f7 f1                	div    %ecx
  800d5c:	89 da                	mov    %ebx,%edx
  800d5e:	83 c4 1c             	add    $0x1c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	39 f2                	cmp    %esi,%edx
  800d6a:	77 1c                	ja     800d88 <__udivdi3+0x68>
  800d6c:	0f bd da             	bsr    %edx,%ebx
  800d6f:	83 f3 1f             	xor    $0x1f,%ebx
  800d72:	75 38                	jne    800dac <__udivdi3+0x8c>
  800d74:	39 f2                	cmp    %esi,%edx
  800d76:	72 08                	jb     800d80 <__udivdi3+0x60>
  800d78:	39 ef                	cmp    %ebp,%edi
  800d7a:	0f 87 98 00 00 00    	ja     800e18 <__udivdi3+0xf8>
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	eb 05                	jmp    800d8c <__udivdi3+0x6c>
  800d87:	90                   	nop
  800d88:	31 db                	xor    %ebx,%ebx
  800d8a:	31 c0                	xor    %eax,%eax
  800d8c:	89 da                	mov    %ebx,%edx
  800d8e:	83 c4 1c             	add    $0x1c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	89 e8                	mov    %ebp,%eax
  800d9a:	89 f2                	mov    %esi,%edx
  800d9c:	f7 f7                	div    %edi
  800d9e:	31 db                	xor    %ebx,%ebx
  800da0:	89 da                	mov    %ebx,%edx
  800da2:	83 c4 1c             	add    $0x1c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
  800daa:	66 90                	xchg   %ax,%ax
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	29 d8                	sub    %ebx,%eax
  800db3:	88 d9                	mov    %bl,%cl
  800db5:	d3 e2                	shl    %cl,%edx
  800db7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dbb:	89 fa                	mov    %edi,%edx
  800dbd:	88 c1                	mov    %al,%cl
  800dbf:	d3 ea                	shr    %cl,%edx
  800dc1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc5:	09 d1                	or     %edx,%ecx
  800dc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcb:	88 d9                	mov    %bl,%cl
  800dcd:	d3 e7                	shl    %cl,%edi
  800dcf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dd3:	89 f7                	mov    %esi,%edi
  800dd5:	88 c1                	mov    %al,%cl
  800dd7:	d3 ef                	shr    %cl,%edi
  800dd9:	88 d9                	mov    %bl,%cl
  800ddb:	d3 e6                	shl    %cl,%esi
  800ddd:	89 ea                	mov    %ebp,%edx
  800ddf:	88 c1                	mov    %al,%cl
  800de1:	d3 ea                	shr    %cl,%edx
  800de3:	09 d6                	or     %edx,%esi
  800de5:	89 f0                	mov    %esi,%eax
  800de7:	89 fa                	mov    %edi,%edx
  800de9:	f7 74 24 08          	divl   0x8(%esp)
  800ded:	89 d7                	mov    %edx,%edi
  800def:	89 c6                	mov    %eax,%esi
  800df1:	f7 64 24 0c          	mull   0xc(%esp)
  800df5:	39 d7                	cmp    %edx,%edi
  800df7:	72 13                	jb     800e0c <__udivdi3+0xec>
  800df9:	74 09                	je     800e04 <__udivdi3+0xe4>
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	31 db                	xor    %ebx,%ebx
  800dff:	eb 8b                	jmp    800d8c <__udivdi3+0x6c>
  800e01:	8d 76 00             	lea    0x0(%esi),%esi
  800e04:	88 d9                	mov    %bl,%cl
  800e06:	d3 e5                	shl    %cl,%ebp
  800e08:	39 c5                	cmp    %eax,%ebp
  800e0a:	73 ef                	jae    800dfb <__udivdi3+0xdb>
  800e0c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e0f:	31 db                	xor    %ebx,%ebx
  800e11:	e9 76 ff ff ff       	jmp    800d8c <__udivdi3+0x6c>
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	31 c0                	xor    %eax,%eax
  800e1a:	e9 6d ff ff ff       	jmp    800d8c <__udivdi3+0x6c>
	...

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e2b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e2f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e33:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	89 da                	mov    %ebx,%edx
  800e3b:	85 ed                	test   %ebp,%ebp
  800e3d:	75 15                	jne    800e54 <__umoddi3+0x34>
  800e3f:	39 df                	cmp    %ebx,%edi
  800e41:	76 39                	jbe    800e7c <__umoddi3+0x5c>
  800e43:	f7 f7                	div    %edi
  800e45:	89 d0                	mov    %edx,%eax
  800e47:	31 d2                	xor    %edx,%edx
  800e49:	83 c4 1c             	add    $0x1c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
  800e51:	8d 76 00             	lea    0x0(%esi),%esi
  800e54:	39 dd                	cmp    %ebx,%ebp
  800e56:	77 f1                	ja     800e49 <__umoddi3+0x29>
  800e58:	0f bd cd             	bsr    %ebp,%ecx
  800e5b:	83 f1 1f             	xor    $0x1f,%ecx
  800e5e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e62:	75 38                	jne    800e9c <__umoddi3+0x7c>
  800e64:	39 dd                	cmp    %ebx,%ebp
  800e66:	72 04                	jb     800e6c <__umoddi3+0x4c>
  800e68:	39 f7                	cmp    %esi,%edi
  800e6a:	77 dd                	ja     800e49 <__umoddi3+0x29>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	83 c4 1c             	add    $0x1c,%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
  800e7c:	89 f9                	mov    %edi,%ecx
  800e7e:	85 ff                	test   %edi,%edi
  800e80:	75 0b                	jne    800e8d <__umoddi3+0x6d>
  800e82:	b8 01 00 00 00       	mov    $0x1,%eax
  800e87:	31 d2                	xor    %edx,%edx
  800e89:	f7 f7                	div    %edi
  800e8b:	89 c1                	mov    %eax,%ecx
  800e8d:	89 d8                	mov    %ebx,%eax
  800e8f:	31 d2                	xor    %edx,%edx
  800e91:	f7 f1                	div    %ecx
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	f7 f1                	div    %ecx
  800e97:	eb ac                	jmp    800e45 <__umoddi3+0x25>
  800e99:	8d 76 00             	lea    0x0(%esi),%esi
  800e9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea1:	89 c2                	mov    %eax,%edx
  800ea3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea7:	29 c2                	sub    %eax,%edx
  800ea9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ead:	88 c1                	mov    %al,%cl
  800eaf:	d3 e5                	shl    %cl,%ebp
  800eb1:	89 f8                	mov    %edi,%eax
  800eb3:	88 d1                	mov    %dl,%cl
  800eb5:	d3 e8                	shr    %cl,%eax
  800eb7:	09 c5                	or     %eax,%ebp
  800eb9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebd:	88 c1                	mov    %al,%cl
  800ebf:	d3 e7                	shl    %cl,%edi
  800ec1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ec5:	89 df                	mov    %ebx,%edi
  800ec7:	88 d1                	mov    %dl,%cl
  800ec9:	d3 ef                	shr    %cl,%edi
  800ecb:	88 c1                	mov    %al,%cl
  800ecd:	d3 e3                	shl    %cl,%ebx
  800ecf:	89 f0                	mov    %esi,%eax
  800ed1:	88 d1                	mov    %dl,%cl
  800ed3:	d3 e8                	shr    %cl,%eax
  800ed5:	09 d8                	or     %ebx,%eax
  800ed7:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800edb:	d3 e6                	shl    %cl,%esi
  800edd:	89 fa                	mov    %edi,%edx
  800edf:	f7 f5                	div    %ebp
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	f7 64 24 08          	mull   0x8(%esp)
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	89 d7                	mov    %edx,%edi
  800eeb:	39 d1                	cmp    %edx,%ecx
  800eed:	72 29                	jb     800f18 <__umoddi3+0xf8>
  800eef:	74 23                	je     800f14 <__umoddi3+0xf4>
  800ef1:	89 ca                	mov    %ecx,%edx
  800ef3:	29 de                	sub    %ebx,%esi
  800ef5:	19 fa                	sbb    %edi,%edx
  800ef7:	89 d0                	mov    %edx,%eax
  800ef9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f03:	88 d9                	mov    %bl,%cl
  800f05:	d3 ee                	shr    %cl,%esi
  800f07:	09 f0                	or     %esi,%eax
  800f09:	d3 ea                	shr    %cl,%edx
  800f0b:	83 c4 1c             	add    $0x1c,%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
  800f14:	39 c6                	cmp    %eax,%esi
  800f16:	73 d9                	jae    800ef1 <__umoddi3+0xd1>
  800f18:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f1c:	19 ea                	sbb    %ebp,%edx
  800f1e:	89 d7                	mov    %edx,%edi
  800f20:	89 c3                	mov    %eax,%ebx
  800f22:	eb cd                	jmp    800ef1 <__umoddi3+0xd1>
