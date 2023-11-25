unit WebModuleUnit1;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker, Datasnap.DSServer,
  Web.WebFileDispatcher, Web.HTTPProd,
  DataSnap.DSAuth,
  Datasnap.DSProxyJavaScript, IPPeerServer, Datasnap.DSMetadata,
  Datasnap.DSServerMetadata, Datasnap.DSClientMetadata, Datasnap.DSCommonServer,
  Datasnap.DSHTTP, System.JSON, Data.DBXCommon, System.Generics.Collections;

type
  TWebModule1 = class(TWebModule)
    DSHTTPWebDispatcher1: TDSHTTPWebDispatcher;
    DSServer1: TDSServer;
    WebFileDispatcher1: TWebFileDispatcher;
    DSProxyGenerator1: TDSProxyGenerator;
    DSServerMetaDataProvider1: TDSServerMetaDataProvider;
    DSClassMobile: TDSServerClass;
    DSAuthenticationManager1: TDSAuthenticationManager;
    DSClassRest1s: TDSServerClass;
    DSClassYandex: TDSServerClass;
    DSServerMetaDataProvider2: TDSServerMetaDataProvider;
    DSClassTerminal: TDSServerClass;
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebFileDispatcher1BeforeDispatch(Sender: TObject;
      const AFileName: string; Request: TWebRequest; Response: TWebResponse;
      var Handled: Boolean);
    procedure DSClassMobileGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure DSHTTPWebDispatcher1FormatResult(Sender: TObject;
      var ResultVal: TJSONValue; const Command: TDBXCommand;
      var Handled: Boolean);
    procedure DSAuthenticationManager1UserAuthenticate(Sender: TObject;
      const Protocol, Context, User, Password: string; var valid: Boolean;
      UserRoles: TStrings);
    procedure WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure DSClassRest1sGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure DSServer1Error(DSErrorEventObject: TDSErrorEventObject);
    procedure DSClassYandexGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure DSAuthenticationManager1UserAuthorize(Sender: TObject;
      AuthorizeEventObject: TDSAuthorizeEventObject; var valid: Boolean);
    procedure DSClassTerminalGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  WebModuleClass: TComponentClass = TWebModule1;

implementation


{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses Web.WebReq, frmSettingUnit, uLog, mURI, IdURI, SessionUnit,
  uRest1s, JsonSerialization, uMobile, uYandex, uTerminal;



procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content :=
    '<html>' +
    '<head><title>REST SERVER</title></head>' +
    '<body>REST SERVER Online</body>' +
    '</html>';
end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
Var
   LogStrings: TStringList;
   ContentEncode:String;
   HeadLog:string;
   RequestId:string;
begin
  HeadLog:='HTTP';
  LogStrings:= TStringList.Create;
  try

    if (Response.ContentType = 'application/json') and (Response.StatusCode=200) then
    begin
      ContentEncode :=  utf16decode(Response.Content);
      Response.ContentType := 'application/json; charset=utf-8';
      Response.Content := ContentEncode;
      Handled := True;

    end;

    if (Response.ContentType = 'application/json') and (Response.StatusCode=500) then
    begin
      ContentEncode :=  utf16decode(Response.Content);
      Response.ContentType := 'application/json; charset=utf-8';
      Handled := True;
      HeadLog:='HTTPError';

      if (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/add')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/add/')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/registration')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/registration/')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/confirm')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/confirm/')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/balance')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/balance/')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/purchase')
      or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/purchase/') then
      begin
        Response.Content := ContentErrorYandexToJSONText(1, ContentEncode);
        Response.StatusCode := 400;
      end else

      Response.Content := ContentErrorToJSONText(1, ContentEncode);
    end;

    if (Response.ContentType = 'text') and (Response.StatusCode=400) then
    begin
      ContentEncode :=  utf16decode(Response.Content);
      Response.ContentType := 'application/json; charset=utf-8';
      Response.Content := ContentErrorToJSONText(1, ContentEncode);
      Handled := True;
      HeadLog:='HTTPError';
    end;

    RequestId := Request.GetFieldByName('X-RequestId');

    LogStrings.Add('-------------------------------------------');
    LogStrings.Add('Запрос: ' + Request.RawPathInfo);
    LogStrings.Add('RequestId: ' + RequestId);
    LogStrings.Add('Дата и время: ' + DateTimeToStr(Now));
    LogStrings.Add('Клиент: ' + Request.UserAgent);
    LogStrings.Add('IP хоста:' + Request.RemoteIP);
    LogStrings.Add('Авторизация:' + Request.Authorization);
    LogStrings.Add('Запрашиваемая страница:' + Request.RawPathInfo);
    LogStrings.Add('ContentType:' + Request.ContentType);

    if Request.ContentLength < 1000 then
    begin
      LogStrings.Add('Content:');
      LogStrings.Add( utf16decode(Request.Content));
    end;

    LogStrings.Add('-------------------------------------------');
    LogStrings.Add('Ответ: ' + IntToStr(Response.StatusCode));
    LogStrings.Add('ContentType:' + Response.ContentType);

    if Response.ContentLength<1000 then
    begin
      LogStrings.Add('Content:');
      LogStrings.Add(Response.Content);
    end else
      LogStrings.Add('ContentLength: ' + IntToStr(Response.ContentLength));

    LogFile.WriteLogHead('HTTP', LogStrings);
  finally
    FreeAndNil(LogStrings);
  end;

  Sessions.EndSession;

end;

procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
Var
   LogStrings: TStringList;
   ApiKey:string;
begin


  Sessions.StartSession;
  LogStrings:= TStringList.Create;
  try
    LogStrings.Add('-------------------------------------------');
    //LogStrings.Add(('thrd : ' + inttostr(GetCurrentThreadId)));
    LogStrings.Add('Дата и время: ' + DateTimeToStr(Request.Date));
    LogStrings.Add('Клиент: ' + Request.UserAgent);
    LogStrings.Add('IP хоста:' + Request.RemoteIP);
    LogStrings.Add('Авторизация:' + Request.Authorization);
    LogStrings.Add('Запрашиваемая страница:' + Request.RawPathInfo);
  finally
    FreeAndNil(LogStrings);
  end;
  if (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/add')
  or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/add/')
  or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/registration')
  or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/registration/')
  or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/balance')
  or (LowerCase(Request.RawPathInfo) = '/json/v1/yandex/balance/') then
  begin
    ApiKey := Request.GetFieldByName('X-ApiKey');
    if ApiKey <> SettingProgram.YandexAPI then
    begin
      Handled := True;
      Response.StatusCode := 403;
      Response.ContentType := 'application/json; charset=utf-8';
      Response.Content := ErrorYandexToJSONText(1, 'Неверный ApiKey', '');

//      Raise Exception.Create('Ошибка выполнения запроса');
    end;
    if Request.Content = '' then
    begin
      // Request.ContentType := 'application/json; charset=utf-8';
     //  Request.Content := '{}';
    end;

  end;

//  DSAuthenticationManager1.OnUserAuthenticate(Sender, '', '', 'yandex', 'yandex', false, );

end;

procedure TWebModule1.DSAuthenticationManager1UserAuthenticate(Sender: TObject;
  const Protocol, Context, User, Password: string; var valid: Boolean;
  UserRoles: TStrings);
begin
  if (LowerCase(User) = LowerCase(SettingProgram.LoginWeb)) and (LowerCase(Password) = LowerCase(SettingProgram.PassWeb)) then
    UserRoles.Add('admin')
  else UserRoles.Add('NotRegistred');

end;

procedure TWebModule1.DSAuthenticationManager1UserAuthorize(Sender: TObject;
  AuthorizeEventObject: TDSAuthorizeEventObject; var valid: Boolean);
begin
  // valid := true;

  //OnUserAuthorize
  {Событие OnUserAuthorize вызывается всякий раз, когда пользователь, который уже прошел успешную аутентификацию,
  пытается вызвать серверный метод. Вам не нужно реализовывать это событие.
  Если вы добавляете роли в список пользовательских ролей в событии OnUserAuthenticate, то только эти роли могут использоваться
  для определения, есть ли у пользователя разрешение на вызов любого заданного серверного метода.
  Однако, если вы хотите иметь больший контроль над процессом
  (например, разрешить или запретить вызов в зависимости от времени суток), вы можете реализовать это событие.
  В событие передается объект, содержащий такую информацию, как имя пользователя, пользовательские роли, заполненные
  в событии аутентификации, и разрешенные / запрещенные роли для вызываемого метода. Вы можете использовать эту информацию,
  а также все остальное, что вам нравится, чтобы решить, хотите ли вы установить значение “valid” равным true или false, что позволит или запретит вызов метода.}

end;

procedure TWebModule1.DSClassMobileGetClass(DSServerClass: TDSServerClass;
  var PersistentClass: TPersistentClass);
begin
  PersistentClass := uMobile.Mobile;
end;

procedure TWebModule1.DSClassRest1sGetClass(DSServerClass: TDSServerClass;
  var PersistentClass: TPersistentClass);
begin
  PersistentClass := uRest1s.Rest1s;

end;

procedure TWebModule1.DSClassTerminalGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := uTerminal.Terminal;
end;

procedure TWebModule1.DSClassYandexGetClass(DSServerClass: TDSServerClass;
  var PersistentClass: TPersistentClass);
begin
  PersistentClass := uYandex.Yandex;
end;

procedure TWebModule1.DSHTTPWebDispatcher1FormatResult(Sender: TObject;
  var ResultVal: TJSONValue; const Command: TDBXCommand; var Handled: Boolean);

 var
  JSONArray:TJSONArray;
  stJson:string;
begin
  Handled := True;
  stJson:=ResultVal.ToJSON;

  JSONArray :=  TJSONObject.ParseJSONValue(stJson, False, True) as TJSONArray;

  stJson := JSONArray.Get(0).ToJSON;

  FreeAndNil(ResultVal);

  try
    ResultVal := TJSONObject.ParseJSONValue(stJson, False, True) as TJSONObject;
  finally
    FreeAndNil(JSONArray);
  end;


end;

procedure TWebModule1.DSServer1Error(DSErrorEventObject: TDSErrorEventObject);
begin
  LogFile.WriteLogHead('Error', DSErrorEventObject.Error.Message);
end;

procedure TWebModule1.WebFileDispatcher1BeforeDispatch(Sender: TObject;
  const AFileName: string; Request: TWebRequest; Response: TWebResponse;
  var Handled: Boolean);
var
  D1, D2: TDateTime;
begin
  Handled := False;
  if SameFileName(ExtractFileName(AFileName), 'serverfunctions.js') then
    if not FileExists(AFileName) or (FileAge(AFileName, D1) and FileAge(WebApplicationFileName, D2) and (D1 < D2)) then
    begin
      DSProxyGenerator1.TargetDirectory := ExtractFilePath(AFileName);
      DSProxyGenerator1.TargetUnitName := ExtractFileName(AFileName);
      DSProxyGenerator1.Write;
    end;
end;

initialization
finalization
  Web.WebReq.FreeWebModules;

end.

