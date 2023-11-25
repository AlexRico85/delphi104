program REST_ONS_MOBILE;
{$APPTYPE GUI}

{$R 'SqlText.res' 'SqlText.rc'}

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppFMX,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  FMX.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  frmMainUnit in 'frmMainUnit.pas' {frmMain},
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  frmSettingUnit in 'frmSettingUnit.pas' {frmSetting},
  structures in 'structures.pas',
  uLog in 'uLog.pas',
  uDCPcrypt in 'uDCPcrypt.pas',
  FunctionMySQL in 'FunctionMySQL.pas',
  StyleUnit in 'StyleUnit.pas' {DM_Style: TDataModule},
  JsonSerialization in 'JsonSerialization.pas',
  Data.DBXClientResStrs in 'Data.DBXClientResStrs.pas',
  mURI in 'mURI.pas',
  SessionUnit in 'SessionUnit.pas',
  FuctionsUnit in 'FuctionsUnit.pas',
  uSqlList in 'uSqlList.pas',
  uRest1s in 'uRest1s.pas',
  uMobile in 'uMobile.pas',
  uWriteDataSQL in 'uWriteDataSQL.pas',
  uYandex in 'uYandex.pas',
  SMS in 'SMS.pas',
  uTerminal in 'uTerminal.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSetting, frmSetting);
  Application.CreateForm(TDM_Style, DM_Style);
  Application.Run;
end.













