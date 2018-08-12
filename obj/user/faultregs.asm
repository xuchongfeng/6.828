
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 77 05 00 00       	call   8005a8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	89 c6                	mov    %eax,%esi
  80003f:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	ff 75 08             	pushl  0x8(%ebp)
  800044:	52                   	push   %edx
  800045:	68 d1 14 80 00       	push   $0x8014d1
  80004a:	68 a0 14 80 00       	push   $0x8014a0
  80004f:	e8 90 06 00 00       	call   8006e4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 33                	pushl  (%ebx)
  800056:	ff 36                	pushl  (%esi)
  800058:	68 b0 14 80 00       	push   $0x8014b0
  80005d:	68 b4 14 80 00       	push   $0x8014b4
  800062:	e8 7d 06 00 00       	call   8006e4 <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 03                	mov    (%ebx),%eax
  80006c:	39 06                	cmp    %eax,(%esi)
  80006e:	0f 84 31 02 00 00    	je     8002a5 <check_regs+0x271>
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	68 c8 14 80 00       	push   $0x8014c8
  80007c:	e8 63 06 00 00       	call   8006e4 <cprintf>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800089:	ff 73 04             	pushl  0x4(%ebx)
  80008c:	ff 76 04             	pushl  0x4(%esi)
  80008f:	68 d2 14 80 00       	push   $0x8014d2
  800094:	68 b4 14 80 00       	push   $0x8014b4
  800099:	e8 46 06 00 00       	call   8006e4 <cprintf>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a4:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a7:	0f 84 12 02 00 00    	je     8002bf <check_regs+0x28b>
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	68 c8 14 80 00       	push   $0x8014c8
  8000b5:	e8 2a 06 00 00       	call   8006e4 <cprintf>
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c2:	ff 73 08             	pushl  0x8(%ebx)
  8000c5:	ff 76 08             	pushl  0x8(%esi)
  8000c8:	68 d6 14 80 00       	push   $0x8014d6
  8000cd:	68 b4 14 80 00       	push   $0x8014b4
  8000d2:	e8 0d 06 00 00       	call   8006e4 <cprintf>
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dd:	39 46 08             	cmp    %eax,0x8(%esi)
  8000e0:	0f 84 ee 01 00 00    	je     8002d4 <check_regs+0x2a0>
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 c8 14 80 00       	push   $0x8014c8
  8000ee:	e8 f1 05 00 00       	call   8006e4 <cprintf>
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fb:	ff 73 10             	pushl  0x10(%ebx)
  8000fe:	ff 76 10             	pushl  0x10(%esi)
  800101:	68 da 14 80 00       	push   $0x8014da
  800106:	68 b4 14 80 00       	push   $0x8014b4
  80010b:	e8 d4 05 00 00       	call   8006e4 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	8b 43 10             	mov    0x10(%ebx),%eax
  800116:	39 46 10             	cmp    %eax,0x10(%esi)
  800119:	0f 84 ca 01 00 00    	je     8002e9 <check_regs+0x2b5>
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	68 c8 14 80 00       	push   $0x8014c8
  800127:	e8 b8 05 00 00       	call   8006e4 <cprintf>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800134:	ff 73 14             	pushl  0x14(%ebx)
  800137:	ff 76 14             	pushl  0x14(%esi)
  80013a:	68 de 14 80 00       	push   $0x8014de
  80013f:	68 b4 14 80 00       	push   $0x8014b4
  800144:	e8 9b 05 00 00       	call   8006e4 <cprintf>
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8b 43 14             	mov    0x14(%ebx),%eax
  80014f:	39 46 14             	cmp    %eax,0x14(%esi)
  800152:	0f 84 a6 01 00 00    	je     8002fe <check_regs+0x2ca>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	68 c8 14 80 00       	push   $0x8014c8
  800160:	e8 7f 05 00 00       	call   8006e4 <cprintf>
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016d:	ff 73 18             	pushl  0x18(%ebx)
  800170:	ff 76 18             	pushl  0x18(%esi)
  800173:	68 e2 14 80 00       	push   $0x8014e2
  800178:	68 b4 14 80 00       	push   $0x8014b4
  80017d:	e8 62 05 00 00       	call   8006e4 <cprintf>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	8b 43 18             	mov    0x18(%ebx),%eax
  800188:	39 46 18             	cmp    %eax,0x18(%esi)
  80018b:	0f 84 82 01 00 00    	je     800313 <check_regs+0x2df>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 c8 14 80 00       	push   $0x8014c8
  800199:	e8 46 05 00 00       	call   8006e4 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a6:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a9:	ff 76 1c             	pushl  0x1c(%esi)
  8001ac:	68 e6 14 80 00       	push   $0x8014e6
  8001b1:	68 b4 14 80 00       	push   $0x8014b4
  8001b6:	e8 29 05 00 00       	call   8006e4 <cprintf>
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c1:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c4:	0f 84 5e 01 00 00    	je     800328 <check_regs+0x2f4>
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	68 c8 14 80 00       	push   $0x8014c8
  8001d2:	e8 0d 05 00 00       	call   8006e4 <cprintf>
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001df:	ff 73 20             	pushl  0x20(%ebx)
  8001e2:	ff 76 20             	pushl  0x20(%esi)
  8001e5:	68 ea 14 80 00       	push   $0x8014ea
  8001ea:	68 b4 14 80 00       	push   $0x8014b4
  8001ef:	e8 f0 04 00 00       	call   8006e4 <cprintf>
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8b 43 20             	mov    0x20(%ebx),%eax
  8001fa:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fd:	0f 84 3a 01 00 00    	je     80033d <check_regs+0x309>
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	68 c8 14 80 00       	push   $0x8014c8
  80020b:	e8 d4 04 00 00       	call   8006e4 <cprintf>
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800218:	ff 73 24             	pushl  0x24(%ebx)
  80021b:	ff 76 24             	pushl  0x24(%esi)
  80021e:	68 ee 14 80 00       	push   $0x8014ee
  800223:	68 b4 14 80 00       	push   $0x8014b4
  800228:	e8 b7 04 00 00       	call   8006e4 <cprintf>
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	8b 43 24             	mov    0x24(%ebx),%eax
  800233:	39 46 24             	cmp    %eax,0x24(%esi)
  800236:	0f 84 16 01 00 00    	je     800352 <check_regs+0x31e>
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	68 c8 14 80 00       	push   $0x8014c8
  800244:	e8 9b 04 00 00       	call   8006e4 <cprintf>
	CHECK(esp, esp);
  800249:	ff 73 28             	pushl  0x28(%ebx)
  80024c:	ff 76 28             	pushl  0x28(%esi)
  80024f:	68 f5 14 80 00       	push   $0x8014f5
  800254:	68 b4 14 80 00       	push   $0x8014b4
  800259:	e8 86 04 00 00       	call   8006e4 <cprintf>
  80025e:	83 c4 20             	add    $0x20,%esp
  800261:	8b 43 28             	mov    0x28(%ebx),%eax
  800264:	39 46 28             	cmp    %eax,0x28(%esi)
  800267:	0f 84 53 01 00 00    	je     8003c0 <check_regs+0x38c>
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	68 c8 14 80 00       	push   $0x8014c8
  800275:	e8 6a 04 00 00       	call   8006e4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80027a:	83 c4 08             	add    $0x8,%esp
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	68 f9 14 80 00       	push   $0x8014f9
  800285:	e8 5a 04 00 00       	call   8006e4 <cprintf>
  80028a:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	68 c8 14 80 00       	push   $0x8014c8
  800295:	e8 4a 04 00 00       	call   8006e4 <cprintf>
  80029a:	83 c4 10             	add    $0x10,%esp
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	68 c4 14 80 00       	push   $0x8014c4
  8002ad:	e8 32 04 00 00       	call   8006e4 <cprintf>
  8002b2:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  8002b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8002ba:	e9 ca fd ff ff       	jmp    800089 <check_regs+0x55>
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
	CHECK(esi, regs.reg_esi);
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 c4 14 80 00       	push   $0x8014c4
  8002c7:	e8 18 04 00 00       	call   8006e4 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	e9 ee fd ff ff       	jmp    8000c2 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	68 c4 14 80 00       	push   $0x8014c4
  8002dc:	e8 03 04 00 00       	call   8006e4 <cprintf>
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	e9 12 fe ff ff       	jmp    8000fb <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	68 c4 14 80 00       	push   $0x8014c4
  8002f1:	e8 ee 03 00 00       	call   8006e4 <cprintf>
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	e9 36 fe ff ff       	jmp    800134 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fe:	83 ec 0c             	sub    $0xc,%esp
  800301:	68 c4 14 80 00       	push   $0x8014c4
  800306:	e8 d9 03 00 00       	call   8006e4 <cprintf>
  80030b:	83 c4 10             	add    $0x10,%esp
  80030e:	e9 5a fe ff ff       	jmp    80016d <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  800313:	83 ec 0c             	sub    $0xc,%esp
  800316:	68 c4 14 80 00       	push   $0x8014c4
  80031b:	e8 c4 03 00 00       	call   8006e4 <cprintf>
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	e9 7e fe ff ff       	jmp    8001a6 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	68 c4 14 80 00       	push   $0x8014c4
  800330:	e8 af 03 00 00       	call   8006e4 <cprintf>
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	e9 a2 fe ff ff       	jmp    8001df <check_regs+0x1ab>
	CHECK(eip, eip);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	68 c4 14 80 00       	push   $0x8014c4
  800345:	e8 9a 03 00 00       	call   8006e4 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	e9 c6 fe ff ff       	jmp    800218 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 c4 14 80 00       	push   $0x8014c4
  80035a:	e8 85 03 00 00       	call   8006e4 <cprintf>
	CHECK(esp, esp);
  80035f:	ff 73 28             	pushl  0x28(%ebx)
  800362:	ff 76 28             	pushl  0x28(%esi)
  800365:	68 f5 14 80 00       	push   $0x8014f5
  80036a:	68 b4 14 80 00       	push   $0x8014b4
  80036f:	e8 70 03 00 00       	call   8006e4 <cprintf>
  800374:	83 c4 20             	add    $0x20,%esp
  800377:	8b 43 28             	mov    0x28(%ebx),%eax
  80037a:	39 46 28             	cmp    %eax,0x28(%esi)
  80037d:	0f 85 ea fe ff ff    	jne    80026d <check_regs+0x239>
  800383:	83 ec 0c             	sub    $0xc,%esp
  800386:	68 c4 14 80 00       	push   $0x8014c4
  80038b:	e8 54 03 00 00       	call   8006e4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800390:	83 c4 08             	add    $0x8,%esp
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	68 f9 14 80 00       	push   $0x8014f9
  80039b:	e8 44 03 00 00       	call   8006e4 <cprintf>
	if (!mismatch)
  8003a0:	83 c4 10             	add    $0x10,%esp
  8003a3:	85 ff                	test   %edi,%edi
  8003a5:	0f 85 e2 fe ff ff    	jne    80028d <check_regs+0x259>
		cprintf("OK\n");
  8003ab:	83 ec 0c             	sub    $0xc,%esp
  8003ae:	68 c4 14 80 00       	push   $0x8014c4
  8003b3:	e8 2c 03 00 00       	call   8006e4 <cprintf>
  8003b8:	83 c4 10             	add    $0x10,%esp
  8003bb:	e9 dd fe ff ff       	jmp    80029d <check_regs+0x269>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  8003c0:	83 ec 0c             	sub    $0xc,%esp
  8003c3:	68 c4 14 80 00       	push   $0x8014c4
  8003c8:	e8 17 03 00 00       	call   8006e4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff 75 0c             	pushl  0xc(%ebp)
  8003d3:	68 f9 14 80 00       	push   $0x8014f9
  8003d8:	e8 07 03 00 00       	call   8006e4 <cprintf>
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	e9 a8 fe ff ff       	jmp    80028d <check_regs+0x259>

008003e5 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	75 6f                	jne    800466 <pgfault+0x81>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003f7:	bf 60 20 80 00       	mov    $0x802060,%edi
  8003fc:	8d 70 08             	lea    0x8(%eax),%esi
  8003ff:	b9 08 00 00 00       	mov    $0x8,%ecx
  800404:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800418:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80041e:	8b 40 30             	mov    0x30(%eax),%eax
  800421:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	68 1f 15 80 00       	push   $0x80151f
  80042e:	68 2d 15 80 00       	push   $0x80152d
  800433:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800438:	ba 18 15 80 00       	mov    $0x801518,%edx
  80043d:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800442:	e8 ed fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800447:	83 c4 0c             	add    $0xc,%esp
  80044a:	6a 07                	push   $0x7
  80044c:	68 00 00 40 00       	push   $0x400000
  800451:	6a 00                	push   $0x0
  800453:	e8 58 0c 00 00       	call   8010b0 <sys_page_alloc>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	85 c0                	test   %eax,%eax
  80045d:	78 1f                	js     80047e <pgfault+0x99>
		panic("sys_page_alloc: %e", r);
}
  80045f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800462:	5e                   	pop    %esi
  800463:	5f                   	pop    %edi
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    
pgfault(struct UTrapframe *utf)
{
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	ff 70 28             	pushl  0x28(%eax)
  80046c:	52                   	push   %edx
  80046d:	68 60 15 80 00       	push   $0x801560
  800472:	6a 51                	push   $0x51
  800474:	68 07 15 80 00       	push   $0x801507
  800479:	e8 8a 01 00 00       	call   800608 <_panic>
	during.esp = utf->utf_esp;
	check_regs(&before, "before", &during, "during", "in UTrapframe");

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  80047e:	50                   	push   %eax
  80047f:	68 34 15 80 00       	push   $0x801534
  800484:	6a 5c                	push   $0x5c
  800486:	68 07 15 80 00       	push   $0x801507
  80048b:	e8 78 01 00 00       	call   800608 <_panic>

00800490 <umain>:
}

void
umain(int argc, char **argv)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800496:	68 e5 03 80 00       	push   $0x8003e5
  80049b:	e8 c0 0d 00 00       	call   801260 <set_pgfault_handler>

	asm volatile(
  8004a0:	50                   	push   %eax
  8004a1:	9c                   	pushf  
  8004a2:	58                   	pop    %eax
  8004a3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004a8:	50                   	push   %eax
  8004a9:	9d                   	popf   
  8004aa:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004af:	8d 05 ea 04 80 00    	lea    0x8004ea,%eax
  8004b5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004ba:	58                   	pop    %eax
  8004bb:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004c1:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004c7:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004cd:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004d3:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004d9:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004df:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004e4:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004ea:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004f1:	00 00 00 
  8004f4:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004fa:	89 35 24 20 80 00    	mov    %esi,0x802024
  800500:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800506:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80050c:	89 15 34 20 80 00    	mov    %edx,0x802034
  800512:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800518:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80051d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800523:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800529:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80052f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800535:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80053b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800541:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800547:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80054c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800552:	50                   	push   %eax
  800553:	9c                   	pushf  
  800554:	58                   	pop    %eax
  800555:	a3 44 20 80 00       	mov    %eax,0x802044
  80055a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800565:	74 10                	je     800577 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	68 94 15 80 00       	push   $0x801594
  80056f:	e8 70 01 00 00       	call   8006e4 <cprintf>
  800574:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800577:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80057c:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	68 47 15 80 00       	push   $0x801547
  800589:	68 58 15 80 00       	push   $0x801558
  80058e:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800593:	ba 18 15 80 00       	mov    $0x801518,%edx
  800598:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80059d:	e8 92 fa ff ff       	call   800034 <check_regs>
}
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    
	...

008005a8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	56                   	push   %esi
  8005ac:	53                   	push   %ebx
  8005ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005b3:	e8 ba 0a 00 00       	call   801072 <sys_getenvid>
  8005b8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005bd:	89 c2                	mov    %eax,%edx
  8005bf:	c1 e2 05             	shl    $0x5,%edx
  8005c2:	29 c2                	sub    %eax,%edx
  8005c4:	8d 04 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%eax
  8005cb:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7e 07                	jle    8005db <libmain+0x33>
		binaryname = argv[0];
  8005d4:	8b 06                	mov    (%esi),%eax
  8005d6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	53                   	push   %ebx
  8005e0:	e8 ab fe ff ff       	call   800490 <umain>

	// exit gracefully
	exit();
  8005e5:	e8 0a 00 00 00       	call   8005f4 <exit>
}
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005f0:	5b                   	pop    %ebx
  8005f1:	5e                   	pop    %esi
  8005f2:	5d                   	pop    %ebp
  8005f3:	c3                   	ret    

008005f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005fa:	6a 00                	push   $0x0
  8005fc:	e8 30 0a 00 00       	call   801031 <sys_env_destroy>
}
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	c9                   	leave  
  800605:	c3                   	ret    
	...

00800608 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80060d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800610:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800616:	e8 57 0a 00 00       	call   801072 <sys_getenvid>
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	ff 75 08             	pushl  0x8(%ebp)
  800624:	56                   	push   %esi
  800625:	50                   	push   %eax
  800626:	68 c0 15 80 00       	push   $0x8015c0
  80062b:	e8 b4 00 00 00       	call   8006e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800630:	83 c4 18             	add    $0x18,%esp
  800633:	53                   	push   %ebx
  800634:	ff 75 10             	pushl  0x10(%ebp)
  800637:	e8 57 00 00 00       	call   800693 <vcprintf>
	cprintf("\n");
  80063c:	c7 04 24 d0 14 80 00 	movl   $0x8014d0,(%esp)
  800643:	e8 9c 00 00 00       	call   8006e4 <cprintf>
  800648:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064b:	cc                   	int3   
  80064c:	eb fd                	jmp    80064b <_panic+0x43>
	...

00800650 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	53                   	push   %ebx
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065a:	8b 13                	mov    (%ebx),%edx
  80065c:	8d 42 01             	lea    0x1(%edx),%eax
  80065f:	89 03                	mov    %eax,(%ebx)
  800661:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800664:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800668:	3d ff 00 00 00       	cmp    $0xff,%eax
  80066d:	74 08                	je     800677 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80066f:	ff 43 04             	incl   0x4(%ebx)
}
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    
static void
putch(int ch, struct printbuf *b)
{
	b->buf[b->idx++] = ch;
	if (b->idx == 256-1) {
		sys_cputs(b->buf, b->idx);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	68 ff 00 00 00       	push   $0xff
  80067f:	8d 43 08             	lea    0x8(%ebx),%eax
  800682:	50                   	push   %eax
  800683:	e8 6c 09 00 00       	call   800ff4 <sys_cputs>
		b->idx = 0;
  800688:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb dc                	jmp    80066f <putch+0x1f>

00800693 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80069c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a3:	00 00 00 
	b.cnt = 0;
  8006a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	ff 75 08             	pushl  0x8(%ebp)
  8006b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	68 50 06 80 00       	push   $0x800650
  8006c2:	e8 17 01 00 00       	call   8007de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006c7:	83 c4 08             	add    $0x8,%esp
  8006ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	e8 18 09 00 00       	call   800ff4 <sys_cputs>

	return b.cnt;
}
  8006dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006ed:	50                   	push   %eax
  8006ee:	ff 75 08             	pushl  0x8(%ebp)
  8006f1:	e8 9d ff ff ff       	call   800693 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	57                   	push   %edi
  8006fc:	56                   	push   %esi
  8006fd:	53                   	push   %ebx
  8006fe:	83 ec 1c             	sub    $0x1c,%esp
  800701:	89 c7                	mov    %eax,%edi
  800703:	89 d6                	mov    %edx,%esi
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800711:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800714:	bb 00 00 00 00       	mov    $0x0,%ebx
  800719:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80071c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80071f:	39 d3                	cmp    %edx,%ebx
  800721:	72 05                	jb     800728 <printnum+0x30>
  800723:	39 45 10             	cmp    %eax,0x10(%ebp)
  800726:	77 78                	ja     8007a0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800728:	83 ec 0c             	sub    $0xc,%esp
  80072b:	ff 75 18             	pushl  0x18(%ebp)
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800734:	53                   	push   %ebx
  800735:	ff 75 10             	pushl  0x10(%ebp)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80073e:	ff 75 e0             	pushl  -0x20(%ebp)
  800741:	ff 75 dc             	pushl  -0x24(%ebp)
  800744:	ff 75 d8             	pushl  -0x28(%ebp)
  800747:	e8 44 0b 00 00       	call   801290 <__udivdi3>
  80074c:	83 c4 18             	add    $0x18,%esp
  80074f:	52                   	push   %edx
  800750:	50                   	push   %eax
  800751:	89 f2                	mov    %esi,%edx
  800753:	89 f8                	mov    %edi,%eax
  800755:	e8 9e ff ff ff       	call   8006f8 <printnum>
  80075a:	83 c4 20             	add    $0x20,%esp
  80075d:	eb 11                	jmp    800770 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	56                   	push   %esi
  800763:	ff 75 18             	pushl  0x18(%ebp)
  800766:	ff d7                	call   *%edi
  800768:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80076b:	4b                   	dec    %ebx
  80076c:	85 db                	test   %ebx,%ebx
  80076e:	7f ef                	jg     80075f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	56                   	push   %esi
  800774:	83 ec 04             	sub    $0x4,%esp
  800777:	ff 75 e4             	pushl  -0x1c(%ebp)
  80077a:	ff 75 e0             	pushl  -0x20(%ebp)
  80077d:	ff 75 dc             	pushl  -0x24(%ebp)
  800780:	ff 75 d8             	pushl  -0x28(%ebp)
  800783:	e8 08 0c 00 00       	call   801390 <__umoddi3>
  800788:	83 c4 14             	add    $0x14,%esp
  80078b:	0f be 80 e3 15 80 00 	movsbl 0x8015e3(%eax),%eax
  800792:	50                   	push   %eax
  800793:	ff d7                	call   *%edi
}
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    
  8007a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007a3:	eb c6                	jmp    80076b <printnum+0x73>

008007a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ab:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8007b3:	73 0a                	jae    8007bf <sprintputch+0x1a>
		*b->buf++ = ch;
  8007b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007b8:	89 08                	mov    %ecx,(%eax)
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	88 02                	mov    %al,(%edx)
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ca:	50                   	push   %eax
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 05 00 00 00       	call   8007de <vprintfmt>
	va_end(ap);
}
  8007d9:	83 c4 10             	add    $0x10,%esp
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	57                   	push   %edi
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 2c             	sub    $0x2c,%esp
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007f0:	e9 ac 03 00 00       	jmp    800ba1 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
  8007f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
  800800:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
  800807:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		precision = -1;
		lflag = 0;
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8d 47 01             	lea    0x1(%edi),%eax
  800816:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800819:	8a 17                	mov    (%edi),%dl
  80081b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80081e:	3c 55                	cmp    $0x55,%al
  800820:	0f 87 fc 03 00 00    	ja     800c22 <vprintfmt+0x444>
  800826:	0f b6 c0             	movzbl %al,%eax
  800829:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
  800830:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800833:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800837:	eb da                	jmp    800813 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800839:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80083c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800840:	eb d1                	jmp    800813 <vprintfmt+0x35>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800842:	0f b6 d2             	movzbl %dl,%edx
  800845:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
  80084d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800850:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800853:	01 c0                	add    %eax,%eax
  800855:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800859:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80085c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80085f:	83 f9 09             	cmp    $0x9,%ecx
  800862:	77 52                	ja     8008b6 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800864:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800865:	eb e9                	jmp    800850 <vprintfmt+0x72>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	8b 00                	mov    (%eax),%eax
  80086c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	79 92                	jns    800813 <vprintfmt+0x35>
				width = precision, precision = -1;
  800881:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800884:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800887:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80088e:	eb 83                	jmp    800813 <vprintfmt+0x35>
  800890:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800894:	78 08                	js     80089e <vprintfmt+0xc0>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800899:	e9 75 ff ff ff       	jmp    800813 <vprintfmt+0x35>
  80089e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008a5:	eb ef                	jmp    800896 <vprintfmt+0xb8>
  8008a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008aa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008b1:	e9 5d ff ff ff       	jmp    800813 <vprintfmt+0x35>
  8008b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008bc:	eb bd                	jmp    80087b <vprintfmt+0x9d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008be:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008c2:	e9 4c ff ff ff       	jmp    800813 <vprintfmt+0x35>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 78 04             	lea    0x4(%eax),%edi
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	53                   	push   %ebx
  8008d1:	ff 30                	pushl  (%eax)
  8008d3:	ff d6                	call   *%esi
			break;
  8008d5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8008db:	e9 be 02 00 00       	jmp    800b9e <vprintfmt+0x3c0>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 78 04             	lea    0x4(%eax),%edi
  8008e6:	8b 00                	mov    (%eax),%eax
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	78 2a                	js     800916 <vprintfmt+0x138>
  8008ec:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008ee:	83 f8 08             	cmp    $0x8,%eax
  8008f1:	7f 27                	jg     80091a <vprintfmt+0x13c>
  8008f3:	8b 04 85 00 18 80 00 	mov    0x801800(,%eax,4),%eax
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	74 1c                	je     80091a <vprintfmt+0x13c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008fe:	50                   	push   %eax
  8008ff:	68 04 16 80 00       	push   $0x801604
  800904:	53                   	push   %ebx
  800905:	56                   	push   %esi
  800906:	e8 b6 fe ff ff       	call   8007c1 <printfmt>
  80090b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80090e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800911:	e9 88 02 00 00       	jmp    800b9e <vprintfmt+0x3c0>
  800916:	f7 d8                	neg    %eax
  800918:	eb d2                	jmp    8008ec <vprintfmt+0x10e>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80091a:	52                   	push   %edx
  80091b:	68 fb 15 80 00       	push   $0x8015fb
  800920:	53                   	push   %ebx
  800921:	56                   	push   %esi
  800922:	e8 9a fe ff ff       	call   8007c1 <printfmt>
  800927:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092a:	89 7d 14             	mov    %edi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80092d:	e9 6c 02 00 00       	jmp    800b9e <vprintfmt+0x3c0>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	83 c0 04             	add    $0x4,%eax
  800938:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8b 38                	mov    (%eax),%edi
  800940:	85 ff                	test   %edi,%edi
  800942:	74 18                	je     80095c <vprintfmt+0x17e>
				p = "(null)";
			if (width > 0 && padc != '-')
  800944:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800948:	0f 8e b7 00 00 00    	jle    800a05 <vprintfmt+0x227>
  80094e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800952:	75 0f                	jne    800963 <vprintfmt+0x185>
  800954:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800957:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80095a:	eb 75                	jmp    8009d1 <vprintfmt+0x1f3>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
  80095c:	bf f4 15 80 00       	mov    $0x8015f4,%edi
  800961:	eb e1                	jmp    800944 <vprintfmt+0x166>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	ff 75 d0             	pushl  -0x30(%ebp)
  800969:	57                   	push   %edi
  80096a:	e8 5f 03 00 00       	call   800cce <strnlen>
  80096f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800972:	29 c1                	sub    %eax,%ecx
  800974:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800977:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80097a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80097e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800981:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800984:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800986:	eb 0d                	jmp    800995 <vprintfmt+0x1b7>
					putch(padc, putdat);
  800988:	83 ec 08             	sub    $0x8,%esp
  80098b:	53                   	push   %ebx
  80098c:	ff 75 e0             	pushl  -0x20(%ebp)
  80098f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800991:	4f                   	dec    %edi
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	85 ff                	test   %edi,%edi
  800997:	7f ef                	jg     800988 <vprintfmt+0x1aa>
  800999:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80099c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80099f:	89 c8                	mov    %ecx,%eax
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	78 10                	js     8009b5 <vprintfmt+0x1d7>
  8009a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009a8:	29 c1                	sub    %eax,%ecx
  8009aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8009ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009b0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009b3:	eb 1c                	jmp    8009d1 <vprintfmt+0x1f3>
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	eb e9                	jmp    8009a5 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009c0:	75 29                	jne    8009eb <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	50                   	push   %eax
  8009c9:	ff d6                	call   *%esi
  8009cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ce:	ff 4d e0             	decl   -0x20(%ebp)
  8009d1:	47                   	inc    %edi
  8009d2:	8a 57 ff             	mov    -0x1(%edi),%dl
  8009d5:	0f be c2             	movsbl %dl,%eax
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	74 4c                	je     800a28 <vprintfmt+0x24a>
  8009dc:	85 db                	test   %ebx,%ebx
  8009de:	78 dc                	js     8009bc <vprintfmt+0x1de>
  8009e0:	4b                   	dec    %ebx
  8009e1:	79 d9                	jns    8009bc <vprintfmt+0x1de>
  8009e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8009e9:	eb 2e                	jmp    800a19 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
  8009eb:	0f be d2             	movsbl %dl,%edx
  8009ee:	83 ea 20             	sub    $0x20,%edx
  8009f1:	83 fa 5e             	cmp    $0x5e,%edx
  8009f4:	76 cc                	jbe    8009c2 <vprintfmt+0x1e4>
					putch('?', putdat);
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	ff 75 0c             	pushl  0xc(%ebp)
  8009fc:	6a 3f                	push   $0x3f
  8009fe:	ff d6                	call   *%esi
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	eb c9                	jmp    8009ce <vprintfmt+0x1f0>
  800a05:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a08:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a0b:	eb c4                	jmp    8009d1 <vprintfmt+0x1f3>
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	53                   	push   %ebx
  800a11:	6a 20                	push   $0x20
  800a13:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a15:	4f                   	dec    %edi
  800a16:	83 c4 10             	add    $0x10,%esp
  800a19:	85 ff                	test   %edi,%edi
  800a1b:	7f f0                	jg     800a0d <vprintfmt+0x22f>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a20:	89 45 14             	mov    %eax,0x14(%ebp)
  800a23:	e9 76 01 00 00       	jmp    800b9e <vprintfmt+0x3c0>
  800a28:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2e:	eb e9                	jmp    800a19 <vprintfmt+0x23b>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a30:	83 f9 01             	cmp    $0x1,%ecx
  800a33:	7e 3f                	jle    800a74 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800a35:	8b 45 14             	mov    0x14(%ebp),%eax
  800a38:	8b 50 04             	mov    0x4(%eax),%edx
  800a3b:	8b 00                	mov    (%eax),%eax
  800a3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a40:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	8d 40 08             	lea    0x8(%eax),%eax
  800a49:	89 45 14             	mov    %eax,0x14(%ebp)
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a4c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a50:	79 5c                	jns    800aae <vprintfmt+0x2d0>
				putch('-', putdat);
  800a52:	83 ec 08             	sub    $0x8,%esp
  800a55:	53                   	push   %ebx
  800a56:	6a 2d                	push   $0x2d
  800a58:	ff d6                	call   *%esi
				num = -(long long) num;
  800a5a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a5d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a60:	f7 da                	neg    %edx
  800a62:	83 d1 00             	adc    $0x0,%ecx
  800a65:	f7 d9                	neg    %ecx
  800a67:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800a6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6f:	e9 10 01 00 00       	jmp    800b84 <vprintfmt+0x3a6>
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	75 1b                	jne    800a93 <vprintfmt+0x2b5>
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800a78:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7b:	8b 00                	mov    (%eax),%eax
  800a7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a80:	89 c1                	mov    %eax,%ecx
  800a82:	c1 f9 1f             	sar    $0x1f,%ecx
  800a85:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 40 04             	lea    0x4(%eax),%eax
  800a8e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a91:	eb b9                	jmp    800a4c <vprintfmt+0x26e>
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
  800a93:	8b 45 14             	mov    0x14(%ebp),%eax
  800a96:	8b 00                	mov    (%eax),%eax
  800a98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9b:	89 c1                	mov    %eax,%ecx
  800a9d:	c1 f9 1f             	sar    $0x1f,%ecx
  800aa0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 40 04             	lea    0x4(%eax),%eax
  800aa9:	89 45 14             	mov    %eax,0x14(%ebp)
  800aac:	eb 9e                	jmp    800a4c <vprintfmt+0x26e>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ab4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab9:	e9 c6 00 00 00       	jmp    800b84 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800abe:	83 f9 01             	cmp    $0x1,%ecx
  800ac1:	7e 18                	jle    800adb <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
  800ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac6:	8b 10                	mov    (%eax),%edx
  800ac8:	8b 48 04             	mov    0x4(%eax),%ecx
  800acb:	8d 40 08             	lea    0x8(%eax),%eax
  800ace:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800ad1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad6:	e9 a9 00 00 00       	jmp    800b84 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800adb:	85 c9                	test   %ecx,%ecx
  800add:	75 1a                	jne    800af9 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8b 10                	mov    (%eax),%edx
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	8d 40 04             	lea    0x4(%eax),%eax
  800aec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800aef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af4:	e9 8b 00 00 00       	jmp    800b84 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 10                	mov    (%eax),%edx
  800afe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b03:	8d 40 04             	lea    0x4(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	eb 74                	jmp    800b84 <vprintfmt+0x3a6>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b10:	83 f9 01             	cmp    $0x1,%ecx
  800b13:	7e 15                	jle    800b2a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
  800b15:	8b 45 14             	mov    0x14(%ebp),%eax
  800b18:	8b 10                	mov    (%eax),%edx
  800b1a:	8b 48 04             	mov    0x4(%eax),%ecx
  800b1d:	8d 40 08             	lea    0x8(%eax),%eax
  800b20:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800b23:	b8 08 00 00 00       	mov    $0x8,%eax
  800b28:	eb 5a                	jmp    800b84 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b2a:	85 c9                	test   %ecx,%ecx
  800b2c:	75 17                	jne    800b45 <vprintfmt+0x367>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b31:	8b 10                	mov    (%eax),%edx
  800b33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b38:	8d 40 04             	lea    0x4(%eax),%eax
  800b3b:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800b3e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b43:	eb 3f                	jmp    800b84 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8b 10                	mov    (%eax),%edx
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	8d 40 04             	lea    0x4(%eax),%eax
  800b52:	89 45 14             	mov    %eax,0x14(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
            num = getuint(&ap, lflag);
			base = 8;
  800b55:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5a:	eb 28                	jmp    800b84 <vprintfmt+0x3a6>
            goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	6a 30                	push   $0x30
  800b62:	ff d6                	call   *%esi
			putch('x', putdat);
  800b64:	83 c4 08             	add    $0x8,%esp
  800b67:	53                   	push   %ebx
  800b68:	6a 78                	push   $0x78
  800b6a:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8b 10                	mov    (%eax),%edx
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b76:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b79:	8d 40 04             	lea    0x4(%eax),%eax
  800b7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b7f:	b8 10 00 00 00       	mov    $0x10,%eax
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b8b:	57                   	push   %edi
  800b8c:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8f:	50                   	push   %eax
  800b90:	51                   	push   %ecx
  800b91:	52                   	push   %edx
  800b92:	89 da                	mov    %ebx,%edx
  800b94:	89 f0                	mov    %esi,%eax
  800b96:	e8 5d fb ff ff       	call   8006f8 <printnum>
			break;
  800b9b:	83 c4 20             	add    $0x20,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ba1:	47                   	inc    %edi
  800ba2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ba6:	83 f8 25             	cmp    $0x25,%eax
  800ba9:	0f 84 46 fc ff ff    	je     8007f5 <vprintfmt+0x17>
			if (ch == '\0')
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	0f 84 89 00 00 00    	je     800c40 <vprintfmt+0x462>
				return;
			putch(ch, putdat);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	53                   	push   %ebx
  800bbb:	50                   	push   %eax
  800bbc:	ff d6                	call   *%esi
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	eb de                	jmp    800ba1 <vprintfmt+0x3c3>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bc3:	83 f9 01             	cmp    $0x1,%ecx
  800bc6:	7e 15                	jle    800bdd <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
  800bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8b 48 04             	mov    0x4(%eax),%ecx
  800bd0:	8d 40 08             	lea    0x8(%eax),%eax
  800bd3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bdb:	eb a7                	jmp    800b84 <vprintfmt+0x3a6>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800bdd:	85 c9                	test   %ecx,%ecx
  800bdf:	75 17                	jne    800bf8 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800be1:	8b 45 14             	mov    0x14(%ebp),%eax
  800be4:	8b 10                	mov    (%eax),%edx
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	8d 40 04             	lea    0x4(%eax),%eax
  800bee:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bf1:	b8 10 00 00 00       	mov    $0x10,%eax
  800bf6:	eb 8c                	jmp    800b84 <vprintfmt+0x3a6>
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
  800bf8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfb:	8b 10                	mov    (%eax),%edx
  800bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c02:	8d 40 04             	lea    0x4(%eax),%eax
  800c05:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c08:	b8 10 00 00 00       	mov    $0x10,%eax
  800c0d:	e9 72 ff ff ff       	jmp    800b84 <vprintfmt+0x3a6>
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c12:	83 ec 08             	sub    $0x8,%esp
  800c15:	53                   	push   %ebx
  800c16:	6a 25                	push   $0x25
  800c18:	ff d6                	call   *%esi
			break;
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	e9 7c ff ff ff       	jmp    800b9e <vprintfmt+0x3c0>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	6a 25                	push   $0x25
  800c28:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	eb 01                	jmp    800c32 <vprintfmt+0x454>
  800c31:	48                   	dec    %eax
  800c32:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c36:	75 f9                	jne    800c31 <vprintfmt+0x453>
  800c38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3b:	e9 5e ff ff ff       	jmp    800b9e <vprintfmt+0x3c0>
				/* do nothing */;
			break;
		}
	}
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 18             	sub    $0x18,%esp
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c57:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c5b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	74 26                	je     800c8f <vsnprintf+0x47>
  800c69:	85 d2                	test   %edx,%edx
  800c6b:	7e 29                	jle    800c96 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6d:	ff 75 14             	pushl  0x14(%ebp)
  800c70:	ff 75 10             	pushl  0x10(%ebp)
  800c73:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c76:	50                   	push   %eax
  800c77:	68 a5 07 80 00       	push   $0x8007a5
  800c7c:	e8 5d fb ff ff       	call   8007de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c84:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8a:	83 c4 10             	add    $0x10,%esp
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c94:	eb f7                	jmp    800c8d <vsnprintf+0x45>
  800c96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c9b:	eb f0                	jmp    800c8d <vsnprintf+0x45>

00800c9d <snprintf>:
	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ca3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ca6:	50                   	push   %eax
  800ca7:	ff 75 10             	pushl  0x10(%ebp)
  800caa:	ff 75 0c             	pushl  0xc(%ebp)
  800cad:	ff 75 08             	pushl  0x8(%ebp)
  800cb0:	e8 93 ff ff ff       	call   800c48 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    
	...

00800cb8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc3:	eb 01                	jmp    800cc6 <strlen+0xe>
		n++;
  800cc5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cca:	75 f9                	jne    800cc5 <strlen+0xd>
		n++;
	return n;
}
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdc:	eb 01                	jmp    800cdf <strnlen+0x11>
		n++;
  800cde:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdf:	39 d0                	cmp    %edx,%eax
  800ce1:	74 06                	je     800ce9 <strnlen+0x1b>
  800ce3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ce7:	75 f5                	jne    800cde <strnlen+0x10>
		n++;
	return n;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf5:	89 c2                	mov    %eax,%edx
  800cf7:	41                   	inc    %ecx
  800cf8:	42                   	inc    %edx
  800cf9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800cfc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 f4                	jne    800cf7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0d:	53                   	push   %ebx
  800d0e:	e8 a5 ff ff ff       	call   800cb8 <strlen>
  800d13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	01 d8                	add    %ebx,%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 ca ff ff ff       	call   800ceb <strcpy>
	return dst;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	39 da                	cmp    %ebx,%edx
  800d3c:	74 0e                	je     800d4c <strncpy+0x24>
		*dst++ = *src;
  800d3e:	42                   	inc    %edx
  800d3f:	8a 01                	mov    (%ecx),%al
  800d41:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d44:	80 39 00             	cmpb   $0x0,(%ecx)
  800d47:	74 f1                	je     800d3a <strncpy+0x12>
			src++;
  800d49:	41                   	inc    %ecx
  800d4a:	eb ee                	jmp    800d3a <strncpy+0x12>
	}
	return ret;
}
  800d4c:	89 f0                	mov    %esi,%eax
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d60:	85 c0                	test   %eax,%eax
  800d62:	74 20                	je     800d84 <strlcpy+0x32>
  800d64:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800d68:	89 f0                	mov    %esi,%eax
  800d6a:	eb 05                	jmp    800d71 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d6c:	42                   	inc    %edx
  800d6d:	40                   	inc    %eax
  800d6e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d71:	39 d8                	cmp    %ebx,%eax
  800d73:	74 06                	je     800d7b <strlcpy+0x29>
  800d75:	8a 0a                	mov    (%edx),%cl
  800d77:	84 c9                	test   %cl,%cl
  800d79:	75 f1                	jne    800d6c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800d7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d7e:	29 f0                	sub    %esi,%eax
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
  800d84:	89 f0                	mov    %esi,%eax
  800d86:	eb f6                	jmp    800d7e <strlcpy+0x2c>

00800d88 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d91:	eb 02                	jmp    800d95 <strcmp+0xd>
		p++, q++;
  800d93:	41                   	inc    %ecx
  800d94:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d95:	8a 01                	mov    (%ecx),%al
  800d97:	84 c0                	test   %al,%al
  800d99:	74 04                	je     800d9f <strcmp+0x17>
  800d9b:	3a 02                	cmp    (%edx),%al
  800d9d:	74 f4                	je     800d93 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9f:	0f b6 c0             	movzbl %al,%eax
  800da2:	0f b6 12             	movzbl (%edx),%edx
  800da5:	29 d0                	sub    %edx,%eax
}
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	53                   	push   %ebx
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db8:	eb 02                	jmp    800dbc <strncmp+0x13>
		n--, p++, q++;
  800dba:	40                   	inc    %eax
  800dbb:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dbc:	39 d8                	cmp    %ebx,%eax
  800dbe:	74 15                	je     800dd5 <strncmp+0x2c>
  800dc0:	8a 08                	mov    (%eax),%cl
  800dc2:	84 c9                	test   %cl,%cl
  800dc4:	74 04                	je     800dca <strncmp+0x21>
  800dc6:	3a 0a                	cmp    (%edx),%cl
  800dc8:	74 f0                	je     800dba <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	0f b6 12             	movzbl (%edx),%edx
  800dd0:	29 d0                	sub    %edx,%eax
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	eb f6                	jmp    800dd2 <strncmp+0x29>

00800ddc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800de5:	8a 10                	mov    (%eax),%dl
  800de7:	84 d2                	test   %dl,%dl
  800de9:	74 07                	je     800df2 <strchr+0x16>
		if (*s == c)
  800deb:	38 ca                	cmp    %cl,%dl
  800ded:	74 08                	je     800df7 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800def:	40                   	inc    %eax
  800df0:	eb f3                	jmp    800de5 <strchr+0x9>
		if (*s == c)
			return (char *) s;
	return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800e02:	8a 10                	mov    (%eax),%dl
  800e04:	84 d2                	test   %dl,%dl
  800e06:	74 07                	je     800e0f <strfind+0x16>
		if (*s == c)
  800e08:	38 ca                	cmp    %cl,%dl
  800e0a:	74 03                	je     800e0f <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e0c:	40                   	inc    %eax
  800e0d:	eb f3                	jmp    800e02 <strfind+0x9>
		if (*s == c)
			break;
	return (char *) s;
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e1d:	85 c9                	test   %ecx,%ecx
  800e1f:	74 13                	je     800e34 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e27:	75 05                	jne    800e2e <memset+0x1d>
  800e29:	f6 c1 03             	test   $0x3,%cl
  800e2c:	74 0d                	je     800e3b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	fc                   	cld    
  800e32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e34:	89 f8                	mov    %edi,%eax
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
  800e3b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e3f:	89 d3                	mov    %edx,%ebx
  800e41:	c1 e3 08             	shl    $0x8,%ebx
  800e44:	89 d0                	mov    %edx,%eax
  800e46:	c1 e0 18             	shl    $0x18,%eax
  800e49:	89 d6                	mov    %edx,%esi
  800e4b:	c1 e6 10             	shl    $0x10,%esi
  800e4e:	09 f0                	or     %esi,%eax
  800e50:	09 c2                	or     %eax,%edx
  800e52:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e54:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e57:	89 d0                	mov    %edx,%eax
  800e59:	fc                   	cld    
  800e5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800e5c:	eb d6                	jmp    800e34 <memset+0x23>

00800e5e <memmove>:
	return v;
}

void *
memmove(void *dst, const void *src, size_t n)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e6c:	39 c6                	cmp    %eax,%esi
  800e6e:	73 33                	jae    800ea3 <memmove+0x45>
  800e70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e73:	39 c2                	cmp    %eax,%edx
  800e75:	76 2c                	jbe    800ea3 <memmove+0x45>
		s += n;
		d += n;
  800e77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7a:	89 d6                	mov    %edx,%esi
  800e7c:	09 fe                	or     %edi,%esi
  800e7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e84:	74 0a                	je     800e90 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e86:	4f                   	dec    %edi
  800e87:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e8a:	fd                   	std    
  800e8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e8d:	fc                   	cld    
  800e8e:	eb 21                	jmp    800eb1 <memmove+0x53>
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e90:	f6 c1 03             	test   $0x3,%cl
  800e93:	75 f1                	jne    800e86 <memmove+0x28>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e95:	83 ef 04             	sub    $0x4,%edi
  800e98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e9b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e9e:	fd                   	std    
  800e9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ea1:	eb ea                	jmp    800e8d <memmove+0x2f>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea3:	89 f2                	mov    %esi,%edx
  800ea5:	09 c2                	or     %eax,%edx
  800ea7:	f6 c2 03             	test   $0x3,%dl
  800eaa:	74 09                	je     800eb5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eac:	89 c7                	mov    %eax,%edi
  800eae:	fc                   	cld    
  800eaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb5:	f6 c1 03             	test   $0x3,%cl
  800eb8:	75 f2                	jne    800eac <memmove+0x4e>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ebd:	89 c7                	mov    %eax,%edi
  800ebf:	fc                   	cld    
  800ec0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec2:	eb ed                	jmp    800eb1 <memmove+0x53>

00800ec4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ec7:	ff 75 10             	pushl  0x10(%ebp)
  800eca:	ff 75 0c             	pushl  0xc(%ebp)
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 89 ff ff ff       	call   800e5e <memmove>
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee2:	89 c6                	mov    %eax,%esi
  800ee4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ee7:	39 f0                	cmp    %esi,%eax
  800ee9:	74 16                	je     800f01 <memcmp+0x2a>
		if (*s1 != *s2)
  800eeb:	8a 08                	mov    (%eax),%cl
  800eed:	8a 1a                	mov    (%edx),%bl
  800eef:	38 d9                	cmp    %bl,%cl
  800ef1:	75 04                	jne    800ef7 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ef3:	40                   	inc    %eax
  800ef4:	42                   	inc    %edx
  800ef5:	eb f0                	jmp    800ee7 <memcmp+0x10>
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
  800ef7:	0f b6 c1             	movzbl %cl,%eax
  800efa:	0f b6 db             	movzbl %bl,%ebx
  800efd:	29 d8                	sub    %ebx,%eax
  800eff:	eb 05                	jmp    800f06 <memcmp+0x2f>
		s1++, s2++;
	}

	return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f18:	39 d0                	cmp    %edx,%eax
  800f1a:	73 07                	jae    800f23 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f1c:	38 08                	cmp    %cl,(%eax)
  800f1e:	74 03                	je     800f23 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f20:	40                   	inc    %eax
  800f21:	eb f5                	jmp    800f18 <memfind+0xe>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2e:	eb 01                	jmp    800f31 <strtol+0xc>
		s++;
  800f30:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f31:	8a 01                	mov    (%ecx),%al
  800f33:	3c 20                	cmp    $0x20,%al
  800f35:	74 f9                	je     800f30 <strtol+0xb>
  800f37:	3c 09                	cmp    $0x9,%al
  800f39:	74 f5                	je     800f30 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f3b:	3c 2b                	cmp    $0x2b,%al
  800f3d:	74 2b                	je     800f6a <strtol+0x45>
		s++;
	else if (*s == '-')
  800f3f:	3c 2d                	cmp    $0x2d,%al
  800f41:	74 2f                	je     800f72 <strtol+0x4d>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f48:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
  800f4f:	75 12                	jne    800f63 <strtol+0x3e>
  800f51:	80 39 30             	cmpb   $0x30,(%ecx)
  800f54:	74 24                	je     800f7a <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5a:	75 07                	jne    800f63 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f5c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	eb 4e                	jmp    800fb8 <strtol+0x93>
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
  800f6a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f70:	eb d6                	jmp    800f48 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
		s++, neg = 1;
  800f72:	41                   	inc    %ecx
  800f73:	bf 01 00 00 00       	mov    $0x1,%edi
  800f78:	eb ce                	jmp    800f48 <strtol+0x23>

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f7a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f7e:	74 10                	je     800f90 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f84:	75 dd                	jne    800f63 <strtol+0x3e>
		s++, base = 8;
  800f86:	41                   	inc    %ecx
  800f87:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800f8e:	eb d3                	jmp    800f63 <strtol+0x3e>
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
  800f90:	83 c1 02             	add    $0x2,%ecx
  800f93:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800f9a:	eb c7                	jmp    800f63 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800f9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f9f:	89 f3                	mov    %esi,%ebx
  800fa1:	80 fb 19             	cmp    $0x19,%bl
  800fa4:	77 24                	ja     800fca <strtol+0xa5>
			dig = *s - 'a' + 10;
  800fa6:	0f be d2             	movsbl %dl,%edx
  800fa9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fac:	39 55 10             	cmp    %edx,0x10(%ebp)
  800faf:	7e 2b                	jle    800fdc <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
  800fb1:	41                   	inc    %ecx
  800fb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fb6:	01 d0                	add    %edx,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb8:	8a 11                	mov    (%ecx),%dl
  800fba:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800fbd:	80 fb 09             	cmp    $0x9,%bl
  800fc0:	77 da                	ja     800f9c <strtol+0x77>
			dig = *s - '0';
  800fc2:	0f be d2             	movsbl %dl,%edx
  800fc5:	83 ea 30             	sub    $0x30,%edx
  800fc8:	eb e2                	jmp    800fac <strtol+0x87>
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800fca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fcd:	89 f3                	mov    %esi,%ebx
  800fcf:	80 fb 19             	cmp    $0x19,%bl
  800fd2:	77 08                	ja     800fdc <strtol+0xb7>
			dig = *s - 'A' + 10;
  800fd4:	0f be d2             	movsbl %dl,%edx
  800fd7:	83 ea 37             	sub    $0x37,%edx
  800fda:	eb d0                	jmp    800fac <strtol+0x87>
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fe0:	74 05                	je     800fe7 <strtol+0xc2>
		*endptr = (char *) s;
  800fe2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800fe7:	85 ff                	test   %edi,%edi
  800fe9:	74 02                	je     800fed <strtol+0xc8>
  800feb:	f7 d8                	neg    %eax
}
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    
	...

00800ff4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffa:	b8 00 00 00 00       	mov    $0x0,%eax
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801005:	89 c3                	mov    %eax,%ebx
  801007:	89 c7                	mov    %eax,%edi
  801009:	89 c6                	mov    %eax,%esi
  80100b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sys_cgetc>:

int
sys_cgetc(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801018:	ba 00 00 00 00       	mov    $0x0,%edx
  80101d:	b8 01 00 00 00       	mov    $0x1,%eax
  801022:	89 d1                	mov    %edx,%ecx
  801024:	89 d3                	mov    %edx,%ebx
  801026:	89 d7                	mov    %edx,%edi
  801028:	89 d6                	mov    %edx,%esi
  80102a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	b8 03 00 00 00       	mov    $0x3,%eax
  801047:	89 cb                	mov    %ecx,%ebx
  801049:	89 cf                	mov    %ecx,%edi
  80104b:	89 ce                	mov    %ecx,%esi
  80104d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	7f 08                	jg     80105b <sys_env_destroy+0x2a>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801053:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	6a 03                	push   $0x3
  801061:	68 24 18 80 00       	push   $0x801824
  801066:	6a 23                	push   $0x23
  801068:	68 41 18 80 00       	push   $0x801841
  80106d:	e8 96 f5 ff ff       	call   800608 <_panic>

00801072 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801078:	ba 00 00 00 00       	mov    $0x0,%edx
  80107d:	b8 02 00 00 00       	mov    $0x2,%eax
  801082:	89 d1                	mov    %edx,%ecx
  801084:	89 d3                	mov    %edx,%ebx
  801086:	89 d7                	mov    %edx,%edi
  801088:	89 d6                	mov    %edx,%esi
  80108a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_yield>:

void
sys_yield(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801097:	ba 00 00 00 00       	mov    $0x0,%edx
  80109c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a1:	89 d1                	mov    %edx,%ecx
  8010a3:	89 d3                	mov    %edx,%ebx
  8010a5:	89 d7                	mov    %edx,%edi
  8010a7:	89 d6                	mov    %edx,%esi
  8010a9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b9:	be 00 00 00 00       	mov    $0x0,%esi
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8010c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cc:	89 f7                	mov    %esi,%edi
  8010ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7f 08                	jg     8010dc <sys_page_alloc+0x2c>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	6a 04                	push   $0x4
  8010e2:	68 24 18 80 00       	push   $0x801824
  8010e7:	6a 23                	push   $0x23
  8010e9:	68 41 18 80 00       	push   $0x801841
  8010ee:	e8 15 f5 ff ff       	call   800608 <_panic>

008010f3 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801102:	b8 05 00 00 00       	mov    $0x5,%eax
  801107:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80110d:	8b 75 18             	mov    0x18(%ebp),%esi
  801110:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7f 08                	jg     80111e <sys_page_map+0x2b>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 05                	push   $0x5
  801124:	68 24 18 80 00       	push   $0x801824
  801129:	6a 23                	push   $0x23
  80112b:	68 41 18 80 00       	push   $0x801841
  801130:	e8 d3 f4 ff ff       	call   800608 <_panic>

00801135 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	b8 06 00 00 00       	mov    $0x6,%eax
  80114e:	89 df                	mov    %ebx,%edi
  801150:	89 de                	mov    %ebx,%esi
  801152:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	7f 08                	jg     801160 <sys_page_unmap+0x2b>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	6a 06                	push   $0x6
  801166:	68 24 18 80 00       	push   $0x801824
  80116b:	6a 23                	push   $0x23
  80116d:	68 41 18 80 00       	push   $0x801841
  801172:	e8 91 f4 ff ff       	call   800608 <_panic>

00801177 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118b:	b8 08 00 00 00       	mov    $0x8,%eax
  801190:	89 df                	mov    %ebx,%edi
  801192:	89 de                	mov    %ebx,%esi
  801194:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	7f 08                	jg     8011a2 <sys_env_set_status+0x2b>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	50                   	push   %eax
  8011a6:	6a 08                	push   $0x8
  8011a8:	68 24 18 80 00       	push   $0x801824
  8011ad:	6a 23                	push   $0x23
  8011af:	68 41 18 80 00       	push   $0x801841
  8011b4:	e8 4f f4 ff ff       	call   800608 <_panic>

008011b9 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d2:	89 df                	mov    %ebx,%edi
  8011d4:	89 de                	mov    %ebx,%esi
  8011d6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	7f 08                	jg     8011e4 <sys_env_set_pgfault_upcall+0x2b>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	50                   	push   %eax
  8011e8:	6a 09                	push   $0x9
  8011ea:	68 24 18 80 00       	push   $0x801824
  8011ef:	6a 23                	push   $0x23
  8011f1:	68 41 18 80 00       	push   $0x801841
  8011f6:	e8 0d f4 ff ff       	call   800608 <_panic>

008011fb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	b8 0b 00 00 00       	mov    $0xb,%eax
  80120c:	be 00 00 00 00       	mov    $0x0,%esi
  801211:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801214:	8b 7d 14             	mov    0x14(%ebp),%edi
  801217:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801227:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122c:	8b 55 08             	mov    0x8(%ebp),%edx
  80122f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801234:	89 cb                	mov    %ecx,%ebx
  801236:	89 cf                	mov    %ecx,%edi
  801238:	89 ce                	mov    %ecx,%esi
  80123a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80123c:	85 c0                	test   %eax,%eax
  80123e:	7f 08                	jg     801248 <sys_ipc_recv+0x2a>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	50                   	push   %eax
  80124c:	6a 0c                	push   $0xc
  80124e:	68 24 18 80 00       	push   $0x801824
  801253:	6a 23                	push   $0x23
  801255:	68 41 18 80 00       	push   $0x801841
  80125a:	e8 a9 f3 ff ff       	call   800608 <_panic>
	...

00801260 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801266:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80126d:	74 0a                	je     801279 <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801277:	c9                   	leave  
  801278:	c3                   	ret    
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	68 50 18 80 00       	push   $0x801850
  801281:	6a 20                	push   $0x20
  801283:	68 74 18 80 00       	push   $0x801874
  801288:	e8 7b f3 ff ff       	call   800608 <_panic>
  80128d:	00 00                	add    %al,(%eax)
	...

00801290 <__udivdi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 1c             	sub    $0x1c,%esp
  801297:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80129b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80129f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012a3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012a7:	85 d2                	test   %edx,%edx
  8012a9:	75 2d                	jne    8012d8 <__udivdi3+0x48>
  8012ab:	39 f7                	cmp    %esi,%edi
  8012ad:	77 59                	ja     801308 <__udivdi3+0x78>
  8012af:	89 f9                	mov    %edi,%ecx
  8012b1:	85 ff                	test   %edi,%edi
  8012b3:	75 0b                	jne    8012c0 <__udivdi3+0x30>
  8012b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ba:	31 d2                	xor    %edx,%edx
  8012bc:	f7 f7                	div    %edi
  8012be:	89 c1                	mov    %eax,%ecx
  8012c0:	31 d2                	xor    %edx,%edx
  8012c2:	89 f0                	mov    %esi,%eax
  8012c4:	f7 f1                	div    %ecx
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	89 e8                	mov    %ebp,%eax
  8012ca:	f7 f1                	div    %ecx
  8012cc:	89 da                	mov    %ebx,%edx
  8012ce:	83 c4 1c             	add    $0x1c,%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	77 1c                	ja     8012f8 <__udivdi3+0x68>
  8012dc:	0f bd da             	bsr    %edx,%ebx
  8012df:	83 f3 1f             	xor    $0x1f,%ebx
  8012e2:	75 38                	jne    80131c <__udivdi3+0x8c>
  8012e4:	39 f2                	cmp    %esi,%edx
  8012e6:	72 08                	jb     8012f0 <__udivdi3+0x60>
  8012e8:	39 ef                	cmp    %ebp,%edi
  8012ea:	0f 87 98 00 00 00    	ja     801388 <__udivdi3+0xf8>
  8012f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f5:	eb 05                	jmp    8012fc <__udivdi3+0x6c>
  8012f7:	90                   	nop
  8012f8:	31 db                	xor    %ebx,%ebx
  8012fa:	31 c0                	xor    %eax,%eax
  8012fc:	89 da                	mov    %ebx,%edx
  8012fe:	83 c4 1c             	add    $0x1c,%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
  801306:	66 90                	xchg   %ax,%ax
  801308:	89 e8                	mov    %ebp,%eax
  80130a:	89 f2                	mov    %esi,%edx
  80130c:	f7 f7                	div    %edi
  80130e:	31 db                	xor    %ebx,%ebx
  801310:	89 da                	mov    %ebx,%edx
  801312:	83 c4 1c             	add    $0x1c,%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	b8 20 00 00 00       	mov    $0x20,%eax
  801321:	29 d8                	sub    %ebx,%eax
  801323:	88 d9                	mov    %bl,%cl
  801325:	d3 e2                	shl    %cl,%edx
  801327:	89 54 24 08          	mov    %edx,0x8(%esp)
  80132b:	89 fa                	mov    %edi,%edx
  80132d:	88 c1                	mov    %al,%cl
  80132f:	d3 ea                	shr    %cl,%edx
  801331:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801335:	09 d1                	or     %edx,%ecx
  801337:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133b:	88 d9                	mov    %bl,%cl
  80133d:	d3 e7                	shl    %cl,%edi
  80133f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801343:	89 f7                	mov    %esi,%edi
  801345:	88 c1                	mov    %al,%cl
  801347:	d3 ef                	shr    %cl,%edi
  801349:	88 d9                	mov    %bl,%cl
  80134b:	d3 e6                	shl    %cl,%esi
  80134d:	89 ea                	mov    %ebp,%edx
  80134f:	88 c1                	mov    %al,%cl
  801351:	d3 ea                	shr    %cl,%edx
  801353:	09 d6                	or     %edx,%esi
  801355:	89 f0                	mov    %esi,%eax
  801357:	89 fa                	mov    %edi,%edx
  801359:	f7 74 24 08          	divl   0x8(%esp)
  80135d:	89 d7                	mov    %edx,%edi
  80135f:	89 c6                	mov    %eax,%esi
  801361:	f7 64 24 0c          	mull   0xc(%esp)
  801365:	39 d7                	cmp    %edx,%edi
  801367:	72 13                	jb     80137c <__udivdi3+0xec>
  801369:	74 09                	je     801374 <__udivdi3+0xe4>
  80136b:	89 f0                	mov    %esi,%eax
  80136d:	31 db                	xor    %ebx,%ebx
  80136f:	eb 8b                	jmp    8012fc <__udivdi3+0x6c>
  801371:	8d 76 00             	lea    0x0(%esi),%esi
  801374:	88 d9                	mov    %bl,%cl
  801376:	d3 e5                	shl    %cl,%ebp
  801378:	39 c5                	cmp    %eax,%ebp
  80137a:	73 ef                	jae    80136b <__udivdi3+0xdb>
  80137c:	8d 46 ff             	lea    -0x1(%esi),%eax
  80137f:	31 db                	xor    %ebx,%ebx
  801381:	e9 76 ff ff ff       	jmp    8012fc <__udivdi3+0x6c>
  801386:	66 90                	xchg   %ax,%ax
  801388:	31 c0                	xor    %eax,%eax
  80138a:	e9 6d ff ff ff       	jmp    8012fc <__udivdi3+0x6c>
	...

00801390 <__umoddi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 1c             	sub    $0x1c,%esp
  801397:	8b 74 24 30          	mov    0x30(%esp),%esi
  80139b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80139f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013a3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8013a7:	89 f0                	mov    %esi,%eax
  8013a9:	89 da                	mov    %ebx,%edx
  8013ab:	85 ed                	test   %ebp,%ebp
  8013ad:	75 15                	jne    8013c4 <__umoddi3+0x34>
  8013af:	39 df                	cmp    %ebx,%edi
  8013b1:	76 39                	jbe    8013ec <__umoddi3+0x5c>
  8013b3:	f7 f7                	div    %edi
  8013b5:	89 d0                	mov    %edx,%eax
  8013b7:	31 d2                	xor    %edx,%edx
  8013b9:	83 c4 1c             	add    $0x1c,%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5f                   	pop    %edi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    
  8013c1:	8d 76 00             	lea    0x0(%esi),%esi
  8013c4:	39 dd                	cmp    %ebx,%ebp
  8013c6:	77 f1                	ja     8013b9 <__umoddi3+0x29>
  8013c8:	0f bd cd             	bsr    %ebp,%ecx
  8013cb:	83 f1 1f             	xor    $0x1f,%ecx
  8013ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013d2:	75 38                	jne    80140c <__umoddi3+0x7c>
  8013d4:	39 dd                	cmp    %ebx,%ebp
  8013d6:	72 04                	jb     8013dc <__umoddi3+0x4c>
  8013d8:	39 f7                	cmp    %esi,%edi
  8013da:	77 dd                	ja     8013b9 <__umoddi3+0x29>
  8013dc:	89 da                	mov    %ebx,%edx
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	29 f8                	sub    %edi,%eax
  8013e2:	19 ea                	sbb    %ebp,%edx
  8013e4:	83 c4 1c             	add    $0x1c,%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    
  8013ec:	89 f9                	mov    %edi,%ecx
  8013ee:	85 ff                	test   %edi,%edi
  8013f0:	75 0b                	jne    8013fd <__umoddi3+0x6d>
  8013f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f7:	31 d2                	xor    %edx,%edx
  8013f9:	f7 f7                	div    %edi
  8013fb:	89 c1                	mov    %eax,%ecx
  8013fd:	89 d8                	mov    %ebx,%eax
  8013ff:	31 d2                	xor    %edx,%edx
  801401:	f7 f1                	div    %ecx
  801403:	89 f0                	mov    %esi,%eax
  801405:	f7 f1                	div    %ecx
  801407:	eb ac                	jmp    8013b5 <__umoddi3+0x25>
  801409:	8d 76 00             	lea    0x0(%esi),%esi
  80140c:	b8 20 00 00 00       	mov    $0x20,%eax
  801411:	89 c2                	mov    %eax,%edx
  801413:	8b 44 24 04          	mov    0x4(%esp),%eax
  801417:	29 c2                	sub    %eax,%edx
  801419:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80141d:	88 c1                	mov    %al,%cl
  80141f:	d3 e5                	shl    %cl,%ebp
  801421:	89 f8                	mov    %edi,%eax
  801423:	88 d1                	mov    %dl,%cl
  801425:	d3 e8                	shr    %cl,%eax
  801427:	09 c5                	or     %eax,%ebp
  801429:	8b 44 24 04          	mov    0x4(%esp),%eax
  80142d:	88 c1                	mov    %al,%cl
  80142f:	d3 e7                	shl    %cl,%edi
  801431:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801435:	89 df                	mov    %ebx,%edi
  801437:	88 d1                	mov    %dl,%cl
  801439:	d3 ef                	shr    %cl,%edi
  80143b:	88 c1                	mov    %al,%cl
  80143d:	d3 e3                	shl    %cl,%ebx
  80143f:	89 f0                	mov    %esi,%eax
  801441:	88 d1                	mov    %dl,%cl
  801443:	d3 e8                	shr    %cl,%eax
  801445:	09 d8                	or     %ebx,%eax
  801447:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80144b:	d3 e6                	shl    %cl,%esi
  80144d:	89 fa                	mov    %edi,%edx
  80144f:	f7 f5                	div    %ebp
  801451:	89 d1                	mov    %edx,%ecx
  801453:	f7 64 24 08          	mull   0x8(%esp)
  801457:	89 c3                	mov    %eax,%ebx
  801459:	89 d7                	mov    %edx,%edi
  80145b:	39 d1                	cmp    %edx,%ecx
  80145d:	72 29                	jb     801488 <__umoddi3+0xf8>
  80145f:	74 23                	je     801484 <__umoddi3+0xf4>
  801461:	89 ca                	mov    %ecx,%edx
  801463:	29 de                	sub    %ebx,%esi
  801465:	19 fa                	sbb    %edi,%edx
  801467:	89 d0                	mov    %edx,%eax
  801469:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80146d:	d3 e0                	shl    %cl,%eax
  80146f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801473:	88 d9                	mov    %bl,%cl
  801475:	d3 ee                	shr    %cl,%esi
  801477:	09 f0                	or     %esi,%eax
  801479:	d3 ea                	shr    %cl,%edx
  80147b:	83 c4 1c             	add    $0x1c,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
  801483:	90                   	nop
  801484:	39 c6                	cmp    %eax,%esi
  801486:	73 d9                	jae    801461 <__umoddi3+0xd1>
  801488:	2b 44 24 08          	sub    0x8(%esp),%eax
  80148c:	19 ea                	sbb    %ebp,%edx
  80148e:	89 d7                	mov    %edx,%edi
  801490:	89 c3                	mov    %eax,%ebx
  801492:	eb cd                	jmp    801461 <__umoddi3+0xd1>
