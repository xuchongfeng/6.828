
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
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 05             	shl    $0x5,%edx
  800056:	29 c2                	sub    %eax,%edx
  800058:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x33>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 bb ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

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
  800109:	68 0a 0f 80 00       	push   $0x800f0a
  80010e:	6a 23                	push   $0x23
  800110:	68 27 0f 80 00       	push   $0x800f27
  800115:	e8 ee 01 00 00       	call   800308 <_panic>

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

00800139 <sys_yield>:

void
sys_yield(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 0a 00 00 00       	mov    $0xa,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	be 00 00 00 00       	mov    $0x0,%esi
  800166:	8b 55 08             	mov    0x8(%ebp),%edx
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800174:	89 f7                	mov    %esi,%edi
  800176:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800178:	85 c0                	test   %eax,%eax
  80017a:	7f 08                	jg     800184 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	50                   	push   %eax
  800188:	6a 04                	push   $0x4
  80018a:	68 0a 0f 80 00       	push   $0x800f0a
  80018f:	6a 23                	push   $0x23
  800191:	68 27 0f 80 00       	push   $0x800f27
  800196:	e8 6d 01 00 00       	call   800308 <_panic>

0080019b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	7f 08                	jg     8001c6 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	6a 05                	push   $0x5
  8001cc:	68 0a 0f 80 00       	push   $0x800f0a
  8001d1:	6a 23                	push   $0x23
  8001d3:	68 27 0f 80 00       	push   $0x800f27
  8001d8:	e8 2b 01 00 00       	call   800308 <_panic>

008001dd <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	89 df                	mov    %ebx,%edi
  8001f8:	89 de                	mov    %ebx,%esi
  8001fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7f 08                	jg     800208 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5f                   	pop    %edi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 06                	push   $0x6
  80020e:	68 0a 0f 80 00       	push   $0x800f0a
  800213:	6a 23                	push   $0x23
  800215:	68 27 0f 80 00       	push   $0x800f27
  80021a:	e8 e9 00 00 00       	call   800308 <_panic>

0080021f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7f 08                	jg     80024a <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	50                   	push   %eax
  80024e:	6a 08                	push   $0x8
  800250:	68 0a 0f 80 00       	push   $0x800f0a
  800255:	6a 23                	push   $0x23
  800257:	68 27 0f 80 00       	push   $0x800f27
  80025c:	e8 a7 00 00 00       	call   800308 <_panic>

00800261 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	8b 55 08             	mov    0x8(%ebp),%edx
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	89 df                	mov    %ebx,%edi
  80027c:	89 de                	mov    %ebx,%esi
  80027e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800280:	85 c0                	test   %eax,%eax
  800282:	7f 08                	jg     80028c <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800287:	5b                   	pop    %ebx
  800288:	5e                   	pop    %esi
  800289:	5f                   	pop    %edi
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	50                   	push   %eax
  800290:	6a 09                	push   $0x9
  800292:	68 0a 0f 80 00       	push   $0x800f0a
  800297:	6a 23                	push   $0x23
  800299:	68 27 0f 80 00       	push   $0x800f27
  80029e:	e8 65 00 00 00       	call   800308 <_panic>

008002a3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002af:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b4:	be 00 00 00 00       	mov    $0x0,%esi
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	89 cb                	mov    %ecx,%ebx
  8002de:	89 cf                	mov    %ecx,%edi
  8002e0:	89 ce                	mov    %ecx,%esi
  8002e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7f 08                	jg     8002f0 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	50                   	push   %eax
  8002f4:	6a 0c                	push   $0xc
  8002f6:	68 0a 0f 80 00       	push   $0x800f0a
  8002fb:	6a 23                	push   $0x23
  8002fd:	68 27 0f 80 00       	push   $0x800f27
  800302:	e8 01 00 00 00       	call   800308 <_panic>
	...

00800308 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800310:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800316:	e8 ff fd ff ff       	call   80011a <sys_getenvid>
  80031b:	83 ec 0c             	sub    $0xc,%esp
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	56                   	push   %esi
  800325:	50                   	push   %eax
  800326:	68 38 0f 80 00       	push   $0x800f38
  80032b:	e8 b4 00 00 00       	call   8003e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800330:	83 c4 18             	add    $0x18,%esp
  800333:	53                   	push   %ebx
  800334:	ff 75 10             	pushl  0x10(%ebp)
  800337:	e8 57 00 00 00       	call   800393 <vcprintf>
	cprintf("\n");
  80033c:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  800343:	e8 9c 00 00 00       	call   8003e4 <cprintf>
  800348:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034b:	cc                   	int3   
  80034c:	eb fd                	jmp    80034b <_panic+0x43>
	...

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	74 08                	je     800377 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80036f:	ff 43 04             	incl   0x4(%ebx)
}
  800372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800375:	c9                   	leave  
  800376:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 14 fd ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
  800391:	eb dc                	jmp    80036f <putch+0x1f>

00800393 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a3:	00 00 00 
	b.cnt = 0;
  8003a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	ff 75 08             	pushl  0x8(%ebp)
  8003b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bc:	50                   	push   %eax
  8003bd:	68 50 03 80 00       	push   $0x800350
  8003c2:	e8 17 01 00 00       	call   8004de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c7:	83 c4 08             	add    $0x8,%esp
  8003ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d6:	50                   	push   %eax
  8003d7:	e8 c0 fc ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  8003dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ed:	50                   	push   %eax
  8003ee:	ff 75 08             	pushl  0x8(%ebp)
  8003f1:	e8 9d ff ff ff       	call   800393 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	57                   	push   %edi
  8003fc:	56                   	push   %esi
  8003fd:	53                   	push   %ebx
  8003fe:	83 ec 1c             	sub    $0x1c,%esp
  800401:	89 c7                	mov    %eax,%edi
  800403:	89 d6                	mov    %edx,%esi
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800411:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800414:	bb 00 00 00 00       	mov    $0x0,%ebx
  800419:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041f:	39 d3                	cmp    %edx,%ebx
  800421:	72 05                	jb     800428 <printnum+0x30>
  800423:	39 45 10             	cmp    %eax,0x10(%ebp)
  800426:	77 78                	ja     8004a0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	ff 75 18             	pushl  0x18(%ebp)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800434:	53                   	push   %ebx
  800435:	ff 75 10             	pushl  0x10(%ebp)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff 75 dc             	pushl  -0x24(%ebp)
  800444:	ff 75 d8             	pushl  -0x28(%ebp)
  800447:	e8 a8 08 00 00       	call   800cf4 <__udivdi3>
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	52                   	push   %edx
  800450:	50                   	push   %eax
  800451:	89 f2                	mov    %esi,%edx
  800453:	89 f8                	mov    %edi,%eax
  800455:	e8 9e ff ff ff       	call   8003f8 <printnum>
  80045a:	83 c4 20             	add    $0x20,%esp
  80045d:	eb 11                	jmp    800470 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	56                   	push   %esi
  800463:	ff 75 18             	pushl  0x18(%ebp)
  800466:	ff d7                	call   *%edi
  800468:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046b:	4b                   	dec    %ebx
  80046c:	85 db                	test   %ebx,%ebx
  80046e:	7f ef                	jg     80045f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	56                   	push   %esi
  800474:	83 ec 04             	sub    $0x4,%esp
  800477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff 75 dc             	pushl  -0x24(%ebp)
  800480:	ff 75 d8             	pushl  -0x28(%ebp)
  800483:	e8 6c 09 00 00       	call   800df4 <__umoddi3>
  800488:	83 c4 14             	add    $0x14,%esp
  80048b:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  800492:	50                   	push   %eax
  800493:	ff d7                	call   *%edi
}
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049b:	5b                   	pop    %ebx
  80049c:	5e                   	pop    %esi
  80049d:	5f                   	pop    %edi
  80049e:	5d                   	pop    %ebp
  80049f:	c3                   	ret    
  8004a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a3:	eb c6                	jmp    80046b <printnum+0x73>

008004a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ab:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b3:	73 0a                	jae    8004bf <sprintputch+0x1a>
		*b->buf++ = ch;
  8004b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b8:	89 08                	mov    %ecx,(%eax)
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	88 02                	mov    %al,(%edx)
}
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ca:	50                   	push   %eax
  8004cb:	ff 75 10             	pushl  0x10(%ebp)
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	ff 75 08             	pushl  0x8(%ebp)
  8004d4:	e8 05 00 00 00       	call   8004de <vprintfmt>
	va_end(ap);
}
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 2c             	sub    $0x2c,%esp
  8004e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f0:	e9 ac 03 00 00       	jmp    8008a1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8004f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800507:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8d 47 01             	lea    0x1(%edi),%eax
  800516:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800519:	8a 17                	mov    (%edi),%dl
  80051b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80051e:	3c 55                	cmp    $0x55,%al
  800520:	0f 87 fc 03 00 00    	ja     800922 <vprintfmt+0x444>
  800526:	0f b6 c0             	movzbl %al,%eax
  800529:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800533:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800537:	eb da                	jmp    800513 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800540:	eb d1                	jmp    800513 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	0f b6 d2             	movzbl %dl,%edx
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	b8 00 00 00 00       	mov    $0x0,%eax
  80054d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800550:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800553:	01 c0                	add    %eax,%eax
  800555:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800559:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80055f:	83 f9 09             	cmp    $0x9,%ecx
  800562:	77 52                	ja     8005b6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800564:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800565:	eb e9                	jmp    800550 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80057b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057f:	79 92                	jns    800513 <vprintfmt+0x35>
				width = precision, precision = -1;
  800581:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800584:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800587:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058e:	eb 83                	jmp    800513 <vprintfmt+0x35>
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	78 08                	js     80059e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	e9 75 ff ff ff       	jmp    800513 <vprintfmt+0x35>
  80059e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005a5:	eb ef                	jmp    800596 <vprintfmt+0xb8>
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005aa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b1:	e9 5d ff ff ff       	jmp    800513 <vprintfmt+0x35>
  8005b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bc:	eb bd                	jmp    80057b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005be:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c2:	e9 4c ff ff ff       	jmp    800513 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 78 04             	lea    0x4(%eax),%edi
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	ff 30                	pushl  (%eax)
  8005d3:	ff d6                	call   *%esi
			break;
  8005d5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005db:	e9 be 02 00 00       	jmp    80089e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 78 04             	lea    0x4(%eax),%edi
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	78 2a                	js     800616 <vprintfmt+0x138>
  8005ec:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ee:	83 f8 08             	cmp    $0x8,%eax
  8005f1:	7f 27                	jg     80061a <vprintfmt+0x13c>
  8005f3:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	74 1c                	je     80061a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005fe:	50                   	push   %eax
  8005ff:	68 7f 0f 80 00       	push   $0x800f7f
  800604:	53                   	push   %ebx
  800605:	56                   	push   %esi
  800606:	e8 b6 fe ff ff       	call   8004c1 <printfmt>
  80060b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800611:	e9 88 02 00 00       	jmp    80089e <vprintfmt+0x3c0>
  800616:	f7 d8                	neg    %eax
  800618:	eb d2                	jmp    8005ec <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061a:	52                   	push   %edx
  80061b:	68 76 0f 80 00       	push   $0x800f76
  800620:	53                   	push   %ebx
  800621:	56                   	push   %esi
  800622:	e8 9a fe ff ff       	call   8004c1 <printfmt>
  800627:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062d:	e9 6c 02 00 00       	jmp    80089e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	83 c0 04             	add    $0x4,%eax
  800638:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 38                	mov    (%eax),%edi
  800640:	85 ff                	test   %edi,%edi
  800642:	74 18                	je     80065c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800644:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800648:	0f 8e b7 00 00 00    	jle    800705 <vprintfmt+0x227>
  80064e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800652:	75 0f                	jne    800663 <vprintfmt+0x185>
  800654:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800657:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80065a:	eb 75                	jmp    8006d1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80065c:	bf 6f 0f 80 00       	mov    $0x800f6f,%edi
  800661:	eb e1                	jmp    800644 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	ff 75 d0             	pushl  -0x30(%ebp)
  800669:	57                   	push   %edi
  80066a:	e8 5f 03 00 00       	call   8009ce <strnlen>
  80066f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800672:	29 c1                	sub    %eax,%ecx
  800674:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800677:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80067e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800681:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800684:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800686:	eb 0d                	jmp    800695 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	4f                   	dec    %edi
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	85 ff                	test   %edi,%edi
  800697:	7f ef                	jg     800688 <vprintfmt+0x1aa>
  800699:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80069c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069f:	89 c8                	mov    %ecx,%eax
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	78 10                	js     8006b5 <vprintfmt+0x1d7>
  8006a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a8:	29 c1                	sub    %eax,%ecx
  8006aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b3:	eb 1c                	jmp    8006d1 <vprintfmt+0x1f3>
  8006b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ba:	eb e9                	jmp    8006a5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c0:	75 29                	jne    8006eb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 0c             	pushl  0xc(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	ff d6                	call   *%esi
  8006cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ce:	ff 4d e0             	decl   -0x20(%ebp)
  8006d1:	47                   	inc    %edi
  8006d2:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006d5:	0f be c2             	movsbl %dl,%eax
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 4c                	je     800728 <vprintfmt+0x24a>
  8006dc:	85 db                	test   %ebx,%ebx
  8006de:	78 dc                	js     8006bc <vprintfmt+0x1de>
  8006e0:	4b                   	dec    %ebx
  8006e1:	79 d9                	jns    8006bc <vprintfmt+0x1de>
  8006e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006e9:	eb 2e                	jmp    800719 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	0f be d2             	movsbl %dl,%edx
  8006ee:	83 ea 20             	sub    $0x20,%edx
  8006f1:	83 fa 5e             	cmp    $0x5e,%edx
  8006f4:	76 cc                	jbe    8006c2 <vprintfmt+0x1e4>
					putch('?', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	6a 3f                	push   $0x3f
  8006fe:	ff d6                	call   *%esi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb c9                	jmp    8006ce <vprintfmt+0x1f0>
  800705:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800708:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80070b:	eb c4                	jmp    8006d1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 20                	push   $0x20
  800713:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800715:	4f                   	dec    %edi
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	85 ff                	test   %edi,%edi
  80071b:	7f f0                	jg     80070d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80071d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
  800723:	e9 76 01 00 00       	jmp    80089e <vprintfmt+0x3c0>
  800728:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80072b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072e:	eb e9                	jmp    800719 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800730:	83 f9 01             	cmp    $0x1,%ecx
  800733:	7e 3f                	jle    800774 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 50 04             	mov    0x4(%eax),%edx
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800740:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 40 08             	lea    0x8(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800750:	79 5c                	jns    8007ae <vprintfmt+0x2d0>
				putch('-', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 2d                	push   $0x2d
  800758:	ff d6                	call   *%esi
				num = -(long long) num;
  80075a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800760:	f7 da                	neg    %edx
  800762:	83 d1 00             	adc    $0x0,%ecx
  800765:	f7 d9                	neg    %ecx
  800767:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076f:	e9 10 01 00 00       	jmp    800884 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	75 1b                	jne    800793 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800780:	89 c1                	mov    %eax,%ecx
  800782:	c1 f9 1f             	sar    $0x1f,%ecx
  800785:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 40 04             	lea    0x4(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
  800791:	eb b9                	jmp    80074c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 00                	mov    (%eax),%eax
  800798:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079b:	89 c1                	mov    %eax,%ecx
  80079d:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ac:	eb 9e                	jmp    80074c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b9:	e9 c6 00 00 00       	jmp    800884 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 f9 01             	cmp    $0x1,%ecx
  8007c1:	7e 18                	jle    8007db <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d6:	e9 a9 00 00 00       	jmp    800884 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007db:	85 c9                	test   %ecx,%ecx
  8007dd:	75 1a                	jne    8007f9 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f4:	e9 8b 00 00 00       	jmp    800884 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800809:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080e:	eb 74                	jmp    800884 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800810:	83 f9 01             	cmp    $0x1,%ecx
  800813:	7e 15                	jle    80082a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	8b 48 04             	mov    0x4(%eax),%ecx
  80081d:	8d 40 08             	lea    0x8(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800823:	b8 08 00 00 00       	mov    $0x8,%eax
  800828:	eb 5a                	jmp    800884 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80082a:	85 c9                	test   %ecx,%ecx
  80082c:	75 17                	jne    800845 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	8b 10                	mov    (%eax),%edx
  800833:	b9 00 00 00 00       	mov    $0x0,%ecx
  800838:	8d 40 04             	lea    0x4(%eax),%eax
  80083b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80083e:	b8 08 00 00 00       	mov    $0x8,%eax
  800843:	eb 3f                	jmp    800884 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084f:	8d 40 04             	lea    0x4(%eax),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800855:	b8 08 00 00 00       	mov    $0x8,%eax
  80085a:	eb 28                	jmp    800884 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 30                	push   $0x30
  800862:	ff d6                	call   *%esi
			putch('x', putdat);
  800864:	83 c4 08             	add    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 78                	push   $0x78
  80086a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 10                	mov    (%eax),%edx
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800876:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800879:	8d 40 04             	lea    0x4(%eax),%eax
  80087c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80087f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800884:	83 ec 0c             	sub    $0xc,%esp
  800887:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80088b:	57                   	push   %edi
  80088c:	ff 75 e0             	pushl  -0x20(%ebp)
  80088f:	50                   	push   %eax
  800890:	51                   	push   %ecx
  800891:	52                   	push   %edx
  800892:	89 da                	mov    %ebx,%edx
  800894:	89 f0                	mov    %esi,%eax
  800896:	e8 5d fb ff ff       	call   8003f8 <printnum>
			break;
  80089b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a1:	47                   	inc    %edi
  8008a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008a6:	83 f8 25             	cmp    $0x25,%eax
  8008a9:	0f 84 46 fc ff ff    	je     8004f5 <vprintfmt+0x17>
			if (ch == '\0')
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	0f 84 89 00 00 00    	je     800940 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	50                   	push   %eax
  8008bc:	ff d6                	call   *%esi
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	eb de                	jmp    8008a1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c3:	83 f9 01             	cmp    $0x1,%ecx
  8008c6:	7e 15                	jle    8008dd <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8b 10                	mov    (%eax),%edx
  8008cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d0:	8d 40 08             	lea    0x8(%eax),%eax
  8008d3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008db:	eb a7                	jmp    800884 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	75 17                	jne    8008f8 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8b 10                	mov    (%eax),%edx
  8008e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008eb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ee:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f1:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f6:	eb 8c                	jmp    800884 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8b 10                	mov    (%eax),%edx
  8008fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800902:	8d 40 04             	lea    0x4(%eax),%eax
  800905:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800908:	b8 10 00 00 00       	mov    $0x10,%eax
  80090d:	e9 72 ff ff ff       	jmp    800884 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	6a 25                	push   $0x25
  800918:	ff d6                	call   *%esi
			break;
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	e9 7c ff ff ff       	jmp    80089e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800922:	83 ec 08             	sub    $0x8,%esp
  800925:	53                   	push   %ebx
  800926:	6a 25                	push   $0x25
  800928:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	eb 01                	jmp    800932 <vprintfmt+0x454>
  800931:	48                   	dec    %eax
  800932:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800936:	75 f9                	jne    800931 <vprintfmt+0x453>
  800938:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80093b:	e9 5e ff ff ff       	jmp    80089e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800940:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 18             	sub    $0x18,%esp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800954:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800957:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80095b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80095e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800965:	85 c0                	test   %eax,%eax
  800967:	74 26                	je     80098f <vsnprintf+0x47>
  800969:	85 d2                	test   %edx,%edx
  80096b:	7e 29                	jle    800996 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80096d:	ff 75 14             	pushl  0x14(%ebp)
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800976:	50                   	push   %eax
  800977:	68 a5 04 80 00       	push   $0x8004a5
  80097c:	e8 5d fb ff ff       	call   8004de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800981:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800984:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098a:	83 c4 10             	add    $0x10,%esp
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800994:	eb f7                	jmp    80098d <vsnprintf+0x45>
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099b:	eb f0                	jmp    80098d <vsnprintf+0x45>

0080099d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a6:	50                   	push   %eax
  8009a7:	ff 75 10             	pushl  0x10(%ebp)
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	ff 75 08             	pushl  0x8(%ebp)
  8009b0:	e8 93 ff ff ff       	call   800948 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    
	...

008009b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	eb 01                	jmp    8009c6 <strlen+0xe>
		n++;
  8009c5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ca:	75 f9                	jne    8009c5 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb 01                	jmp    8009df <strnlen+0x11>
		n++;
  8009de:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009df:	39 d0                	cmp    %edx,%eax
  8009e1:	74 06                	je     8009e9 <strnlen+0x1b>
  8009e3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009e7:	75 f5                	jne    8009de <strnlen+0x10>
		n++;
	return n;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	41                   	inc    %ecx
  8009f8:	42                   	inc    %edx
  8009f9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8009fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ff:	84 db                	test   %bl,%bl
  800a01:	75 f4                	jne    8009f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0d:	53                   	push   %ebx
  800a0e:	e8 a5 ff ff ff       	call   8009b8 <strlen>
  800a13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	01 d8                	add    %ebx,%eax
  800a1b:	50                   	push   %eax
  800a1c:	e8 ca ff ff ff       	call   8009eb <strcpy>
	return dst;
}
  800a21:	89 d8                	mov    %ebx,%eax
  800a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a38:	89 f2                	mov    %esi,%edx
  800a3a:	39 da                	cmp    %ebx,%edx
  800a3c:	74 0e                	je     800a4c <strncpy+0x24>
		*dst++ = *src;
  800a3e:	42                   	inc    %edx
  800a3f:	8a 01                	mov    (%ecx),%al
  800a41:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a44:	80 39 00             	cmpb   $0x0,(%ecx)
  800a47:	74 f1                	je     800a3a <strncpy+0x12>
			src++;
  800a49:	41                   	inc    %ecx
  800a4a:	eb ee                	jmp    800a3a <strncpy+0x12>
	}
	return ret;
}
  800a4c:	89 f0                	mov    %esi,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a60:	85 c0                	test   %eax,%eax
  800a62:	74 20                	je     800a84 <strlcpy+0x32>
  800a64:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a68:	89 f0                	mov    %esi,%eax
  800a6a:	eb 05                	jmp    800a71 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6c:	42                   	inc    %edx
  800a6d:	40                   	inc    %eax
  800a6e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a71:	39 d8                	cmp    %ebx,%eax
  800a73:	74 06                	je     800a7b <strlcpy+0x29>
  800a75:	8a 0a                	mov    (%edx),%cl
  800a77:	84 c9                	test   %cl,%cl
  800a79:	75 f1                	jne    800a6c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7e:	29 f0                	sub    %esi,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    
  800a84:	89 f0                	mov    %esi,%eax
  800a86:	eb f6                	jmp    800a7e <strlcpy+0x2c>

00800a88 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a91:	eb 02                	jmp    800a95 <strcmp+0xd>
		p++, q++;
  800a93:	41                   	inc    %ecx
  800a94:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a95:	8a 01                	mov    (%ecx),%al
  800a97:	84 c0                	test   %al,%al
  800a99:	74 04                	je     800a9f <strcmp+0x17>
  800a9b:	3a 02                	cmp    (%edx),%al
  800a9d:	74 f4                	je     800a93 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9f:	0f b6 c0             	movzbl %al,%eax
  800aa2:	0f b6 12             	movzbl (%edx),%edx
  800aa5:	29 d0                	sub    %edx,%eax
}
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	53                   	push   %ebx
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab3:	89 c3                	mov    %eax,%ebx
  800ab5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab8:	eb 02                	jmp    800abc <strncmp+0x13>
		n--, p++, q++;
  800aba:	40                   	inc    %eax
  800abb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800abc:	39 d8                	cmp    %ebx,%eax
  800abe:	74 15                	je     800ad5 <strncmp+0x2c>
  800ac0:	8a 08                	mov    (%eax),%cl
  800ac2:	84 c9                	test   %cl,%cl
  800ac4:	74 04                	je     800aca <strncmp+0x21>
  800ac6:	3a 0a                	cmp    (%edx),%cl
  800ac8:	74 f0                	je     800aba <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aca:	0f b6 00             	movzbl (%eax),%eax
  800acd:	0f b6 12             	movzbl (%edx),%edx
  800ad0:	29 d0                	sub    %edx,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	eb f6                	jmp    800ad2 <strncmp+0x29>

00800adc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ae5:	8a 10                	mov    (%eax),%dl
  800ae7:	84 d2                	test   %dl,%dl
  800ae9:	74 07                	je     800af2 <strchr+0x16>
		if (*s == c)
  800aeb:	38 ca                	cmp    %cl,%dl
  800aed:	74 08                	je     800af7 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aef:	40                   	inc    %eax
  800af0:	eb f3                	jmp    800ae5 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b02:	8a 10                	mov    (%eax),%dl
  800b04:	84 d2                	test   %dl,%dl
  800b06:	74 07                	je     800b0f <strfind+0x16>
		if (*s == c)
  800b08:	38 ca                	cmp    %cl,%dl
  800b0a:	74 03                	je     800b0f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b0c:	40                   	inc    %eax
  800b0d:	eb f3                	jmp    800b02 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 13                	je     800b34 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 05                	jne    800b2e <memset+0x1d>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	74 0d                	je     800b3b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b3b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	c1 e3 08             	shl    $0x8,%ebx
  800b44:	89 d0                	mov    %edx,%eax
  800b46:	c1 e0 18             	shl    $0x18,%eax
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	c1 e6 10             	shl    $0x10,%esi
  800b4e:	09 f0                	or     %esi,%eax
  800b50:	09 c2                	or     %eax,%edx
  800b52:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b54:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	fc                   	cld    
  800b5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5c:	eb d6                	jmp    800b34 <memset+0x23>

00800b5e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6c:	39 c6                	cmp    %eax,%esi
  800b6e:	73 33                	jae    800ba3 <memmove+0x45>
  800b70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b73:	39 c2                	cmp    %eax,%edx
  800b75:	76 2c                	jbe    800ba3 <memmove+0x45>
		s += n;
		d += n;
  800b77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	09 fe                	or     %edi,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	74 0a                	je     800b90 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b86:	4f                   	dec    %edi
  800b87:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8a:	fd                   	std    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8d:	fc                   	cld    
  800b8e:	eb 21                	jmp    800bb1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	f6 c1 03             	test   $0x3,%cl
  800b93:	75 f1                	jne    800b86 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b95:	83 ef 04             	sub    $0x4,%edi
  800b98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b9e:	fd                   	std    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba1:	eb ea                	jmp    800b8d <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba3:	89 f2                	mov    %esi,%edx
  800ba5:	09 c2                	or     %eax,%edx
  800ba7:	f6 c2 03             	test   $0x3,%dl
  800baa:	74 09                	je     800bb5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	fc                   	cld    
  800baf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	f6 c1 03             	test   $0x3,%cl
  800bb8:	75 f2                	jne    800bac <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc2:	eb ed                	jmp    800bb1 <memmove+0x53>

00800bc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	ff 75 0c             	pushl  0xc(%ebp)
  800bcd:	ff 75 08             	pushl  0x8(%ebp)
  800bd0:	e8 89 ff ff ff       	call   800b5e <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be2:	89 c6                	mov    %eax,%esi
  800be4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be7:	39 f0                	cmp    %esi,%eax
  800be9:	74 16                	je     800c01 <memcmp+0x2a>
		if (*s1 != *s2)
  800beb:	8a 08                	mov    (%eax),%cl
  800bed:	8a 1a                	mov    (%edx),%bl
  800bef:	38 d9                	cmp    %bl,%cl
  800bf1:	75 04                	jne    800bf7 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bf3:	40                   	inc    %eax
  800bf4:	42                   	inc    %edx
  800bf5:	eb f0                	jmp    800be7 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800bf7:	0f b6 c1             	movzbl %cl,%eax
  800bfa:	0f b6 db             	movzbl %bl,%ebx
  800bfd:	29 d8                	sub    %ebx,%eax
  800bff:	eb 05                	jmp    800c06 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c18:	39 d0                	cmp    %edx,%eax
  800c1a:	73 07                	jae    800c23 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	38 08                	cmp    %cl,(%eax)
  800c1e:	74 03                	je     800c23 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c20:	40                   	inc    %eax
  800c21:	eb f5                	jmp    800c18 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2e:	eb 01                	jmp    800c31 <strtol+0xc>
		s++;
  800c30:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c31:	8a 01                	mov    (%ecx),%al
  800c33:	3c 20                	cmp    $0x20,%al
  800c35:	74 f9                	je     800c30 <strtol+0xb>
  800c37:	3c 09                	cmp    $0x9,%al
  800c39:	74 f5                	je     800c30 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3b:	3c 2b                	cmp    $0x2b,%al
  800c3d:	74 2b                	je     800c6a <strtol+0x45>
		s++;
	else if (*s == '-')
  800c3f:	3c 2d                	cmp    $0x2d,%al
  800c41:	74 2f                	je     800c72 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c48:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c4f:	75 12                	jne    800c63 <strtol+0x3e>
  800c51:	80 39 30             	cmpb   $0x30,(%ecx)
  800c54:	74 24                	je     800c7a <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c5a:	75 07                	jne    800c63 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	eb 4e                	jmp    800cb8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c6a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	eb d6                	jmp    800c48 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c72:	41                   	inc    %ecx
  800c73:	bf 01 00 00 00       	mov    $0x1,%edi
  800c78:	eb ce                	jmp    800c48 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7e:	74 10                	je     800c90 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c84:	75 dd                	jne    800c63 <strtol+0x3e>
		s++, base = 8;
  800c86:	41                   	inc    %ecx
  800c87:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c8e:	eb d3                	jmp    800c63 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800c90:	83 c1 02             	add    $0x2,%ecx
  800c93:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c9a:	eb c7                	jmp    800c63 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9f:	89 f3                	mov    %esi,%ebx
  800ca1:	80 fb 19             	cmp    $0x19,%bl
  800ca4:	77 24                	ja     800cca <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ca6:	0f be d2             	movsbl %dl,%edx
  800ca9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cac:	39 55 10             	cmp    %edx,0x10(%ebp)
  800caf:	7e 2b                	jle    800cdc <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cb1:	41                   	inc    %ecx
  800cb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb8:	8a 11                	mov    (%ecx),%dl
  800cba:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800cbd:	80 fb 09             	cmp    $0x9,%bl
  800cc0:	77 da                	ja     800c9c <strtol+0x77>
			dig = *s - '0';
  800cc2:	0f be d2             	movsbl %dl,%edx
  800cc5:	83 ea 30             	sub    $0x30,%edx
  800cc8:	eb e2                	jmp    800cac <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 19             	cmp    $0x19,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0xb7>
			dig = *s - 'A' + 10;
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 37             	sub    $0x37,%edx
  800cda:	eb d0                	jmp    800cac <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce0:	74 05                	je     800ce7 <strtol+0xc2>
		*endptr = (char *) s;
  800ce2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ce7:	85 ff                	test   %edi,%edi
  800ce9:	74 02                	je     800ced <strtol+0xc8>
  800ceb:	f7 d8                	neg    %eax
}
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
	...

00800cf4 <__udivdi3>:
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
  800cfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0b:	85 d2                	test   %edx,%edx
  800d0d:	75 2d                	jne    800d3c <__udivdi3+0x48>
  800d0f:	39 f7                	cmp    %esi,%edi
  800d11:	77 59                	ja     800d6c <__udivdi3+0x78>
  800d13:	89 f9                	mov    %edi,%ecx
  800d15:	85 ff                	test   %edi,%edi
  800d17:	75 0b                	jne    800d24 <__udivdi3+0x30>
  800d19:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1e:	31 d2                	xor    %edx,%edx
  800d20:	f7 f7                	div    %edi
  800d22:	89 c1                	mov    %eax,%ecx
  800d24:	31 d2                	xor    %edx,%edx
  800d26:	89 f0                	mov    %esi,%eax
  800d28:	f7 f1                	div    %ecx
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	89 e8                	mov    %ebp,%eax
  800d2e:	f7 f1                	div    %ecx
  800d30:	89 da                	mov    %ebx,%edx
  800d32:	83 c4 1c             	add    $0x1c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	39 f2                	cmp    %esi,%edx
  800d3e:	77 1c                	ja     800d5c <__udivdi3+0x68>
  800d40:	0f bd da             	bsr    %edx,%ebx
  800d43:	83 f3 1f             	xor    $0x1f,%ebx
  800d46:	75 38                	jne    800d80 <__udivdi3+0x8c>
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	72 08                	jb     800d54 <__udivdi3+0x60>
  800d4c:	39 ef                	cmp    %ebp,%edi
  800d4e:	0f 87 98 00 00 00    	ja     800dec <__udivdi3+0xf8>
  800d54:	b8 01 00 00 00       	mov    $0x1,%eax
  800d59:	eb 05                	jmp    800d60 <__udivdi3+0x6c>
  800d5b:	90                   	nop
  800d5c:	31 db                	xor    %ebx,%ebx
  800d5e:	31 c0                	xor    %eax,%eax
  800d60:	89 da                	mov    %ebx,%edx
  800d62:	83 c4 1c             	add    $0x1c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	89 e8                	mov    %ebp,%eax
  800d6e:	89 f2                	mov    %esi,%edx
  800d70:	f7 f7                	div    %edi
  800d72:	31 db                	xor    %ebx,%ebx
  800d74:	89 da                	mov    %ebx,%edx
  800d76:	83 c4 1c             	add    $0x1c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	b8 20 00 00 00       	mov    $0x20,%eax
  800d85:	29 d8                	sub    %ebx,%eax
  800d87:	88 d9                	mov    %bl,%cl
  800d89:	d3 e2                	shl    %cl,%edx
  800d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d8f:	89 fa                	mov    %edi,%edx
  800d91:	88 c1                	mov    %al,%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d99:	09 d1                	or     %edx,%ecx
  800d9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d9f:	88 d9                	mov    %bl,%cl
  800da1:	d3 e7                	shl    %cl,%edi
  800da3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800da7:	89 f7                	mov    %esi,%edi
  800da9:	88 c1                	mov    %al,%cl
  800dab:	d3 ef                	shr    %cl,%edi
  800dad:	88 d9                	mov    %bl,%cl
  800daf:	d3 e6                	shl    %cl,%esi
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	88 c1                	mov    %al,%cl
  800db5:	d3 ea                	shr    %cl,%edx
  800db7:	09 d6                	or     %edx,%esi
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 fa                	mov    %edi,%edx
  800dbd:	f7 74 24 08          	divl   0x8(%esp)
  800dc1:	89 d7                	mov    %edx,%edi
  800dc3:	89 c6                	mov    %eax,%esi
  800dc5:	f7 64 24 0c          	mull   0xc(%esp)
  800dc9:	39 d7                	cmp    %edx,%edi
  800dcb:	72 13                	jb     800de0 <__udivdi3+0xec>
  800dcd:	74 09                	je     800dd8 <__udivdi3+0xe4>
  800dcf:	89 f0                	mov    %esi,%eax
  800dd1:	31 db                	xor    %ebx,%ebx
  800dd3:	eb 8b                	jmp    800d60 <__udivdi3+0x6c>
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	88 d9                	mov    %bl,%cl
  800dda:	d3 e5                	shl    %cl,%ebp
  800ddc:	39 c5                	cmp    %eax,%ebp
  800dde:	73 ef                	jae    800dcf <__udivdi3+0xdb>
  800de0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800de3:	31 db                	xor    %ebx,%ebx
  800de5:	e9 76 ff ff ff       	jmp    800d60 <__udivdi3+0x6c>
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	31 c0                	xor    %eax,%eax
  800dee:	e9 6d ff ff ff       	jmp    800d60 <__udivdi3+0x6c>
	...

00800df4 <__umoddi3>:
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e0b:	89 f0                	mov    %esi,%eax
  800e0d:	89 da                	mov    %ebx,%edx
  800e0f:	85 ed                	test   %ebp,%ebp
  800e11:	75 15                	jne    800e28 <__umoddi3+0x34>
  800e13:	39 df                	cmp    %ebx,%edi
  800e15:	76 39                	jbe    800e50 <__umoddi3+0x5c>
  800e17:	f7 f7                	div    %edi
  800e19:	89 d0                	mov    %edx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 dd                	cmp    %ebx,%ebp
  800e2a:	77 f1                	ja     800e1d <__umoddi3+0x29>
  800e2c:	0f bd cd             	bsr    %ebp,%ecx
  800e2f:	83 f1 1f             	xor    $0x1f,%ecx
  800e32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e36:	75 38                	jne    800e70 <__umoddi3+0x7c>
  800e38:	39 dd                	cmp    %ebx,%ebp
  800e3a:	72 04                	jb     800e40 <__umoddi3+0x4c>
  800e3c:	39 f7                	cmp    %esi,%edi
  800e3e:	77 dd                	ja     800e1d <__umoddi3+0x29>
  800e40:	89 da                	mov    %ebx,%edx
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	29 f8                	sub    %edi,%eax
  800e46:	19 ea                	sbb    %ebp,%edx
  800e48:	83 c4 1c             	add    $0x1c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	85 ff                	test   %edi,%edi
  800e54:	75 0b                	jne    800e61 <__umoddi3+0x6d>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f7                	div    %edi
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 f1                	div    %ecx
  800e67:	89 f0                	mov    %esi,%eax
  800e69:	f7 f1                	div    %ecx
  800e6b:	eb ac                	jmp    800e19 <__umoddi3+0x25>
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	b8 20 00 00 00       	mov    $0x20,%eax
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e7b:	29 c2                	sub    %eax,%edx
  800e7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e81:	88 c1                	mov    %al,%cl
  800e83:	d3 e5                	shl    %cl,%ebp
  800e85:	89 f8                	mov    %edi,%eax
  800e87:	88 d1                	mov    %dl,%cl
  800e89:	d3 e8                	shr    %cl,%eax
  800e8b:	09 c5                	or     %eax,%ebp
  800e8d:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e91:	88 c1                	mov    %al,%cl
  800e93:	d3 e7                	shl    %cl,%edi
  800e95:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e99:	89 df                	mov    %ebx,%edi
  800e9b:	88 d1                	mov    %dl,%cl
  800e9d:	d3 ef                	shr    %cl,%edi
  800e9f:	88 c1                	mov    %al,%cl
  800ea1:	d3 e3                	shl    %cl,%ebx
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	88 d1                	mov    %dl,%cl
  800ea7:	d3 e8                	shr    %cl,%eax
  800ea9:	09 d8                	or     %ebx,%eax
  800eab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800eaf:	d3 e6                	shl    %cl,%esi
  800eb1:	89 fa                	mov    %edi,%edx
  800eb3:	f7 f5                	div    %ebp
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	f7 64 24 08          	mull   0x8(%esp)
  800ebb:	89 c3                	mov    %eax,%ebx
  800ebd:	89 d7                	mov    %edx,%edi
  800ebf:	39 d1                	cmp    %edx,%ecx
  800ec1:	72 29                	jb     800eec <__umoddi3+0xf8>
  800ec3:	74 23                	je     800ee8 <__umoddi3+0xf4>
  800ec5:	89 ca                	mov    %ecx,%edx
  800ec7:	29 de                	sub    %ebx,%esi
  800ec9:	19 fa                	sbb    %edi,%edx
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ed1:	d3 e0                	shl    %cl,%eax
  800ed3:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800ed7:	88 d9                	mov    %bl,%cl
  800ed9:	d3 ee                	shr    %cl,%esi
  800edb:	09 f0                	or     %esi,%eax
  800edd:	d3 ea                	shr    %cl,%edx
  800edf:	83 c4 1c             	add    $0x1c,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
  800ee8:	39 c6                	cmp    %eax,%esi
  800eea:	73 d9                	jae    800ec5 <__umoddi3+0xd1>
  800eec:	2b 44 24 08          	sub    0x8(%esp),%eax
  800ef0:	19 ea                	sbb    %ebp,%edx
  800ef2:	89 d7                	mov    %edx,%edi
  800ef4:	89 c3                	mov    %eax,%ebx
  800ef6:	eb cd                	jmp    800ec5 <__umoddi3+0xd1>
