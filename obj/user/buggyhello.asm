
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
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 05             	shl    $0x5,%edx
  800062:	29 c2                	sub    %eax,%edx
  800064:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x33>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 af ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

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
  800115:	68 2a 0f 80 00       	push   $0x800f2a
  80011a:	6a 23                	push   $0x23
  80011c:	68 47 0f 80 00       	push   $0x800f47
  800121:	e8 ee 01 00 00       	call   800314 <_panic>

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

00800145 <sys_yield>:

void
sys_yield(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	57                   	push   %edi
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014b:	ba 00 00 00 00       	mov    $0x0,%edx
  800150:	b8 0a 00 00 00       	mov    $0xa,%eax
  800155:	89 d1                	mov    %edx,%ecx
  800157:	89 d3                	mov    %edx,%ebx
  800159:	89 d7                	mov    %edx,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	be 00 00 00 00       	mov    $0x0,%esi
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800180:	89 f7                	mov    %esi,%edi
  800182:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	7f 08                	jg     800190 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	50                   	push   %eax
  800194:	6a 04                	push   $0x4
  800196:	68 2a 0f 80 00       	push   $0x800f2a
  80019b:	6a 23                	push   $0x23
  80019d:	68 47 0f 80 00       	push   $0x800f47
  8001a2:	e8 6d 01 00 00       	call   800314 <_panic>

008001a7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	7f 08                	jg     8001d2 <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	6a 05                	push   $0x5
  8001d8:	68 2a 0f 80 00       	push   $0x800f2a
  8001dd:	6a 23                	push   $0x23
  8001df:	68 47 0f 80 00       	push   $0x800f47
  8001e4:	e8 2b 01 00 00       	call   800314 <_panic>

008001e9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	89 df                	mov    %ebx,%edi
  800204:	89 de                	mov    %ebx,%esi
  800206:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7f 08                	jg     800214 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 06                	push   $0x6
  80021a:	68 2a 0f 80 00       	push   $0x800f2a
  80021f:	6a 23                	push   $0x23
  800221:	68 47 0f 80 00       	push   $0x800f47
  800226:	e8 e9 00 00 00       	call   800314 <_panic>

0080022b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800234:	bb 00 00 00 00       	mov    $0x0,%ebx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	89 df                	mov    %ebx,%edi
  800246:	89 de                	mov    %ebx,%esi
  800248:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7f 08                	jg     800256 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	6a 08                	push   $0x8
  80025c:	68 2a 0f 80 00       	push   $0x800f2a
  800261:	6a 23                	push   $0x23
  800263:	68 47 0f 80 00       	push   $0x800f47
  800268:	e8 a7 00 00 00       	call   800314 <_panic>

0080026d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	57                   	push   %edi
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	89 df                	mov    %ebx,%edi
  800288:	89 de                	mov    %ebx,%esi
  80028a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028c:	85 c0                	test   %eax,%eax
  80028e:	7f 08                	jg     800298 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800298:	83 ec 0c             	sub    $0xc,%esp
  80029b:	50                   	push   %eax
  80029c:	6a 09                	push   $0x9
  80029e:	68 2a 0f 80 00       	push   $0x800f2a
  8002a3:	6a 23                	push   $0x23
  8002a5:	68 47 0f 80 00       	push   $0x800f47
  8002aa:	e8 65 00 00 00       	call   800314 <_panic>

008002af <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c0:	be 00 00 00 00       	mov    $0x0,%esi
  8002c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e8:	89 cb                	mov    %ecx,%ebx
  8002ea:	89 cf                	mov    %ecx,%edi
  8002ec:	89 ce                	mov    %ecx,%esi
  8002ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	7f 08                	jg     8002fc <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fc:	83 ec 0c             	sub    $0xc,%esp
  8002ff:	50                   	push   %eax
  800300:	6a 0c                	push   $0xc
  800302:	68 2a 0f 80 00       	push   $0x800f2a
  800307:	6a 23                	push   $0x23
  800309:	68 47 0f 80 00       	push   $0x800f47
  80030e:	e8 01 00 00 00       	call   800314 <_panic>
	...

00800314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800322:	e8 ff fd ff ff       	call   800126 <sys_getenvid>
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	56                   	push   %esi
  800331:	50                   	push   %eax
  800332:	68 58 0f 80 00       	push   $0x800f58
  800337:	e8 b4 00 00 00       	call   8003f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	53                   	push   %ebx
  800340:	ff 75 10             	pushl  0x10(%ebp)
  800343:	e8 57 00 00 00       	call   80039f <vcprintf>
	cprintf("\n");
  800348:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  80034f:	e8 9c 00 00 00       	call   8003f0 <cprintf>
  800354:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800357:	cc                   	int3   
  800358:	eb fd                	jmp    800357 <_panic+0x43>
	...

0080035c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	53                   	push   %ebx
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800366:	8b 13                	mov    (%ebx),%edx
  800368:	8d 42 01             	lea    0x1(%edx),%eax
  80036b:	89 03                	mov    %eax,(%ebx)
  80036d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800370:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800374:	3d ff 00 00 00       	cmp    $0xff,%eax
  800379:	74 08                	je     800383 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80037b:	ff 43 04             	incl   0x4(%ebx)
}
  80037e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800381:	c9                   	leave  
  800382:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800383:	83 ec 08             	sub    $0x8,%esp
  800386:	68 ff 00 00 00       	push   $0xff
  80038b:	8d 43 08             	lea    0x8(%ebx),%eax
  80038e:	50                   	push   %eax
  80038f:	e8 14 fd ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800394:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	eb dc                	jmp    80037b <putch+0x1f>

0080039f <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003af:	00 00 00 
	b.cnt = 0;
  8003b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003bc:	ff 75 0c             	pushl  0xc(%ebp)
  8003bf:	ff 75 08             	pushl  0x8(%ebp)
  8003c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	68 5c 03 80 00       	push   $0x80035c
  8003ce:	e8 17 01 00 00       	call   8004ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d3:	83 c4 08             	add    $0x8,%esp
  8003d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e2:	50                   	push   %eax
  8003e3:	e8 c0 fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  8003e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f9:	50                   	push   %eax
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	e8 9d ff ff ff       	call   80039f <vcprintf>
	va_end(ap);

	return cnt;
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 1c             	sub    $0x1c,%esp
  80040d:	89 c7                	mov    %eax,%edi
  80040f:	89 d6                	mov    %edx,%esi
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	8b 55 0c             	mov    0xc(%ebp),%edx
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800420:	bb 00 00 00 00       	mov    $0x0,%ebx
  800425:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800428:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042b:	39 d3                	cmp    %edx,%ebx
  80042d:	72 05                	jb     800434 <printnum+0x30>
  80042f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800432:	77 78                	ja     8004ac <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	83 ec 0c             	sub    $0xc,%esp
  800437:	ff 75 18             	pushl  0x18(%ebp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800440:	53                   	push   %ebx
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044a:	ff 75 e0             	pushl  -0x20(%ebp)
  80044d:	ff 75 dc             	pushl  -0x24(%ebp)
  800450:	ff 75 d8             	pushl  -0x28(%ebp)
  800453:	e8 a8 08 00 00       	call   800d00 <__udivdi3>
  800458:	83 c4 18             	add    $0x18,%esp
  80045b:	52                   	push   %edx
  80045c:	50                   	push   %eax
  80045d:	89 f2                	mov    %esi,%edx
  80045f:	89 f8                	mov    %edi,%eax
  800461:	e8 9e ff ff ff       	call   800404 <printnum>
  800466:	83 c4 20             	add    $0x20,%esp
  800469:	eb 11                	jmp    80047c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	56                   	push   %esi
  80046f:	ff 75 18             	pushl  0x18(%ebp)
  800472:	ff d7                	call   *%edi
  800474:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	4b                   	dec    %ebx
  800478:	85 db                	test   %ebx,%ebx
  80047a:	7f ef                	jg     80046b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	83 ec 04             	sub    $0x4,%esp
  800483:	ff 75 e4             	pushl  -0x1c(%ebp)
  800486:	ff 75 e0             	pushl  -0x20(%ebp)
  800489:	ff 75 dc             	pushl  -0x24(%ebp)
  80048c:	ff 75 d8             	pushl  -0x28(%ebp)
  80048f:	e8 6c 09 00 00       	call   800e00 <__umoddi3>
  800494:	83 c4 14             	add    $0x14,%esp
  800497:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  80049e:	50                   	push   %eax
  80049f:	ff d7                	call   *%edi
}
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a7:	5b                   	pop    %ebx
  8004a8:	5e                   	pop    %esi
  8004a9:	5f                   	pop    %edi
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    
  8004ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004af:	eb c6                	jmp    800477 <printnum+0x73>

008004b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004ba:	8b 10                	mov    (%eax),%edx
  8004bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bf:	73 0a                	jae    8004cb <sprintputch+0x1a>
		*b->buf++ = ch;
  8004c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c4:	89 08                	mov    %ecx,(%eax)
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	88 02                	mov    %al,(%edx)
}
  8004cb:	5d                   	pop    %ebp
  8004cc:	c3                   	ret    

008004cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d6:	50                   	push   %eax
  8004d7:	ff 75 10             	pushl  0x10(%ebp)
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	ff 75 08             	pushl  0x8(%ebp)
  8004e0:	e8 05 00 00 00       	call   8004ea <vprintfmt>
	va_end(ap);
}
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	57                   	push   %edi
  8004ee:	56                   	push   %esi
  8004ef:	53                   	push   %ebx
  8004f0:	83 ec 2c             	sub    $0x2c,%esp
  8004f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fc:	e9 ac 03 00 00       	jmp    8008ad <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800501:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  800505:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  80050c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800513:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80051a:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8d 47 01             	lea    0x1(%edi),%eax
  800522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800525:	8a 17                	mov    (%edi),%dl
  800527:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 fc 03 00 00    	ja     80092e <vprintfmt+0x444>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800543:	eb da                	jmp    80051f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054c:	eb d1                	jmp    80051f <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	0f b6 d2             	movzbl %dl,%edx
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800554:	b8 00 00 00 00       	mov    $0x0,%eax
  800559:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055f:	01 c0                	add    %eax,%eax
  800561:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800565:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800568:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056b:	83 f9 09             	cmp    $0x9,%ecx
  80056e:	77 52                	ja     8005c2 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800570:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800571:	eb e9                	jmp    80055c <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	79 92                	jns    80051f <vprintfmt+0x35>
				width = precision, precision = -1;
  80058d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800590:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800593:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059a:	eb 83                	jmp    80051f <vprintfmt+0x35>
  80059c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a0:	78 08                	js     8005aa <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a5:	e9 75 ff ff ff       	jmp    80051f <vprintfmt+0x35>
  8005aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005b1:	eb ef                	jmp    8005a2 <vprintfmt+0xb8>
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bd:	e9 5d ff ff ff       	jmp    80051f <vprintfmt+0x35>
  8005c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c8:	eb bd                	jmp    800587 <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ca:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ce:	e9 4c ff ff ff       	jmp    80051f <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 78 04             	lea    0x4(%eax),%edi
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	ff 30                	pushl  (%eax)
  8005df:	ff d6                	call   *%esi
			break;
  8005e1:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e7:	e9 be 02 00 00       	jmp    8008aa <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 78 04             	lea    0x4(%eax),%edi
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	78 2a                	js     800622 <vprintfmt+0x138>
  8005f8:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fa:	83 f8 08             	cmp    $0x8,%eax
  8005fd:	7f 27                	jg     800626 <vprintfmt+0x13c>
  8005ff:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  800606:	85 c0                	test   %eax,%eax
  800608:	74 1c                	je     800626 <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80060a:	50                   	push   %eax
  80060b:	68 9f 0f 80 00       	push   $0x800f9f
  800610:	53                   	push   %ebx
  800611:	56                   	push   %esi
  800612:	e8 b6 fe ff ff       	call   8004cd <printfmt>
  800617:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80061d:	e9 88 02 00 00       	jmp    8008aa <vprintfmt+0x3c0>
  800622:	f7 d8                	neg    %eax
  800624:	eb d2                	jmp    8005f8 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800626:	52                   	push   %edx
  800627:	68 96 0f 80 00       	push   $0x800f96
  80062c:	53                   	push   %ebx
  80062d:	56                   	push   %esi
  80062e:	e8 9a fe ff ff       	call   8004cd <printfmt>
  800633:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800636:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800639:	e9 6c 02 00 00       	jmp    8008aa <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	83 c0 04             	add    $0x4,%eax
  800644:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 38                	mov    (%eax),%edi
  80064c:	85 ff                	test   %edi,%edi
  80064e:	74 18                	je     800668 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800650:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800654:	0f 8e b7 00 00 00    	jle    800711 <vprintfmt+0x227>
  80065a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80065e:	75 0f                	jne    80066f <vprintfmt+0x185>
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800666:	eb 75                	jmp    8006dd <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800668:	bf 8f 0f 80 00       	mov    $0x800f8f,%edi
  80066d:	eb e1                	jmp    800650 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	ff 75 d0             	pushl  -0x30(%ebp)
  800675:	57                   	push   %edi
  800676:	e8 5f 03 00 00       	call   8009da <strnlen>
  80067b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067e:	29 c1                	sub    %eax,%ecx
  800680:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800683:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800686:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800690:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800692:	eb 0d                	jmp    8006a1 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	4f                   	dec    %edi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	7f ef                	jg     800694 <vprintfmt+0x1aa>
  8006a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ab:	89 c8                	mov    %ecx,%eax
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	78 10                	js     8006c1 <vprintfmt+0x1d7>
  8006b1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b4:	29 c1                	sub    %eax,%ecx
  8006b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006bf:	eb 1c                	jmp    8006dd <vprintfmt+0x1f3>
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c6:	eb e9                	jmp    8006b1 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006cc:	75 29                	jne    8006f7 <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	50                   	push   %eax
  8006d5:	ff d6                	call   *%esi
  8006d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	ff 4d e0             	decl   -0x20(%ebp)
  8006dd:	47                   	inc    %edi
  8006de:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006e1:	0f be c2             	movsbl %dl,%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 4c                	je     800734 <vprintfmt+0x24a>
  8006e8:	85 db                	test   %ebx,%ebx
  8006ea:	78 dc                	js     8006c8 <vprintfmt+0x1de>
  8006ec:	4b                   	dec    %ebx
  8006ed:	79 d9                	jns    8006c8 <vprintfmt+0x1de>
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006f5:	eb 2e                	jmp    800725 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f7:	0f be d2             	movsbl %dl,%edx
  8006fa:	83 ea 20             	sub    $0x20,%edx
  8006fd:	83 fa 5e             	cmp    $0x5e,%edx
  800700:	76 cc                	jbe    8006ce <vprintfmt+0x1e4>
					putch('?', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	6a 3f                	push   $0x3f
  80070a:	ff d6                	call   *%esi
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb c9                	jmp    8006da <vprintfmt+0x1f0>
  800711:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800714:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800717:	eb c4                	jmp    8006dd <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	6a 20                	push   $0x20
  80071f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800721:	4f                   	dec    %edi
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	85 ff                	test   %edi,%edi
  800727:	7f f0                	jg     800719 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800729:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
  80072f:	e9 76 01 00 00       	jmp    8008aa <vprintfmt+0x3c0>
  800734:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb e9                	jmp    800725 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073c:	83 f9 01             	cmp    $0x1,%ecx
  80073f:	7e 3f                	jle    800780 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 50 04             	mov    0x4(%eax),%edx
  800747:	8b 00                	mov    (%eax),%eax
  800749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 40 08             	lea    0x8(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800758:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075c:	79 5c                	jns    8007ba <vprintfmt+0x2d0>
				putch('-', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 2d                	push   $0x2d
  800764:	ff d6                	call   *%esi
				num = -(long long) num;
  800766:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800769:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076c:	f7 da                	neg    %edx
  80076e:	83 d1 00             	adc    $0x0,%ecx
  800771:	f7 d9                	neg    %ecx
  800773:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800776:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077b:	e9 10 01 00 00       	jmp    800890 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800780:	85 c9                	test   %ecx,%ecx
  800782:	75 1b                	jne    80079f <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 00                	mov    (%eax),%eax
  800789:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078c:	89 c1                	mov    %eax,%ecx
  80078e:	c1 f9 1f             	sar    $0x1f,%ecx
  800791:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
  80079d:	eb b9                	jmp    800758 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a7:	89 c1                	mov    %eax,%ecx
  8007a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b8:	eb 9e                	jmp    800758 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c5:	e9 c6 00 00 00       	jmp    800890 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 18                	jle    8007e7 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e2:	e9 a9 00 00 00       	jmp    800890 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007e7:	85 c9                	test   %ecx,%ecx
  8007e9:	75 1a                	jne    800805 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8b 10                	mov    (%eax),%edx
  8007f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f5:	8d 40 04             	lea    0x4(%eax),%eax
  8007f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800800:	e9 8b 00 00 00       	jmp    800890 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081a:	eb 74                	jmp    800890 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7e 15                	jle    800836 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	8b 48 04             	mov    0x4(%eax),%ecx
  800829:	8d 40 08             	lea    0x8(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80082f:	b8 08 00 00 00       	mov    $0x8,%eax
  800834:	eb 5a                	jmp    800890 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	75 17                	jne    800851 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  80084a:	b8 08 00 00 00       	mov    $0x8,%eax
  80084f:	eb 3f                	jmp    800890 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800861:	b8 08 00 00 00       	mov    $0x8,%eax
  800866:	eb 28                	jmp    800890 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 30                	push   $0x30
  80086e:	ff d6                	call   *%esi
			putch('x', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 78                	push   $0x78
  800876:	ff d6                	call   *%esi
			num = (unsigned long long)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800882:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800885:	8d 40 04             	lea    0x4(%eax),%eax
  800888:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088b:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800890:	83 ec 0c             	sub    $0xc,%esp
  800893:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800897:	57                   	push   %edi
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	50                   	push   %eax
  80089c:	51                   	push   %ecx
  80089d:	52                   	push   %edx
  80089e:	89 da                	mov    %ebx,%edx
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	e8 5d fb ff ff       	call   800404 <printnum>
			break;
  8008a7:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ad:	47                   	inc    %edi
  8008ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b2:	83 f8 25             	cmp    $0x25,%eax
  8008b5:	0f 84 46 fc ff ff    	je     800501 <vprintfmt+0x17>
			if (ch == '\0')
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	0f 84 89 00 00 00    	je     80094c <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	50                   	push   %eax
  8008c8:	ff d6                	call   *%esi
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	eb de                	jmp    8008ad <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008cf:	83 f9 01             	cmp    $0x1,%ecx
  8008d2:	7e 15                	jle    8008e9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8b 10                	mov    (%eax),%edx
  8008d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008dc:	8d 40 08             	lea    0x8(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008e2:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e7:	eb a7                	jmp    800890 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	75 17                	jne    800904 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8b 10                	mov    (%eax),%edx
  8008f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f7:	8d 40 04             	lea    0x4(%eax),%eax
  8008fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008fd:	b8 10 00 00 00       	mov    $0x10,%eax
  800902:	eb 8c                	jmp    800890 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800904:	8b 45 14             	mov    0x14(%ebp),%eax
  800907:	8b 10                	mov    (%eax),%edx
  800909:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800914:	b8 10 00 00 00       	mov    $0x10,%eax
  800919:	e9 72 ff ff ff       	jmp    800890 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	6a 25                	push   $0x25
  800924:	ff d6                	call   *%esi
			break;
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	e9 7c ff ff ff       	jmp    8008aa <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 25                	push   $0x25
  800934:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	89 f8                	mov    %edi,%eax
  80093b:	eb 01                	jmp    80093e <vprintfmt+0x454>
  80093d:	48                   	dec    %eax
  80093e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800942:	75 f9                	jne    80093d <vprintfmt+0x453>
  800944:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800947:	e9 5e ff ff ff       	jmp    8008aa <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  80094c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 18             	sub    $0x18,%esp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800960:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800963:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800967:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80096a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 26                	je     80099b <vsnprintf+0x47>
  800975:	85 d2                	test   %edx,%edx
  800977:	7e 29                	jle    8009a2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800979:	ff 75 14             	pushl  0x14(%ebp)
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800982:	50                   	push   %eax
  800983:	68 b1 04 80 00       	push   $0x8004b1
  800988:	e8 5d fb ff ff       	call   8004ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80098d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800990:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800996:	83 c4 10             	add    $0x10,%esp
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80099b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a0:	eb f7                	jmp    800999 <vsnprintf+0x45>
  8009a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a7:	eb f0                	jmp    800999 <vsnprintf+0x45>

008009a9 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b2:	50                   	push   %eax
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 93 ff ff ff       	call   800954 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    
	...

008009c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cf:	eb 01                	jmp    8009d2 <strlen+0xe>
		n++;
  8009d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d6:	75 f9                	jne    8009d1 <strlen+0xd>
		n++;
	return n;
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb 01                	jmp    8009eb <strnlen+0x11>
		n++;
  8009ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009eb:	39 d0                	cmp    %edx,%eax
  8009ed:	74 06                	je     8009f5 <strnlen+0x1b>
  8009ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f3:	75 f5                	jne    8009ea <strnlen+0x10>
		n++;
	return n;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	41                   	inc    %ecx
  800a04:	42                   	inc    %edx
  800a05:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a08:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a0b:	84 db                	test   %bl,%bl
  800a0d:	75 f4                	jne    800a03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a19:	53                   	push   %ebx
  800a1a:	e8 a5 ff ff ff       	call   8009c4 <strlen>
  800a1f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	01 d8                	add    %ebx,%eax
  800a27:	50                   	push   %eax
  800a28:	e8 ca ff ff ff       	call   8009f7 <strcpy>
	return dst;
}
  800a2d:	89 d8                	mov    %ebx,%eax
  800a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a44:	89 f2                	mov    %esi,%edx
  800a46:	39 da                	cmp    %ebx,%edx
  800a48:	74 0e                	je     800a58 <strncpy+0x24>
		*dst++ = *src;
  800a4a:	42                   	inc    %edx
  800a4b:	8a 01                	mov    (%ecx),%al
  800a4d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a50:	80 39 00             	cmpb   $0x0,(%ecx)
  800a53:	74 f1                	je     800a46 <strncpy+0x12>
			src++;
  800a55:	41                   	inc    %ecx
  800a56:	eb ee                	jmp    800a46 <strncpy+0x12>
	}
	return ret;
}
  800a58:	89 f0                	mov    %esi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a69:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	74 20                	je     800a90 <strlcpy+0x32>
  800a70:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	eb 05                	jmp    800a7d <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a78:	42                   	inc    %edx
  800a79:	40                   	inc    %eax
  800a7a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7d:	39 d8                	cmp    %ebx,%eax
  800a7f:	74 06                	je     800a87 <strlcpy+0x29>
  800a81:	8a 0a                	mov    (%edx),%cl
  800a83:	84 c9                	test   %cl,%cl
  800a85:	75 f1                	jne    800a78 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a8a:	29 f0                	sub    %esi,%eax
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    
  800a90:	89 f0                	mov    %esi,%eax
  800a92:	eb f6                	jmp    800a8a <strlcpy+0x2c>

00800a94 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9d:	eb 02                	jmp    800aa1 <strcmp+0xd>
		p++, q++;
  800a9f:	41                   	inc    %ecx
  800aa0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa1:	8a 01                	mov    (%ecx),%al
  800aa3:	84 c0                	test   %al,%al
  800aa5:	74 04                	je     800aab <strcmp+0x17>
  800aa7:	3a 02                	cmp    (%edx),%al
  800aa9:	74 f4                	je     800a9f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aab:	0f b6 c0             	movzbl %al,%eax
  800aae:	0f b6 12             	movzbl (%edx),%edx
  800ab1:	29 d0                	sub    %edx,%eax
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	53                   	push   %ebx
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac4:	eb 02                	jmp    800ac8 <strncmp+0x13>
		n--, p++, q++;
  800ac6:	40                   	inc    %eax
  800ac7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac8:	39 d8                	cmp    %ebx,%eax
  800aca:	74 15                	je     800ae1 <strncmp+0x2c>
  800acc:	8a 08                	mov    (%eax),%cl
  800ace:	84 c9                	test   %cl,%cl
  800ad0:	74 04                	je     800ad6 <strncmp+0x21>
  800ad2:	3a 0a                	cmp    (%edx),%cl
  800ad4:	74 f0                	je     800ac6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad6:	0f b6 00             	movzbl (%eax),%eax
  800ad9:	0f b6 12             	movzbl (%edx),%edx
  800adc:	29 d0                	sub    %edx,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	eb f6                	jmp    800ade <strncmp+0x29>

00800ae8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800af1:	8a 10                	mov    (%eax),%dl
  800af3:	84 d2                	test   %dl,%dl
  800af5:	74 07                	je     800afe <strchr+0x16>
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 08                	je     800b03 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afb:	40                   	inc    %eax
  800afc:	eb f3                	jmp    800af1 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b0e:	8a 10                	mov    (%eax),%dl
  800b10:	84 d2                	test   %dl,%dl
  800b12:	74 07                	je     800b1b <strfind+0x16>
		if (*s == c)
  800b14:	38 ca                	cmp    %cl,%dl
  800b16:	74 03                	je     800b1b <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b18:	40                   	inc    %eax
  800b19:	eb f3                	jmp    800b0e <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b29:	85 c9                	test   %ecx,%ecx
  800b2b:	74 13                	je     800b40 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b33:	75 05                	jne    800b3a <memset+0x1d>
  800b35:	f6 c1 03             	test   $0x3,%cl
  800b38:	74 0d                	je     800b47 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	fc                   	cld    
  800b3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b40:	89 f8                	mov    %edi,%eax
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b47:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	c1 e3 08             	shl    $0x8,%ebx
  800b50:	89 d0                	mov    %edx,%eax
  800b52:	c1 e0 18             	shl    $0x18,%eax
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	c1 e6 10             	shl    $0x10,%esi
  800b5a:	09 f0                	or     %esi,%eax
  800b5c:	09 c2                	or     %eax,%edx
  800b5e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b60:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b63:	89 d0                	mov    %edx,%eax
  800b65:	fc                   	cld    
  800b66:	f3 ab                	rep stos %eax,%es:(%edi)
  800b68:	eb d6                	jmp    800b40 <memset+0x23>

00800b6a <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b78:	39 c6                	cmp    %eax,%esi
  800b7a:	73 33                	jae    800baf <memmove+0x45>
  800b7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b7f:	39 c2                	cmp    %eax,%edx
  800b81:	76 2c                	jbe    800baf <memmove+0x45>
		s += n;
		d += n;
  800b83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	09 fe                	or     %edi,%esi
  800b8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b90:	74 0a                	je     800b9c <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b92:	4f                   	dec    %edi
  800b93:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b96:	fd                   	std    
  800b97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b99:	fc                   	cld    
  800b9a:	eb 21                	jmp    800bbd <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 f1                	jne    800b92 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba1:	83 ef 04             	sub    $0x4,%edi
  800ba4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800baa:	fd                   	std    
  800bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bad:	eb ea                	jmp    800b99 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	89 f2                	mov    %esi,%edx
  800bb1:	09 c2                	or     %eax,%edx
  800bb3:	f6 c2 03             	test   $0x3,%dl
  800bb6:	74 09                	je     800bc1 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	fc                   	cld    
  800bbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	f6 c1 03             	test   $0x3,%cl
  800bc4:	75 f2                	jne    800bb8 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	fc                   	cld    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb ed                	jmp    800bbd <memmove+0x53>

00800bd0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd3:	ff 75 10             	pushl  0x10(%ebp)
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	ff 75 08             	pushl  0x8(%ebp)
  800bdc:	e8 89 ff ff ff       	call   800b6a <memmove>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bee:	89 c6                	mov    %eax,%esi
  800bf0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf3:	39 f0                	cmp    %esi,%eax
  800bf5:	74 16                	je     800c0d <memcmp+0x2a>
		if (*s1 != *s2)
  800bf7:	8a 08                	mov    (%eax),%cl
  800bf9:	8a 1a                	mov    (%edx),%bl
  800bfb:	38 d9                	cmp    %bl,%cl
  800bfd:	75 04                	jne    800c03 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bff:	40                   	inc    %eax
  800c00:	42                   	inc    %edx
  800c01:	eb f0                	jmp    800bf3 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800c03:	0f b6 c1             	movzbl %cl,%eax
  800c06:	0f b6 db             	movzbl %bl,%ebx
  800c09:	29 d8                	sub    %ebx,%eax
  800c0b:	eb 05                	jmp    800c12 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	73 07                	jae    800c2f <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c28:	38 08                	cmp    %cl,(%eax)
  800c2a:	74 03                	je     800c2f <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2c:	40                   	inc    %eax
  800c2d:	eb f5                	jmp    800c24 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	eb 01                	jmp    800c3d <strtol+0xc>
		s++;
  800c3c:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3d:	8a 01                	mov    (%ecx),%al
  800c3f:	3c 20                	cmp    $0x20,%al
  800c41:	74 f9                	je     800c3c <strtol+0xb>
  800c43:	3c 09                	cmp    $0x9,%al
  800c45:	74 f5                	je     800c3c <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c47:	3c 2b                	cmp    $0x2b,%al
  800c49:	74 2b                	je     800c76 <strtol+0x45>
		s++;
	else if (*s == '-')
  800c4b:	3c 2d                	cmp    $0x2d,%al
  800c4d:	74 2f                	je     800c7e <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c54:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c5b:	75 12                	jne    800c6f <strtol+0x3e>
  800c5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c60:	74 24                	je     800c86 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c66:	75 07                	jne    800c6f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c68:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	eb 4e                	jmp    800cc4 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c76:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	eb d6                	jmp    800c54 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c7e:	41                   	inc    %ecx
  800c7f:	bf 01 00 00 00       	mov    $0x1,%edi
  800c84:	eb ce                	jmp    800c54 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c86:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8a:	74 10                	je     800c9c <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c90:	75 dd                	jne    800c6f <strtol+0x3e>
		s++, base = 8;
  800c92:	41                   	inc    %ecx
  800c93:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c9a:	eb d3                	jmp    800c6f <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800c9c:	83 c1 02             	add    $0x2,%ecx
  800c9f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ca6:	eb c7                	jmp    800c6f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ca8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cab:	89 f3                	mov    %esi,%ebx
  800cad:	80 fb 19             	cmp    $0x19,%bl
  800cb0:	77 24                	ja     800cd6 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cb2:	0f be d2             	movsbl %dl,%edx
  800cb5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb8:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cbb:	7e 2b                	jle    800ce8 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cbd:	41                   	inc    %ecx
  800cbe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc2:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc4:	8a 11                	mov    (%ecx),%dl
  800cc6:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800cc9:	80 fb 09             	cmp    $0x9,%bl
  800ccc:	77 da                	ja     800ca8 <strtol+0x77>
			dig = *s - '0';
  800cce:	0f be d2             	movsbl %dl,%edx
  800cd1:	83 ea 30             	sub    $0x30,%edx
  800cd4:	eb e2                	jmp    800cb8 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd9:	89 f3                	mov    %esi,%ebx
  800cdb:	80 fb 19             	cmp    $0x19,%bl
  800cde:	77 08                	ja     800ce8 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ce0:	0f be d2             	movsbl %dl,%edx
  800ce3:	83 ea 37             	sub    $0x37,%edx
  800ce6:	eb d0                	jmp    800cb8 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cec:	74 05                	je     800cf3 <strtol+0xc2>
		*endptr = (char *) s;
  800cee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cf3:	85 ff                	test   %edi,%edi
  800cf5:	74 02                	je     800cf9 <strtol+0xc8>
  800cf7:	f7 d8                	neg    %eax
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
	...

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d0b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d0f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d13:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d17:	85 d2                	test   %edx,%edx
  800d19:	75 2d                	jne    800d48 <__udivdi3+0x48>
  800d1b:	39 f7                	cmp    %esi,%edi
  800d1d:	77 59                	ja     800d78 <__udivdi3+0x78>
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	85 ff                	test   %edi,%edi
  800d23:	75 0b                	jne    800d30 <__udivdi3+0x30>
  800d25:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2a:	31 d2                	xor    %edx,%edx
  800d2c:	f7 f7                	div    %edi
  800d2e:	89 c1                	mov    %eax,%ecx
  800d30:	31 d2                	xor    %edx,%edx
  800d32:	89 f0                	mov    %esi,%eax
  800d34:	f7 f1                	div    %ecx
  800d36:	89 c3                	mov    %eax,%ebx
  800d38:	89 e8                	mov    %ebp,%eax
  800d3a:	f7 f1                	div    %ecx
  800d3c:	89 da                	mov    %ebx,%edx
  800d3e:	83 c4 1c             	add    $0x1c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	77 1c                	ja     800d68 <__udivdi3+0x68>
  800d4c:	0f bd da             	bsr    %edx,%ebx
  800d4f:	83 f3 1f             	xor    $0x1f,%ebx
  800d52:	75 38                	jne    800d8c <__udivdi3+0x8c>
  800d54:	39 f2                	cmp    %esi,%edx
  800d56:	72 08                	jb     800d60 <__udivdi3+0x60>
  800d58:	39 ef                	cmp    %ebp,%edi
  800d5a:	0f 87 98 00 00 00    	ja     800df8 <__udivdi3+0xf8>
  800d60:	b8 01 00 00 00       	mov    $0x1,%eax
  800d65:	eb 05                	jmp    800d6c <__udivdi3+0x6c>
  800d67:	90                   	nop
  800d68:	31 db                	xor    %ebx,%ebx
  800d6a:	31 c0                	xor    %eax,%eax
  800d6c:	89 da                	mov    %ebx,%edx
  800d6e:	83 c4 1c             	add    $0x1c,%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	89 e8                	mov    %ebp,%eax
  800d7a:	89 f2                	mov    %esi,%edx
  800d7c:	f7 f7                	div    %edi
  800d7e:	31 db                	xor    %ebx,%ebx
  800d80:	89 da                	mov    %ebx,%edx
  800d82:	83 c4 1c             	add    $0x1c,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	29 d8                	sub    %ebx,%eax
  800d93:	88 d9                	mov    %bl,%cl
  800d95:	d3 e2                	shl    %cl,%edx
  800d97:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d9b:	89 fa                	mov    %edi,%edx
  800d9d:	88 c1                	mov    %al,%cl
  800d9f:	d3 ea                	shr    %cl,%edx
  800da1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da5:	09 d1                	or     %edx,%ecx
  800da7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dab:	88 d9                	mov    %bl,%cl
  800dad:	d3 e7                	shl    %cl,%edi
  800daf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800db3:	89 f7                	mov    %esi,%edi
  800db5:	88 c1                	mov    %al,%cl
  800db7:	d3 ef                	shr    %cl,%edi
  800db9:	88 d9                	mov    %bl,%cl
  800dbb:	d3 e6                	shl    %cl,%esi
  800dbd:	89 ea                	mov    %ebp,%edx
  800dbf:	88 c1                	mov    %al,%cl
  800dc1:	d3 ea                	shr    %cl,%edx
  800dc3:	09 d6                	or     %edx,%esi
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	89 fa                	mov    %edi,%edx
  800dc9:	f7 74 24 08          	divl   0x8(%esp)
  800dcd:	89 d7                	mov    %edx,%edi
  800dcf:	89 c6                	mov    %eax,%esi
  800dd1:	f7 64 24 0c          	mull   0xc(%esp)
  800dd5:	39 d7                	cmp    %edx,%edi
  800dd7:	72 13                	jb     800dec <__udivdi3+0xec>
  800dd9:	74 09                	je     800de4 <__udivdi3+0xe4>
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	31 db                	xor    %ebx,%ebx
  800ddf:	eb 8b                	jmp    800d6c <__udivdi3+0x6c>
  800de1:	8d 76 00             	lea    0x0(%esi),%esi
  800de4:	88 d9                	mov    %bl,%cl
  800de6:	d3 e5                	shl    %cl,%ebp
  800de8:	39 c5                	cmp    %eax,%ebp
  800dea:	73 ef                	jae    800ddb <__udivdi3+0xdb>
  800dec:	8d 46 ff             	lea    -0x1(%esi),%eax
  800def:	31 db                	xor    %ebx,%ebx
  800df1:	e9 76 ff ff ff       	jmp    800d6c <__udivdi3+0x6c>
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	31 c0                	xor    %eax,%eax
  800dfa:	e9 6d ff ff ff       	jmp    800d6c <__udivdi3+0x6c>
	...

00800e00 <__umoddi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e0b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e0f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e13:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	89 da                	mov    %ebx,%edx
  800e1b:	85 ed                	test   %ebp,%ebp
  800e1d:	75 15                	jne    800e34 <__umoddi3+0x34>
  800e1f:	39 df                	cmp    %ebx,%edi
  800e21:	76 39                	jbe    800e5c <__umoddi3+0x5c>
  800e23:	f7 f7                	div    %edi
  800e25:	89 d0                	mov    %edx,%eax
  800e27:	31 d2                	xor    %edx,%edx
  800e29:	83 c4 1c             	add    $0x1c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    
  800e31:	8d 76 00             	lea    0x0(%esi),%esi
  800e34:	39 dd                	cmp    %ebx,%ebp
  800e36:	77 f1                	ja     800e29 <__umoddi3+0x29>
  800e38:	0f bd cd             	bsr    %ebp,%ecx
  800e3b:	83 f1 1f             	xor    $0x1f,%ecx
  800e3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e42:	75 38                	jne    800e7c <__umoddi3+0x7c>
  800e44:	39 dd                	cmp    %ebx,%ebp
  800e46:	72 04                	jb     800e4c <__umoddi3+0x4c>
  800e48:	39 f7                	cmp    %esi,%edi
  800e4a:	77 dd                	ja     800e29 <__umoddi3+0x29>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	83 c4 1c             	add    $0x1c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
  800e5c:	89 f9                	mov    %edi,%ecx
  800e5e:	85 ff                	test   %edi,%edi
  800e60:	75 0b                	jne    800e6d <__umoddi3+0x6d>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	31 d2                	xor    %edx,%edx
  800e69:	f7 f7                	div    %edi
  800e6b:	89 c1                	mov    %eax,%ecx
  800e6d:	89 d8                	mov    %ebx,%eax
  800e6f:	31 d2                	xor    %edx,%edx
  800e71:	f7 f1                	div    %ecx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	eb ac                	jmp    800e25 <__umoddi3+0x25>
  800e79:	8d 76 00             	lea    0x0(%esi),%esi
  800e7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e81:	89 c2                	mov    %eax,%edx
  800e83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e87:	29 c2                	sub    %eax,%edx
  800e89:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e8d:	88 c1                	mov    %al,%cl
  800e8f:	d3 e5                	shl    %cl,%ebp
  800e91:	89 f8                	mov    %edi,%eax
  800e93:	88 d1                	mov    %dl,%cl
  800e95:	d3 e8                	shr    %cl,%eax
  800e97:	09 c5                	or     %eax,%ebp
  800e99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9d:	88 c1                	mov    %al,%cl
  800e9f:	d3 e7                	shl    %cl,%edi
  800ea1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea5:	89 df                	mov    %ebx,%edi
  800ea7:	88 d1                	mov    %dl,%cl
  800ea9:	d3 ef                	shr    %cl,%edi
  800eab:	88 c1                	mov    %al,%cl
  800ead:	d3 e3                	shl    %cl,%ebx
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	88 d1                	mov    %dl,%cl
  800eb3:	d3 e8                	shr    %cl,%eax
  800eb5:	09 d8                	or     %ebx,%eax
  800eb7:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ebb:	d3 e6                	shl    %cl,%esi
  800ebd:	89 fa                	mov    %edi,%edx
  800ebf:	f7 f5                	div    %ebp
  800ec1:	89 d1                	mov    %edx,%ecx
  800ec3:	f7 64 24 08          	mull   0x8(%esp)
  800ec7:	89 c3                	mov    %eax,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	39 d1                	cmp    %edx,%ecx
  800ecd:	72 29                	jb     800ef8 <__umoddi3+0xf8>
  800ecf:	74 23                	je     800ef4 <__umoddi3+0xf4>
  800ed1:	89 ca                	mov    %ecx,%edx
  800ed3:	29 de                	sub    %ebx,%esi
  800ed5:	19 fa                	sbb    %edi,%edx
  800ed7:	89 d0                	mov    %edx,%eax
  800ed9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800edd:	d3 e0                	shl    %cl,%eax
  800edf:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800ee3:	88 d9                	mov    %bl,%cl
  800ee5:	d3 ee                	shr    %cl,%esi
  800ee7:	09 f0                	or     %esi,%eax
  800ee9:	d3 ea                	shr    %cl,%edx
  800eeb:	83 c4 1c             	add    $0x1c,%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
  800ef4:	39 c6                	cmp    %eax,%esi
  800ef6:	73 d9                	jae    800ed1 <__umoddi3+0xd1>
  800ef8:	2b 44 24 08          	sub    0x8(%esp),%eax
  800efc:	19 ea                	sbb    %ebp,%edx
  800efe:	89 d7                	mov    %edx,%edi
  800f00:	89 c3                	mov    %eax,%ebx
  800f02:	eb cd                	jmp    800ed1 <__umoddi3+0xd1>
