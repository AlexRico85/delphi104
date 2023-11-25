unit frmSettingUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.TabControl,
  structures,  System.IniFiles, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TfrmSetting = class(TForm)
    tc_Setting: TTabControl;
    ti_WebSetting: TTabItem;
    GridPanelLayout1: TGridPanelLayout;
    LabelPortWebServer: TLabel;
    ePortWebServer: TEdit;
    LabelLoginWeb: TLabel;
    sLoginWeb: TEdit;
    LabelsPassWeb: TLabel;
    sPassWeb: TEdit;
    ButtonOK: TButton;
    GridPaneMain: TGridPanelLayout;
    ti_MySQL: TTabItem;
    GridPanelServerMYSQL: TGridPanelLayout;
    LabelAdressMySQL: TLabel;
    EdAdressMySQL: TEdit;
    LabelLoginMySQL: TLabel;
    EdLoginMySQL: TEdit;
    LabelPassMySQL: TLabel;
    EdPassMySQL: TEdit;
    LabelBaseNameMySQL: TLabel;
    EdBaseNameMySQL: TEdit;
    LabelPortMySQL: TLabel;
    EdPortMySQL: TEdit;
    FDConnectionTest: TFDConnection;
    ButtonTestMySQL: TButton;
    LabelResultTestMySQL: TLabel;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    ti_Yandex: TTabItem;
    GPL_YandexSetting: TGridPanelLayout;
    LabelYandexAdress: TLabel;
    EdAdressYandex: TEdit;
    LabelYandexLogin: TLabel;
    EdLoginYandex: TEdit;
    LabelYandexPass: TLabel;
    EdPassYandex: TEdit;
    LabelYandexBaseName: TLabel;
    EdBaseNameYandex: TEdit;
    LabelYandexPort: TLabel;
    EdPortYandex: TEdit;
    LabelYandexAPI: TLabel;
    EdApiYandex: TEdit;
    ButtonTestYandex: TButton;
    LabelResultTestYandex: TLabel;
    ti_SMS: TTabItem;
    GPLSMS: TGridPanelLayout;
    lb_ServerSMS: TLabel;
    ed_ServerSMS: TEdit;
    lb_LoginSMS: TLabel;
    ed_LoginSMS: TEdit;
    lb_PassSMS: TLabel;
    ed_PassSMS: TEdit;
    LabelResultTestSMS: TLabel;
    bt_TestSMS: TButton;
    LabelTestSMSPhone: TLabel;
    EditTestSMSPhone: TEdit;
    LabelTESTSMS: TLabel;
    MemoTESTSMS: TMemo;
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonTestMySQLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonTestYandexClick(Sender: TObject);
    procedure bt_TestSMSClick(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure LoadParams();
    Procedure SaveParams();
  end;

Procedure LoadParamToRecord();

Procedure Write_ParamSetting(Section, Ident, Value: string); overload;
Procedure Write_ParamSetting(Section, Ident:string; Value: Boolean); overload;
Procedure Write_ParamSetting(Section, Ident:string; Value: Integer); overload;

Function Read_ParamSetting(Section, Ident:string; default:Boolean): boolean; overload;
Function Read_ParamSetting(Section, Ident:string;default:string): string; overload;
Function Read_ParamSetting(Section, Ident:string;default:integer): integer; overload;

var
  frmSetting: TfrmSetting;
  SettingProgram: TSettingProgram;
  dllCurrentDir: string;

  const
  filenameini = '\settingconnect.ini';

implementation

{$R *.fmx}

uses uDCPcrypt, FunctionMySQL, StyleUnit, SMS;

Procedure Write_ParamSetting(Section, Ident, Value: string);
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  IniFile.WriteString(Section, Ident, Value);
  IniFile.Free;
end;

Procedure Write_ParamSetting(Section, Ident:string; Value: Boolean);
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  IniFile.WriteBool(Section, Ident, Value);
  IniFile.Free;
end;

Procedure Write_ParamSetting(Section, Ident:string; Value: Integer); overload;
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  IniFile.WriteInteger(Section, Ident, Value);
  IniFile.Free;
end;

Function Read_ParamSetting(Section, Ident:string; default:Boolean): boolean;
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  result := IniFile.ReadBool(Section, Ident, default);
  IniFile.Free;
end;

Function Read_ParamSetting(Section, Ident:string; default:string): string;
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  result := IniFile.ReadString(Section, Ident, default);
  IniFile.Free;
end;

Function Read_ParamSetting(Section, Ident:string; default:Integer): integer;
Var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(dllCurrentDir + filenameini);
  result := IniFile.ReadInteger(Section, Ident, default);
  IniFile.Free;
end;




procedure TfrmSetting.ButtonOKClick(Sender: TObject);
begin
  SaveParams();
  LoadParamToRecord();
  Hide;
end;

procedure TfrmSetting.ButtonTestMySQLClick(Sender: TObject);
var
  ClientMySQLSet:TClientMySQLSet;
  ErrorDescription: AnsiString;
begin

  ClientMySQLSet.ServerAdress:=  SettingProgram.ServerAdressMySQL;
  ClientMySQLSet.Login:=  SettingProgram.LoginMySQL;
  ClientMySQLSet.Uinpromt:=  SettingProgram.PassWordMySQL;
  ClientMySQLSet.DataBase:=  SettingProgram.DataBaseMySQL;
  ClientMySQLSet.Port:=  SettingProgram.PortMySQL;


  if ConnectToServer(ErrorDescription, FDConnectionTest, ClientMySQLSet) then
  begin
    LabelResultTestMySQL.text := 'Подключено!';
    DisConnectToServer(ErrorDescription, FDConnectionTest);
  end
  else
    LabelResultTestMySQL.text := ErrorDescription;




end;

procedure TfrmSetting.ButtonTestYandexClick(Sender: TObject);
var
  ClientMySQLSet:TClientMySQLSet;
  ErrorDescription: AnsiString;
begin

  SaveParams();
  LoadParamToRecord();

  ClientMySQLSet.ServerAdress:=   SettingProgram.YandexServerBD;
  ClientMySQLSet.Login:=          SettingProgram.YandexLoginBD;
  ClientMySQLSet.Uinpromt:=       SettingProgram.YandexPassBD;
  ClientMySQLSet.DataBase:=       SettingProgram.YandexNameBD;
  ClientMySQLSet.Port:=           SettingProgram.YandexPortBD;


  if ConnectToServer(ErrorDescription, FDConnectionTest, ClientMySQLSet) then
  begin
    LabelResultTestYandex.text := 'Подключено!';
    DisConnectToServer(ErrorDescription, FDConnectionTest);
  end
  else
    LabelResultTestYandex.text := ErrorDescription;

end;

procedure TfrmSetting.bt_TestSMSClick(Sender: TObject);

var
  SMSParams:TSMSParams;
  ResultSend:string;
  ResultSendSMS:Boolean;
begin
  SaveParams();
  LoadParamToRecord();

  SMSParams.Server  :=  SettingProgram.SMSServer;
  SMSParams.Login   :=  SettingProgram.SMSLogin;
  SMSParams.Pass    :=  SettingProgram.SMSPass;

  SMSParams.Phone   :=  EditTestSMSPhone.Text;
  SMSParams.SMS     :=  MemoTESTSMS.Text;

  ResultSendSMS := SENDSMS(SMSParams, ResultSend);

  if ResultSendSMS then
    LabelResultTestSMS.Text := 'УСПЕХ'
  else
    LabelResultTestSMS.Text := ResultSend;



end;

procedure TfrmSetting.FormCreate(Sender: TObject);
begin
   dllCurrentDir := GetCurrentDir();
end;

procedure TfrmSetting.LoadParams;
var
  CashPass: string;
begin
   LoadParamToRecord();

   self.sLoginWeb.Text :=  SettingProgram.LoginWeb;
   self.sPassWeb.Text :=  SettingProgram.PassWeb;
   self.ePortWebServer.Text :=  IntToStr(SettingProgram.PortHTTP);

   self.EdAdressMySQL.Text    :=  SettingProgram.ServerAdressMySQL;
   self.EdLoginMySQL.Text     :=  SettingProgram.LoginMySQL;
   self.EdBaseNameMySQL.Text  :=  SettingProgram.DataBaseMySQL;
   self.EdPortMySQL.Text      :=  SettingProgram.PortMySQL;
   self.EdPassMySQL.Text      :=  SettingProgram.PassWordMySQL;

   self.EdAdressYandex.Text    :=  SettingProgram.YandexServerBD;
   self.EdBaseNameYandex.Text  :=  SettingProgram.YandexNameBD;
   self.EdPortYandex.Text      :=  SettingProgram.YandexPortBD;
   self.EdLoginYandex.Text     :=  SettingProgram.YandexLoginBD;
   self.EdPassYandex.Text      :=  SettingProgram.YandexPassBD;
   self.EdApiYandex.Text       :=  SettingProgram.YandexAPI;

   self.ed_ServerSMS.Text    :=  SettingProgram.SMSServer;
   self.ed_LoginSMS.Text     :=  SettingProgram.SMSLogin;
   self.ed_PassSMS.Text      :=  SettingProgram.SMSPass;

end;

procedure TfrmSetting.SaveParams;
var
  CashInt:integer;
begin


  Write_ParamSetting('WEB', 'Login', self.sLoginWeb.Text);
  Write_ParamSetting('WEB', 'Password', self.sPassWeb.Text);
  Write_ParamSetting('WEB', 'Port', StrToInt(Trim(self.ePortWebServer.Text)));


  Write_ParamSetting('MySQL', 'ServerAdress', self.EdAdressMySQL.Text);
  Write_ParamSetting('MySQL', 'Login', self.EdLoginMySQL.Text);
  Write_ParamSetting('MySQL', 'DataBase', self.EdBaseNameMySQL.Text);
  Write_ParamSetting('MySQL', 'Port', self.EdPortMySQL.Text);
  Write_ParamSetting('MySQL', 'Password', EncryptString(EdPassMySQL.Text));

  Write_ParamSetting('Yandex', 'ServerAdress',  self.EdAdressYandex.Text);
  Write_ParamSetting('Yandex', 'Login',         self.EdLoginYandex.Text);
  Write_ParamSetting('Yandex', 'DataBase',      self.EdBaseNameYandex.Text);
  Write_ParamSetting('Yandex', 'Port',          self.EdPortYandex.Text);
  Write_ParamSetting('Yandex', 'API',           self.EdApiYandex.Text);
  Write_ParamSetting('Yandex', 'Password',      EncryptString(EdPassYandex.Text));

  Write_ParamSetting('SMS', 'Server',       self.ed_ServerSMS.Text);
  Write_ParamSetting('SMS', 'Login',         self.ed_LoginSMS.Text);
  Write_ParamSetting('SMS', 'Password',      EncryptString(ed_PassSMS.Text));

end;





Procedure LoadParamToRecord();
var
  CashPass: string;
begin

  SettingProgram.LoginWeb := Read_ParamSetting('WEB','Login','');
  SettingProgram.PassWeb := Read_ParamSetting('WEB','Password','');
  SettingProgram.PortHTTP := Read_ParamSetting('WEB','Port', 0);

  SettingProgram.ServerAdressMySQL  := Read_ParamSetting('MySQL', 'ServerAdress', '');
  SettingProgram.LoginMySQL         := Read_ParamSetting('MySQL', 'Login', '');
  SettingProgram.DataBaseMySQL      := Read_ParamSetting('MySQL', 'DataBase', '');
  SettingProgram.PortMySQL          := Read_ParamSetting('MySQL', 'Port', '');

  CashPass := Read_ParamSetting('MySQL', 'Password', '');
  SettingProgram.PassWordMySQL := DecryptString(CashPass);


  SettingProgram.YandexServerBD    := Read_ParamSetting('Yandex', 'ServerAdress', '');
  SettingProgram.YandexLoginBD     := Read_ParamSetting('Yandex', 'Login', '');
  SettingProgram.YandexNameBD      := Read_ParamSetting('Yandex', 'DataBase', '');
  SettingProgram.YandexPortBD      := Read_ParamSetting('Yandex', 'Port', '');
  SettingProgram.YandexAPI         := Read_ParamSetting('Yandex', 'API', '');

  CashPass := Read_ParamSetting('Yandex', 'Password', '');
  SettingProgram.YandexPassBD := DecryptString(CashPass);

  SettingProgram.SMSServer    := Read_ParamSetting('SMS', 'Server', '');
  SettingProgram.SMSLogin     := Read_ParamSetting('SMS', 'Login', '');

  CashPass := Read_ParamSetting('SMS', 'Password', '');
  SettingProgram.SMSPass      := DecryptString(CashPass);




end;

end.
