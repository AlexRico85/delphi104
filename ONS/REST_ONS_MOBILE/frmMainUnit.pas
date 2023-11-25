unit frmMainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, IdHTTPWebBrokerBridge, IdGlobal, Web.HTTPApp,
  FMX.Controls.Presentation, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Menus;

type
  TfrmMain = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    MemoLog: TMemo;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    sCheckBoxEnabledJurnal: TCheckBox;
    LabelSessions: TLabel;
    TimerActivity: TTimer;
    ButtonClearLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerActivityTimer(Sender: TObject);
    procedure ButtonClearLogClick(Sender: TObject);
  private
    FServer: TIdHTTPWebBrokerBridge;
    procedure StartServer;
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);
    { Private declarations }
  public
    procedure StartProgram;
    Procedure AddLogForm(AddString:AnsiString);
    procedure AddLogFormStrings(AddString:TStrings);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.XLgXhdpiTb.fmx ANDROID}

uses
  WinApi.Windows, Winapi.ShellApi, Datasnap.DSSession, frmSettingUnit, uLog,
  StyleUnit, SessionUnit;

procedure TfrmMain.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin

  ButtonStart.Enabled := not FServer.Active;
  ButtonStop.Enabled := FServer.Active;

end;



procedure TfrmMain.ButtonClearLogClick(Sender: TObject);
begin
  MemoLog.Lines.Clear;
end;

procedure TfrmMain.ButtonStartClick(Sender: TObject);
begin
  StartServer;
end;

procedure TerminateThreads;
begin
  if TDSSessionManager.Instance <> nil then
    TDSSessionManager.Instance.TerminateAllSessions;
end;

procedure TfrmMain.ButtonStopClick(Sender: TObject);
begin
  TimerActivity.Enabled := False;
  TerminateThreads;
  FServer.Active := False;
  FServer.Bindings.Clear;
  LogFile.WriteLog('Стоп.');
  //LogFile.Destroy;

  Sessions.Destroy;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FServer := TIdHTTPWebBrokerBridge.Create(Self);
  Application.OnIdle := ApplicationIdle;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
    StartProgram;
end;

procedure TfrmMain.MenuItem1Click(Sender: TObject);
begin
  FrmSetting.LoadParams;
  FrmSetting.Show;
end;

procedure TfrmMain.StartProgram;
begin
  LogFile := TLogFile.Create(AddLogForm, AddLogFormStrings);
  Sessions :=TSessions.Create;
  FrmSetting.LoadParams();

end;

procedure TfrmMain.StartServer;
var
  ErrorDescription: AnsiString;
begin
  if not FServer.Active then
  begin

//    if not DMMobil.Connect(ErrorDescription) then
//    begin
//       LogFile.WriteLog('Ошибка подключения Mobile:'+ ErrorDescription);
//       exit;
//    end else LogFile.WriteLog('Подключено модуль Mobile:'+ ErrorDescription);
//
//    if not mRest1s.Connect(ErrorDescription) then
//    begin
//       LogFile.WriteLog('Ошибка подключения Rest 1s:'+ ErrorDescription);
//       exit;
//    end else LogFile.WriteLog('Подключено модуль Rest 1s:'+ ErrorDescription);

    FServer.Bindings.Clear;
    FServer.DefaultPort := SettingProgram.PortHTTP;
    FServer.Active := True;
    LogFile.WriteLog('Старт. Web порт:'+ IntToStr(SettingProgram.PortHTTP));
    TimerActivity.Enabled := True;
  end;


end;

procedure TfrmMain.TimerActivityTimer(Sender: TObject);
begin
  LabelSessions.Text := 'Активные сессии: '+IntToStr(Sessions.ActiveSession);
end;

procedure TfrmMain.AddLogForm(AddString:AnsiString);
begin

  try
    if sCheckBoxEnabledJurnal.IsChecked then
        self.MemoLog.Lines.Add(AddString);
  except

  end;

end;

procedure TfrmMain.AddLogFormStrings(AddString:TStrings);
begin
  self.MemoLog.Lines.AddStrings(AddString);
end;


end.
