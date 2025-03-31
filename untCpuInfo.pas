unit untCpuInfo;

interface

{ 获取 CPU 制造商 }
function GetCpuFactory: String;

{ 获取 CPU 家族系统 }
function GetCpuFamily: Cardinal;

{ 获取 CPU 型号 }
function GetCpuModel: Cardinal;

{ 获取 CPU 步进 }
function GetCpuStepping: Cardinal;

{ 获取 CPU 名称 }
function GetCpuName: String;

{ 获取 CPU 频率 }
function GetCpuFrequency: Cardinal;

{ 获取 CPU 指令集 }
function GetCpuInstructs: String;

{ 获取 CPU 个数 }
function GetCPUCount: String;

{ 获取 CPU 缓存信息 }
function GetCPUCacheInfo: String;

implementation

uses Windows, SysUtils, Math;

type
  TCPUParam = record
    bit: Integer;
    desc: array [0 .. 19] of AnsiChar;
    detail: array [0 .. 63] of AnsiChar;
  end;

  { 寄存器 }
  TRegisters = record
    EAX: DWORD;
    EBX: DWORD;
    ECX: DWORD;
    EDX: DWORD;
  end;

  PROCESSOR_CACHE_TYPE            = (CacheUnified, CacheInstruction, CacheData, CacheTrace);
  TLOGICAL_PROCESSOR_RELATIONSHIP = (RelationProcessorCore, RelationNumaNode, RelationCache, RelationProcessorPackage, RelationGroup, RelationAll = $FFFFFF);

  CACHE_DESCRIPTOR = record
    Level: Byte;
    Associativity: Byte;
    LineSize: WORD;
    Size: DWORD;
    iType: PROCESSOR_CACHE_TYPE;
  end;

  TCACHE_DESCRIPTOR = CACHE_DESCRIPTOR;
  PCACHE_DESCRIPTOR = ^TCACHE_DESCRIPTOR;

  SYSTEM_LOGICAL_PROCESSOR_INFORMATION = record
    ProcessorMask: NativeUInt;
    Relationship: TLOGICAL_PROCESSOR_RELATIONSHIP;
    Cache: TCACHE_DESCRIPTOR;
    Reserved: DWORD;
  end;

  TSYSTEM_LOGICAL_PROCESSOR_INFORMATION = SYSTEM_LOGICAL_PROCESSOR_INFORMATION;
  PSYSTEM_LOGICAL_PROCESSOR_INFORMATION = ^TSYSTEM_LOGICAL_PROCESSOR_INFORMATION;

const
  IntelCPUParam_1: array [0 .. 29] of TCPUParam = (                          { }
    (bit: 0; desc: 'FPU'; detail: 'Floating-point unit on-chip'),            { }
    (bit: 1; desc: 'VME'; detail: 'Virtual Mode Enhancements'),              { }
    (bit: 2; desc: 'DE'; detail: 'Debugging Extension'),                     { }
    (bit: 3; desc: 'PSE'; detail: 'Page Size Extension'),                    { }
    (bit: 4; desc: 'TSC'; detail: 'Time Stamp Counter'),                     { }
    (bit: 5; desc: 'MSR'; detail: 'Pentium Processor MSR'),                  { }
    (bit: 6; desc: 'PAE'; detail: 'Physical Address Extension'),             { }
    (bit: 7; desc: 'MCE'; detail: 'Machine Check Exception'),                { }
    (bit: 8; desc: 'CX8'; detail: 'CMPXCHG8B Instruction Supported'),        { }
    (bit: 9; desc: 'APIC'; detail: 'On-chip APIC Hardware Enabled'),         { }
    (bit: 11; desc: 'SEP'; detail: 'SYSENTER and SYSEXIT'),                  { }
    (bit: 12; desc: 'MTRR'; detail: 'Memory Type Range Registers'),          { }
    (bit: 13; desc: 'PGE'; detail: 'PTE Global Bit'),                        { }
    (bit: 14; desc: 'MCA'; detail: 'Machine Check Architecture'),            { }
    (bit: 15; desc: 'CMOV'; detail: 'Conditional Move/Compare Instruction'), { }
    (bit: 16; desc: 'PAT'; detail: 'Page Attribute Table'),                  { }
    (bit: 17; desc: 'PSE36'; detail: 'Page Size Extension 36-bit'),          { }
    (bit: 18; desc: 'PN'; detail: 'Processor Serial Number'),                { }
    (bit: 19; desc: 'CLFLUSH'; detail: 'CFLUSH instruction'),                { }
    (bit: 21; desc: 'DTS'; detail: 'Debug Store'),                           { }
    (bit: 22; desc: 'ACPI'; detail: 'Thermal Monitor and Clock Ctrl'),       { }
    (bit: 23; desc: 'MMX'; detail: 'MMX Technology'),                        { }
    (bit: 24; desc: 'FXSR'; detail: 'FXSAVE/FXRSTOR'),                       { }
    (bit: 25; desc: 'SSE'; detail: 'SSE Extensions'),                        { }
    (bit: 26; desc: 'SSE2'; detail: 'SSE2 Extensions'),                      { }
    (bit: 27; desc: 'SS'; detail: 'Self Snoop'),                             { }
    (bit: 28; desc: 'HT'; detail: 'Multi-threading'),                        { }
    (bit: 29; desc: 'TM'; detail: 'Therm. Monitor'),                         { }
    (bit: 30; desc: 'IA64'; detail: 'IA-64 Processor'),                      { }
    (bit: 31; desc: 'PBE'; detail: 'Pend. Brk. EN.')                         { }
    );

  IntelCPUParam_2: array [0 .. 24] of TCPUParam = (                       { }
    (bit: 0; desc: 'PNI'; detail: 'SSE3 Extensions '),                    { }
    (bit: 1; desc: 'PCLMULQDQ'; detail: 'Carryless Multiplication'),      { }
    (bit: 2; desc: 'DTES64'; detail: '64-bit Debug Store'),               { }
    (bit: 3; desc: 'MONITOR'; detail: 'MONITOR/MWAIT'),                   { }
    (bit: 4; desc: 'DS_CPL'; detail: 'CPL Qualified Debug Store'),        { }
    (bit: 5; desc: 'VMX'; detail: 'Virtual Machine Extensions'),          { }
    (bit: 6; desc: 'SMX'; detail: 'Safer Mode Extensions'),               { }
    (bit: 7; desc: 'EST'; detail: 'Enhanced Intel SpeedStep Technology'), { }
    (bit: 8; desc: 'TM2'; detail: 'Thermal Monitor 2'),                   { }
    (bit: 9; desc: 'SSSE3'; detail: 'Supplemental SSE3'),                 { }
    (bit: 10; desc: 'CID'; detail: 'L1 Context ID'),                      { }
    (bit: 12; desc: 'FMA'; detail: 'Fused Multiply Add'),                 { }
    (bit: 13; desc: 'CX16'; detail: 'CMPXCHG16B Available'),              { }
    (bit: 14; desc: 'XTPR'; detail: 'xTPR Disable'),                      { }
    (bit: 15; desc: 'PDCM'; detail: 'Perf/Debug Capability MSR'),         { }
    (bit: 18; desc: 'DCA'; detail: 'Direct Cache Access'),                { }
    (bit: 19; desc: 'SSE4_1'; detail: 'SSE4.1 Extensions'),               { }
    (bit: 20; desc: 'SSE4_2'; detail: 'SSE4.2 Extensions'),               { }
    (bit: 21; desc: 'X2APIC'; detail: 'x2APIC Feature'),                  { }
    (bit: 22; desc: 'MOVBE'; detail: 'MOVBE Instruction'),                { }
    (bit: 23; desc: 'POPCNT'; detail: 'Pop Count Instruction'),           { }
    (bit: 25; desc: 'AES'; detail: 'AES Instruction'),                    { }
    (bit: 26; desc: 'XSAVE'; detail: 'XSAVE/XRSTOR Extensions'),          { }
    (bit: 27; desc: 'OSXSAVE'; detail: 'XSAVE/XRSTOR Enabled in the OS'), { }
    (bit: 28; desc: 'AVX'; detail: 'Advanced Vector Extension')           { }
    );

  AMDCPUParam_1: array [0 .. 9] of TCPUParam = (                          { }
    (bit: 11; desc: 'SYSCALL'; detail: 'SYSCALL and SYSRET'),             { }
    (bit: 19; desc: 'MP'; detail: 'MP Capable'),                          { }
    (bit: 20; desc: 'NX'; detail: 'No-Execute Page Protection'),          { }
    (bit: 22; desc: 'MMXEXT'; detail: 'MMX Technology (AMD Extensions)'), { }
    (bit: 25; desc: 'FXSR_OPT'; detail: 'Fast FXSAVE/FXRSTOR'),           { }
    (bit: 26; desc: 'PDPE1GB'; detail: 'PDP Entry for 1GiB Page'),        { }
    (bit: 27; desc: 'RDTSCP'; detail: 'RDTSCP Instruction'),              { }
    (bit: 29; desc: 'LM'; detail: 'Long Mode Capable'),                   { }
    (bit: 30; desc: '3DNOWEXT'; detail: '3DNow! Extensions'),             { }
    (bit: 31; desc: '3DNOW'; detail: '3DNow!')                            { }
    );

  AMDCPUParam_2: array [0 .. 13] of TCPUParam = (                            { }
    (bit: 0; desc: 'LAHF_LM'; detail: 'LAHF/SAHF Supported in 64-bit Mode'), { }
    (bit: 1; desc: 'CMP_LEGACY'; detail: 'Chip Multi-Core'),                 { }
    (bit: 2; desc: 'SVM'; detail: 'Secure Virtual Machine'),                 { }
    (bit: 3; desc: 'EXTAPIC'; detail: 'Extended APIC Space'),                { }
    (bit: 4; desc: 'CR8_LEGACY'; detail: 'CR8 Available in Legacy Mode'),    { }
    (bit: 5; desc: 'ABM'; detail: 'Advanced Bit Manipulation'),              { }
    (bit: 6; desc: 'SSE4A'; detail: 'SSE4A Extensions'),                     { }
    (bit: 7; desc: 'MISALIGNSSE'; detail: 'Misaligned SSE Mode'),            { }
    (bit: 8; desc: '3DNOWPREFETCH'; detail: '3DNow! Prefetch/PrefetchW'),    { }
    (bit: 9; desc: 'OSVW'; detail: 'OS Visible Workaround'),                 { }
    (bit: 10; desc: 'IBS'; detail: 'Instruction Based Sampling'),            { }
    (bit: 11; desc: 'SSE5'; detail: 'SSE5 Extensions'),                      { }
    (bit: 12; desc: 'SKINIT'; detail: 'SKINIT, STGI, and DEV Support'),      { }
    (bit: 13; desc: 'WDT'; detail: 'Watchdog Timer Support')                 { }
    );

function GetLogicalProcessorInformation(Buffer: PSYSTEM_LOGICAL_PROCESSOR_INFORMATION; var ReturnLength: DWORD): BOOL; stdcall; external 'kernel32.dll';

procedure GetCPUID(Param: Cardinal; var Registers: TRegisters);
asm
  PUSH    EBX                         { save affected registers }
  PUSH    EDI
  MOV     EDI, Registers
  XOR     EBX, EBX                    { clear EBX register }
  XOR     ECX, ECX                    { clear ECX register }
  XOR     EDX, EDX                    { clear EDX register }
  DB $0F, $A2                         { CPUID opcode }
  MOV     TRegisters(EDI).&EAX, EAX   { save EAX register }
  MOV     TRegisters(EDI).&EBX, EBX   { save EBX register }
  MOV     TRegisters(EDI).&ECX, ECX   { save ECX register }
  MOV     TRegisters(EDI).&EDX, EDX   { save EDX register }
  POP     EDI                         { restore registers }
  POP     EBX
end;

{ 获取 CPU 制造商 }
function GetCpuFactory: String;
var
  regs      : TRegisters;
  VendorName: array [0 .. 12] of AnsiChar;
begin
  GetCPUID(0, regs);
  { 1、制造商 }
  Move(regs.EBX, VendorName[0], 4);
  Move(regs.EDX, VendorName[4], 4);
  Move(regs.ECX, VendorName[8], 4);
  VendorName[12] := #0;
  Result         := string(AnsiString(VendorName));
end;

{ 获取 CPU 家族系统 }
function GetCpuFamily: Cardinal;
var
  regs: TRegisters;
begin
  GetCPUID(1, regs);
  Result := (regs.EAX shr 8) and $F;
  if (Result = $F) then
    Result := Result + (regs.EAX shr 20) and $FF;
end;

{ 获取 CPU 型号 }
function GetCpuModel: Cardinal;
var
  regs: TRegisters;
begin
  GetCPUID(1, regs);
  Result := (regs.EAX shr 4) and $F;
  if (GetCpuFamily = $F) or (GetCpuFamily = 6) then
    Result := Result + ((regs.EAX shr 16) and $F) shl 4;
end;

{ 获取 CPU 步进 }
function GetCpuStepping: Cardinal;
var
  regs: TRegisters;
begin
  GetCPUID(1, regs);
  Result := regs.EAX and $F;
end;

{ 获取 CPU 名称 }
function GetCpuName: String;
var
  regs          : TRegisters;
  processor_name: array [0 .. 48] of AnsiChar;
  III           : Integer;
  TTT           : Cardinal;
begin
  for III := 2 to 4 do
  begin
    TTT := 1 shl 31 + III;
    GetCPUID(TTT, regs);
    Move(regs.EAX, processor_name[(III - 2) * 16 + 00], 4);
    Move(regs.EBX, processor_name[(III - 2) * 16 + 04], 4);
    Move(regs.ECX, processor_name[(III - 2) * 16 + 08], 4);
    Move(regs.EDX, processor_name[(III - 2) * 16 + 12], 4);
  end;
  processor_name[48] := #0;
  Result             := string(AnsiString(processor_name));
end;

{ 获取 CPU 频率 }
function GetCpuFrequency: Cardinal;
var
  CurrTicks, TicksCount: TLargeInteger;
  iST, iET             : Int64;
  OldProcessP          : DWORD;
  OldThreadP           : DWORD;
begin
  { 获取进程、线程级别 }
  OldProcessP := GetPriorityClass(GetCurrentProcess);
  OldThreadP  := GetThreadPriority(GetCurrentThread);

  { 调整进程、线程级别到最高级别 }
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  QueryPerformanceFrequency(TicksCount);
  QueryPerformanceCounter(CurrTicks);
  LARGE_INTEGER(TicksCount).QuadPart := Round(LARGE_INTEGER(TicksCount).QuadPart / 16);
  LARGE_INTEGER(TicksCount).QuadPart := LARGE_INTEGER(TicksCount).QuadPart + LARGE_INTEGER(CurrTicks).QuadPart;

  asm
    RDTSC
    MOV DWORD PTR iST + 0, EAX
    MOV DWORD PTR iST + 4, EDX
  end;

  while (LARGE_INTEGER(CurrTicks).QuadPart < LARGE_INTEGER(TicksCount).QuadPart) do
  begin
    QueryPerformanceCounter(CurrTicks);
  end;

  asm
    RDTSC
    MOV DWORD PTR iET + 0, EAX
    MOV DWORD PTR iET + 4, EDX
  end;

  { 恢复进程、线程级别原有级别 }
  SetThreadPriority(GetCurrentThread, OldThreadP);
  SetPriorityClass(GetCurrentProcess, OldProcessP);

  { 返回结果 MHz }
  Result := Round((iET - iST) / 62500);
end;



{ 获取 CPU 指令集 }
function GetCpuInstructs: String;
var
  regs1, regs2          : TRegisters;
  amd_flags1, amd_flags2: Integer;
  III                   : Integer;
begin
  GetCPUID(1, regs1);

  for III := 29 downto 0 do
  begin
    if regs1.EDX and (1 shl IntelCPUParam_1[III].bit) = 1 shl IntelCPUParam_1[III].bit then
    begin
      Result := string(StrPas(IntelCPUParam_1[III].desc)) + ' ' + Result;
    end;
  end;

  for III := 24 downto 0 do
  begin
    if regs1.ECX and (1 shl IntelCPUParam_2[III].bit) = 1 shl IntelCPUParam_2[III].bit then
    begin
      Result := Result + ' ' + string(StrPas(IntelCPUParam_2[III].desc));
    end;
  end;

  GetCPUID($80000001, regs2);
  amd_flags1 := regs2.EDX;
  amd_flags2 := regs2.ECX;

  for III := 10 downto 0 do
  begin
    if amd_flags1 and (1 shl AMDCPUParam_1[III].bit) = 1 shl AMDCPUParam_1[III].bit then
    begin
      Result := Result + ' ' + string(StrPas(AMDCPUParam_1[III].desc));
    end;
  end;

  for III := 13 downto 0 do
  begin
    if amd_flags2 and (1 shl AMDCPUParam_2[III].bit) = 1 shl AMDCPUParam_2[III].bit then
    begin
      Result := Result + ' ' + string(StrPas(AMDCPUParam_2[III].desc));
    end;
  end;
end;

function CountSetBits(const bitMask: Cardinal): DWORD;
var
  LSHIFT     : DWORD;
  bitSetCount: DWORD;
  bitTest    : Uint64;
  I          : DWORD;
begin
  LSHIFT      := sizeof(Cardinal) * 8 - 1;
  bitSetCount := 0;
  bitTest     := 1 shl LSHIFT;

  for I := 0 to LSHIFT - 1 do
  begin
    bitSetCount := Ifthen((bitMask and bitTest) = 0, 1, 0);
    bitTest     := bitTest div 2;
  end;

  Result := bitSetCount;
end;

{ 获取 CPU 个数 }
function GetCPUCount: String;
var
  Buffer               : array of SYSTEM_LOGICAL_PROCESSOR_INFORMATION;
  ReturnLength         : DWORD;
  III, Count           : Integer;
  processorCoreCount   : Integer;
  numaNodeCount        : Integer;
  logicalProcessorCount: Integer;
  processorPackageCount: Integer;
  JJJ                  : Integer;
begin
  SetLength(Buffer, 1);
  ReturnLength := sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);

  { 第一次调用获取缓冲区大小 }
  if not GetLogicalProcessorInformation(@Buffer[0], ReturnLength) then
  begin
    if GetLastError = ERROR_INSUFFICIENT_BUFFER then
    begin
      SetLength(Buffer, ReturnLength div sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION) + 1);
      { 第二次调用，返回结果 }
      if not GetLogicalProcessorInformation(@Buffer[0], ReturnLength) then
      begin
        Exit;
      end;
    end;
  end;

  processorCoreCount    := 0;
  numaNodeCount         := 0;
  logicalProcessorCount := 0;
  processorPackageCount := 0;

  Count   := ReturnLength div sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
  for III := 0 to Count - 1 do
  begin
    case Buffer[III].Relationship of
      RelationProcessorCore:
        Inc(processorCoreCount);
      RelationNumaNode:
        Inc(numaNodeCount);
      RelationProcessorPackage:
        Inc(processorPackageCount);
      RelationCache:
        begin
          JJJ := CountSetBits(Buffer[III].ProcessorMask);
          if JJJ = 1 then
          begin
            Inc(logicalProcessorCount);
          end;
        end;
    end;
  end;
  Result := Format('NumaNodes=%d PhysicalProcessorPackages=%d ProcessorCores=%d LogicalProcessors=%d', [numaNodeCount, processorPackageCount, processorCoreCount,
    logicalProcessorCount]);
end;

{ 获取 CPU 缓存信息 }
function GetCPUCacheInfo: String;
var
  Buffer               : array of SYSTEM_LOGICAL_PROCESSOR_INFORMATION;
  ReturnLength         : DWORD;
  III, Count           : Integer;
  L1DataCache          : Integer;
  L1InstructionCache   : Integer;
  L2DataCache          : Integer;
  L3DataCache          : Integer;
  L1DataCacheStr       : String;
  L1InstructionCacheStr: String;
  L2DataCacheStr       : String;
  L3DataCacheStr       : String;
  L10                  : String;
  L11                  : String;
  L2, L3               : string;
  L1DataSize           : Integer;
  L1InstructionSize    : Integer;
  L2DataSize           : Integer;
  L3DataSize           : Integer;
begin
  SetLength(Buffer, 1);
  ReturnLength      := sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
  L1DataSize        := 0;
  L1InstructionSize := 0;
  L2DataSize        := 0;
  L3DataSize        := 0;

  { 第一次调用获取缓冲区大小 }
  if not GetLogicalProcessorInformation(@Buffer[0], ReturnLength) then
  begin
    if GetLastError = ERROR_INSUFFICIENT_BUFFER then
    begin
      SetLength(Buffer, ReturnLength div sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION) + 1);
      { 第二次调用，返回结果 }
      if not GetLogicalProcessorInformation(@Buffer[0], ReturnLength) then
      begin
        Exit;
      end;
    end;
  end;

  L1DataCache        := 0;
  L1InstructionCache := 0;

  L2DataCache := 0;
  L3DataCache := 0;

  Count   := ReturnLength div sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
  for III := 0 to Count - 1 do
  begin
    { CPU一级缓存 }
    if Buffer[III].Cache.Level = 1 then
    begin
      { CPU一级数据缓存 }
      if Buffer[III].Cache.iType = CacheData then
      begin
        Inc(L1DataCache);
        L1DataSize     := Buffer[III].Cache.Size div 1024;
        L1DataCacheStr := Format('%d 路成组相连，%d 字节管道尺寸', [Buffer[III].Cache.Associativity, Buffer[III].Cache.LineSize]);
      end;

      { CPU一级指令缓存 }
      if Buffer[III].Cache.iType = CacheInstruction then
      begin
        Inc(L1InstructionCache);
        L1InstructionSize     := Buffer[III].Cache.Size div 1024;
        L1InstructionCacheStr := Format('%d 路成组相连，%d 字节管道尺寸', [Buffer[III].Cache.Associativity, Buffer[III].Cache.LineSize]);
      end;
    end;

    { CPU二级缓存 }
    if Buffer[III].Cache.Level = 2 then
    begin
      Inc(L2DataCache);
      L2DataSize     := Buffer[III].Cache.Size div 1024;
      L2DataCacheStr := Format('%d 路成组相连，%d 字节管道尺寸', [Buffer[III].Cache.Associativity, Buffer[III].Cache.LineSize]);
    end;

    { CPU三级缓存 }
    if Buffer[III].Cache.Level = 3 then
    begin
      Inc(L3DataCache);
      L3DataSize     := Buffer[III].Cache.Size div 1024;
      L3DataCacheStr := Format('%d 路成组相连，%d 字节管道尺寸', [Buffer[III].Cache.Associativity, Buffer[III].Cache.LineSize]);
    end;
  end;

  L10 := Format('一级缓存数据缓存(参数：%s)：%d×%dK', [L1DataCacheStr, L1DataCache, L1DataSize]);
  L11 := Format('一级缓存指令缓存(%s)：%d×%dK', [L1InstructionCacheStr, L1InstructionCache, L1InstructionSize]);
  L2  := Format('二级缓存(%s)：%d×%dK', [L2DataCacheStr, L2DataCache, L2DataSize]);
  L3  := Format('三级缓存(%s)：%d×%dK', [L3DataCacheStr, L3DataCache, L3DataSize]);

  Result := L10 + '    ' + L11 + '    ' + L2 + '    ' + L3;
end;

end.