
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
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
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
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 05             	shl    $0x5,%edx
  80006a:	29 c2                	sub    %eax,%edx
  80006c:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  800073:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x33>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a7 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

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
  80011d:	68 38 0f 80 00       	push   $0x800f38
  800122:	6a 23                	push   $0x23
  800124:	68 55 0f 80 00       	push   $0x800f55
  800129:	e8 ee 01 00 00       	call   80031c <_panic>

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

0080014d <sys_yield>:

void
sys_yield(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	be 00 00 00 00       	mov    $0x0,%esi
  80017a:	8b 55 08             	mov    0x8(%ebp),%edx
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	b8 04 00 00 00       	mov    $0x4,%eax
  800185:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800188:	89 f7                	mov    %esi,%edi
  80018a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018c:	85 c0                	test   %eax,%eax
  80018e:	7f 08                	jg     800198 <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	50                   	push   %eax
  80019c:	6a 04                	push   $0x4
  80019e:	68 38 0f 80 00       	push   $0x800f38
  8001a3:	6a 23                	push   $0x23
  8001a5:	68 55 0f 80 00       	push   $0x800f55
  8001aa:	e8 6d 01 00 00       	call   80031c <_panic>

008001af <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	7f 08                	jg     8001da <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	50                   	push   %eax
  8001de:	6a 05                	push   $0x5
  8001e0:	68 38 0f 80 00       	push   $0x800f38
  8001e5:	6a 23                	push   $0x23
  8001e7:	68 55 0f 80 00       	push   $0x800f55
  8001ec:	e8 2b 01 00 00       	call   80031c <_panic>

008001f1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	89 df                	mov    %ebx,%edi
  80020c:	89 de                	mov    %ebx,%esi
  80020e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7f 08                	jg     80021c <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	50                   	push   %eax
  800220:	6a 06                	push   $0x6
  800222:	68 38 0f 80 00       	push   $0x800f38
  800227:	6a 23                	push   $0x23
  800229:	68 55 0f 80 00       	push   $0x800f55
  80022e:	e8 e9 00 00 00       	call   80031c <_panic>

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	b8 08 00 00 00       	mov    $0x8,%eax
  80024c:	89 df                	mov    %ebx,%edi
  80024e:	89 de                	mov    %ebx,%esi
  800250:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800252:	85 c0                	test   %eax,%eax
  800254:	7f 08                	jg     80025e <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	50                   	push   %eax
  800262:	6a 08                	push   $0x8
  800264:	68 38 0f 80 00       	push   $0x800f38
  800269:	6a 23                	push   $0x23
  80026b:	68 55 0f 80 00       	push   $0x800f55
  800270:	e8 a7 00 00 00       	call   80031c <_panic>

00800275 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	89 df                	mov    %ebx,%edi
  800290:	89 de                	mov    %ebx,%esi
  800292:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	7f 08                	jg     8002a0 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a0:	83 ec 0c             	sub    $0xc,%esp
  8002a3:	50                   	push   %eax
  8002a4:	6a 09                	push   $0x9
  8002a6:	68 38 0f 80 00       	push   $0x800f38
  8002ab:	6a 23                	push   $0x23
  8002ad:	68 55 0f 80 00       	push   $0x800f55
  8002b2:	e8 65 00 00 00       	call   80031c <_panic>

008002b7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c8:	be 00 00 00 00       	mov    $0x0,%esi
  8002cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f0:	89 cb                	mov    %ecx,%ebx
  8002f2:	89 cf                	mov    %ecx,%edi
  8002f4:	89 ce                	mov    %ecx,%esi
  8002f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	7f 08                	jg     800304 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  800304:	83 ec 0c             	sub    $0xc,%esp
  800307:	50                   	push   %eax
  800308:	6a 0c                	push   $0xc
  80030a:	68 38 0f 80 00       	push   $0x800f38
  80030f:	6a 23                	push   $0x23
  800311:	68 55 0f 80 00       	push   $0x800f55
  800316:	e8 01 00 00 00       	call   80031c <_panic>
	...

0080031c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800324:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80032a:	e8 ff fd ff ff       	call   80012e <sys_getenvid>
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	56                   	push   %esi
  800339:	50                   	push   %eax
  80033a:	68 64 0f 80 00       	push   $0x800f64
  80033f:	e8 b4 00 00 00       	call   8003f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800344:	83 c4 18             	add    $0x18,%esp
  800347:	53                   	push   %ebx
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	e8 57 00 00 00       	call   8003a7 <vcprintf>
	cprintf("\n");
  800350:	c7 04 24 2c 0f 80 00 	movl   $0x800f2c,(%esp)
  800357:	e8 9c 00 00 00       	call   8003f8 <cprintf>
  80035c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035f:	cc                   	int3   
  800360:	eb fd                	jmp    80035f <_panic+0x43>
	...

00800364 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	53                   	push   %ebx
  800368:	83 ec 04             	sub    $0x4,%esp
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036e:	8b 13                	mov    (%ebx),%edx
  800370:	8d 42 01             	lea    0x1(%edx),%eax
  800373:	89 03                	mov    %eax,(%ebx)
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80037c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800381:	74 08                	je     80038b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800383:	ff 43 04             	incl   0x4(%ebx)
}
  800386:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800389:	c9                   	leave  
  80038a:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	68 ff 00 00 00       	push   $0xff
  800393:	8d 43 08             	lea    0x8(%ebx),%eax
  800396:	50                   	push   %eax
  800397:	e8 14 fd ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80039c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a2:	83 c4 10             	add    $0x10,%esp
  8003a5:	eb dc                	jmp    800383 <putch+0x1f>

008003a7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b7:	00 00 00 
	b.cnt = 0;
  8003ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c4:	ff 75 0c             	pushl  0xc(%ebp)
  8003c7:	ff 75 08             	pushl  0x8(%ebp)
  8003ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	68 64 03 80 00       	push   $0x800364
  8003d6:	e8 17 01 00 00       	call   8004f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003db:	83 c4 08             	add    $0x8,%esp
  8003de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ea:	50                   	push   %eax
  8003eb:	e8 c0 fc ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8003f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800401:	50                   	push   %eax
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	e8 9d ff ff ff       	call   8003a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 1c             	sub    $0x1c,%esp
  800415:	89 c7                	mov    %eax,%edi
  800417:	89 d6                	mov    %edx,%esi
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800422:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800425:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800428:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800430:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800433:	39 d3                	cmp    %edx,%ebx
  800435:	72 05                	jb     80043c <printnum+0x30>
  800437:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043a:	77 78                	ja     8004b4 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043c:	83 ec 0c             	sub    $0xc,%esp
  80043f:	ff 75 18             	pushl  0x18(%ebp)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800448:	53                   	push   %ebx
  800449:	ff 75 10             	pushl  0x10(%ebp)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800452:	ff 75 e0             	pushl  -0x20(%ebp)
  800455:	ff 75 dc             	pushl  -0x24(%ebp)
  800458:	ff 75 d8             	pushl  -0x28(%ebp)
  80045b:	e8 a8 08 00 00       	call   800d08 <__udivdi3>
  800460:	83 c4 18             	add    $0x18,%esp
  800463:	52                   	push   %edx
  800464:	50                   	push   %eax
  800465:	89 f2                	mov    %esi,%edx
  800467:	89 f8                	mov    %edi,%eax
  800469:	e8 9e ff ff ff       	call   80040c <printnum>
  80046e:	83 c4 20             	add    $0x20,%esp
  800471:	eb 11                	jmp    800484 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	56                   	push   %esi
  800477:	ff 75 18             	pushl  0x18(%ebp)
  80047a:	ff d7                	call   *%edi
  80047c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047f:	4b                   	dec    %ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f ef                	jg     800473 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	56                   	push   %esi
  800488:	83 ec 04             	sub    $0x4,%esp
  80048b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048e:	ff 75 e0             	pushl  -0x20(%ebp)
  800491:	ff 75 dc             	pushl  -0x24(%ebp)
  800494:	ff 75 d8             	pushl  -0x28(%ebp)
  800497:	e8 6c 09 00 00       	call   800e08 <__umoddi3>
  80049c:	83 c4 14             	add    $0x14,%esp
  80049f:	0f be 80 88 0f 80 00 	movsbl 0x800f88(%eax),%eax
  8004a6:	50                   	push   %eax
  8004a7:	ff d7                	call   *%edi
}
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5f                   	pop    %edi
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    
  8004b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b7:	eb c6                	jmp    80047f <printnum+0x73>

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c7:	73 0a                	jae    8004d3 <sprintputch+0x1a>
		*b->buf++ = ch;
  8004c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	88 02                	mov    %al,(%edx)
}
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004de:	50                   	push   %eax
  8004df:	ff 75 10             	pushl  0x10(%ebp)
  8004e2:	ff 75 0c             	pushl  0xc(%ebp)
  8004e5:	ff 75 08             	pushl  0x8(%ebp)
  8004e8:	e8 05 00 00 00       	call   8004f2 <vprintfmt>
	va_end(ap);
}
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 2c             	sub    $0x2c,%esp
  8004fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800501:	8b 7d 10             	mov    0x10(%ebp),%edi
  800504:	e9 ac 03 00 00       	jmp    8008b5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800509:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  80050d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800514:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8d 47 01             	lea    0x1(%edi),%eax
  80052a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052d:	8a 17                	mov    (%edi),%dl
  80052f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800532:	3c 55                	cmp    $0x55,%al
  800534:	0f 87 fc 03 00 00    	ja     800936 <vprintfmt+0x444>
  80053a:	0f b6 c0             	movzbl %al,%eax
  80053d:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80054b:	eb da                	jmp    800527 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800554:	eb d1                	jmp    800527 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	0f b6 d2             	movzbl %dl,%edx
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80055c:	b8 00 00 00 00       	mov    $0x0,%eax
  800561:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800564:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800567:	01 c0                	add    %eax,%eax
  800569:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80056d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800570:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800573:	83 f9 09             	cmp    $0x9,%ecx
  800576:	77 52                	ja     8005ca <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800578:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800579:	eb e9                	jmp    800564 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80058f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800593:	79 92                	jns    800527 <vprintfmt+0x35>
				width = precision, precision = -1;
  800595:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800598:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a2:	eb 83                	jmp    800527 <vprintfmt+0x35>
  8005a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a8:	78 08                	js     8005b2 <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 75 ff ff ff       	jmp    800527 <vprintfmt+0x35>
  8005b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005b9:	eb ef                	jmp    8005aa <vprintfmt+0xb8>
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c5:	e9 5d ff ff ff       	jmp    800527 <vprintfmt+0x35>
  8005ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d0:	eb bd                	jmp    80058f <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d6:	e9 4c ff ff ff       	jmp    800527 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 78 04             	lea    0x4(%eax),%edi
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	ff 30                	pushl  (%eax)
  8005e7:	ff d6                	call   *%esi
			break;
  8005e9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ec:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ef:	e9 be 02 00 00       	jmp    8008b2 <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	78 2a                	js     80062a <vprintfmt+0x138>
  800600:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800602:	83 f8 08             	cmp    $0x8,%eax
  800605:	7f 27                	jg     80062e <vprintfmt+0x13c>
  800607:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80060e:	85 c0                	test   %eax,%eax
  800610:	74 1c                	je     80062e <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800612:	50                   	push   %eax
  800613:	68 a9 0f 80 00       	push   $0x800fa9
  800618:	53                   	push   %ebx
  800619:	56                   	push   %esi
  80061a:	e8 b6 fe ff ff       	call   8004d5 <printfmt>
  80061f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800622:	89 7d 14             	mov    %edi,0x14(%ebp)
  800625:	e9 88 02 00 00       	jmp    8008b2 <vprintfmt+0x3c0>
  80062a:	f7 d8                	neg    %eax
  80062c:	eb d2                	jmp    800600 <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062e:	52                   	push   %edx
  80062f:	68 a0 0f 80 00       	push   $0x800fa0
  800634:	53                   	push   %ebx
  800635:	56                   	push   %esi
  800636:	e8 9a fe ff ff       	call   8004d5 <printfmt>
  80063b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063e:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800641:	e9 6c 02 00 00       	jmp    8008b2 <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	83 c0 04             	add    $0x4,%eax
  80064c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 38                	mov    (%eax),%edi
  800654:	85 ff                	test   %edi,%edi
  800656:	74 18                	je     800670 <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800658:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065c:	0f 8e b7 00 00 00    	jle    800719 <vprintfmt+0x227>
  800662:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800666:	75 0f                	jne    800677 <vprintfmt+0x185>
  800668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80066e:	eb 75                	jmp    8006e5 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  800670:	bf 99 0f 80 00       	mov    $0x800f99,%edi
  800675:	eb e1                	jmp    800658 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d0             	pushl  -0x30(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 5f 03 00 00       	call   8009e2 <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0d                	jmp    8006a9 <vprintfmt+0x1b7>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	4f                   	dec    %edi
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	85 ff                	test   %edi,%edi
  8006ab:	7f ef                	jg     80069c <vprintfmt+0x1aa>
  8006ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b3:	89 c8                	mov    %ecx,%eax
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	78 10                	js     8006c9 <vprintfmt+0x1d7>
  8006b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bc:	29 c1                	sub    %eax,%ecx
  8006be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c7:	eb 1c                	jmp    8006e5 <vprintfmt+0x1f3>
  8006c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ce:	eb e9                	jmp    8006b9 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d4:	75 29                	jne    8006ff <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	50                   	push   %eax
  8006dd:	ff d6                	call   *%esi
  8006df:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e2:	ff 4d e0             	decl   -0x20(%ebp)
  8006e5:	47                   	inc    %edi
  8006e6:	8a 57 ff             	mov    -0x1(%edi),%dl
  8006e9:	0f be c2             	movsbl %dl,%eax
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 4c                	je     80073c <vprintfmt+0x24a>
  8006f0:	85 db                	test   %ebx,%ebx
  8006f2:	78 dc                	js     8006d0 <vprintfmt+0x1de>
  8006f4:	4b                   	dec    %ebx
  8006f5:	79 d9                	jns    8006d0 <vprintfmt+0x1de>
  8006f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006fd:	eb 2e                	jmp    80072d <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ff:	0f be d2             	movsbl %dl,%edx
  800702:	83 ea 20             	sub    $0x20,%edx
  800705:	83 fa 5e             	cmp    $0x5e,%edx
  800708:	76 cc                	jbe    8006d6 <vprintfmt+0x1e4>
					putch('?', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	ff 75 0c             	pushl  0xc(%ebp)
  800710:	6a 3f                	push   $0x3f
  800712:	ff d6                	call   *%esi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb c9                	jmp    8006e2 <vprintfmt+0x1f0>
  800719:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071f:	eb c4                	jmp    8006e5 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 20                	push   $0x20
  800727:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800729:	4f                   	dec    %edi
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 ff                	test   %edi,%edi
  80072f:	7f f0                	jg     800721 <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800731:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
  800737:	e9 76 01 00 00       	jmp    8008b2 <vprintfmt+0x3c0>
  80073c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80073f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800742:	eb e9                	jmp    80072d <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800744:	83 f9 01             	cmp    $0x1,%ecx
  800747:	7e 3f                	jle    800788 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 50 04             	mov    0x4(%eax),%edx
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800754:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 40 08             	lea    0x8(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800760:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800764:	79 5c                	jns    8007c2 <vprintfmt+0x2d0>
				putch('-', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 2d                	push   $0x2d
  80076c:	ff d6                	call   *%esi
				num = -(long long) num;
  80076e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800771:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800774:	f7 da                	neg    %edx
  800776:	83 d1 00             	adc    $0x0,%ecx
  800779:	f7 d9                	neg    %ecx
  80077b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800783:	e9 10 01 00 00       	jmp    800898 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800788:	85 c9                	test   %ecx,%ecx
  80078a:	75 1b                	jne    8007a7 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800794:	89 c1                	mov    %eax,%ecx
  800796:	c1 f9 1f             	sar    $0x1f,%ecx
  800799:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 40 04             	lea    0x4(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a5:	eb b9                	jmp    800760 <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007af:	89 c1                	mov    %eax,%ecx
  8007b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 40 04             	lea    0x4(%eax),%eax
  8007bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c0:	eb 9e                	jmp    800760 <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cd:	e9 c6 00 00 00       	jmp    800898 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d2:	83 f9 01             	cmp    $0x1,%ecx
  8007d5:	7e 18                	jle    8007ef <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8b 10                	mov    (%eax),%edx
  8007dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007df:	8d 40 08             	lea    0x8(%eax),%eax
  8007e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ea:	e9 a9 00 00 00       	jmp    800898 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	75 1a                	jne    80080d <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800803:	b8 0a 00 00 00       	mov    $0xa,%eax
  800808:	e9 8b 00 00 00       	jmp    800898 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8b 10                	mov    (%eax),%edx
  800812:	b9 00 00 00 00       	mov    $0x0,%ecx
  800817:	8d 40 04             	lea    0x4(%eax),%eax
  80081a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800822:	eb 74                	jmp    800898 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800824:	83 f9 01             	cmp    $0x1,%ecx
  800827:	7e 15                	jle    80083e <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8b 48 04             	mov    0x4(%eax),%ecx
  800831:	8d 40 08             	lea    0x8(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800837:	b8 08 00 00 00       	mov    $0x8,%eax
  80083c:	eb 5a                	jmp    800898 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	75 17                	jne    800859 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800852:	b8 08 00 00 00       	mov    $0x8,%eax
  800857:	eb 3f                	jmp    800898 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800863:	8d 40 04             	lea    0x4(%eax),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800869:	b8 08 00 00 00       	mov    $0x8,%eax
  80086e:	eb 28                	jmp    800898 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 30                	push   $0x30
  800876:	ff d6                	call   *%esi
			putch('x', putdat);
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 78                	push   $0x78
  80087e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8b 10                	mov    (%eax),%edx
  800885:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088d:	8d 40 04             	lea    0x4(%eax),%eax
  800890:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800893:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089f:	57                   	push   %edi
  8008a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a3:	50                   	push   %eax
  8008a4:	51                   	push   %ecx
  8008a5:	52                   	push   %edx
  8008a6:	89 da                	mov    %ebx,%edx
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	e8 5d fb ff ff       	call   80040c <printnum>
			break;
  8008af:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b5:	47                   	inc    %edi
  8008b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ba:	83 f8 25             	cmp    $0x25,%eax
  8008bd:	0f 84 46 fc ff ff    	je     800509 <vprintfmt+0x17>
			if (ch == '\0')
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	0f 84 89 00 00 00    	je     800954 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	50                   	push   %eax
  8008d0:	ff d6                	call   *%esi
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	eb de                	jmp    8008b5 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d7:	83 f9 01             	cmp    $0x1,%ecx
  8008da:	7e 15                	jle    8008f1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8b 10                	mov    (%eax),%edx
  8008e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e4:	8d 40 08             	lea    0x8(%eax),%eax
  8008e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ef:	eb a7                	jmp    800898 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008f1:	85 c9                	test   %ecx,%ecx
  8008f3:	75 17                	jne    80090c <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8b 10                	mov    (%eax),%edx
  8008fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ff:	8d 40 04             	lea    0x4(%eax),%eax
  800902:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800905:	b8 10 00 00 00       	mov    $0x10,%eax
  80090a:	eb 8c                	jmp    800898 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	8d 40 04             	lea    0x4(%eax),%eax
  800919:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091c:	b8 10 00 00 00       	mov    $0x10,%eax
  800921:	e9 72 ff ff ff       	jmp    800898 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	53                   	push   %ebx
  80092a:	6a 25                	push   $0x25
  80092c:	ff d6                	call   *%esi
			break;
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	e9 7c ff ff ff       	jmp    8008b2 <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800936:	83 ec 08             	sub    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 25                	push   $0x25
  80093c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	89 f8                	mov    %edi,%eax
  800943:	eb 01                	jmp    800946 <vprintfmt+0x454>
  800945:	48                   	dec    %eax
  800946:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80094a:	75 f9                	jne    800945 <vprintfmt+0x453>
  80094c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094f:	e9 5e ff ff ff       	jmp    8008b2 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800954:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 18             	sub    $0x18,%esp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800968:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800972:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800979:	85 c0                	test   %eax,%eax
  80097b:	74 26                	je     8009a3 <vsnprintf+0x47>
  80097d:	85 d2                	test   %edx,%edx
  80097f:	7e 29                	jle    8009aa <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800981:	ff 75 14             	pushl  0x14(%ebp)
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098a:	50                   	push   %eax
  80098b:	68 b9 04 80 00       	push   $0x8004b9
  800990:	e8 5d fb ff ff       	call   8004f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800995:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800998:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	83 c4 10             	add    $0x10,%esp
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a8:	eb f7                	jmp    8009a1 <vsnprintf+0x45>
  8009aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009af:	eb f0                	jmp    8009a1 <vsnprintf+0x45>

008009b1 <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ba:	50                   	push   %eax
  8009bb:	ff 75 10             	pushl  0x10(%ebp)
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 93 ff ff ff       	call   80095c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    
	...

008009cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb 01                	jmp    8009da <strlen+0xe>
		n++;
  8009d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009de:	75 f9                	jne    8009d9 <strlen+0xd>
		n++;
	return n;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f0:	eb 01                	jmp    8009f3 <strnlen+0x11>
		n++;
  8009f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f3:	39 d0                	cmp    %edx,%eax
  8009f5:	74 06                	je     8009fd <strnlen+0x1b>
  8009f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009fb:	75 f5                	jne    8009f2 <strnlen+0x10>
		n++;
	return n;
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	41                   	inc    %ecx
  800a0c:	42                   	inc    %edx
  800a0d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a10:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a13:	84 db                	test   %bl,%bl
  800a15:	75 f4                	jne    800a0b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a21:	53                   	push   %ebx
  800a22:	e8 a5 ff ff ff       	call   8009cc <strlen>
  800a27:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	01 d8                	add    %ebx,%eax
  800a2f:	50                   	push   %eax
  800a30:	e8 ca ff ff ff       	call   8009ff <strcpy>
	return dst;
}
  800a35:	89 d8                	mov    %ebx,%eax
  800a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 08             	mov    0x8(%ebp),%esi
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4c:	89 f2                	mov    %esi,%edx
  800a4e:	39 da                	cmp    %ebx,%edx
  800a50:	74 0e                	je     800a60 <strncpy+0x24>
		*dst++ = *src;
  800a52:	42                   	inc    %edx
  800a53:	8a 01                	mov    (%ecx),%al
  800a55:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a58:	80 39 00             	cmpb   $0x0,(%ecx)
  800a5b:	74 f1                	je     800a4e <strncpy+0x12>
			src++;
  800a5d:	41                   	inc    %ecx
  800a5e:	eb ee                	jmp    800a4e <strncpy+0x12>
	}
	return ret;
}
  800a60:	89 f0                	mov    %esi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a74:	85 c0                	test   %eax,%eax
  800a76:	74 20                	je     800a98 <strlcpy+0x32>
  800a78:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a7c:	89 f0                	mov    %esi,%eax
  800a7e:	eb 05                	jmp    800a85 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a80:	42                   	inc    %edx
  800a81:	40                   	inc    %eax
  800a82:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a85:	39 d8                	cmp    %ebx,%eax
  800a87:	74 06                	je     800a8f <strlcpy+0x29>
  800a89:	8a 0a                	mov    (%edx),%cl
  800a8b:	84 c9                	test   %cl,%cl
  800a8d:	75 f1                	jne    800a80 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a8f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a92:	29 f0                	sub    %esi,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    
  800a98:	89 f0                	mov    %esi,%eax
  800a9a:	eb f6                	jmp    800a92 <strlcpy+0x2c>

00800a9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa5:	eb 02                	jmp    800aa9 <strcmp+0xd>
		p++, q++;
  800aa7:	41                   	inc    %ecx
  800aa8:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa9:	8a 01                	mov    (%ecx),%al
  800aab:	84 c0                	test   %al,%al
  800aad:	74 04                	je     800ab3 <strcmp+0x17>
  800aaf:	3a 02                	cmp    (%edx),%al
  800ab1:	74 f4                	je     800aa7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab3:	0f b6 c0             	movzbl %al,%eax
  800ab6:	0f b6 12             	movzbl (%edx),%edx
  800ab9:	29 d0                	sub    %edx,%eax
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800acc:	eb 02                	jmp    800ad0 <strncmp+0x13>
		n--, p++, q++;
  800ace:	40                   	inc    %eax
  800acf:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad0:	39 d8                	cmp    %ebx,%eax
  800ad2:	74 15                	je     800ae9 <strncmp+0x2c>
  800ad4:	8a 08                	mov    (%eax),%cl
  800ad6:	84 c9                	test   %cl,%cl
  800ad8:	74 04                	je     800ade <strncmp+0x21>
  800ada:	3a 0a                	cmp    (%edx),%cl
  800adc:	74 f0                	je     800ace <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ade:	0f b6 00             	movzbl (%eax),%eax
  800ae1:	0f b6 12             	movzbl (%edx),%edx
  800ae4:	29 d0                	sub    %edx,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	eb f6                	jmp    800ae6 <strncmp+0x29>

00800af0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800af9:	8a 10                	mov    (%eax),%dl
  800afb:	84 d2                	test   %dl,%dl
  800afd:	74 07                	je     800b06 <strchr+0x16>
		if (*s == c)
  800aff:	38 ca                	cmp    %cl,%dl
  800b01:	74 08                	je     800b0b <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b03:	40                   	inc    %eax
  800b04:	eb f3                	jmp    800af9 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b16:	8a 10                	mov    (%eax),%dl
  800b18:	84 d2                	test   %dl,%dl
  800b1a:	74 07                	je     800b23 <strfind+0x16>
		if (*s == c)
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	74 03                	je     800b23 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b20:	40                   	inc    %eax
  800b21:	eb f3                	jmp    800b16 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 13                	je     800b48 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3b:	75 05                	jne    800b42 <memset+0x1d>
  800b3d:	f6 c1 03             	test   $0x3,%cl
  800b40:	74 0d                	je     800b4f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	fc                   	cld    
  800b46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b48:	89 f8                	mov    %edi,%eax
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800b4f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	c1 e3 08             	shl    $0x8,%ebx
  800b58:	89 d0                	mov    %edx,%eax
  800b5a:	c1 e0 18             	shl    $0x18,%eax
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	c1 e6 10             	shl    $0x10,%esi
  800b62:	09 f0                	or     %esi,%eax
  800b64:	09 c2                	or     %eax,%edx
  800b66:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b68:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	fc                   	cld    
  800b6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b70:	eb d6                	jmp    800b48 <memset+0x23>

00800b72 <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b80:	39 c6                	cmp    %eax,%esi
  800b82:	73 33                	jae    800bb7 <memmove+0x45>
  800b84:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b87:	39 c2                	cmp    %eax,%edx
  800b89:	76 2c                	jbe    800bb7 <memmove+0x45>
		s += n;
		d += n;
  800b8b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	09 fe                	or     %edi,%esi
  800b92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b98:	74 0a                	je     800ba4 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b9a:	4f                   	dec    %edi
  800b9b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9e:	fd                   	std    
  800b9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba1:	fc                   	cld    
  800ba2:	eb 21                	jmp    800bc5 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba4:	f6 c1 03             	test   $0x3,%cl
  800ba7:	75 f1                	jne    800b9a <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba9:	83 ef 04             	sub    $0x4,%edi
  800bac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800baf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bb2:	fd                   	std    
  800bb3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb5:	eb ea                	jmp    800ba1 <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb7:	89 f2                	mov    %esi,%edx
  800bb9:	09 c2                	or     %eax,%edx
  800bbb:	f6 c2 03             	test   $0x3,%dl
  800bbe:	74 09                	je     800bc9 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	fc                   	cld    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc9:	f6 c1 03             	test   $0x3,%cl
  800bcc:	75 f2                	jne    800bc0 <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bce:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bd1:	89 c7                	mov    %eax,%edi
  800bd3:	fc                   	cld    
  800bd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd6:	eb ed                	jmp    800bc5 <memmove+0x53>

00800bd8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdb:	ff 75 10             	pushl  0x10(%ebp)
  800bde:	ff 75 0c             	pushl  0xc(%ebp)
  800be1:	ff 75 08             	pushl  0x8(%ebp)
  800be4:	e8 89 ff ff ff       	call   800b72 <memmove>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfb:	39 f0                	cmp    %esi,%eax
  800bfd:	74 16                	je     800c15 <memcmp+0x2a>
		if (*s1 != *s2)
  800bff:	8a 08                	mov    (%eax),%cl
  800c01:	8a 1a                	mov    (%edx),%bl
  800c03:	38 d9                	cmp    %bl,%cl
  800c05:	75 04                	jne    800c0b <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c07:	40                   	inc    %eax
  800c08:	42                   	inc    %edx
  800c09:	eb f0                	jmp    800bfb <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800c0b:	0f b6 c1             	movzbl %cl,%eax
  800c0e:	0f b6 db             	movzbl %bl,%ebx
  800c11:	29 d8                	sub    %ebx,%eax
  800c13:	eb 05                	jmp    800c1a <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c2c:	39 d0                	cmp    %edx,%eax
  800c2e:	73 07                	jae    800c37 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c30:	38 08                	cmp    %cl,(%eax)
  800c32:	74 03                	je     800c37 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c34:	40                   	inc    %eax
  800c35:	eb f5                	jmp    800c2c <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c42:	eb 01                	jmp    800c45 <strtol+0xc>
		s++;
  800c44:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c45:	8a 01                	mov    (%ecx),%al
  800c47:	3c 20                	cmp    $0x20,%al
  800c49:	74 f9                	je     800c44 <strtol+0xb>
  800c4b:	3c 09                	cmp    $0x9,%al
  800c4d:	74 f5                	je     800c44 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4f:	3c 2b                	cmp    $0x2b,%al
  800c51:	74 2b                	je     800c7e <strtol+0x45>
		s++;
	else if (*s == '-')
  800c53:	3c 2d                	cmp    $0x2d,%al
  800c55:	74 2f                	je     800c86 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800c63:	75 12                	jne    800c77 <strtol+0x3e>
  800c65:	80 39 30             	cmpb   $0x30,(%ecx)
  800c68:	74 24                	je     800c8e <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c6e:	75 07                	jne    800c77 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c70:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	eb 4e                	jmp    800ccc <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800c7e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c84:	eb d6                	jmp    800c5c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800c86:	41                   	inc    %ecx
  800c87:	bf 01 00 00 00       	mov    $0x1,%edi
  800c8c:	eb ce                	jmp    800c5c <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c92:	74 10                	je     800ca4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c98:	75 dd                	jne    800c77 <strtol+0x3e>
		s++, base = 8;
  800c9a:	41                   	inc    %ecx
  800c9b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ca2:	eb d3                	jmp    800c77 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800ca4:	83 c1 02             	add    $0x2,%ecx
  800ca7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cae:	eb c7                	jmp    800c77 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cb0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 19             	cmp    $0x19,%bl
  800cb8:	77 24                	ja     800cde <strtol+0xa5>
			dig = *s - 'a' + 10;
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc0:	39 55 10             	cmp    %edx,0x10(%ebp)
  800cc3:	7e 2b                	jle    800cf0 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800cc5:	41                   	inc    %ecx
  800cc6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cca:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ccc:	8a 11                	mov    (%ecx),%dl
  800cce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800cd1:	80 fb 09             	cmp    $0x9,%bl
  800cd4:	77 da                	ja     800cb0 <strtol+0x77>
			dig = *s - '0';
  800cd6:	0f be d2             	movsbl %dl,%edx
  800cd9:	83 ea 30             	sub    $0x30,%edx
  800cdc:	eb e2                	jmp    800cc0 <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cde:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce1:	89 f3                	mov    %esi,%ebx
  800ce3:	80 fb 19             	cmp    $0x19,%bl
  800ce6:	77 08                	ja     800cf0 <strtol+0xb7>
			dig = *s - 'A' + 10;
  800ce8:	0f be d2             	movsbl %dl,%edx
  800ceb:	83 ea 37             	sub    $0x37,%edx
  800cee:	eb d0                	jmp    800cc0 <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf4:	74 05                	je     800cfb <strtol+0xc2>
		*endptr = (char *) s;
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	74 02                	je     800d01 <strtol+0xc8>
  800cff:	f7 d8                	neg    %eax
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
	...

00800d08 <__udivdi3>:
  800d08:	55                   	push   %ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 1c             	sub    $0x1c,%esp
  800d0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d1f:	85 d2                	test   %edx,%edx
  800d21:	75 2d                	jne    800d50 <__udivdi3+0x48>
  800d23:	39 f7                	cmp    %esi,%edi
  800d25:	77 59                	ja     800d80 <__udivdi3+0x78>
  800d27:	89 f9                	mov    %edi,%ecx
  800d29:	85 ff                	test   %edi,%edi
  800d2b:	75 0b                	jne    800d38 <__udivdi3+0x30>
  800d2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d32:	31 d2                	xor    %edx,%edx
  800d34:	f7 f7                	div    %edi
  800d36:	89 c1                	mov    %eax,%ecx
  800d38:	31 d2                	xor    %edx,%edx
  800d3a:	89 f0                	mov    %esi,%eax
  800d3c:	f7 f1                	div    %ecx
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	89 e8                	mov    %ebp,%eax
  800d42:	f7 f1                	div    %ecx
  800d44:	89 da                	mov    %ebx,%edx
  800d46:	83 c4 1c             	add    $0x1c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
  800d4e:	66 90                	xchg   %ax,%ax
  800d50:	39 f2                	cmp    %esi,%edx
  800d52:	77 1c                	ja     800d70 <__udivdi3+0x68>
  800d54:	0f bd da             	bsr    %edx,%ebx
  800d57:	83 f3 1f             	xor    $0x1f,%ebx
  800d5a:	75 38                	jne    800d94 <__udivdi3+0x8c>
  800d5c:	39 f2                	cmp    %esi,%edx
  800d5e:	72 08                	jb     800d68 <__udivdi3+0x60>
  800d60:	39 ef                	cmp    %ebp,%edi
  800d62:	0f 87 98 00 00 00    	ja     800e00 <__udivdi3+0xf8>
  800d68:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6d:	eb 05                	jmp    800d74 <__udivdi3+0x6c>
  800d6f:	90                   	nop
  800d70:	31 db                	xor    %ebx,%ebx
  800d72:	31 c0                	xor    %eax,%eax
  800d74:	89 da                	mov    %ebx,%edx
  800d76:	83 c4 1c             	add    $0x1c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	89 e8                	mov    %ebp,%eax
  800d82:	89 f2                	mov    %esi,%edx
  800d84:	f7 f7                	div    %edi
  800d86:	31 db                	xor    %ebx,%ebx
  800d88:	89 da                	mov    %ebx,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	66 90                	xchg   %ax,%ax
  800d94:	b8 20 00 00 00       	mov    $0x20,%eax
  800d99:	29 d8                	sub    %ebx,%eax
  800d9b:	88 d9                	mov    %bl,%cl
  800d9d:	d3 e2                	shl    %cl,%edx
  800d9f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800da3:	89 fa                	mov    %edi,%edx
  800da5:	88 c1                	mov    %al,%cl
  800da7:	d3 ea                	shr    %cl,%edx
  800da9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dad:	09 d1                	or     %edx,%ecx
  800daf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db3:	88 d9                	mov    %bl,%cl
  800db5:	d3 e7                	shl    %cl,%edi
  800db7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dbb:	89 f7                	mov    %esi,%edi
  800dbd:	88 c1                	mov    %al,%cl
  800dbf:	d3 ef                	shr    %cl,%edi
  800dc1:	88 d9                	mov    %bl,%cl
  800dc3:	d3 e6                	shl    %cl,%esi
  800dc5:	89 ea                	mov    %ebp,%edx
  800dc7:	88 c1                	mov    %al,%cl
  800dc9:	d3 ea                	shr    %cl,%edx
  800dcb:	09 d6                	or     %edx,%esi
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	89 fa                	mov    %edi,%edx
  800dd1:	f7 74 24 08          	divl   0x8(%esp)
  800dd5:	89 d7                	mov    %edx,%edi
  800dd7:	89 c6                	mov    %eax,%esi
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	39 d7                	cmp    %edx,%edi
  800ddf:	72 13                	jb     800df4 <__udivdi3+0xec>
  800de1:	74 09                	je     800dec <__udivdi3+0xe4>
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	31 db                	xor    %ebx,%ebx
  800de7:	eb 8b                	jmp    800d74 <__udivdi3+0x6c>
  800de9:	8d 76 00             	lea    0x0(%esi),%esi
  800dec:	88 d9                	mov    %bl,%cl
  800dee:	d3 e5                	shl    %cl,%ebp
  800df0:	39 c5                	cmp    %eax,%ebp
  800df2:	73 ef                	jae    800de3 <__udivdi3+0xdb>
  800df4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800df7:	31 db                	xor    %ebx,%ebx
  800df9:	e9 76 ff ff ff       	jmp    800d74 <__udivdi3+0x6c>
  800dfe:	66 90                	xchg   %ax,%ax
  800e00:	31 c0                	xor    %eax,%eax
  800e02:	e9 6d ff ff ff       	jmp    800d74 <__udivdi3+0x6c>
	...

00800e08 <__umoddi3>:
  800e08:	55                   	push   %ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 1c             	sub    $0x1c,%esp
  800e0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e1b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	89 da                	mov    %ebx,%edx
  800e23:	85 ed                	test   %ebp,%ebp
  800e25:	75 15                	jne    800e3c <__umoddi3+0x34>
  800e27:	39 df                	cmp    %ebx,%edi
  800e29:	76 39                	jbe    800e64 <__umoddi3+0x5c>
  800e2b:	f7 f7                	div    %edi
  800e2d:	89 d0                	mov    %edx,%eax
  800e2f:	31 d2                	xor    %edx,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d 76 00             	lea    0x0(%esi),%esi
  800e3c:	39 dd                	cmp    %ebx,%ebp
  800e3e:	77 f1                	ja     800e31 <__umoddi3+0x29>
  800e40:	0f bd cd             	bsr    %ebp,%ecx
  800e43:	83 f1 1f             	xor    $0x1f,%ecx
  800e46:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e4a:	75 38                	jne    800e84 <__umoddi3+0x7c>
  800e4c:	39 dd                	cmp    %ebx,%ebp
  800e4e:	72 04                	jb     800e54 <__umoddi3+0x4c>
  800e50:	39 f7                	cmp    %esi,%edi
  800e52:	77 dd                	ja     800e31 <__umoddi3+0x29>
  800e54:	89 da                	mov    %ebx,%edx
  800e56:	89 f0                	mov    %esi,%eax
  800e58:	29 f8                	sub    %edi,%eax
  800e5a:	19 ea                	sbb    %ebp,%edx
  800e5c:	83 c4 1c             	add    $0x1c,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	89 f9                	mov    %edi,%ecx
  800e66:	85 ff                	test   %edi,%edi
  800e68:	75 0b                	jne    800e75 <__umoddi3+0x6d>
  800e6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6f:	31 d2                	xor    %edx,%edx
  800e71:	f7 f7                	div    %edi
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	89 d8                	mov    %ebx,%eax
  800e77:	31 d2                	xor    %edx,%edx
  800e79:	f7 f1                	div    %ecx
  800e7b:	89 f0                	mov    %esi,%eax
  800e7d:	f7 f1                	div    %ecx
  800e7f:	eb ac                	jmp    800e2d <__umoddi3+0x25>
  800e81:	8d 76 00             	lea    0x0(%esi),%esi
  800e84:	b8 20 00 00 00       	mov    $0x20,%eax
  800e89:	89 c2                	mov    %eax,%edx
  800e8b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e8f:	29 c2                	sub    %eax,%edx
  800e91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e95:	88 c1                	mov    %al,%cl
  800e97:	d3 e5                	shl    %cl,%ebp
  800e99:	89 f8                	mov    %edi,%eax
  800e9b:	88 d1                	mov    %dl,%cl
  800e9d:	d3 e8                	shr    %cl,%eax
  800e9f:	09 c5                	or     %eax,%ebp
  800ea1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea5:	88 c1                	mov    %al,%cl
  800ea7:	d3 e7                	shl    %cl,%edi
  800ea9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	88 d1                	mov    %dl,%cl
  800eb1:	d3 ef                	shr    %cl,%edi
  800eb3:	88 c1                	mov    %al,%cl
  800eb5:	d3 e3                	shl    %cl,%ebx
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	88 d1                	mov    %dl,%cl
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	09 d8                	or     %ebx,%eax
  800ebf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ec3:	d3 e6                	shl    %cl,%esi
  800ec5:	89 fa                	mov    %edi,%edx
  800ec7:	f7 f5                	div    %ebp
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	f7 64 24 08          	mull   0x8(%esp)
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	89 d7                	mov    %edx,%edi
  800ed3:	39 d1                	cmp    %edx,%ecx
  800ed5:	72 29                	jb     800f00 <__umoddi3+0xf8>
  800ed7:	74 23                	je     800efc <__umoddi3+0xf4>
  800ed9:	89 ca                	mov    %ecx,%edx
  800edb:	29 de                	sub    %ebx,%esi
  800edd:	19 fa                	sbb    %edi,%edx
  800edf:	89 d0                	mov    %edx,%eax
  800ee1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  800ee5:	d3 e0                	shl    %cl,%eax
  800ee7:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800eeb:	88 d9                	mov    %bl,%cl
  800eed:	d3 ee                	shr    %cl,%esi
  800eef:	09 f0                	or     %esi,%eax
  800ef1:	d3 ea                	shr    %cl,%edx
  800ef3:	83 c4 1c             	add    $0x1c,%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	90                   	nop
  800efc:	39 c6                	cmp    %eax,%esi
  800efe:	73 d9                	jae    800ed9 <__umoddi3+0xd1>
  800f00:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f04:	19 ea                	sbb    %ebp,%edx
  800f06:	89 d7                	mov    %edx,%edi
  800f08:	89 c3                	mov    %eax,%ebx
  800f0a:	eb cd                	jmp    800ed9 <__umoddi3+0xd1>
