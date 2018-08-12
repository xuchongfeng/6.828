
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
  800059:	89 c2                	mov    %eax,%edx
  80005b:	c1 e2 05             	shl    $0x5,%edx
  80005e:	29 c2                	sub    %eax,%edx
  800060:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x33>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

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
  800111:	68 0a 0f 80 00       	push   $0x800f0a
  800116:	6a 23                	push   $0x23
  800118:	68 27 0f 80 00       	push   $0x800f27
  80011d:	e8 ee 01 00 00       	call   800310 <_panic>

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

00800141 <sys_yield>:

void
sys_yield(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	57                   	push   %edi
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800147:	ba 00 00 00 00       	mov    $0x0,%edx
  80014c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800151:	89 d1                	mov    %edx,%ecx
  800153:	89 d3                	mov    %edx,%ebx
  800155:	89 d7                	mov    %edx,%edi
  800157:	89 d6                	mov    %edx,%esi
  800159:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	be 00 00 00 00       	mov    $0x0,%esi
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017c:	89 f7                	mov    %esi,%edi
  80017e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800180:	85 c0                	test   %eax,%eax
  800182:	7f 08                	jg     80018c <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5f                   	pop    %edi
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 0a 0f 80 00       	push   $0x800f0a
  800197:	6a 23                	push   $0x23
  800199:	68 27 0f 80 00       	push   $0x800f27
  80019e:	e8 6d 01 00 00       	call   800310 <_panic>

008001a3 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7f 08                	jg     8001ce <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 0a 0f 80 00       	push   $0x800f0a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 27 0f 80 00       	push   $0x800f27
  8001e0:	e8 2b 01 00 00       	call   800310 <_panic>

008001e5 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	89 df                	mov    %ebx,%edi
  800200:	89 de                	mov    %ebx,%esi
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7f 08                	jg     800210 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 0a 0f 80 00       	push   $0x800f0a
  80021b:	6a 23                	push   $0x23
  80021d:	68 27 0f 80 00       	push   $0x800f27
  800222:	e8 e9 00 00 00       	call   800310 <_panic>

00800227 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7f 08                	jg     800252 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 0a 0f 80 00       	push   $0x800f0a
  80025d:	6a 23                	push   $0x23
  80025f:	68 27 0f 80 00       	push   $0x800f27
  800264:	e8 a7 00 00 00       	call   800310 <_panic>

00800269 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7f 08                	jg     800294 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 0a 0f 80 00       	push   $0x800f0a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 27 0f 80 00       	push   $0x800f27
  8002a6:	e8 65 00 00 00       	call   800310 <_panic>

008002ab <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bc:	be 00 00 00 00       	mov    $0x0,%esi
  8002c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e4:	89 cb                	mov    %ecx,%ebx
  8002e6:	89 cf                	mov    %ecx,%edi
  8002e8:	89 ce                	mov    %ecx,%esi
  8002ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7f 08                	jg     8002f8 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f3:	5b                   	pop    %ebx
  8002f4:	5e                   	pop    %esi
  8002f5:	5f                   	pop    %edi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 0a 0f 80 00       	push   $0x800f0a
  800303:	6a 23                	push   $0x23
  800305:	68 27 0f 80 00       	push   $0x800f27
  80030a:	e8 01 00 00 00       	call   800310 <_panic>
	...

00800310 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800315:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800318:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031e:	e8 ff fd ff ff       	call   800122 <sys_getenvid>
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	ff 75 0c             	pushl  0xc(%ebp)
  800329:	ff 75 08             	pushl  0x8(%ebp)
  80032c:	56                   	push   %esi
  80032d:	50                   	push   %eax
  80032e:	68 38 0f 80 00       	push   $0x800f38
  800333:	e8 b4 00 00 00       	call   8003ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800338:	83 c4 18             	add    $0x18,%esp
  80033b:	53                   	push   %ebx
  80033c:	ff 75 10             	pushl  0x10(%ebp)
  80033f:	e8 57 00 00 00       	call   80039b <vcprintf>
	cprintf("\n");
  800344:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  80034b:	e8 9c 00 00 00       	call   8003ec <cprintf>
  800350:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800353:	cc                   	int3   
  800354:	eb fd                	jmp    800353 <_panic+0x43>
	...

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	74 08                	je     80037f <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800377:	ff 43 04             	incl   0x4(%ebx)
}
  80037a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	68 ff 00 00 00       	push   $0xff
  800387:	8d 43 08             	lea    0x8(%ebx),%eax
  80038a:	50                   	push   %eax
  80038b:	e8 14 fd ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800390:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	eb dc                	jmp    800377 <putch+0x1f>

0080039b <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ab:	00 00 00 
	b.cnt = 0;
  8003ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b8:	ff 75 0c             	pushl  0xc(%ebp)
  8003bb:	ff 75 08             	pushl  0x8(%ebp)
  8003be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c4:	50                   	push   %eax
  8003c5:	68 58 03 80 00       	push   $0x800358
  8003ca:	e8 17 01 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cf:	83 c4 08             	add    $0x8,%esp
  8003d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	e8 c0 fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8003e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f5:	50                   	push   %eax
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 9d ff ff ff       	call   80039b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 1c             	sub    $0x1c,%esp
  800409:	89 c7                	mov    %eax,%edi
  80040b:	89 d6                	mov    %edx,%esi
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800419:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800421:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800424:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800427:	39 d3                	cmp    %edx,%ebx
  800429:	72 05                	jb     800430 <printnum+0x30>
  80042b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042e:	77 78                	ja     8004a8 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800430:	83 ec 0c             	sub    $0xc,%esp
  800433:	ff 75 18             	pushl  0x18(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043c:	53                   	push   %ebx
  80043d:	ff 75 10             	pushl  0x10(%ebp)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	ff 75 e4             	pushl  -0x1c(%ebp)
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff 75 dc             	pushl  -0x24(%ebp)
  80044c:	ff 75 d8             	pushl  -0x28(%ebp)
  80044f:	e8 a8 08 00 00       	call   800cfc <__udivdi3>
  800454:	83 c4 18             	add    $0x18,%esp
  800457:	52                   	push   %edx
  800458:	50                   	push   %eax
  800459:	89 f2                	mov    %esi,%edx
  80045b:	89 f8                	mov    %edi,%eax
  80045d:	e8 9e ff ff ff       	call   800400 <printnum>
  800462:	83 c4 20             	add    $0x20,%esp
  800465:	eb 11                	jmp    800478 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	ff 75 18             	pushl  0x18(%ebp)
  80046e:	ff d7                	call   *%edi
  800470:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800473:	4b                   	dec    %ebx
  800474:	85 db                	test   %ebx,%ebx
  800476:	7f ef                	jg     800467 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	83 ec 04             	sub    $0x4,%esp
  80047f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	e8 6c 09 00 00       	call   800dfc <__umoddi3>
  800490:	83 c4 14             	add    $0x14,%esp
  800493:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  80049a:	50                   	push   %eax
  80049b:	ff d7                	call   *%edi
}
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a3:	5b                   	pop    %ebx
  8004a4:	5e                   	pop    %esi
  8004a5:	5f                   	pop    %edi
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    
  8004a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004ab:	eb c6                	jmp    800473 <printnum+0x73>

008004ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bb:	73 0a                	jae    8004c7 <sprintputch+0x1a>
		*b->buf++ = ch;
  8004bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	88 02                	mov    %al,(%edx)
}
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d2:	50                   	push   %eax
  8004d3:	ff 75 10             	pushl  0x10(%ebp)
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	ff 75 08             	pushl  0x8(%ebp)
  8004dc:	e8 05 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 2c             	sub    $0x2c,%esp
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f8:	e9 ac 03 00 00       	jmp    8008a9 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800501:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800508:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80050f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800516:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8d 47 01             	lea    0x1(%edi),%eax
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	8a 17                	mov    (%edi),%dl
  800523:	8d 42 dd             	lea    -0x23(%edx),%eax
  800526:	3c 55                	cmp    $0x55,%al
  800528:	0f 87 fc 03 00 00    	ja     80092a <vprintfmt+0x444>
  80052e:	0f b6 c0             	movzbl %al,%eax
  800531:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053f:	eb da                	jmp    80051b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800544:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800548:	eb d1                	jmp    80051b <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	0f b6 d2             	movzbl %dl,%edx
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800558:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055b:	01 c0                	add    %eax,%eax
  80055d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800561:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800564:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800567:	83 f9 09             	cmp    $0x9,%ecx
  80056a:	77 52                	ja     8005be <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80056d:	eb e9                	jmp    800558 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800583:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800587:	79 92                	jns    80051b <vprintfmt+0x35>
				width = precision, precision = -1;
  800589:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800596:	eb 83                	jmp    80051b <vprintfmt+0x35>
  800598:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059c:	78 08                	js     8005a6 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	e9 75 ff ff ff       	jmp    80051b <vprintfmt+0x35>
  8005a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005ad:	eb ef                	jmp    80059e <vprintfmt+0xb8>
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b9:	e9 5d ff ff ff       	jmp    80051b <vprintfmt+0x35>
  8005be:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c4:	eb bd                	jmp    800583 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ca:	e9 4c ff ff ff       	jmp    80051b <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 78 04             	lea    0x4(%eax),%edi
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	ff 30                	pushl  (%eax)
  8005db:	ff d6                	call   *%esi
			break;
  8005dd:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e3:	e9 be 02 00 00       	jmp    8008a6 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 78 04             	lea    0x4(%eax),%edi
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	78 2a                	js     80061e <vprintfmt+0x138>
  8005f4:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f6:	83 f8 08             	cmp    $0x8,%eax
  8005f9:	7f 27                	jg     800622 <vprintfmt+0x13c>
  8005fb:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  800602:	85 c0                	test   %eax,%eax
  800604:	74 1c                	je     800622 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800606:	50                   	push   %eax
  800607:	68 7f 0f 80 00       	push   $0x800f7f
  80060c:	53                   	push   %ebx
  80060d:	56                   	push   %esi
  80060e:	e8 b6 fe ff ff       	call   8004c9 <printfmt>
  800613:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800616:	89 7d 14             	mov    %edi,0x14(%ebp)
  800619:	e9 88 02 00 00       	jmp    8008a6 <vprintfmt+0x3c0>
  80061e:	f7 d8                	neg    %eax
  800620:	eb d2                	jmp    8005f4 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800622:	52                   	push   %edx
  800623:	68 76 0f 80 00       	push   $0x800f76
  800628:	53                   	push   %ebx
  800629:	56                   	push   %esi
  80062a:	e8 9a fe ff ff       	call   8004c9 <printfmt>
  80062f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800632:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800635:	e9 6c 02 00 00       	jmp    8008a6 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	83 c0 04             	add    $0x4,%eax
  800640:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 38                	mov    (%eax),%edi
  800648:	85 ff                	test   %edi,%edi
  80064a:	74 18                	je     800664 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  80064c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800650:	0f 8e b7 00 00 00    	jle    80070d <vprintfmt+0x227>
  800656:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80065a:	75 0f                	jne    80066b <vprintfmt+0x185>
  80065c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800662:	eb 75                	jmp    8006d9 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800664:	bf 6f 0f 80 00       	mov    $0x800f6f,%edi
  800669:	eb e1                	jmp    80064c <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	ff 75 d0             	pushl  -0x30(%ebp)
  800671:	57                   	push   %edi
  800672:	e8 5f 03 00 00       	call   8009d6 <strnlen>
  800677:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067a:	29 c1                	sub    %eax,%ecx
  80067c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800682:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800686:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800689:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068e:	eb 0d                	jmp    80069d <vprintfmt+0x1b7>
					putch(padc, putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	ff 75 e0             	pushl  -0x20(%ebp)
  800697:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800699:	4f                   	dec    %edi
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 ff                	test   %edi,%edi
  80069f:	7f ef                	jg     800690 <vprintfmt+0x1aa>
  8006a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a7:	89 c8                	mov    %ecx,%eax
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	78 10                	js     8006bd <vprintfmt+0x1d7>
  8006ad:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b0:	29 c1                	sub    %eax,%ecx
  8006b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006bb:	eb 1c                	jmp    8006d9 <vprintfmt+0x1f3>
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	eb e9                	jmp    8006ad <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c8:	75 29                	jne    8006f3 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	50                   	push   %eax
  8006d1:	ff d6                	call   *%esi
  8006d3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d6:	ff 4d e0             	decl   -0x20(%ebp)
  8006d9:	47                   	inc    %edi
  8006da:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006dd:	0f be c2             	movsbl %dl,%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 4c                	je     800730 <vprintfmt+0x24a>
  8006e4:	85 db                	test   %ebx,%ebx
  8006e6:	78 dc                	js     8006c4 <vprintfmt+0x1de>
  8006e8:	4b                   	dec    %ebx
  8006e9:	79 d9                	jns    8006c4 <vprintfmt+0x1de>
  8006eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ee:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006f1:	eb 2e                	jmp    800721 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f3:	0f be d2             	movsbl %dl,%edx
  8006f6:	83 ea 20             	sub    $0x20,%edx
  8006f9:	83 fa 5e             	cmp    $0x5e,%edx
  8006fc:	76 cc                	jbe    8006ca <vprintfmt+0x1e4>
					putch('?', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	6a 3f                	push   $0x3f
  800706:	ff d6                	call   *%esi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb c9                	jmp    8006d6 <vprintfmt+0x1f0>
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800713:	eb c4                	jmp    8006d9 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 20                	push   $0x20
  80071b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071d:	4f                   	dec    %edi
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	85 ff                	test   %edi,%edi
  800723:	7f f0                	jg     800715 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800725:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
  80072b:	e9 76 01 00 00       	jmp    8008a6 <vprintfmt+0x3c0>
  800730:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800736:	eb e9                	jmp    800721 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800738:	83 f9 01             	cmp    $0x1,%ecx
  80073b:	7e 3f                	jle    80077c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 50 04             	mov    0x4(%eax),%edx
  800743:	8b 00                	mov    (%eax),%eax
  800745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800748:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 40 08             	lea    0x8(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800754:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800758:	79 5c                	jns    8007b6 <vprintfmt+0x2d0>
				putch('-', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 2d                	push   $0x2d
  800760:	ff d6                	call   *%esi
				num = -(long long) num;
  800762:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800765:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800768:	f7 da                	neg    %edx
  80076a:	83 d1 00             	adc    $0x0,%ecx
  80076d:	f7 d9                	neg    %ecx
  80076f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800772:	b8 0a 00 00 00       	mov    $0xa,%eax
  800777:	e9 10 01 00 00       	jmp    80088c <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	75 1b                	jne    80079b <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 00                	mov    (%eax),%eax
  800785:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800788:	89 c1                	mov    %eax,%ecx
  80078a:	c1 f9 1f             	sar    $0x1f,%ecx
  80078d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
  800799:	eb b9                	jmp    800754 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a3:	89 c1                	mov    %eax,%ecx
  8007a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b4:	eb 9e                	jmp    800754 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c1:	e9 c6 00 00 00       	jmp    80088c <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c6:	83 f9 01             	cmp    $0x1,%ecx
  8007c9:	7e 18                	jle    8007e3 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d3:	8d 40 08             	lea    0x8(%eax),%eax
  8007d6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007de:	e9 a9 00 00 00       	jmp    80088c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007e3:	85 c9                	test   %ecx,%ecx
  8007e5:	75 1a                	jne    800801 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fc:	e9 8b 00 00 00       	jmp    80088c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800811:	b8 0a 00 00 00       	mov    $0xa,%eax
  800816:	eb 74                	jmp    80088c <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800818:	83 f9 01             	cmp    $0x1,%ecx
  80081b:	7e 15                	jle    800832 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 10                	mov    (%eax),%edx
  800822:	8b 48 04             	mov    0x4(%eax),%ecx
  800825:	8d 40 08             	lea    0x8(%eax),%eax
  800828:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80082b:	b8 08 00 00 00       	mov    $0x8,%eax
  800830:	eb 5a                	jmp    80088c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800832:	85 c9                	test   %ecx,%ecx
  800834:	75 17                	jne    80084d <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8b 10                	mov    (%eax),%edx
  80083b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800840:	8d 40 04             	lea    0x4(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800846:	b8 08 00 00 00       	mov    $0x8,%eax
  80084b:	eb 3f                	jmp    80088c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 10                	mov    (%eax),%edx
  800852:	b9 00 00 00 00       	mov    $0x0,%ecx
  800857:	8d 40 04             	lea    0x4(%eax),%eax
  80085a:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80085d:	b8 08 00 00 00       	mov    $0x8,%eax
  800862:	eb 28                	jmp    80088c <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 30                	push   $0x30
  80086a:	ff d6                	call   *%esi
			putch('x', putdat);
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 78                	push   $0x78
  800872:	ff d6                	call   *%esi
			num = (unsigned long long)
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8b 10                	mov    (%eax),%edx
  800879:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800881:	8d 40 04             	lea    0x4(%eax),%eax
  800884:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800887:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088c:	83 ec 0c             	sub    $0xc,%esp
  80088f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800893:	57                   	push   %edi
  800894:	ff 75 e0             	pushl  -0x20(%ebp)
  800897:	50                   	push   %eax
  800898:	51                   	push   %ecx
  800899:	52                   	push   %edx
  80089a:	89 da                	mov    %ebx,%edx
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	e8 5d fb ff ff       	call   800400 <printnum>
			break;
  8008a3:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a9:	47                   	inc    %edi
  8008aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ae:	83 f8 25             	cmp    $0x25,%eax
  8008b1:	0f 84 46 fc ff ff    	je     8004fd <vprintfmt+0x17>
			if (ch == '\0')
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	0f 84 89 00 00 00    	je     800948 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	50                   	push   %eax
  8008c4:	ff d6                	call   *%esi
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb de                	jmp    8008a9 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008cb:	83 f9 01             	cmp    $0x1,%ecx
  8008ce:	7e 15                	jle    8008e5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8b 10                	mov    (%eax),%edx
  8008d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d8:	8d 40 08             	lea    0x8(%eax),%eax
  8008db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008de:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e3:	eb a7                	jmp    80088c <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	75 17                	jne    800900 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	8b 10                	mov    (%eax),%edx
  8008ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f3:	8d 40 04             	lea    0x4(%eax),%eax
  8008f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f9:	b8 10 00 00 00       	mov    $0x10,%eax
  8008fe:	eb 8c                	jmp    80088c <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8b 10                	mov    (%eax),%edx
  800905:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090a:	8d 40 04             	lea    0x4(%eax),%eax
  80090d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800910:	b8 10 00 00 00       	mov    $0x10,%eax
  800915:	e9 72 ff ff ff       	jmp    80088c <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	6a 25                	push   $0x25
  800920:	ff d6                	call   *%esi
			break;
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	e9 7c ff ff ff       	jmp    8008a6 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092a:	83 ec 08             	sub    $0x8,%esp
  80092d:	53                   	push   %ebx
  80092e:	6a 25                	push   $0x25
  800930:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800932:	83 c4 10             	add    $0x10,%esp
  800935:	89 f8                	mov    %edi,%eax
  800937:	eb 01                	jmp    80093a <vprintfmt+0x454>
  800939:	48                   	dec    %eax
  80093a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80093e:	75 f9                	jne    800939 <vprintfmt+0x453>
  800940:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800943:	e9 5e ff ff ff       	jmp    8008a6 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800948:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 18             	sub    $0x18,%esp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800963:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800966:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096d:	85 c0                	test   %eax,%eax
  80096f:	74 26                	je     800997 <vsnprintf+0x47>
  800971:	85 d2                	test   %edx,%edx
  800973:	7e 29                	jle    80099e <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800975:	ff 75 14             	pushl  0x14(%ebp)
  800978:	ff 75 10             	pushl  0x10(%ebp)
  80097b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097e:	50                   	push   %eax
  80097f:	68 ad 04 80 00       	push   $0x8004ad
  800984:	e8 5d fb ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800989:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800992:	83 c4 10             	add    $0x10,%esp
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800997:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099c:	eb f7                	jmp    800995 <vsnprintf+0x45>
  80099e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a3:	eb f0                	jmp    800995 <vsnprintf+0x45>

008009a5 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ae:	50                   	push   %eax
  8009af:	ff 75 10             	pushl  0x10(%ebp)
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	ff 75 08             	pushl  0x8(%ebp)
  8009b8:	e8 93 ff ff ff       	call   800950 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	eb 01                	jmp    8009ce <strlen+0xe>
		n++;
  8009cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d2:	75 f9                	jne    8009cd <strlen+0xd>
		n++;
	return n;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	eb 01                	jmp    8009e7 <strnlen+0x11>
		n++;
  8009e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e7:	39 d0                	cmp    %edx,%eax
  8009e9:	74 06                	je     8009f1 <strnlen+0x1b>
  8009eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009ef:	75 f5                	jne    8009e6 <strnlen+0x10>
		n++;
	return n;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	41                   	inc    %ecx
  800a00:	42                   	inc    %edx
  800a01:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a04:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a07:	84 db                	test   %bl,%bl
  800a09:	75 f4                	jne    8009ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a15:	53                   	push   %ebx
  800a16:	e8 a5 ff ff ff       	call   8009c0 <strlen>
  800a1b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	01 d8                	add    %ebx,%eax
  800a23:	50                   	push   %eax
  800a24:	e8 ca ff ff ff       	call   8009f3 <strcpy>
	return dst;
}
  800a29:	89 d8                	mov    %ebx,%eax
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 08             	mov    0x8(%ebp),%esi
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a40:	89 f2                	mov    %esi,%edx
  800a42:	39 da                	cmp    %ebx,%edx
  800a44:	74 0e                	je     800a54 <strncpy+0x24>
		*dst++ = *src;
  800a46:	42                   	inc    %edx
  800a47:	8a 01                	mov    (%ecx),%al
  800a49:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a4c:	80 39 00             	cmpb   $0x0,(%ecx)
  800a4f:	74 f1                	je     800a42 <strncpy+0x12>
			src++;
  800a51:	41                   	inc    %ecx
  800a52:	eb ee                	jmp    800a42 <strncpy+0x12>
	}
	return ret;
}
  800a54:	89 f0                	mov    %esi,%eax
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	74 20                	je     800a8c <strlcpy+0x32>
  800a6c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a70:	89 f0                	mov    %esi,%eax
  800a72:	eb 05                	jmp    800a79 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a74:	42                   	inc    %edx
  800a75:	40                   	inc    %eax
  800a76:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a79:	39 d8                	cmp    %ebx,%eax
  800a7b:	74 06                	je     800a83 <strlcpy+0x29>
  800a7d:	8a 0a                	mov    (%edx),%cl
  800a7f:	84 c9                	test   %cl,%cl
  800a81:	75 f1                	jne    800a74 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a83:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
  800a8c:	89 f0                	mov    %esi,%eax
  800a8e:	eb f6                	jmp    800a86 <strlcpy+0x2c>

00800a90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a99:	eb 02                	jmp    800a9d <strcmp+0xd>
		p++, q++;
  800a9b:	41                   	inc    %ecx
  800a9c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9d:	8a 01                	mov    (%ecx),%al
  800a9f:	84 c0                	test   %al,%al
  800aa1:	74 04                	je     800aa7 <strcmp+0x17>
  800aa3:	3a 02                	cmp    (%edx),%al
  800aa5:	74 f4                	je     800a9b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	0f b6 c0             	movzbl %al,%eax
  800aaa:	0f b6 12             	movzbl (%edx),%edx
  800aad:	29 d0                	sub    %edx,%eax
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	53                   	push   %ebx
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abb:	89 c3                	mov    %eax,%ebx
  800abd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac0:	eb 02                	jmp    800ac4 <strncmp+0x13>
		n--, p++, q++;
  800ac2:	40                   	inc    %eax
  800ac3:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac4:	39 d8                	cmp    %ebx,%eax
  800ac6:	74 15                	je     800add <strncmp+0x2c>
  800ac8:	8a 08                	mov    (%eax),%cl
  800aca:	84 c9                	test   %cl,%cl
  800acc:	74 04                	je     800ad2 <strncmp+0x21>
  800ace:	3a 0a                	cmp    (%edx),%cl
  800ad0:	74 f0                	je     800ac2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad2:	0f b6 00             	movzbl (%eax),%eax
  800ad5:	0f b6 12             	movzbl (%edx),%edx
  800ad8:	29 d0                	sub    %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	eb f6                	jmp    800ada <strncmp+0x29>

00800ae4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aed:	8a 10                	mov    (%eax),%dl
  800aef:	84 d2                	test   %dl,%dl
  800af1:	74 07                	je     800afa <strchr+0x16>
		if (*s == c)
  800af3:	38 ca                	cmp    %cl,%dl
  800af5:	74 08                	je     800aff <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af7:	40                   	inc    %eax
  800af8:	eb f3                	jmp    800aed <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b0a:	8a 10                	mov    (%eax),%dl
  800b0c:	84 d2                	test   %dl,%dl
  800b0e:	74 07                	je     800b17 <strfind+0x16>
		if (*s == c)
  800b10:	38 ca                	cmp    %cl,%dl
  800b12:	74 03                	je     800b17 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b14:	40                   	inc    %eax
  800b15:	eb f3                	jmp    800b0a <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b25:	85 c9                	test   %ecx,%ecx
  800b27:	74 13                	je     800b3c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2f:	75 05                	jne    800b36 <memset+0x1d>
  800b31:	f6 c1 03             	test   $0x3,%cl
  800b34:	74 0d                	je     800b43 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	fc                   	cld    
  800b3a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3c:	89 f8                	mov    %edi,%eax
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b43:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	c1 e3 08             	shl    $0x8,%ebx
  800b4c:	89 d0                	mov    %edx,%eax
  800b4e:	c1 e0 18             	shl    $0x18,%eax
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	c1 e6 10             	shl    $0x10,%esi
  800b56:	09 f0                	or     %esi,%eax
  800b58:	09 c2                	or     %eax,%edx
  800b5a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	fc                   	cld    
  800b62:	f3 ab                	rep stos %eax,%es:(%edi)
  800b64:	eb d6                	jmp    800b3c <memset+0x23>

00800b66 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b74:	39 c6                	cmp    %eax,%esi
  800b76:	73 33                	jae    800bab <memmove+0x45>
  800b78:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b7b:	39 c2                	cmp    %eax,%edx
  800b7d:	76 2c                	jbe    800bab <memmove+0x45>
		s += n;
		d += n;
  800b7f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	09 fe                	or     %edi,%esi
  800b86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8c:	74 0a                	je     800b98 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8e:	4f                   	dec    %edi
  800b8f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b92:	fd                   	std    
  800b93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b95:	fc                   	cld    
  800b96:	eb 21                	jmp    800bb9 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b98:	f6 c1 03             	test   $0x3,%cl
  800b9b:	75 f1                	jne    800b8e <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9d:	83 ef 04             	sub    $0x4,%edi
  800ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb ea                	jmp    800b95 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bab:	89 f2                	mov    %esi,%edx
  800bad:	09 c2                	or     %eax,%edx
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	74 09                	je     800bbd <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	fc                   	cld    
  800bb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 f2                	jne    800bb4 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc5:	89 c7                	mov    %eax,%edi
  800bc7:	fc                   	cld    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb ed                	jmp    800bb9 <memmove+0x53>

00800bcc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcf:	ff 75 10             	pushl  0x10(%ebp)
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	ff 75 08             	pushl  0x8(%ebp)
  800bd8:	e8 89 ff ff ff       	call   800b66 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bea:	89 c6                	mov    %eax,%esi
  800bec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	39 f0                	cmp    %esi,%eax
  800bf1:	74 16                	je     800c09 <memcmp+0x2a>
		if (*s1 != *s2)
  800bf3:	8a 08                	mov    (%eax),%cl
  800bf5:	8a 1a                	mov    (%edx),%bl
  800bf7:	38 d9                	cmp    %bl,%cl
  800bf9:	75 04                	jne    800bff <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bfb:	40                   	inc    %eax
  800bfc:	42                   	inc    %edx
  800bfd:	eb f0                	jmp    800bef <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800bff:	0f b6 c1             	movzbl %cl,%eax
  800c02:	0f b6 db             	movzbl %bl,%ebx
  800c05:	29 d8                	sub    %ebx,%eax
  800c07:	eb 05                	jmp    800c0e <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c1b:	89 c2                	mov    %eax,%edx
  800c1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c20:	39 d0                	cmp    %edx,%eax
  800c22:	73 07                	jae    800c2b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	38 08                	cmp    %cl,(%eax)
  800c26:	74 03                	je     800c2b <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c28:	40                   	inc    %eax
  800c29:	eb f5                	jmp    800c20 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c36:	eb 01                	jmp    800c39 <strtol+0xc>
		s++;
  800c38:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c39:	8a 01                	mov    (%ecx),%al
  800c3b:	3c 20                	cmp    $0x20,%al
  800c3d:	74 f9                	je     800c38 <strtol+0xb>
  800c3f:	3c 09                	cmp    $0x9,%al
  800c41:	74 f5                	je     800c38 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c43:	3c 2b                	cmp    $0x2b,%al
  800c45:	74 2b                	je     800c72 <strtol+0x45>
		s++;
	else if (*s == '-')
  800c47:	3c 2d                	cmp    $0x2d,%al
  800c49:	74 2f                	je     800c7a <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c50:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c57:	75 12                	jne    800c6b <strtol+0x3e>
  800c59:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5c:	74 24                	je     800c82 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c62:	75 07                	jne    800c6b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c64:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	eb 4e                	jmp    800cc0 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c72:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c73:	bf 00 00 00 00       	mov    $0x0,%edi
  800c78:	eb d6                	jmp    800c50 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c7a:	41                   	inc    %ecx
  800c7b:	bf 01 00 00 00       	mov    $0x1,%edi
  800c80:	eb ce                	jmp    800c50 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c86:	74 10                	je     800c98 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c8c:	75 dd                	jne    800c6b <strtol+0x3e>
		s++, base = 8;
  800c8e:	41                   	inc    %ecx
  800c8f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c96:	eb d3                	jmp    800c6b <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800c98:	83 c1 02             	add    $0x2,%ecx
  800c9b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ca2:	eb c7                	jmp    800c6b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ca4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca7:	89 f3                	mov    %esi,%ebx
  800ca9:	80 fb 19             	cmp    $0x19,%bl
  800cac:	77 24                	ja     800cd2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cae:	0f be d2             	movsbl %dl,%edx
  800cb1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb4:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cb7:	7e 2b                	jle    800ce4 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cb9:	41                   	inc    %ecx
  800cba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbe:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc0:	8a 11                	mov    (%ecx),%dl
  800cc2:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800cc5:	80 fb 09             	cmp    $0x9,%bl
  800cc8:	77 da                	ja     800ca4 <strtol+0x77>
			dig = *s - '0';
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 30             	sub    $0x30,%edx
  800cd0:	eb e2                	jmp    800cb4 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 08                	ja     800ce4 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 37             	sub    $0x37,%edx
  800ce2:	eb d0                	jmp    800cb4 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce8:	74 05                	je     800cef <strtol+0xc2>
		*endptr = (char *) s;
  800cea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ced:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cef:	85 ff                	test   %edi,%edi
  800cf1:	74 02                	je     800cf5 <strtol+0xc8>
  800cf3:	f7 d8                	neg    %eax
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
	...

00800cfc <__udivdi3>:
  800cfc:	55                   	push   %ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 1c             	sub    $0x1c,%esp
  800d03:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d07:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d0b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d0f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d13:	85 d2                	test   %edx,%edx
  800d15:	75 2d                	jne    800d44 <__udivdi3+0x48>
  800d17:	39 f7                	cmp    %esi,%edi
  800d19:	77 59                	ja     800d74 <__udivdi3+0x78>
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	85 ff                	test   %edi,%edi
  800d1f:	75 0b                	jne    800d2c <__udivdi3+0x30>
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	f7 f7                	div    %edi
  800d2a:	89 c1                	mov    %eax,%ecx
  800d2c:	31 d2                	xor    %edx,%edx
  800d2e:	89 f0                	mov    %esi,%eax
  800d30:	f7 f1                	div    %ecx
  800d32:	89 c3                	mov    %eax,%ebx
  800d34:	89 e8                	mov    %ebp,%eax
  800d36:	f7 f1                	div    %ecx
  800d38:	89 da                	mov    %ebx,%edx
  800d3a:	83 c4 1c             	add    $0x1c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
  800d42:	66 90                	xchg   %ax,%ax
  800d44:	39 f2                	cmp    %esi,%edx
  800d46:	77 1c                	ja     800d64 <__udivdi3+0x68>
  800d48:	0f bd da             	bsr    %edx,%ebx
  800d4b:	83 f3 1f             	xor    $0x1f,%ebx
  800d4e:	75 38                	jne    800d88 <__udivdi3+0x8c>
  800d50:	39 f2                	cmp    %esi,%edx
  800d52:	72 08                	jb     800d5c <__udivdi3+0x60>
  800d54:	39 ef                	cmp    %ebp,%edi
  800d56:	0f 87 98 00 00 00    	ja     800df4 <__udivdi3+0xf8>
  800d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d61:	eb 05                	jmp    800d68 <__udivdi3+0x6c>
  800d63:	90                   	nop
  800d64:	31 db                	xor    %ebx,%ebx
  800d66:	31 c0                	xor    %eax,%eax
  800d68:	89 da                	mov    %ebx,%edx
  800d6a:	83 c4 1c             	add    $0x1c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
  800d72:	66 90                	xchg   %ax,%ax
  800d74:	89 e8                	mov    %ebp,%eax
  800d76:	89 f2                	mov    %esi,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	31 db                	xor    %ebx,%ebx
  800d7c:	89 da                	mov    %ebx,%edx
  800d7e:	83 c4 1c             	add    $0x1c,%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	b8 20 00 00 00       	mov    $0x20,%eax
  800d8d:	29 d8                	sub    %ebx,%eax
  800d8f:	88 d9                	mov    %bl,%cl
  800d91:	d3 e2                	shl    %cl,%edx
  800d93:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d97:	89 fa                	mov    %edi,%edx
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da1:	09 d1                	or     %edx,%ecx
  800da3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800da7:	88 d9                	mov    %bl,%cl
  800da9:	d3 e7                	shl    %cl,%edi
  800dab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800daf:	89 f7                	mov    %esi,%edi
  800db1:	88 c1                	mov    %al,%cl
  800db3:	d3 ef                	shr    %cl,%edi
  800db5:	88 d9                	mov    %bl,%cl
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	89 ea                	mov    %ebp,%edx
  800dbb:	88 c1                	mov    %al,%cl
  800dbd:	d3 ea                	shr    %cl,%edx
  800dbf:	09 d6                	or     %edx,%esi
  800dc1:	89 f0                	mov    %esi,%eax
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	f7 74 24 08          	divl   0x8(%esp)
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 c6                	mov    %eax,%esi
  800dcd:	f7 64 24 0c          	mull   0xc(%esp)
  800dd1:	39 d7                	cmp    %edx,%edi
  800dd3:	72 13                	jb     800de8 <__udivdi3+0xec>
  800dd5:	74 09                	je     800de0 <__udivdi3+0xe4>
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	31 db                	xor    %ebx,%ebx
  800ddb:	eb 8b                	jmp    800d68 <__udivdi3+0x6c>
  800ddd:	8d 76 00             	lea    0x0(%esi),%esi
  800de0:	88 d9                	mov    %bl,%cl
  800de2:	d3 e5                	shl    %cl,%ebp
  800de4:	39 c5                	cmp    %eax,%ebp
  800de6:	73 ef                	jae    800dd7 <__udivdi3+0xdb>
  800de8:	8d 46 ff             	lea    -0x1(%esi),%eax
  800deb:	31 db                	xor    %ebx,%ebx
  800ded:	e9 76 ff ff ff       	jmp    800d68 <__udivdi3+0x6c>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	31 c0                	xor    %eax,%eax
  800df6:	e9 6d ff ff ff       	jmp    800d68 <__udivdi3+0x6c>
	...

00800dfc <__umoddi3>:
  800dfc:	55                   	push   %ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 1c             	sub    $0x1c,%esp
  800e03:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e07:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e0b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e0f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e13:	89 f0                	mov    %esi,%eax
  800e15:	89 da                	mov    %ebx,%edx
  800e17:	85 ed                	test   %ebp,%ebp
  800e19:	75 15                	jne    800e30 <__umoddi3+0x34>
  800e1b:	39 df                	cmp    %ebx,%edi
  800e1d:	76 39                	jbe    800e58 <__umoddi3+0x5c>
  800e1f:	f7 f7                	div    %edi
  800e21:	89 d0                	mov    %edx,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	83 c4 1c             	add    $0x1c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	39 dd                	cmp    %ebx,%ebp
  800e32:	77 f1                	ja     800e25 <__umoddi3+0x29>
  800e34:	0f bd cd             	bsr    %ebp,%ecx
  800e37:	83 f1 1f             	xor    $0x1f,%ecx
  800e3a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e3e:	75 38                	jne    800e78 <__umoddi3+0x7c>
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 04                	jb     800e48 <__umoddi3+0x4c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	77 dd                	ja     800e25 <__umoddi3+0x29>
  800e48:	89 da                	mov    %ebx,%edx
  800e4a:	89 f0                	mov    %esi,%eax
  800e4c:	29 f8                	sub    %edi,%eax
  800e4e:	19 ea                	sbb    %ebp,%edx
  800e50:	83 c4 1c             	add    $0x1c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
  800e58:	89 f9                	mov    %edi,%ecx
  800e5a:	85 ff                	test   %edi,%edi
  800e5c:	75 0b                	jne    800e69 <__umoddi3+0x6d>
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 f7                	div    %edi
  800e67:	89 c1                	mov    %eax,%ecx
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 f0                	mov    %esi,%eax
  800e71:	f7 f1                	div    %ecx
  800e73:	eb ac                	jmp    800e21 <__umoddi3+0x25>
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e83:	29 c2                	sub    %eax,%edx
  800e85:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e89:	88 c1                	mov    %al,%cl
  800e8b:	d3 e5                	shl    %cl,%ebp
  800e8d:	89 f8                	mov    %edi,%eax
  800e8f:	88 d1                	mov    %dl,%cl
  800e91:	d3 e8                	shr    %cl,%eax
  800e93:	09 c5                	or     %eax,%ebp
  800e95:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e99:	88 c1                	mov    %al,%cl
  800e9b:	d3 e7                	shl    %cl,%edi
  800e9d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea1:	89 df                	mov    %ebx,%edi
  800ea3:	88 d1                	mov    %dl,%cl
  800ea5:	d3 ef                	shr    %cl,%edi
  800ea7:	88 c1                	mov    %al,%cl
  800ea9:	d3 e3                	shl    %cl,%ebx
  800eab:	89 f0                	mov    %esi,%eax
  800ead:	88 d1                	mov    %dl,%cl
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	09 d8                	or     %ebx,%eax
  800eb3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800eb7:	d3 e6                	shl    %cl,%esi
  800eb9:	89 fa                	mov    %edi,%edx
  800ebb:	f7 f5                	div    %ebp
  800ebd:	89 d1                	mov    %edx,%ecx
  800ebf:	f7 64 24 08          	mull   0x8(%esp)
  800ec3:	89 c3                	mov    %eax,%ebx
  800ec5:	89 d7                	mov    %edx,%edi
  800ec7:	39 d1                	cmp    %edx,%ecx
  800ec9:	72 29                	jb     800ef4 <__umoddi3+0xf8>
  800ecb:	74 23                	je     800ef0 <__umoddi3+0xf4>
  800ecd:	89 ca                	mov    %ecx,%edx
  800ecf:	29 de                	sub    %ebx,%esi
  800ed1:	19 fa                	sbb    %edi,%edx
  800ed3:	89 d0                	mov    %edx,%eax
  800ed5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ed9:	d3 e0                	shl    %cl,%eax
  800edb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800edf:	88 d9                	mov    %bl,%cl
  800ee1:	d3 ee                	shr    %cl,%esi
  800ee3:	09 f0                	or     %esi,%eax
  800ee5:	d3 ea                	shr    %cl,%edx
  800ee7:	83 c4 1c             	add    $0x1c,%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    
  800eef:	90                   	nop
  800ef0:	39 c6                	cmp    %eax,%esi
  800ef2:	73 d9                	jae    800ecd <__umoddi3+0xd1>
  800ef4:	2b 44 24 08          	sub    0x8(%esp),%eax
  800ef8:	19 ea                	sbb    %ebp,%edx
  800efa:	89 d7                	mov    %edx,%edi
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	eb cd                	jmp    800ecd <__umoddi3+0xd1>
