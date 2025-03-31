unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Forms, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Controls, Vcl.ComCtrls, Vcl.NumberBox,
  ActiveX, ComObj, unLIB, Vcl.VirtualImage;

type
  TFrmMain = class(TForm)
    IC: TImageCollection;
    Timer1: TTimer;
    VIL: TVirtualImageList;
    Label3: TLabel;
    Label4: TLabel;
    PageControl: TPageControl;
    TabMain: TTabSheet;
    LabCPU: TLabel;
    LabGPU: TLabel;
    Image1: TImage;
    LabData: TLabel;
    LabSet: TLabel;
    TabOption: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    NBTTCL: TNumberBox;
    NBFast: TNumberBox;
    NBslow: TNumberBox;
    NBVRM: TNumberBox;
    NBFastTime: TNumberBox;
    NBSlowTime: TNumberBox;
    BtnApply: TButton;
    RBEco: TRadioButton;
    RBPerf: TRadioButton;
    NBstamp: TNumberBox;
    NBAPUTemp: TNumberBox;
    VI1: TVirtualImage;
    LabHint: TLabel;
    Panel1: TPanel;
    Btn04: TButton;
    Btn03: TButton;
    Btn02: TButton;
    Btn01: TButton;
    BalloonHint1: TBalloonHint;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Btn02Click(Sender: TObject);
    procedure Btn03Click(Sender: TObject);
    procedure Btn04Click(Sender: TObject);
    procedure Btn01Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TabOptionShow(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
  private
  public
  end;

var
  FrmMain: TFrmMain;
  MyPath: String;
  Adj: Pointer;
  DllProc: HModule;
  Support: Boolean;
  Cpufamily: Integer;
  GpuInfo,CpuInfo: OleVariant;

implementation

{$R *.dfm}

type
  TADJPram = packed record
    ttcl_temp,
    api_skin_temp,
    stapm,
    fast,
    slow,
    stapm_time,
    slow_time,
    vrmmax,
    vrmsoc,
    vrmsocmax,
    vrmgfx: Integer;
    //
  end;
  TADJStatus = packed record
    coreclk,
    corevolt,
    corepower,
    coretemp,
    memclk,
    fclk,
    socpower,
    socvolt,
    socketpower,
    gfxclk,
    gfxvolt,
    gfxtemp: Single;
  end;

var
  AdjParam, CurrParam: TADJPram;
  AdjStatus: TADJStatus;
  MaxCpuPower,MaxApuPower: Single;
  CapTitle: String;

function GetAdj(FunName: String): Single;
type
  TFunction = function (Adj: Pointer): Single; stdcall;
var
  FunProc: Pointer;
  Fun: TFunction;
begin
  FunProc:=GetProcAddress(DllProc,PChar('get_'+FunName));
  Fun:=TFunction(FunProc);
  Result:=Fun(Adj);
end;

function SetAdj(FunName: String; Param: Single): Integer;
type
  TFunction = function (Adj: Pointer; Param: Single): Integer; stdcall;
var
  FunProc: Pointer;
  Fun: TFunction;
begin
  FunProc:=GetProcAddress(DllProc,PChar('set_'+FunName));
  Fun:=TFunction(FunProc);
  Result:=Fun(Adj,Param);
end;

function ExtractUrlFileName(const AUrl: string): string;
var
  I: Integer;
begin
  I := LastDelimiter('\:/', AUrl);
  Result := Copy(AUrl, I + 1, MaxInt);
end;

procedure GetDebugPrivs;
var
  hToken: THandle;
  tkp: TTokenPrivileges;
  retval: dword;
Const
  SE_DEBUG_NAME = 'SeDebugPrivilege' ;
begin
  if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or  TOKEN_QUERY, hToken)) then
  begin
    LookupPrivilegeValue(nil, SE_DEBUG_NAME  , tkp.Privileges[0].Luid);
    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, false, tkp, 0, nil, retval);
  end;
end;

function GetWMI: Boolean;
var
  wmi, objgpu, objcpu: OleVariant;
  enum: IEnumVariant;
  value: Cardinal;
begin
  Result:= True;
  try
    wmi := CreateOleObject('WbemScripting.SWbemLocator');

    objgpu := wmi.ConnectServer().ExecQuery('SELECT * FROM Win32_VideoController');
    enum := IUnknown(objgpu._NewEnum) as IEnumVariant;
    enum.Reset;
    if enum.Next(1, GpuInfo, value)<> S_OK then Result:=False;

    objcpu := wmi.ConnectServer().ExecQuery('SELECT * FROM Win32_Processor');
    enum := IUnknown(objcpu._NewEnum) as IEnumVariant;
    enum.Reset;
    if enum.Next(1, CpuInfo, value)<>S_OK then Result:=False;
  except
    Result:=False;
  end;
end;

procedure GetAdjStatus;
begin

  AdjStatus.coreclk:=get_core_clk(adj,0);
  AdjStatus.corevolt:=get_core_volt(adj,0);
  AdjStatus.corepower:=get_core_power(adj,0);
  AdjStatus.coretemp:=get_core_temp(adj,0);

  AdjStatus.memclk:=get_mem_clk(adj);
  AdjStatus.fclk:=get_fclk(adj);

  AdjStatus.socpower:=get_soc_power(adj);
  AdjStatus.socvolt:=get_soc_volt(adj);

  AdjStatus.socketpower:=get_socket_power(adj);

  AdjStatus.gfxclk:=get_gfx_clk(adj);
  AdjStatus.gfxvolt:=get_gfx_volt(adj);
  AdjStatus.gfxtemp:=get_gfx_temp(adj);
end;

procedure ApplyAdj(Param: TADJPram);
begin
  set_tctl_temp(adj, Param.ttcl_temp); // THM Limit
  set_apu_skin_temp_limit(adj, Param.api_skin_temp);  //STT Limit APU
  set_dgpu_skin_temp_limit(adj, Param.api_skin_temp);  //STT Limit dGPU
  set_stapm_limit(adj, Param.stapm); // STAPM Limit
  set_fast_limit(adj, Param.fast); // PPT Limit Fast
  set_slow_limit(adj, Param.slow); // PPT Limit Slow
  set_slow_time(adj, Param.slow_time); // SlowPPTTimeConstant
  set_stapm_time(adj, Param.stapm_time); // StampTimeConstant

  set_vrmmax_current(adj, Param.vrmmax); // EDC Limit VDD
  set_vrmsoc_current(adj, Param.vrmsoc); // TDC Limit SoC
  set_vrmsocmax_current(adj, Param.vrmsocmax); // TDC Limit SoC
  set_vrmgfx_current(adj, Param.vrmgfx);
  //TDC Limit VDD
  // PSI0 Limit SoC
end;

function GetCurrAd: Integer;
begin
  Result:=-1;

  CurrParam.ttcl_temp:=Round(get_tctl_temp(adj));
  CurrParam.stapm:=Round(get_stapm_limit(adj));
  CurrParam.fast:=Round(get_fast_limit(adj));
  CurrParam.slow:=Round(get_slow_limit(adj));
  CurrParam.vrmmax:=Round(get_vrmmax_current(adj));

  case CurrParam.fast of
    15:
      if (CurrParam.slow = 12) and (CurrParam.stapm = 10) and (CurrParam.vrmmax = 100) then
        Result:=1;
    35:
      if (CurrParam.slow = 33) and (CurrParam.stapm = 30) and (CurrParam.vrmmax = 180) then
        Result:=2;
    42:
      if (CurrParam.slow = 40) and (CurrParam.stapm = 35) and (CurrParam.vrmmax = 180) then
        Result:=3;
    56:
      if (CurrParam.slow = 56) and (CurrParam.stapm = 56) and (CurrParam.vrmmax = 180) then
        Result:=4;
  end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var
  I,TableSize: Integer;
  Table: Pointer;
  TableData: Array of Single;
begin
  if not Support then Exit;

  refresh_table(adj);

//  GetAdjStatus;

  I:=GetCurrAd;
  case I of
    1: VI1.Left:=Btn01.Left;
    2: VI1.Left:=Btn02.Left;
    3: VI1.Left:=Btn03.Left;
    4: VI1.Left:=Btn04.Left;
  end;
  LabHint.Left:=VI1.Left+25;
  LabHint.Caption:='已应用设置';//'已设置'+IntToStr(CurrParam.fast)+'W';
  if I<>-1 then
  begin
    VI1.Visible:=True;
    LabHint.Visible:=True;
  end else begin
    VI1.Visible:=False;
    LabHint.Visible:=False;
  end;

  TableSize:=get_table_size(adj);
  SetLength(TableData,TableSize div 4);

  Table:=get_table_values(adj);
  CopyMemory(TableData,Table,TableSize);

  if TableData[63]+TableData[67]>MaxCpuPower then MaxCpuPower:=TableData[63]+TableData[67];
  if TableData[1]>MaxApuPower then MaxApuPower:=TableData[1];

  LabData.Caption:=Format(
  'CPU 功耗 %.2f W '+#9+' 温度 %.2f ℃'+#9+'最大功耗 %f W'+#13#10+#13#10+
  'APU 功耗 %.2f W '+#9+' 温度 %.2f ℃'+#9+'最大功耗 %f W'+#13#10+#13#10+
  'GPU 频率 %.2f MHz '+#9+' SoC 频率 %.2f MHz '+#9+' 显存频率 %.2f MHz',[
  TableData[63]+TableData[67],TableData[33],MaxCpuPower,
  TableData[1],TableData[21],MaxApuPower,
  TableData[154], TableData[183], TableData[178]
  ]);
  //CPU+SOC POWER 3 cpu 63 + soc 67
  //APU POWER 1
  //MEM CLOCK 178 MAX 166
  //GPU CLOCK 184 SOC CLOCK 183
  //CPU SOC TEMP 33
  //APU TEMP 21
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  MyPath:=ExtractFilePath(ParamStr(0));
  DllProc:=LoadLibrary('libryzenadj.dll');

  CapTitle:=Self.Caption;

  LabData.Parent.DoubleBuffered:=True;

  adj:=init_ryzenadj;
  if (adj<>nil) and (init_table(adj)=0) then Support:=True;
  Cpufamily:=get_cpu_family(adj);
  GetAdjStatus;

  if not Support then
  begin
    LabData.Caption:='不支持的平台, 错误代码: '+IntToStr(init_table(adj));
  end;

  if GetWMI then
  begin
    LabCPU.Caption:=CPUInfo.name;
    LabGPU.Caption:=GPUInfo.name;
  end;

  LabSet.Caption:='';
  LabData.Caption:='';

  Timer1Timer(nil);
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled:=False;
  cleanup_ryzenadj(adj);
  adj:=nil;
end;

procedure TFrmMain.TabOptionShow(Sender: TObject);
begin
  if NBTTCL.ValueInt<>0 then Exit;

  NBTTCL.Value:=get_tctl_temp(adj);
  NBstamp.Value:=get_stapm_limit(adj);
  NBfast.Value:=get_fast_limit(adj);
  NBslow.Value:=get_slow_limit(adj);
  NBSlowtime.Value:=get_slow_time(adj);
  NBFasttime.Value:=get_stapm_time(adj);
  NBVRM.Value:=get_vrmmax_current(adj);
  NBAPUTemp.Value:=get_tctl_temp(adj);
end;

procedure TFrmMain.BtnApplyClick(Sender: TObject);
begin
  AdjParam.ttcl_temp:=NBTTCL.ValueInt;
  AdjParam.api_skin_temp:=NBTTCL.ValueInt;
  AdjParam.stapm:=NBstamp.ValueInt * 1000;
  AdjParam.fast:=NBfast.ValueInt * 1000;
  AdjParam.slow:=NBslow.ValueInt * 1000;
  AdjParam.slow_time:=NBSlowtime.ValueInt;
  AdjParam.stapm_time:=NBFasttime.ValueInt;

  AdjParam.vrmmax:=NBVRM.ValueInt * 1000;
  AdjParam.vrmsoc:=NBVRM.ValueInt * 1000;
  AdjParam.vrmsocmax:=NBVRM.ValueInt * 1000;
  AdjParam.vrmgfx:=NBVRM.ValueInt * 1000;

  ApplyAdj(AdjParam);

  if RBEco.Checked then set_power_saving(adj);
  if RBPerf.Checked then set_max_performance(adj);
end;

procedure TFrmMain.Btn01Click(Sender: TObject);
begin
  if not Support then Exit;

  AdjParam.ttcl_temp:=75;
  AdjParam.api_skin_temp:=65;
  AdjParam.stapm:=10000;
  AdjParam.fast:=15000;
  AdjParam.slow:=12000;
  AdjParam.slow_time:=128;
  AdjParam.stapm_time:=64;

  AdjParam.vrmmax:=100000;
  AdjParam.vrmsoc:=100000;
  AdjParam.vrmsocmax:=100000;
  AdjParam.vrmgfx:=100000;

  ApplyAdj(AdjParam);

  set_power_saving(adj);
end;

procedure TFrmMain.Btn02Click(Sender: TObject);
begin
  if not Support then Exit;

  AdjParam.ttcl_temp:=95;
  AdjParam.api_skin_temp:=95;
  AdjParam.stapm:=30000;
  AdjParam.fast:=35000;
  AdjParam.slow:=33000;
  AdjParam.slow_time:=128;
  AdjParam.stapm_time:=64;

  AdjParam.vrmmax:=180000;
  AdjParam.vrmsoc:=180000;
  AdjParam.vrmsocmax:=180000;
  AdjParam.vrmgfx:=180000;

  ApplyAdj(AdjParam);

  set_max_performance(adj);
end;

procedure TFrmMain.Btn03Click(Sender: TObject);
begin
  if not Support then Exit;

  AdjParam.ttcl_temp:=95;
  AdjParam.api_skin_temp:=95;
  AdjParam.stapm:=35000;
  AdjParam.fast:=42000;
  AdjParam.slow:=40000;
  AdjParam.slow_time:=128;
  AdjParam.stapm_time:=64;

  AdjParam.vrmmax:=180000;
  AdjParam.vrmsoc:=180000;
  AdjParam.vrmsocmax:=180000;
  AdjParam.vrmgfx:=180000;

  ApplyAdj(AdjParam);

  set_max_performance(adj);
end;

procedure TFrmMain.Btn04Click(Sender: TObject);
begin
  if not Support then Exit;

  AdjParam.ttcl_temp:=95;
  AdjParam.api_skin_temp:=95;
  AdjParam.stapm:=56000;
  AdjParam.fast:=56000;
  AdjParam.slow:=56000;
  AdjParam.slow_time:=128;
  AdjParam.stapm_time:=64;

  AdjParam.vrmmax:=180000;
  AdjParam.vrmsoc:=180000;
  AdjParam.vrmsocmax:=180000;
  AdjParam.vrmgfx:=180000;

  ApplyAdj(AdjParam);

  set_max_performance(adj);
end;

end.
