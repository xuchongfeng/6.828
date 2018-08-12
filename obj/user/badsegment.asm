
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800048:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004b:	e8 ce 00 00 00       	call   80011e <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	89 c2                	mov    %eax,%edx
  800057:	c1 e2 05             	shl    $0x5,%edx
  80005a:	29 c2                	sub    %eax,%edx
  80005c:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800063:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x33>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b7 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 44 00 00 00       	call   8000dd <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7f 08                	jg     800107 <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 0a 0f 80 00       	push   $0x800f0a
  800112:	6a 23                	push   $0x23
  800114:	68 27 0f 80 00       	push   $0x800f27
  800119:	e8 ee 01 00 00       	call   80030c <_panic>

0080011e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <sys_yield>:

void
sys_yield(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014d:	89 d1                	mov    %edx,%ecx
  80014f:	89 d3                	mov    %edx,%ebx
  800151:	89 d7                	mov    %edx,%edi
  800153:	89 d6                	mov    %edx,%esi
  800155:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5f                   	pop    %edi
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800165:	be 00 00 00 00       	mov    $0x0,%esi
  80016a:	8b 55 08             	mov    0x8(%ebp),%edx
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800178:	89 f7                	mov    %esi,%edi
  80017a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017c:	85 c0                	test   %eax,%eax
  80017e:	7f 08                	jg     800188 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	6a 04                	push   $0x4
  80018e:	68 0a 0f 80 00       	push   $0x800f0a
  800193:	6a 23                	push   $0x23
  800195:	68 27 0f 80 00       	push   $0x800f27
  80019a:	e8 6d 01 00 00       	call   80030c <_panic>

0080019f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	57                   	push   %edi
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7f 08                	jg     8001ca <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5f                   	pop    %edi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 05                	push   $0x5
  8001d0:	68 0a 0f 80 00       	push   $0x800f0a
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 27 0f 80 00       	push   $0x800f27
  8001dc:	e8 2b 01 00 00       	call   80030c <_panic>

008001e1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	89 df                	mov    %ebx,%edi
  8001fc:	89 de                	mov    %ebx,%esi
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7f 08                	jg     80020c <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 06                	push   $0x6
  800212:	68 0a 0f 80 00       	push   $0x800f0a
  800217:	6a 23                	push   $0x23
  800219:	68 27 0f 80 00       	push   $0x800f27
  80021e:	e8 e9 00 00 00       	call   80030c <_panic>

00800223 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	8b 55 08             	mov    0x8(%ebp),%edx
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7f 08                	jg     80024e <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 08                	push   $0x8
  800254:	68 0a 0f 80 00       	push   $0x800f0a
  800259:	6a 23                	push   $0x23
  80025b:	68 27 0f 80 00       	push   $0x800f27
  800260:	e8 a7 00 00 00       	call   80030c <_panic>

00800265 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7f 08                	jg     800290 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	50                   	push   %eax
  800294:	6a 09                	push   $0x9
  800296:	68 0a 0f 80 00       	push   $0x800f0a
  80029b:	6a 23                	push   $0x23
  80029d:	68 27 0f 80 00       	push   $0x800f27
  8002a2:	e8 65 00 00 00       	call   80030c <_panic>

008002a7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b8:	be 00 00 00 00       	mov    $0x0,%esi
  8002bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e0:	89 cb                	mov    %ecx,%ebx
  8002e2:	89 cf                	mov    %ecx,%edi
  8002e4:	89 ce                	mov    %ecx,%esi
  8002e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	7f 08                	jg     8002f4 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	50                   	push   %eax
  8002f8:	6a 0c                	push   $0xc
  8002fa:	68 0a 0f 80 00       	push   $0x800f0a
  8002ff:	6a 23                	push   $0x23
  800301:	68 27 0f 80 00       	push   $0x800f27
  800306:	e8 01 00 00 00       	call   80030c <_panic>
	...

0080030c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800314:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031a:	e8 ff fd ff ff       	call   80011e <sys_getenvid>
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	56                   	push   %esi
  800329:	50                   	push   %eax
  80032a:	68 38 0f 80 00       	push   $0x800f38
  80032f:	e8 b4 00 00 00       	call   8003e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800334:	83 c4 18             	add    $0x18,%esp
  800337:	53                   	push   %ebx
  800338:	ff 75 10             	pushl  0x10(%ebp)
  80033b:	e8 57 00 00 00       	call   800397 <vcprintf>
	cprintf("\n");
  800340:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  800347:	e8 9c 00 00 00       	call   8003e8 <cprintf>
  80034c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034f:	cc                   	int3   
  800350:	eb fd                	jmp    80034f <_panic+0x43>
	...

00800354 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	53                   	push   %ebx
  800358:	83 ec 04             	sub    $0x4,%esp
  80035b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035e:	8b 13                	mov    (%ebx),%edx
  800360:	8d 42 01             	lea    0x1(%edx),%eax
  800363:	89 03                	mov    %eax,(%ebx)
  800365:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800368:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800371:	74 08                	je     80037b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800373:	ff 43 04             	incl   0x4(%ebx)
}
  800376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800379:	c9                   	leave  
  80037a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	68 ff 00 00 00       	push   $0xff
  800383:	8d 43 08             	lea    0x8(%ebx),%eax
  800386:	50                   	push   %eax
  800387:	e8 14 fd ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  80038c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	eb dc                	jmp    800373 <putch+0x1f>

00800397 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a7:	00 00 00 
	b.cnt = 0;
  8003aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b4:	ff 75 0c             	pushl  0xc(%ebp)
  8003b7:	ff 75 08             	pushl  0x8(%ebp)
  8003ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c0:	50                   	push   %eax
  8003c1:	68 54 03 80 00       	push   $0x800354
  8003c6:	e8 17 01 00 00       	call   8004e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cb:	83 c4 08             	add    $0x8,%esp
  8003ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003da:	50                   	push   %eax
  8003db:	e8 c0 fc ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8003e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f1:	50                   	push   %eax
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 9d ff ff ff       	call   800397 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 1c             	sub    $0x1c,%esp
  800405:	89 c7                	mov    %eax,%edi
  800407:	89 d6                	mov    %edx,%esi
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800412:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800415:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800418:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800420:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800423:	39 d3                	cmp    %edx,%ebx
  800425:	72 05                	jb     80042c <printnum+0x30>
  800427:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042a:	77 78                	ja     8004a4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	ff 75 18             	pushl  0x18(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800438:	53                   	push   %ebx
  800439:	ff 75 10             	pushl  0x10(%ebp)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 a8 08 00 00       	call   800cf8 <__udivdi3>
  800450:	83 c4 18             	add    $0x18,%esp
  800453:	52                   	push   %edx
  800454:	50                   	push   %eax
  800455:	89 f2                	mov    %esi,%edx
  800457:	89 f8                	mov    %edi,%eax
  800459:	e8 9e ff ff ff       	call   8003fc <printnum>
  80045e:	83 c4 20             	add    $0x20,%esp
  800461:	eb 11                	jmp    800474 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	56                   	push   %esi
  800467:	ff 75 18             	pushl  0x18(%ebp)
  80046a:	ff d7                	call   *%edi
  80046c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046f:	4b                   	dec    %ebx
  800470:	85 db                	test   %ebx,%ebx
  800472:	7f ef                	jg     800463 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	56                   	push   %esi
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff 75 dc             	pushl  -0x24(%ebp)
  800484:	ff 75 d8             	pushl  -0x28(%ebp)
  800487:	e8 6c 09 00 00       	call   800df8 <__umoddi3>
  80048c:	83 c4 14             	add    $0x14,%esp
  80048f:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  800496:	50                   	push   %eax
  800497:	ff d7                	call   *%edi
}
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049f:	5b                   	pop    %ebx
  8004a0:	5e                   	pop    %esi
  8004a1:	5f                   	pop    %edi
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    
  8004a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a7:	eb c6                	jmp    80046f <printnum+0x73>

008004a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004af:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b7:	73 0a                	jae    8004c3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8004b9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	88 02                	mov    %al,(%edx)
}
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ce:	50                   	push   %eax
  8004cf:	ff 75 10             	pushl  0x10(%ebp)
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	ff 75 08             	pushl  0x8(%ebp)
  8004d8:	e8 05 00 00 00       	call   8004e2 <vprintfmt>
	va_end(ap);
}
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    

008004e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 2c             	sub    $0x2c,%esp
  8004eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f4:	e9 ac 03 00 00       	jmp    8008a5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8004fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800504:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80050b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8d 47 01             	lea    0x1(%edi),%eax
  80051a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051d:	8a 17                	mov    (%edi),%dl
  80051f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800522:	3c 55                	cmp    $0x55,%al
  800524:	0f 87 fc 03 00 00    	ja     800926 <vprintfmt+0x444>
  80052a:	0f b6 c0             	movzbl %al,%eax
  80052d:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
  800534:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800537:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053b:	eb da                	jmp    800517 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800540:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800544:	eb d1                	jmp    800517 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	0f b6 d2             	movzbl %dl,%edx
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80054c:	b8 00 00 00 00       	mov    $0x0,%eax
  800551:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800554:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800557:	01 c0                	add    %eax,%eax
  800559:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80055d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800560:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800563:	83 f9 09             	cmp    $0x9,%ecx
  800566:	77 52                	ja     8005ba <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800568:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800569:	eb e9                	jmp    800554 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80057f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800583:	79 92                	jns    800517 <vprintfmt+0x35>
				width = precision, precision = -1;
  800585:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800588:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800592:	eb 83                	jmp    800517 <vprintfmt+0x35>
  800594:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800598:	78 08                	js     8005a2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	e9 75 ff ff ff       	jmp    800517 <vprintfmt+0x35>
  8005a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005a9:	eb ef                	jmp    80059a <vprintfmt+0xb8>
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b5:	e9 5d ff ff ff       	jmp    800517 <vprintfmt+0x35>
  8005ba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c0:	eb bd                	jmp    80057f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c6:	e9 4c ff ff ff       	jmp    800517 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 78 04             	lea    0x4(%eax),%edi
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	ff 30                	pushl  (%eax)
  8005d7:	ff d6                	call   *%esi
			break;
  8005d9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005df:	e9 be 02 00 00       	jmp    8008a2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 78 04             	lea    0x4(%eax),%edi
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	78 2a                	js     80061a <vprintfmt+0x138>
  8005f0:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f2:	83 f8 08             	cmp    $0x8,%eax
  8005f5:	7f 27                	jg     80061e <vprintfmt+0x13c>
  8005f7:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	74 1c                	je     80061e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800602:	50                   	push   %eax
  800603:	68 7f 0f 80 00       	push   $0x800f7f
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 b6 fe ff ff       	call   8004c5 <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	89 7d 14             	mov    %edi,0x14(%ebp)
  800615:	e9 88 02 00 00       	jmp    8008a2 <vprintfmt+0x3c0>
  80061a:	f7 d8                	neg    %eax
  80061c:	eb d2                	jmp    8005f0 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061e:	52                   	push   %edx
  80061f:	68 76 0f 80 00       	push   $0x800f76
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 9a fe ff ff       	call   8004c5 <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 6c 02 00 00       	jmp    8008a2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	83 c0 04             	add    $0x4,%eax
  80063c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 38                	mov    (%eax),%edi
  800644:	85 ff                	test   %edi,%edi
  800646:	74 18                	je     800660 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800648:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064c:	0f 8e b7 00 00 00    	jle    800709 <vprintfmt+0x227>
  800652:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800656:	75 0f                	jne    800667 <vprintfmt+0x185>
  800658:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80065e:	eb 75                	jmp    8006d5 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800660:	bf 6f 0f 80 00       	mov    $0x800f6f,%edi
  800665:	eb e1                	jmp    800648 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 d0             	pushl  -0x30(%ebp)
  80066d:	57                   	push   %edi
  80066e:	e8 5f 03 00 00       	call   8009d2 <strnlen>
  800673:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800676:	29 c1                	sub    %eax,%ecx
  800678:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800685:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800688:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	eb 0d                	jmp    800699 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	4f                   	dec    %edi
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	85 ff                	test   %edi,%edi
  80069b:	7f ef                	jg     80068c <vprintfmt+0x1aa>
  80069d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a3:	89 c8                	mov    %ecx,%eax
  8006a5:	85 c9                	test   %ecx,%ecx
  8006a7:	78 10                	js     8006b9 <vprintfmt+0x1d7>
  8006a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ac:	29 c1                	sub    %eax,%ecx
  8006ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b7:	eb 1c                	jmp    8006d5 <vprintfmt+0x1f3>
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006be:	eb e9                	jmp    8006a9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c4:	75 29                	jne    8006ef <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	50                   	push   %eax
  8006cd:	ff d6                	call   *%esi
  8006cf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d2:	ff 4d e0             	decl   -0x20(%ebp)
  8006d5:	47                   	inc    %edi
  8006d6:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006d9:	0f be c2             	movsbl %dl,%eax
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 4c                	je     80072c <vprintfmt+0x24a>
  8006e0:	85 db                	test   %ebx,%ebx
  8006e2:	78 dc                	js     8006c0 <vprintfmt+0x1de>
  8006e4:	4b                   	dec    %ebx
  8006e5:	79 d9                	jns    8006c0 <vprintfmt+0x1de>
  8006e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ea:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ed:	eb 2e                	jmp    80071d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	0f be d2             	movsbl %dl,%edx
  8006f2:	83 ea 20             	sub    $0x20,%edx
  8006f5:	83 fa 5e             	cmp    $0x5e,%edx
  8006f8:	76 cc                	jbe    8006c6 <vprintfmt+0x1e4>
					putch('?', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	ff 75 0c             	pushl  0xc(%ebp)
  800700:	6a 3f                	push   $0x3f
  800702:	ff d6                	call   *%esi
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb c9                	jmp    8006d2 <vprintfmt+0x1f0>
  800709:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80070f:	eb c4                	jmp    8006d5 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 20                	push   $0x20
  800717:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800719:	4f                   	dec    %edi
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	85 ff                	test   %edi,%edi
  80071f:	7f f0                	jg     800711 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800721:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
  800727:	e9 76 01 00 00       	jmp    8008a2 <vprintfmt+0x3c0>
  80072c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80072f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800732:	eb e9                	jmp    80071d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800734:	83 f9 01             	cmp    $0x1,%ecx
  800737:	7e 3f                	jle    800778 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 50 04             	mov    0x4(%eax),%edx
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 08             	lea    0x8(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800750:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800754:	79 5c                	jns    8007b2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 2d                	push   $0x2d
  80075c:	ff d6                	call   *%esi
				num = -(long long) num;
  80075e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800761:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800764:	f7 da                	neg    %edx
  800766:	83 d1 00             	adc    $0x0,%ecx
  800769:	f7 d9                	neg    %ecx
  80076b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 10 01 00 00       	jmp    800888 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800778:	85 c9                	test   %ecx,%ecx
  80077a:	75 1b                	jne    800797 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800784:	89 c1                	mov    %eax,%ecx
  800786:	c1 f9 1f             	sar    $0x1f,%ecx
  800789:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 40 04             	lea    0x4(%eax),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
  800795:	eb b9                	jmp    800750 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079f:	89 c1                	mov    %eax,%ecx
  8007a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 40 04             	lea    0x4(%eax),%eax
  8007ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b0:	eb 9e                	jmp    800750 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bd:	e9 c6 00 00 00       	jmp    800888 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c2:	83 f9 01             	cmp    $0x1,%ecx
  8007c5:	7e 18                	jle    8007df <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cf:	8d 40 08             	lea    0x8(%eax),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007da:	e9 a9 00 00 00       	jmp    800888 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007df:	85 c9                	test   %ecx,%ecx
  8007e1:	75 1a                	jne    8007fd <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ed:	8d 40 04             	lea    0x4(%eax),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f8:	e9 8b 00 00 00       	jmp    800888 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	b9 00 00 00 00       	mov    $0x0,%ecx
  800807:	8d 40 04             	lea    0x4(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80080d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800812:	eb 74                	jmp    800888 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800814:	83 f9 01             	cmp    $0x1,%ecx
  800817:	7e 15                	jle    80082e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	8b 48 04             	mov    0x4(%eax),%ecx
  800821:	8d 40 08             	lea    0x8(%eax),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800827:	b8 08 00 00 00       	mov    $0x8,%eax
  80082c:	eb 5a                	jmp    800888 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80082e:	85 c9                	test   %ecx,%ecx
  800830:	75 17                	jne    800849 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 10                	mov    (%eax),%edx
  800837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083c:	8d 40 04             	lea    0x4(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800842:	b8 08 00 00 00       	mov    $0x8,%eax
  800847:	eb 3f                	jmp    800888 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800853:	8d 40 04             	lea    0x4(%eax),%eax
  800856:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800859:	b8 08 00 00 00       	mov    $0x8,%eax
  80085e:	eb 28                	jmp    800888 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 30                	push   $0x30
  800866:	ff d6                	call   *%esi
			putch('x', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 78                	push   $0x78
  80086e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 10                	mov    (%eax),%edx
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800883:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80088f:	57                   	push   %edi
  800890:	ff 75 e0             	pushl  -0x20(%ebp)
  800893:	50                   	push   %eax
  800894:	51                   	push   %ecx
  800895:	52                   	push   %edx
  800896:	89 da                	mov    %ebx,%edx
  800898:	89 f0                	mov    %esi,%eax
  80089a:	e8 5d fb ff ff       	call   8003fc <printnum>
			break;
  80089f:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a5:	47                   	inc    %edi
  8008a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008aa:	83 f8 25             	cmp    $0x25,%eax
  8008ad:	0f 84 46 fc ff ff    	je     8004f9 <vprintfmt+0x17>
			if (ch == '\0')
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	0f 84 89 00 00 00    	je     800944 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	50                   	push   %eax
  8008c0:	ff d6                	call   *%esi
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb de                	jmp    8008a5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c7:	83 f9 01             	cmp    $0x1,%ecx
  8008ca:	7e 15                	jle    8008e1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8b 10                	mov    (%eax),%edx
  8008d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d4:	8d 40 08             	lea    0x8(%eax),%eax
  8008d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008da:	b8 10 00 00 00       	mov    $0x10,%eax
  8008df:	eb a7                	jmp    800888 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008e1:	85 c9                	test   %ecx,%ecx
  8008e3:	75 17                	jne    8008fc <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8b 10                	mov    (%eax),%edx
  8008ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ef:	8d 40 04             	lea    0x4(%eax),%eax
  8008f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8008fa:	eb 8c                	jmp    800888 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8b 10                	mov    (%eax),%edx
  800901:	b9 00 00 00 00       	mov    $0x0,%ecx
  800906:	8d 40 04             	lea    0x4(%eax),%eax
  800909:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80090c:	b8 10 00 00 00       	mov    $0x10,%eax
  800911:	e9 72 ff ff ff       	jmp    800888 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	53                   	push   %ebx
  80091a:	6a 25                	push   $0x25
  80091c:	ff d6                	call   *%esi
			break;
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	e9 7c ff ff ff       	jmp    8008a2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	53                   	push   %ebx
  80092a:	6a 25                	push   $0x25
  80092c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	89 f8                	mov    %edi,%eax
  800933:	eb 01                	jmp    800936 <vprintfmt+0x454>
  800935:	48                   	dec    %eax
  800936:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80093a:	75 f9                	jne    800935 <vprintfmt+0x453>
  80093c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80093f:	e9 5e ff ff ff       	jmp    8008a2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800944:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 18             	sub    $0x18,%esp
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800958:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80095f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800962:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800969:	85 c0                	test   %eax,%eax
  80096b:	74 26                	je     800993 <vsnprintf+0x47>
  80096d:	85 d2                	test   %edx,%edx
  80096f:	7e 29                	jle    80099a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800971:	ff 75 14             	pushl  0x14(%ebp)
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097a:	50                   	push   %eax
  80097b:	68 a9 04 80 00       	push   $0x8004a9
  800980:	e8 5d fb ff ff       	call   8004e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800985:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800988:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098e:	83 c4 10             	add    $0x10,%esp
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800998:	eb f7                	jmp    800991 <vsnprintf+0x45>
  80099a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099f:	eb f0                	jmp    800991 <vsnprintf+0x45>

008009a1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009aa:	50                   	push   %eax
  8009ab:	ff 75 10             	pushl  0x10(%ebp)
  8009ae:	ff 75 0c             	pushl  0xc(%ebp)
  8009b1:	ff 75 08             	pushl  0x8(%ebp)
  8009b4:	e8 93 ff ff ff       	call   80094c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    
	...

008009bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb 01                	jmp    8009ca <strlen+0xe>
		n++;
  8009c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ce:	75 f9                	jne    8009c9 <strlen+0xd>
		n++;
	return n;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	eb 01                	jmp    8009e3 <strnlen+0x11>
		n++;
  8009e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e3:	39 d0                	cmp    %edx,%eax
  8009e5:	74 06                	je     8009ed <strnlen+0x1b>
  8009e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009eb:	75 f5                	jne    8009e2 <strnlen+0x10>
		n++;
	return n;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	41                   	inc    %ecx
  8009fc:	42                   	inc    %edx
  8009fd:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a00:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a03:	84 db                	test   %bl,%bl
  800a05:	75 f4                	jne    8009fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a11:	53                   	push   %ebx
  800a12:	e8 a5 ff ff ff       	call   8009bc <strlen>
  800a17:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1a:	ff 75 0c             	pushl  0xc(%ebp)
  800a1d:	01 d8                	add    %ebx,%eax
  800a1f:	50                   	push   %eax
  800a20:	e8 ca ff ff ff       	call   8009ef <strcpy>
	return dst;
}
  800a25:	89 d8                	mov    %ebx,%eax
  800a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3c:	89 f2                	mov    %esi,%edx
  800a3e:	39 da                	cmp    %ebx,%edx
  800a40:	74 0e                	je     800a50 <strncpy+0x24>
		*dst++ = *src;
  800a42:	42                   	inc    %edx
  800a43:	8a 01                	mov    (%ecx),%al
  800a45:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a48:	80 39 00             	cmpb   $0x0,(%ecx)
  800a4b:	74 f1                	je     800a3e <strncpy+0x12>
			src++;
  800a4d:	41                   	inc    %ecx
  800a4e:	eb ee                	jmp    800a3e <strncpy+0x12>
	}
	return ret;
}
  800a50:	89 f0                	mov    %esi,%eax
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a64:	85 c0                	test   %eax,%eax
  800a66:	74 20                	je     800a88 <strlcpy+0x32>
  800a68:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a6c:	89 f0                	mov    %esi,%eax
  800a6e:	eb 05                	jmp    800a75 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a70:	42                   	inc    %edx
  800a71:	40                   	inc    %eax
  800a72:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a75:	39 d8                	cmp    %ebx,%eax
  800a77:	74 06                	je     800a7f <strlcpy+0x29>
  800a79:	8a 0a                	mov    (%edx),%cl
  800a7b:	84 c9                	test   %cl,%cl
  800a7d:	75 f1                	jne    800a70 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a7f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a82:	29 f0                	sub    %esi,%eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	eb f6                	jmp    800a82 <strlcpy+0x2c>

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a95:	eb 02                	jmp    800a99 <strcmp+0xd>
		p++, q++;
  800a97:	41                   	inc    %ecx
  800a98:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a99:	8a 01                	mov    (%ecx),%al
  800a9b:	84 c0                	test   %al,%al
  800a9d:	74 04                	je     800aa3 <strcmp+0x17>
  800a9f:	3a 02                	cmp    (%edx),%al
  800aa1:	74 f4                	je     800a97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa3:	0f b6 c0             	movzbl %al,%eax
  800aa6:	0f b6 12             	movzbl (%edx),%edx
  800aa9:	29 d0                	sub    %edx,%eax
}
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab7:	89 c3                	mov    %eax,%ebx
  800ab9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800abc:	eb 02                	jmp    800ac0 <strncmp+0x13>
		n--, p++, q++;
  800abe:	40                   	inc    %eax
  800abf:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac0:	39 d8                	cmp    %ebx,%eax
  800ac2:	74 15                	je     800ad9 <strncmp+0x2c>
  800ac4:	8a 08                	mov    (%eax),%cl
  800ac6:	84 c9                	test   %cl,%cl
  800ac8:	74 04                	je     800ace <strncmp+0x21>
  800aca:	3a 0a                	cmp    (%edx),%cl
  800acc:	74 f0                	je     800abe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ace:	0f b6 00             	movzbl (%eax),%eax
  800ad1:	0f b6 12             	movzbl (%edx),%edx
  800ad4:	29 d0                	sub    %edx,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	eb f6                	jmp    800ad6 <strncmp+0x29>

00800ae0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ae9:	8a 10                	mov    (%eax),%dl
  800aeb:	84 d2                	test   %dl,%dl
  800aed:	74 07                	je     800af6 <strchr+0x16>
		if (*s == c)
  800aef:	38 ca                	cmp    %cl,%dl
  800af1:	74 08                	je     800afb <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af3:	40                   	inc    %eax
  800af4:	eb f3                	jmp    800ae9 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b06:	8a 10                	mov    (%eax),%dl
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	74 07                	je     800b13 <strfind+0x16>
		if (*s == c)
  800b0c:	38 ca                	cmp    %cl,%dl
  800b0e:	74 03                	je     800b13 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b10:	40                   	inc    %eax
  800b11:	eb f3                	jmp    800b06 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b21:	85 c9                	test   %ecx,%ecx
  800b23:	74 13                	je     800b38 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2b:	75 05                	jne    800b32 <memset+0x1d>
  800b2d:	f6 c1 03             	test   $0x3,%cl
  800b30:	74 0d                	je     800b3f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	fc                   	cld    
  800b36:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b38:	89 f8                	mov    %edi,%eax
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b43:	89 d3                	mov    %edx,%ebx
  800b45:	c1 e3 08             	shl    $0x8,%ebx
  800b48:	89 d0                	mov    %edx,%eax
  800b4a:	c1 e0 18             	shl    $0x18,%eax
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 10             	shl    $0x10,%esi
  800b52:	09 f0                	or     %esi,%eax
  800b54:	09 c2                	or     %eax,%edx
  800b56:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b58:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	fc                   	cld    
  800b5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b60:	eb d6                	jmp    800b38 <memset+0x23>

00800b62 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b70:	39 c6                	cmp    %eax,%esi
  800b72:	73 33                	jae    800ba7 <memmove+0x45>
  800b74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b77:	39 c2                	cmp    %eax,%edx
  800b79:	76 2c                	jbe    800ba7 <memmove+0x45>
		s += n;
		d += n;
  800b7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	09 fe                	or     %edi,%esi
  800b82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b88:	74 0a                	je     800b94 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8a:	4f                   	dec    %edi
  800b8b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8e:	fd                   	std    
  800b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b91:	fc                   	cld    
  800b92:	eb 21                	jmp    800bb5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 f1                	jne    800b8a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b99:	83 ef 04             	sub    $0x4,%edi
  800b9c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba2:	fd                   	std    
  800ba3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba5:	eb ea                	jmp    800b91 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba7:	89 f2                	mov    %esi,%edx
  800ba9:	09 c2                	or     %eax,%edx
  800bab:	f6 c2 03             	test   $0x3,%dl
  800bae:	74 09                	je     800bb9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb0:	89 c7                	mov    %eax,%edi
  800bb2:	fc                   	cld    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 f2                	jne    800bb0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bbe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc1:	89 c7                	mov    %eax,%edi
  800bc3:	fc                   	cld    
  800bc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc6:	eb ed                	jmp    800bb5 <memmove+0x53>

00800bc8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcb:	ff 75 10             	pushl  0x10(%ebp)
  800bce:	ff 75 0c             	pushl  0xc(%ebp)
  800bd1:	ff 75 08             	pushl  0x8(%ebp)
  800bd4:	e8 89 ff ff ff       	call   800b62 <memmove>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800beb:	39 f0                	cmp    %esi,%eax
  800bed:	74 16                	je     800c05 <memcmp+0x2a>
		if (*s1 != *s2)
  800bef:	8a 08                	mov    (%eax),%cl
  800bf1:	8a 1a                	mov    (%edx),%bl
  800bf3:	38 d9                	cmp    %bl,%cl
  800bf5:	75 04                	jne    800bfb <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bf7:	40                   	inc    %eax
  800bf8:	42                   	inc    %edx
  800bf9:	eb f0                	jmp    800beb <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800bfb:	0f b6 c1             	movzbl %cl,%eax
  800bfe:	0f b6 db             	movzbl %bl,%ebx
  800c01:	29 d8                	sub    %ebx,%eax
  800c03:	eb 05                	jmp    800c0a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c17:	89 c2                	mov    %eax,%edx
  800c19:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c1c:	39 d0                	cmp    %edx,%eax
  800c1e:	73 07                	jae    800c27 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c20:	38 08                	cmp    %cl,(%eax)
  800c22:	74 03                	je     800c27 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c24:	40                   	inc    %eax
  800c25:	eb f5                	jmp    800c1c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c32:	eb 01                	jmp    800c35 <strtol+0xc>
		s++;
  800c34:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c35:	8a 01                	mov    (%ecx),%al
  800c37:	3c 20                	cmp    $0x20,%al
  800c39:	74 f9                	je     800c34 <strtol+0xb>
  800c3b:	3c 09                	cmp    $0x9,%al
  800c3d:	74 f5                	je     800c34 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3f:	3c 2b                	cmp    $0x2b,%al
  800c41:	74 2b                	je     800c6e <strtol+0x45>
		s++;
	else if (*s == '-')
  800c43:	3c 2d                	cmp    $0x2d,%al
  800c45:	74 2f                	je     800c76 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c53:	75 12                	jne    800c67 <strtol+0x3e>
  800c55:	80 39 30             	cmpb   $0x30,(%ecx)
  800c58:	74 24                	je     800c7e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c5e:	75 07                	jne    800c67 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c60:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	eb 4e                	jmp    800cbc <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c6e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c74:	eb d6                	jmp    800c4c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c76:	41                   	inc    %ecx
  800c77:	bf 01 00 00 00       	mov    $0x1,%edi
  800c7c:	eb ce                	jmp    800c4c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c82:	74 10                	je     800c94 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c88:	75 dd                	jne    800c67 <strtol+0x3e>
		s++, base = 8;
  800c8a:	41                   	inc    %ecx
  800c8b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c92:	eb d3                	jmp    800c67 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800c94:	83 c1 02             	add    $0x2,%ecx
  800c97:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c9e:	eb c7                	jmp    800c67 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ca0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca3:	89 f3                	mov    %esi,%ebx
  800ca5:	80 fb 19             	cmp    $0x19,%bl
  800ca8:	77 24                	ja     800cce <strtol+0xa5>
			dig = *s - 'a' + 10;
  800caa:	0f be d2             	movsbl %dl,%edx
  800cad:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cb3:	7e 2b                	jle    800ce0 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cb5:	41                   	inc    %ecx
  800cb6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cba:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cbc:	8a 11                	mov    (%ecx),%dl
  800cbe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800cc1:	80 fb 09             	cmp    $0x9,%bl
  800cc4:	77 da                	ja     800ca0 <strtol+0x77>
			dig = *s - '0';
  800cc6:	0f be d2             	movsbl %dl,%edx
  800cc9:	83 ea 30             	sub    $0x30,%edx
  800ccc:	eb e2                	jmp    800cb0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cce:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 08                	ja     800ce0 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800cd8:	0f be d2             	movsbl %dl,%edx
  800cdb:	83 ea 37             	sub    $0x37,%edx
  800cde:	eb d0                	jmp    800cb0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce4:	74 05                	je     800ceb <strtol+0xc2>
		*endptr = (char *) s;
  800ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	74 02                	je     800cf1 <strtol+0xc8>
  800cef:	f7 d8                	neg    %eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
	...

00800cf8 <__udivdi3>:
  800cf8:	55                   	push   %ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 1c             	sub    $0x1c,%esp
  800cff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0f:	85 d2                	test   %edx,%edx
  800d11:	75 2d                	jne    800d40 <__udivdi3+0x48>
  800d13:	39 f7                	cmp    %esi,%edi
  800d15:	77 59                	ja     800d70 <__udivdi3+0x78>
  800d17:	89 f9                	mov    %edi,%ecx
  800d19:	85 ff                	test   %edi,%edi
  800d1b:	75 0b                	jne    800d28 <__udivdi3+0x30>
  800d1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d22:	31 d2                	xor    %edx,%edx
  800d24:	f7 f7                	div    %edi
  800d26:	89 c1                	mov    %eax,%ecx
  800d28:	31 d2                	xor    %edx,%edx
  800d2a:	89 f0                	mov    %esi,%eax
  800d2c:	f7 f1                	div    %ecx
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	89 e8                	mov    %ebp,%eax
  800d32:	f7 f1                	div    %ecx
  800d34:	89 da                	mov    %ebx,%edx
  800d36:	83 c4 1c             	add    $0x1c,%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	39 f2                	cmp    %esi,%edx
  800d42:	77 1c                	ja     800d60 <__udivdi3+0x68>
  800d44:	0f bd da             	bsr    %edx,%ebx
  800d47:	83 f3 1f             	xor    $0x1f,%ebx
  800d4a:	75 38                	jne    800d84 <__udivdi3+0x8c>
  800d4c:	39 f2                	cmp    %esi,%edx
  800d4e:	72 08                	jb     800d58 <__udivdi3+0x60>
  800d50:	39 ef                	cmp    %ebp,%edi
  800d52:	0f 87 98 00 00 00    	ja     800df0 <__udivdi3+0xf8>
  800d58:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5d:	eb 05                	jmp    800d64 <__udivdi3+0x6c>
  800d5f:	90                   	nop
  800d60:	31 db                	xor    %ebx,%ebx
  800d62:	31 c0                	xor    %eax,%eax
  800d64:	89 da                	mov    %ebx,%edx
  800d66:	83 c4 1c             	add    $0x1c,%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	89 e8                	mov    %ebp,%eax
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	f7 f7                	div    %edi
  800d76:	31 db                	xor    %ebx,%ebx
  800d78:	89 da                	mov    %ebx,%edx
  800d7a:	83 c4 1c             	add    $0x1c,%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
  800d82:	66 90                	xchg   %ax,%ax
  800d84:	b8 20 00 00 00       	mov    $0x20,%eax
  800d89:	29 d8                	sub    %ebx,%eax
  800d8b:	88 d9                	mov    %bl,%cl
  800d8d:	d3 e2                	shl    %cl,%edx
  800d8f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d93:	89 fa                	mov    %edi,%edx
  800d95:	88 c1                	mov    %al,%cl
  800d97:	d3 ea                	shr    %cl,%edx
  800d99:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d9d:	09 d1                	or     %edx,%ecx
  800d9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800da3:	88 d9                	mov    %bl,%cl
  800da5:	d3 e7                	shl    %cl,%edi
  800da7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dab:	89 f7                	mov    %esi,%edi
  800dad:	88 c1                	mov    %al,%cl
  800daf:	d3 ef                	shr    %cl,%edi
  800db1:	88 d9                	mov    %bl,%cl
  800db3:	d3 e6                	shl    %cl,%esi
  800db5:	89 ea                	mov    %ebp,%edx
  800db7:	88 c1                	mov    %al,%cl
  800db9:	d3 ea                	shr    %cl,%edx
  800dbb:	09 d6                	or     %edx,%esi
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	f7 74 24 08          	divl   0x8(%esp)
  800dc5:	89 d7                	mov    %edx,%edi
  800dc7:	89 c6                	mov    %eax,%esi
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d7                	cmp    %edx,%edi
  800dcf:	72 13                	jb     800de4 <__udivdi3+0xec>
  800dd1:	74 09                	je     800ddc <__udivdi3+0xe4>
  800dd3:	89 f0                	mov    %esi,%eax
  800dd5:	31 db                	xor    %ebx,%ebx
  800dd7:	eb 8b                	jmp    800d64 <__udivdi3+0x6c>
  800dd9:	8d 76 00             	lea    0x0(%esi),%esi
  800ddc:	88 d9                	mov    %bl,%cl
  800dde:	d3 e5                	shl    %cl,%ebp
  800de0:	39 c5                	cmp    %eax,%ebp
  800de2:	73 ef                	jae    800dd3 <__udivdi3+0xdb>
  800de4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800de7:	31 db                	xor    %ebx,%ebx
  800de9:	e9 76 ff ff ff       	jmp    800d64 <__udivdi3+0x6c>
  800dee:	66 90                	xchg   %ax,%ax
  800df0:	31 c0                	xor    %eax,%eax
  800df2:	e9 6d ff ff ff       	jmp    800d64 <__udivdi3+0x6c>
	...

00800df8 <__umoddi3>:
  800df8:	55                   	push   %ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 1c             	sub    $0x1c,%esp
  800dff:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e0b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e0f:	89 f0                	mov    %esi,%eax
  800e11:	89 da                	mov    %ebx,%edx
  800e13:	85 ed                	test   %ebp,%ebp
  800e15:	75 15                	jne    800e2c <__umoddi3+0x34>
  800e17:	39 df                	cmp    %ebx,%edi
  800e19:	76 39                	jbe    800e54 <__umoddi3+0x5c>
  800e1b:	f7 f7                	div    %edi
  800e1d:	89 d0                	mov    %edx,%eax
  800e1f:	31 d2                	xor    %edx,%edx
  800e21:	83 c4 1c             	add    $0x1c,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	8d 76 00             	lea    0x0(%esi),%esi
  800e2c:	39 dd                	cmp    %ebx,%ebp
  800e2e:	77 f1                	ja     800e21 <__umoddi3+0x29>
  800e30:	0f bd cd             	bsr    %ebp,%ecx
  800e33:	83 f1 1f             	xor    $0x1f,%ecx
  800e36:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e3a:	75 38                	jne    800e74 <__umoddi3+0x7c>
  800e3c:	39 dd                	cmp    %ebx,%ebp
  800e3e:	72 04                	jb     800e44 <__umoddi3+0x4c>
  800e40:	39 f7                	cmp    %esi,%edi
  800e42:	77 dd                	ja     800e21 <__umoddi3+0x29>
  800e44:	89 da                	mov    %ebx,%edx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	29 f8                	sub    %edi,%eax
  800e4a:	19 ea                	sbb    %ebp,%edx
  800e4c:	83 c4 1c             	add    $0x1c,%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    
  800e54:	89 f9                	mov    %edi,%ecx
  800e56:	85 ff                	test   %edi,%edi
  800e58:	75 0b                	jne    800e65 <__umoddi3+0x6d>
  800e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5f:	31 d2                	xor    %edx,%edx
  800e61:	f7 f7                	div    %edi
  800e63:	89 c1                	mov    %eax,%ecx
  800e65:	89 d8                	mov    %ebx,%eax
  800e67:	31 d2                	xor    %edx,%edx
  800e69:	f7 f1                	div    %ecx
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	f7 f1                	div    %ecx
  800e6f:	eb ac                	jmp    800e1d <__umoddi3+0x25>
  800e71:	8d 76 00             	lea    0x0(%esi),%esi
  800e74:	b8 20 00 00 00       	mov    $0x20,%eax
  800e79:	89 c2                	mov    %eax,%edx
  800e7b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e7f:	29 c2                	sub    %eax,%edx
  800e81:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e85:	88 c1                	mov    %al,%cl
  800e87:	d3 e5                	shl    %cl,%ebp
  800e89:	89 f8                	mov    %edi,%eax
  800e8b:	88 d1                	mov    %dl,%cl
  800e8d:	d3 e8                	shr    %cl,%eax
  800e8f:	09 c5                	or     %eax,%ebp
  800e91:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e95:	88 c1                	mov    %al,%cl
  800e97:	d3 e7                	shl    %cl,%edi
  800e99:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e9d:	89 df                	mov    %ebx,%edi
  800e9f:	88 d1                	mov    %dl,%cl
  800ea1:	d3 ef                	shr    %cl,%edi
  800ea3:	88 c1                	mov    %al,%cl
  800ea5:	d3 e3                	shl    %cl,%ebx
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	88 d1                	mov    %dl,%cl
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 d8                	or     %ebx,%eax
  800eaf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800eb3:	d3 e6                	shl    %cl,%esi
  800eb5:	89 fa                	mov    %edi,%edx
  800eb7:	f7 f5                	div    %ebp
  800eb9:	89 d1                	mov    %edx,%ecx
  800ebb:	f7 64 24 08          	mull   0x8(%esp)
  800ebf:	89 c3                	mov    %eax,%ebx
  800ec1:	89 d7                	mov    %edx,%edi
  800ec3:	39 d1                	cmp    %edx,%ecx
  800ec5:	72 29                	jb     800ef0 <__umoddi3+0xf8>
  800ec7:	74 23                	je     800eec <__umoddi3+0xf4>
  800ec9:	89 ca                	mov    %ecx,%edx
  800ecb:	29 de                	sub    %ebx,%esi
  800ecd:	19 fa                	sbb    %edi,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ed5:	d3 e0                	shl    %cl,%eax
  800ed7:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800edb:	88 d9                	mov    %bl,%cl
  800edd:	d3 ee                	shr    %cl,%esi
  800edf:	09 f0                	or     %esi,%eax
  800ee1:	d3 ea                	shr    %cl,%edx
  800ee3:	83 c4 1c             	add    $0x1c,%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    
  800eeb:	90                   	nop
  800eec:	39 c6                	cmp    %eax,%esi
  800eee:	73 d9                	jae    800ec9 <__umoddi3+0xd1>
  800ef0:	2b 44 24 08          	sub    0x8(%esp),%eax
  800ef4:	19 ea                	sbb    %ebp,%edx
  800ef6:	89 d7                	mov    %edx,%edi
  800ef8:	89 c3                	mov    %eax,%ebx
  800efa:	eb cd                	jmp    800ec9 <__umoddi3+0xd1>
