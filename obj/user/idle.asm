
obj/user/idle:     file format elf32-i386


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
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 20 	movl   $0x800f20,0x802000
  800041:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 00 01 00 00       	call   800149 <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
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
  800061:	89 c2                	mov    %eax,%edx
  800063:	c1 e2 05             	shl    $0x5,%edx
  800066:	29 c2                	sub    %eax,%edx
  800068:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x33>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 ab ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

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
  800119:	68 2f 0f 80 00       	push   $0x800f2f
  80011e:	6a 23                	push   $0x23
  800120:	68 4c 0f 80 00       	push   $0x800f4c
  800125:	e8 ee 01 00 00       	call   800318 <_panic>

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

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 2f 0f 80 00       	push   $0x800f2f
  80019f:	6a 23                	push   $0x23
  8001a1:	68 4c 0f 80 00       	push   $0x800f4c
  8001a6:	e8 6d 01 00 00       	call   800318 <_panic>

008001ab <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 2f 0f 80 00       	push   $0x800f2f
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 4c 0f 80 00       	push   $0x800f4c
  8001e8:	e8 2b 01 00 00       	call   800318 <_panic>

008001ed <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 2f 0f 80 00       	push   $0x800f2f
  800223:	6a 23                	push   $0x23
  800225:	68 4c 0f 80 00       	push   $0x800f4c
  80022a:	e8 e9 00 00 00       	call   800318 <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 2f 0f 80 00       	push   $0x800f2f
  800265:	6a 23                	push   $0x23
  800267:	68 4c 0f 80 00       	push   $0x800f4c
  80026c:	e8 a7 00 00 00       	call   800318 <_panic>

00800271 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 2f 0f 80 00       	push   $0x800f2f
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 4c 0f 80 00       	push   $0x800f4c
  8002ae:	e8 65 00 00 00       	call   800318 <_panic>

008002b3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 2f 0f 80 00       	push   $0x800f2f
  80030b:	6a 23                	push   $0x23
  80030d:	68 4c 0f 80 00       	push   $0x800f4c
  800312:	e8 01 00 00 00       	call   800318 <_panic>
	...

00800318 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80031d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800320:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800326:	e8 ff fd ff ff       	call   80012a <sys_getenvid>
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	56                   	push   %esi
  800335:	50                   	push   %eax
  800336:	68 5c 0f 80 00       	push   $0x800f5c
  80033b:	e8 b4 00 00 00       	call   8003f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800340:	83 c4 18             	add    $0x18,%esp
  800343:	53                   	push   %ebx
  800344:	ff 75 10             	pushl  0x10(%ebp)
  800347:	e8 57 00 00 00       	call   8003a3 <vcprintf>
	cprintf("\n");
  80034c:	c7 04 24 80 0f 80 00 	movl   $0x800f80,(%esp)
  800353:	e8 9c 00 00 00       	call   8003f4 <cprintf>
  800358:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035b:	cc                   	int3   
  80035c:	eb fd                	jmp    80035b <_panic+0x43>
	...

00800360 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	53                   	push   %ebx
  800364:	83 ec 04             	sub    $0x4,%esp
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036a:	8b 13                	mov    (%ebx),%edx
  80036c:	8d 42 01             	lea    0x1(%edx),%eax
  80036f:	89 03                	mov    %eax,(%ebx)
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800378:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037d:	74 08                	je     800387 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80037f:	ff 43 04             	incl   0x4(%ebx)
}
  800382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800385:	c9                   	leave  
  800386:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	68 ff 00 00 00       	push   $0xff
  80038f:	8d 43 08             	lea    0x8(%ebx),%eax
  800392:	50                   	push   %eax
  800393:	e8 14 fd ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800398:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	eb dc                	jmp    80037f <putch+0x1f>

008003a3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b3:	00 00 00 
	b.cnt = 0;
  8003b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c0:	ff 75 0c             	pushl  0xc(%ebp)
  8003c3:	ff 75 08             	pushl  0x8(%ebp)
  8003c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	68 60 03 80 00       	push   $0x800360
  8003d2:	e8 17 01 00 00       	call   8004ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d7:	83 c4 08             	add    $0x8,%esp
  8003da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e6:	50                   	push   %eax
  8003e7:	e8 c0 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8003ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 9d ff ff ff       	call   8003a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
  80040e:	83 ec 1c             	sub    $0x1c,%esp
  800411:	89 c7                	mov    %eax,%edi
  800413:	89 d6                	mov    %edx,%esi
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800421:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800424:	bb 00 00 00 00       	mov    $0x0,%ebx
  800429:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042f:	39 d3                	cmp    %edx,%ebx
  800431:	72 05                	jb     800438 <printnum+0x30>
  800433:	39 45 10             	cmp    %eax,0x10(%ebp)
  800436:	77 78                	ja     8004b0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800438:	83 ec 0c             	sub    $0xc,%esp
  80043b:	ff 75 18             	pushl  0x18(%ebp)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800444:	53                   	push   %ebx
  800445:	ff 75 10             	pushl  0x10(%ebp)
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff 75 dc             	pushl  -0x24(%ebp)
  800454:	ff 75 d8             	pushl  -0x28(%ebp)
  800457:	e8 a8 08 00 00       	call   800d04 <__udivdi3>
  80045c:	83 c4 18             	add    $0x18,%esp
  80045f:	52                   	push   %edx
  800460:	50                   	push   %eax
  800461:	89 f2                	mov    %esi,%edx
  800463:	89 f8                	mov    %edi,%eax
  800465:	e8 9e ff ff ff       	call   800408 <printnum>
  80046a:	83 c4 20             	add    $0x20,%esp
  80046d:	eb 11                	jmp    800480 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	56                   	push   %esi
  800473:	ff 75 18             	pushl  0x18(%ebp)
  800476:	ff d7                	call   *%edi
  800478:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047b:	4b                   	dec    %ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f ef                	jg     80046f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff 75 dc             	pushl  -0x24(%ebp)
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	e8 6c 09 00 00       	call   800e04 <__umoddi3>
  800498:	83 c4 14             	add    $0x14,%esp
  80049b:	0f be 80 82 0f 80 00 	movsbl 0x800f82(%eax),%eax
  8004a2:	50                   	push   %eax
  8004a3:	ff d7                	call   *%edi
}
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    
  8004b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b3:	eb c6                	jmp    80047b <printnum+0x73>

008004b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c3:	73 0a                	jae    8004cf <sprintputch+0x1a>
		*b->buf++ = ch;
  8004c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cd:	88 02                	mov    %al,(%edx)
}
  8004cf:	5d                   	pop    %ebp
  8004d0:	c3                   	ret    

008004d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004da:	50                   	push   %eax
  8004db:	ff 75 10             	pushl  0x10(%ebp)
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	ff 75 08             	pushl  0x8(%ebp)
  8004e4:	e8 05 00 00 00       	call   8004ee <vprintfmt>
	va_end(ap);
}
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 2c             	sub    $0x2c,%esp
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800500:	e9 ac 03 00 00       	jmp    8008b1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800505:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800509:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800510:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800517:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8d 47 01             	lea    0x1(%edi),%eax
  800526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800529:	8a 17                	mov    (%edi),%dl
  80052b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052e:	3c 55                	cmp    $0x55,%al
  800530:	0f 87 fc 03 00 00    	ja     800932 <vprintfmt+0x444>
  800536:	0f b6 c0             	movzbl %al,%eax
  800539:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800543:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800547:	eb da                	jmp    800523 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80054c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800550:	eb d1                	jmp    800523 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	0f b6 d2             	movzbl %dl,%edx
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800558:	b8 00 00 00 00       	mov    $0x0,%eax
  80055d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800560:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800563:	01 c0                	add    %eax,%eax
  800565:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800569:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056f:	83 f9 09             	cmp    $0x9,%ecx
  800572:	77 52                	ja     8005c6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800574:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800575:	eb e9                	jmp    800560 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 40 04             	lea    0x4(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80058b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058f:	79 92                	jns    800523 <vprintfmt+0x35>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	eb 83                	jmp    800523 <vprintfmt+0x35>
  8005a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a4:	78 08                	js     8005ae <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 75 ff ff ff       	jmp    800523 <vprintfmt+0x35>
  8005ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005b5:	eb ef                	jmp    8005a6 <vprintfmt+0xb8>
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c1:	e9 5d ff ff ff       	jmp    800523 <vprintfmt+0x35>
  8005c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005cc:	eb bd                	jmp    80058b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ce:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d2:	e9 4c ff ff ff       	jmp    800523 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 78 04             	lea    0x4(%eax),%edi
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 30                	pushl  (%eax)
  8005e3:	ff d6                	call   *%esi
			break;
  8005e5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005eb:	e9 be 02 00 00       	jmp    8008ae <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 78 04             	lea    0x4(%eax),%edi
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	78 2a                	js     800626 <vprintfmt+0x138>
  8005fc:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fe:	83 f8 08             	cmp    $0x8,%eax
  800601:	7f 27                	jg     80062a <vprintfmt+0x13c>
  800603:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80060a:	85 c0                	test   %eax,%eax
  80060c:	74 1c                	je     80062a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80060e:	50                   	push   %eax
  80060f:	68 a3 0f 80 00       	push   $0x800fa3
  800614:	53                   	push   %ebx
  800615:	56                   	push   %esi
  800616:	e8 b6 fe ff ff       	call   8004d1 <printfmt>
  80061b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800621:	e9 88 02 00 00       	jmp    8008ae <vprintfmt+0x3c0>
  800626:	f7 d8                	neg    %eax
  800628:	eb d2                	jmp    8005fc <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062a:	52                   	push   %edx
  80062b:	68 9a 0f 80 00       	push   $0x800f9a
  800630:	53                   	push   %ebx
  800631:	56                   	push   %esi
  800632:	e8 9a fe ff ff       	call   8004d1 <printfmt>
  800637:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063d:	e9 6c 02 00 00       	jmp    8008ae <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	83 c0 04             	add    $0x4,%eax
  800648:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 38                	mov    (%eax),%edi
  800650:	85 ff                	test   %edi,%edi
  800652:	74 18                	je     80066c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800658:	0f 8e b7 00 00 00    	jle    800715 <vprintfmt+0x227>
  80065e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800662:	75 0f                	jne    800673 <vprintfmt+0x185>
  800664:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800667:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80066a:	eb 75                	jmp    8006e1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80066c:	bf 93 0f 80 00       	mov    $0x800f93,%edi
  800671:	eb e1                	jmp    800654 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	ff 75 d0             	pushl  -0x30(%ebp)
  800679:	57                   	push   %edi
  80067a:	e8 5f 03 00 00       	call   8009de <strnlen>
  80067f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800682:	29 c1                	sub    %eax,%ecx
  800684:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800687:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800691:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800694:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800696:	eb 0d                	jmp    8006a5 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	ff 75 e0             	pushl  -0x20(%ebp)
  80069f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	4f                   	dec    %edi
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	7f ef                	jg     800698 <vprintfmt+0x1aa>
  8006a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006af:	89 c8                	mov    %ecx,%eax
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	78 10                	js     8006c5 <vprintfmt+0x1d7>
  8006b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b8:	29 c1                	sub    %eax,%ecx
  8006ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c3:	eb 1c                	jmp    8006e1 <vprintfmt+0x1f3>
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb e9                	jmp    8006b5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d0:	75 29                	jne    8006fb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	50                   	push   %eax
  8006d9:	ff d6                	call   *%esi
  8006db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006de:	ff 4d e0             	decl   -0x20(%ebp)
  8006e1:	47                   	inc    %edi
  8006e2:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006e5:	0f be c2             	movsbl %dl,%eax
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 4c                	je     800738 <vprintfmt+0x24a>
  8006ec:	85 db                	test   %ebx,%ebx
  8006ee:	78 dc                	js     8006cc <vprintfmt+0x1de>
  8006f0:	4b                   	dec    %ebx
  8006f1:	79 d9                	jns    8006cc <vprintfmt+0x1de>
  8006f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006f9:	eb 2e                	jmp    800729 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fb:	0f be d2             	movsbl %dl,%edx
  8006fe:	83 ea 20             	sub    $0x20,%edx
  800701:	83 fa 5e             	cmp    $0x5e,%edx
  800704:	76 cc                	jbe    8006d2 <vprintfmt+0x1e4>
					putch('?', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	ff 75 0c             	pushl  0xc(%ebp)
  80070c:	6a 3f                	push   $0x3f
  80070e:	ff d6                	call   *%esi
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb c9                	jmp    8006de <vprintfmt+0x1f0>
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071b:	eb c4                	jmp    8006e1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	6a 20                	push   $0x20
  800723:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800725:	4f                   	dec    %edi
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	85 ff                	test   %edi,%edi
  80072b:	7f f0                	jg     80071d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80072d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
  800733:	e9 76 01 00 00       	jmp    8008ae <vprintfmt+0x3c0>
  800738:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80073b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073e:	eb e9                	jmp    800729 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800740:	83 f9 01             	cmp    $0x1,%ecx
  800743:	7e 3f                	jle    800784 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 50 04             	mov    0x4(%eax),%edx
  80074b:	8b 00                	mov    (%eax),%eax
  80074d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800750:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 40 08             	lea    0x8(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80075c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800760:	79 5c                	jns    8007be <vprintfmt+0x2d0>
				putch('-', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 2d                	push   $0x2d
  800768:	ff d6                	call   *%esi
				num = -(long long) num;
  80076a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800770:	f7 da                	neg    %edx
  800772:	83 d1 00             	adc    $0x0,%ecx
  800775:	f7 d9                	neg    %ecx
  800777:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 10 01 00 00       	jmp    800894 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	75 1b                	jne    8007a3 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 c1                	mov    %eax,%ecx
  800792:	c1 f9 1f             	sar    $0x1f,%ecx
  800795:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a1:	eb b9                	jmp    80075c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 c1                	mov    %eax,%ecx
  8007ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bc:	eb 9e                	jmp    80075c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c9:	e9 c6 00 00 00       	jmp    800894 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ce:	83 f9 01             	cmp    $0x1,%ecx
  8007d1:	7e 18                	jle    8007eb <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007db:	8d 40 08             	lea    0x8(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e6:	e9 a9 00 00 00       	jmp    800894 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	75 1a                	jne    800809 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800804:	e9 8b 00 00 00       	jmp    800894 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800813:	8d 40 04             	lea    0x4(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800819:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081e:	eb 74                	jmp    800894 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800820:	83 f9 01             	cmp    $0x1,%ecx
  800823:	7e 15                	jle    80083a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	8b 48 04             	mov    0x4(%eax),%ecx
  80082d:	8d 40 08             	lea    0x8(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800833:	b8 08 00 00 00       	mov    $0x8,%eax
  800838:	eb 5a                	jmp    800894 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	75 17                	jne    800855 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80084e:	b8 08 00 00 00       	mov    $0x8,%eax
  800853:	eb 3f                	jmp    800894 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8b 10                	mov    (%eax),%edx
  80085a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085f:	8d 40 04             	lea    0x4(%eax),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800865:	b8 08 00 00 00       	mov    $0x8,%eax
  80086a:	eb 28                	jmp    800894 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 30                	push   $0x30
  800872:	ff d6                	call   *%esi
			putch('x', putdat);
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	6a 78                	push   $0x78
  80087a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800889:	8d 40 04             	lea    0x4(%eax),%eax
  80088c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800894:	83 ec 0c             	sub    $0xc,%esp
  800897:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089b:	57                   	push   %edi
  80089c:	ff 75 e0             	pushl  -0x20(%ebp)
  80089f:	50                   	push   %eax
  8008a0:	51                   	push   %ecx
  8008a1:	52                   	push   %edx
  8008a2:	89 da                	mov    %ebx,%edx
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	e8 5d fb ff ff       	call   800408 <printnum>
			break;
  8008ab:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b1:	47                   	inc    %edi
  8008b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b6:	83 f8 25             	cmp    $0x25,%eax
  8008b9:	0f 84 46 fc ff ff    	je     800505 <vprintfmt+0x17>
			if (ch == '\0')
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	0f 84 89 00 00 00    	je     800950 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	50                   	push   %eax
  8008cc:	ff d6                	call   *%esi
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	eb de                	jmp    8008b1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d3:	83 f9 01             	cmp    $0x1,%ecx
  8008d6:	7e 15                	jle    8008ed <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8b 10                	mov    (%eax),%edx
  8008dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e0:	8d 40 08             	lea    0x8(%eax),%eax
  8008e3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008e6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008eb:	eb a7                	jmp    800894 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	75 17                	jne    800908 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f4:	8b 10                	mov    (%eax),%edx
  8008f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fb:	8d 40 04             	lea    0x4(%eax),%eax
  8008fe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800901:	b8 10 00 00 00       	mov    $0x10,%eax
  800906:	eb 8c                	jmp    800894 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8b 10                	mov    (%eax),%edx
  80090d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800912:	8d 40 04             	lea    0x4(%eax),%eax
  800915:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800918:	b8 10 00 00 00       	mov    $0x10,%eax
  80091d:	e9 72 ff ff ff       	jmp    800894 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800922:	83 ec 08             	sub    $0x8,%esp
  800925:	53                   	push   %ebx
  800926:	6a 25                	push   $0x25
  800928:	ff d6                	call   *%esi
			break;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	e9 7c ff ff ff       	jmp    8008ae <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	53                   	push   %ebx
  800936:	6a 25                	push   $0x25
  800938:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	eb 01                	jmp    800942 <vprintfmt+0x454>
  800941:	48                   	dec    %eax
  800942:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800946:	75 f9                	jne    800941 <vprintfmt+0x453>
  800948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094b:	e9 5e ff ff ff       	jmp    8008ae <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800950:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 18             	sub    $0x18,%esp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800964:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800967:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80096e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800975:	85 c0                	test   %eax,%eax
  800977:	74 26                	je     80099f <vsnprintf+0x47>
  800979:	85 d2                	test   %edx,%edx
  80097b:	7e 29                	jle    8009a6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80097d:	ff 75 14             	pushl  0x14(%ebp)
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800986:	50                   	push   %eax
  800987:	68 b5 04 80 00       	push   $0x8004b5
  80098c:	e8 5d fb ff ff       	call   8004ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800991:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800994:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099a:	83 c4 10             	add    $0x10,%esp
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80099f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a4:	eb f7                	jmp    80099d <vsnprintf+0x45>
  8009a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ab:	eb f0                	jmp    80099d <vsnprintf+0x45>

008009ad <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b6:	50                   	push   %eax
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 93 ff ff ff       	call   800958 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    
	...

008009c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb 01                	jmp    8009d6 <strlen+0xe>
		n++;
  8009d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009da:	75 f9                	jne    8009d5 <strlen+0xd>
		n++;
	return n;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	eb 01                	jmp    8009ef <strnlen+0x11>
		n++;
  8009ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	74 06                	je     8009f9 <strnlen+0x1b>
  8009f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f7:	75 f5                	jne    8009ee <strnlen+0x10>
		n++;
	return n;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	41                   	inc    %ecx
  800a08:	42                   	inc    %edx
  800a09:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a0c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a0f:	84 db                	test   %bl,%bl
  800a11:	75 f4                	jne    800a07 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a13:	5b                   	pop    %ebx
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a1d:	53                   	push   %ebx
  800a1e:	e8 a5 ff ff ff       	call   8009c8 <strlen>
  800a23:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a26:	ff 75 0c             	pushl  0xc(%ebp)
  800a29:	01 d8                	add    %ebx,%eax
  800a2b:	50                   	push   %eax
  800a2c:	e8 ca ff ff ff       	call   8009fb <strcpy>
	return dst;
}
  800a31:	89 d8                	mov    %ebx,%eax
  800a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a48:	89 f2                	mov    %esi,%edx
  800a4a:	39 da                	cmp    %ebx,%edx
  800a4c:	74 0e                	je     800a5c <strncpy+0x24>
		*dst++ = *src;
  800a4e:	42                   	inc    %edx
  800a4f:	8a 01                	mov    (%ecx),%al
  800a51:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a54:	80 39 00             	cmpb   $0x0,(%ecx)
  800a57:	74 f1                	je     800a4a <strncpy+0x12>
			src++;
  800a59:	41                   	inc    %ecx
  800a5a:	eb ee                	jmp    800a4a <strncpy+0x12>
	}
	return ret;
}
  800a5c:	89 f0                	mov    %esi,%eax
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a70:	85 c0                	test   %eax,%eax
  800a72:	74 20                	je     800a94 <strlcpy+0x32>
  800a74:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a78:	89 f0                	mov    %esi,%eax
  800a7a:	eb 05                	jmp    800a81 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7c:	42                   	inc    %edx
  800a7d:	40                   	inc    %eax
  800a7e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a81:	39 d8                	cmp    %ebx,%eax
  800a83:	74 06                	je     800a8b <strlcpy+0x29>
  800a85:	8a 0a                	mov    (%edx),%cl
  800a87:	84 c9                	test   %cl,%cl
  800a89:	75 f1                	jne    800a7c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a8b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a8e:	29 f0                	sub    %esi,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	eb f6                	jmp    800a8e <strlcpy+0x2c>

00800a98 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa1:	eb 02                	jmp    800aa5 <strcmp+0xd>
		p++, q++;
  800aa3:	41                   	inc    %ecx
  800aa4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa5:	8a 01                	mov    (%ecx),%al
  800aa7:	84 c0                	test   %al,%al
  800aa9:	74 04                	je     800aaf <strcmp+0x17>
  800aab:	3a 02                	cmp    (%edx),%al
  800aad:	74 f4                	je     800aa3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaf:	0f b6 c0             	movzbl %al,%eax
  800ab2:	0f b6 12             	movzbl (%edx),%edx
  800ab5:	29 d0                	sub    %edx,%eax
}
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	53                   	push   %ebx
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac8:	eb 02                	jmp    800acc <strncmp+0x13>
		n--, p++, q++;
  800aca:	40                   	inc    %eax
  800acb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800acc:	39 d8                	cmp    %ebx,%eax
  800ace:	74 15                	je     800ae5 <strncmp+0x2c>
  800ad0:	8a 08                	mov    (%eax),%cl
  800ad2:	84 c9                	test   %cl,%cl
  800ad4:	74 04                	je     800ada <strncmp+0x21>
  800ad6:	3a 0a                	cmp    (%edx),%cl
  800ad8:	74 f0                	je     800aca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ada:	0f b6 00             	movzbl (%eax),%eax
  800add:	0f b6 12             	movzbl (%edx),%edx
  800ae0:	29 d0                	sub    %edx,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	eb f6                	jmp    800ae2 <strncmp+0x29>

00800aec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800af5:	8a 10                	mov    (%eax),%dl
  800af7:	84 d2                	test   %dl,%dl
  800af9:	74 07                	je     800b02 <strchr+0x16>
		if (*s == c)
  800afb:	38 ca                	cmp    %cl,%dl
  800afd:	74 08                	je     800b07 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aff:	40                   	inc    %eax
  800b00:	eb f3                	jmp    800af5 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b12:	8a 10                	mov    (%eax),%dl
  800b14:	84 d2                	test   %dl,%dl
  800b16:	74 07                	je     800b1f <strfind+0x16>
		if (*s == c)
  800b18:	38 ca                	cmp    %cl,%dl
  800b1a:	74 03                	je     800b1f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1c:	40                   	inc    %eax
  800b1d:	eb f3                	jmp    800b12 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2d:	85 c9                	test   %ecx,%ecx
  800b2f:	74 13                	je     800b44 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b37:	75 05                	jne    800b3e <memset+0x1d>
  800b39:	f6 c1 03             	test   $0x3,%cl
  800b3c:	74 0d                	je     800b4b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	c1 e3 08             	shl    $0x8,%ebx
  800b54:	89 d0                	mov    %edx,%eax
  800b56:	c1 e0 18             	shl    $0x18,%eax
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	c1 e6 10             	shl    $0x10,%esi
  800b5e:	09 f0                	or     %esi,%eax
  800b60:	09 c2                	or     %eax,%edx
  800b62:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b64:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	fc                   	cld    
  800b6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b6c:	eb d6                	jmp    800b44 <memset+0x23>

00800b6e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7c:	39 c6                	cmp    %eax,%esi
  800b7e:	73 33                	jae    800bb3 <memmove+0x45>
  800b80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b83:	39 c2                	cmp    %eax,%edx
  800b85:	76 2c                	jbe    800bb3 <memmove+0x45>
		s += n;
		d += n;
  800b87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	09 fe                	or     %edi,%esi
  800b8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b94:	74 0a                	je     800ba0 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b96:	4f                   	dec    %edi
  800b97:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9a:	fd                   	std    
  800b9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9d:	fc                   	cld    
  800b9e:	eb 21                	jmp    800bc1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba0:	f6 c1 03             	test   $0x3,%cl
  800ba3:	75 f1                	jne    800b96 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba5:	83 ef 04             	sub    $0x4,%edi
  800ba8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bab:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bae:	fd                   	std    
  800baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb1:	eb ea                	jmp    800b9d <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb3:	89 f2                	mov    %esi,%edx
  800bb5:	09 c2                	or     %eax,%edx
  800bb7:	f6 c2 03             	test   $0x3,%dl
  800bba:	74 09                	je     800bc5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbc:	89 c7                	mov    %eax,%edi
  800bbe:	fc                   	cld    
  800bbf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc5:	f6 c1 03             	test   $0x3,%cl
  800bc8:	75 f2                	jne    800bbc <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	fc                   	cld    
  800bd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd2:	eb ed                	jmp    800bc1 <memmove+0x53>

00800bd4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd7:	ff 75 10             	pushl  0x10(%ebp)
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	ff 75 08             	pushl  0x8(%ebp)
  800be0:	e8 89 ff ff ff       	call   800b6e <memmove>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf2:	89 c6                	mov    %eax,%esi
  800bf4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	39 f0                	cmp    %esi,%eax
  800bf9:	74 16                	je     800c11 <memcmp+0x2a>
		if (*s1 != *s2)
  800bfb:	8a 08                	mov    (%eax),%cl
  800bfd:	8a 1a                	mov    (%edx),%bl
  800bff:	38 d9                	cmp    %bl,%cl
  800c01:	75 04                	jne    800c07 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c03:	40                   	inc    %eax
  800c04:	42                   	inc    %edx
  800c05:	eb f0                	jmp    800bf7 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800c07:	0f b6 c1             	movzbl %cl,%eax
  800c0a:	0f b6 db             	movzbl %bl,%ebx
  800c0d:	29 d8                	sub    %ebx,%eax
  800c0f:	eb 05                	jmp    800c16 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c28:	39 d0                	cmp    %edx,%eax
  800c2a:	73 07                	jae    800c33 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2c:	38 08                	cmp    %cl,(%eax)
  800c2e:	74 03                	je     800c33 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c30:	40                   	inc    %eax
  800c31:	eb f5                	jmp    800c28 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3e:	eb 01                	jmp    800c41 <strtol+0xc>
		s++;
  800c40:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c41:	8a 01                	mov    (%ecx),%al
  800c43:	3c 20                	cmp    $0x20,%al
  800c45:	74 f9                	je     800c40 <strtol+0xb>
  800c47:	3c 09                	cmp    $0x9,%al
  800c49:	74 f5                	je     800c40 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4b:	3c 2b                	cmp    $0x2b,%al
  800c4d:	74 2b                	je     800c7a <strtol+0x45>
		s++;
	else if (*s == '-')
  800c4f:	3c 2d                	cmp    $0x2d,%al
  800c51:	74 2f                	je     800c82 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c58:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c5f:	75 12                	jne    800c73 <strtol+0x3e>
  800c61:	80 39 30             	cmpb   $0x30,(%ecx)
  800c64:	74 24                	je     800c8a <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c6a:	75 07                	jne    800c73 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	eb 4e                	jmp    800cc8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c7a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb d6                	jmp    800c58 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c82:	41                   	inc    %ecx
  800c83:	bf 01 00 00 00       	mov    $0x1,%edi
  800c88:	eb ce                	jmp    800c58 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8e:	74 10                	je     800ca0 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c94:	75 dd                	jne    800c73 <strtol+0x3e>
		s++, base = 8;
  800c96:	41                   	inc    %ecx
  800c97:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c9e:	eb d3                	jmp    800c73 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ca0:	83 c1 02             	add    $0x2,%ecx
  800ca3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800caa:	eb c7                	jmp    800c73 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 19             	cmp    $0x19,%bl
  800cb4:	77 24                	ja     800cda <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cbc:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cbf:	7e 2b                	jle    800cec <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cc1:	41                   	inc    %ecx
  800cc2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc8:	8a 11                	mov    (%ecx),%dl
  800cca:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ccd:	80 fb 09             	cmp    $0x9,%bl
  800cd0:	77 da                	ja     800cac <strtol+0x77>
			dig = *s - '0';
  800cd2:	0f be d2             	movsbl %dl,%edx
  800cd5:	83 ea 30             	sub    $0x30,%edx
  800cd8:	eb e2                	jmp    800cbc <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	80 fb 19             	cmp    $0x19,%bl
  800ce2:	77 08                	ja     800cec <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ce4:	0f be d2             	movsbl %dl,%edx
  800ce7:	83 ea 37             	sub    $0x37,%edx
  800cea:	eb d0                	jmp    800cbc <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf0:	74 05                	je     800cf7 <strtol+0xc2>
		*endptr = (char *) s;
  800cf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cf7:	85 ff                	test   %edi,%edi
  800cf9:	74 02                	je     800cfd <strtol+0xc8>
  800cfb:	f7 d8                	neg    %eax
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
	...

00800d04 <__udivdi3>:
  800d04:	55                   	push   %ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 1c             	sub    $0x1c,%esp
  800d0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d1b:	85 d2                	test   %edx,%edx
  800d1d:	75 2d                	jne    800d4c <__udivdi3+0x48>
  800d1f:	39 f7                	cmp    %esi,%edi
  800d21:	77 59                	ja     800d7c <__udivdi3+0x78>
  800d23:	89 f9                	mov    %edi,%ecx
  800d25:	85 ff                	test   %edi,%edi
  800d27:	75 0b                	jne    800d34 <__udivdi3+0x30>
  800d29:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f7                	div    %edi
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	31 d2                	xor    %edx,%edx
  800d36:	89 f0                	mov    %esi,%eax
  800d38:	f7 f1                	div    %ecx
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 e8                	mov    %ebp,%eax
  800d3e:	f7 f1                	div    %ecx
  800d40:	89 da                	mov    %ebx,%edx
  800d42:	83 c4 1c             	add    $0x1c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	39 f2                	cmp    %esi,%edx
  800d4e:	77 1c                	ja     800d6c <__udivdi3+0x68>
  800d50:	0f bd da             	bsr    %edx,%ebx
  800d53:	83 f3 1f             	xor    $0x1f,%ebx
  800d56:	75 38                	jne    800d90 <__udivdi3+0x8c>
  800d58:	39 f2                	cmp    %esi,%edx
  800d5a:	72 08                	jb     800d64 <__udivdi3+0x60>
  800d5c:	39 ef                	cmp    %ebp,%edi
  800d5e:	0f 87 98 00 00 00    	ja     800dfc <__udivdi3+0xf8>
  800d64:	b8 01 00 00 00       	mov    $0x1,%eax
  800d69:	eb 05                	jmp    800d70 <__udivdi3+0x6c>
  800d6b:	90                   	nop
  800d6c:	31 db                	xor    %ebx,%ebx
  800d6e:	31 c0                	xor    %eax,%eax
  800d70:	89 da                	mov    %ebx,%edx
  800d72:	83 c4 1c             	add    $0x1c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	89 e8                	mov    %ebp,%eax
  800d7e:	89 f2                	mov    %esi,%edx
  800d80:	f7 f7                	div    %edi
  800d82:	31 db                	xor    %ebx,%ebx
  800d84:	89 da                	mov    %ebx,%edx
  800d86:	83 c4 1c             	add    $0x1c,%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	b8 20 00 00 00       	mov    $0x20,%eax
  800d95:	29 d8                	sub    %ebx,%eax
  800d97:	88 d9                	mov    %bl,%cl
  800d99:	d3 e2                	shl    %cl,%edx
  800d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	88 c1                	mov    %al,%cl
  800da3:	d3 ea                	shr    %cl,%edx
  800da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da9:	09 d1                	or     %edx,%ecx
  800dab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800daf:	88 d9                	mov    %bl,%cl
  800db1:	d3 e7                	shl    %cl,%edi
  800db3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800db7:	89 f7                	mov    %esi,%edi
  800db9:	88 c1                	mov    %al,%cl
  800dbb:	d3 ef                	shr    %cl,%edi
  800dbd:	88 d9                	mov    %bl,%cl
  800dbf:	d3 e6                	shl    %cl,%esi
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	88 c1                	mov    %al,%cl
  800dc5:	d3 ea                	shr    %cl,%edx
  800dc7:	09 d6                	or     %edx,%esi
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	f7 74 24 08          	divl   0x8(%esp)
  800dd1:	89 d7                	mov    %edx,%edi
  800dd3:	89 c6                	mov    %eax,%esi
  800dd5:	f7 64 24 0c          	mull   0xc(%esp)
  800dd9:	39 d7                	cmp    %edx,%edi
  800ddb:	72 13                	jb     800df0 <__udivdi3+0xec>
  800ddd:	74 09                	je     800de8 <__udivdi3+0xe4>
  800ddf:	89 f0                	mov    %esi,%eax
  800de1:	31 db                	xor    %ebx,%ebx
  800de3:	eb 8b                	jmp    800d70 <__udivdi3+0x6c>
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	88 d9                	mov    %bl,%cl
  800dea:	d3 e5                	shl    %cl,%ebp
  800dec:	39 c5                	cmp    %eax,%ebp
  800dee:	73 ef                	jae    800ddf <__udivdi3+0xdb>
  800df0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800df3:	31 db                	xor    %ebx,%ebx
  800df5:	e9 76 ff ff ff       	jmp    800d70 <__udivdi3+0x6c>
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	e9 6d ff ff ff       	jmp    800d70 <__udivdi3+0x6c>
	...

00800e04 <__umoddi3>:
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	89 da                	mov    %ebx,%edx
  800e1f:	85 ed                	test   %ebp,%ebp
  800e21:	75 15                	jne    800e38 <__umoddi3+0x34>
  800e23:	39 df                	cmp    %ebx,%edi
  800e25:	76 39                	jbe    800e60 <__umoddi3+0x5c>
  800e27:	f7 f7                	div    %edi
  800e29:	89 d0                	mov    %edx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 dd                	cmp    %ebx,%ebp
  800e3a:	77 f1                	ja     800e2d <__umoddi3+0x29>
  800e3c:	0f bd cd             	bsr    %ebp,%ecx
  800e3f:	83 f1 1f             	xor    $0x1f,%ecx
  800e42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e46:	75 38                	jne    800e80 <__umoddi3+0x7c>
  800e48:	39 dd                	cmp    %ebx,%ebp
  800e4a:	72 04                	jb     800e50 <__umoddi3+0x4c>
  800e4c:	39 f7                	cmp    %esi,%edi
  800e4e:	77 dd                	ja     800e2d <__umoddi3+0x29>
  800e50:	89 da                	mov    %ebx,%edx
  800e52:	89 f0                	mov    %esi,%eax
  800e54:	29 f8                	sub    %edi,%eax
  800e56:	19 ea                	sbb    %ebp,%edx
  800e58:	83 c4 1c             	add    $0x1c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    
  800e60:	89 f9                	mov    %edi,%ecx
  800e62:	85 ff                	test   %edi,%edi
  800e64:	75 0b                	jne    800e71 <__umoddi3+0x6d>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f7                	div    %edi
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f1                	div    %ecx
  800e77:	89 f0                	mov    %esi,%eax
  800e79:	f7 f1                	div    %ecx
  800e7b:	eb ac                	jmp    800e29 <__umoddi3+0x25>
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
  800e80:	b8 20 00 00 00       	mov    $0x20,%eax
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e8b:	29 c2                	sub    %eax,%edx
  800e8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e91:	88 c1                	mov    %al,%cl
  800e93:	d3 e5                	shl    %cl,%ebp
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	88 d1                	mov    %dl,%cl
  800e99:	d3 e8                	shr    %cl,%eax
  800e9b:	09 c5                	or     %eax,%ebp
  800e9d:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea1:	88 c1                	mov    %al,%cl
  800ea3:	d3 e7                	shl    %cl,%edi
  800ea5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea9:	89 df                	mov    %ebx,%edi
  800eab:	88 d1                	mov    %dl,%cl
  800ead:	d3 ef                	shr    %cl,%edi
  800eaf:	88 c1                	mov    %al,%cl
  800eb1:	d3 e3                	shl    %cl,%ebx
  800eb3:	89 f0                	mov    %esi,%eax
  800eb5:	88 d1                	mov    %dl,%cl
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	09 d8                	or     %ebx,%eax
  800ebb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ebf:	d3 e6                	shl    %cl,%esi
  800ec1:	89 fa                	mov    %edi,%edx
  800ec3:	f7 f5                	div    %ebp
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	f7 64 24 08          	mull   0x8(%esp)
  800ecb:	89 c3                	mov    %eax,%ebx
  800ecd:	89 d7                	mov    %edx,%edi
  800ecf:	39 d1                	cmp    %edx,%ecx
  800ed1:	72 29                	jb     800efc <__umoddi3+0xf8>
  800ed3:	74 23                	je     800ef8 <__umoddi3+0xf4>
  800ed5:	89 ca                	mov    %ecx,%edx
  800ed7:	29 de                	sub    %ebx,%esi
  800ed9:	19 fa                	sbb    %edi,%edx
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ee1:	d3 e0                	shl    %cl,%eax
  800ee3:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800ee7:	88 d9                	mov    %bl,%cl
  800ee9:	d3 ee                	shr    %cl,%esi
  800eeb:	09 f0                	or     %esi,%eax
  800eed:	d3 ea                	shr    %cl,%edx
  800eef:	83 c4 1c             	add    $0x1c,%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
  800ef7:	90                   	nop
  800ef8:	39 c6                	cmp    %eax,%esi
  800efa:	73 d9                	jae    800ed5 <__umoddi3+0xd1>
  800efc:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f00:	19 ea                	sbb    %ebp,%edx
  800f02:	89 d7                	mov    %edx,%edi
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	eb cd                	jmp    800ed5 <__umoddi3+0xd1>
