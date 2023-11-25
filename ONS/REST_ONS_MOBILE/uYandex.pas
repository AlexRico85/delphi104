unit uYandex;

interface

uses
  System.SysUtils, System.StrUtils, System.Math, FireDAC.Comp.Client, System.Classes, structures, System.JSON,
   Datasnap.DSAuth, Web.HTTPApp, Datasnap.DSHTTPWebBroker;

type
{$METHODINFO ON}
  Yandex = class(TPersistent)
    FDConnection: TFDConnection;
    FDConnectionYandex: TFDConnection;
  private
    FClientMySQLSet:TClientMySQLSet;
    FClientYandexMySQLSet:TClientMySQLSet;
  public
    function updateAdd(JsonText: String): TJSONObject;
    function updateRegistration(JsonText: String): TJSONObject;
    function updateConfirm(JsonText: String): TJSONObject;
    function updatebalance(JsonText: String): TJSONObject;
    function updatepurchase(JsonText: String): TJSONObject;

    function balance(): TJSONObject;
    ///registration, /confirm - нужны описания методов

    Procedure Connect();
    Procedure DisConnect();
    constructor Create();
    Destructor Destroy;
  end;
{$METHODINFO OFF}

Function GetNewGuid:string;

implementation

uses FunctionMySQL, JsonSerialization, uLog, uSqlList,
  frmSettingUnit, uWriteDataSQL , IdURI, EncdDecd, SMS;



function Yandex.updateAdd(JsonText: String): TJSONObject;
var
  QueryGetCartListByPhone:TFDQuery;
  GetBlankCard:TFDQuery;
  QueryGetInfoBonus:TFDQuery;
  QueryGetParamCard:TFDQuery;

  JSON:TJSONObject;
  JSonValue:TJSONValue;

  RinfoBonuxCard: TinfoBonuxCard;

  N:integer;
  ParamPhone,ParamCard_number, ParamMask_login:string;
  ParamIdCard:string;
  resultText : string;

  ErrorDescription: AnsiString;

  SMSParams:TSMSParams;
  ResultSend:string;
  ResultSendSMS:Boolean;
  SMSCode : Integer;
  YandexRegData: TYandexRegData;
begin

  Connect;

  ParamCard_number:='';
  ParamPhone:='';

  QueryGetCartListByPhone := TFDQuery.Create(nil);
  QueryGetCartListByPhone.Connection :=  FDConnection;
  QueryGetCartListByPhone.SQL.Text := SqlList['GetCartListByPhone'];

  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardYandex'];

  QueryGetInfoBonus := TFDQuery.Create(nil);
  QueryGetInfoBonus.Connection :=  FDConnection;
  QueryGetInfoBonus.SQL.Text := SqlList['GetInfoBonusYandex'];

  GetBlankCard := TFDQuery.Create(nil);
  GetBlankCard.Connection :=  FDConnection;
  GetBlankCard.SQL.Text := SqlList['GetBlankCard'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try


    JSonValue := Json.FindValue('card_number');
    if JSonValue <> nil then
    begin
      ParamCard_number := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('phone');
    if JSonValue <> nil then
    begin
      ParamPhone := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('mask_login');
    if JSonValue <> nil then
    begin
      ParamMask_login := JSonValue.Value;
    end;

    if ((ParamPhone = '') and (ParamMask_login = '')) then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Не верные параметры запроса', 'Ошибка на сервере, повторите.'));
    end;

    if ParamPhone <> '' then
    Begin
        QueryGetCartListByPhone.Active := False;
        QueryGetCartListByPhone.Params[0].Value := '%'+AnsiRightStr(ParamPhone, 10)+'%';

        try
          QueryGetCartListByPhone.Open;
          QueryGetCartListByPhone.First;
        except
          Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере, повторите.'));
        end;


        if QueryGetCartListByPhone.RecordCount>0 then
          ParamCard_number :=  QueryGetCartListByPhone.FieldByName('codeCard').AsString
        else
        begin
          ErrorDescription := ErrorYandexToJSONText(404, 'По данному номеру не зарегистрирована карта '+QueryGetCartListByPhone.FieldByName('codeCard').AsString, '');
          Raise Exception.Create(ErrorDescription);
        end;
    End;

    if ParamCard_number = '' then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Не верные параметры запроса', 'Ошибка на сервере, повторите.'));
    end;

    QueryGetParamCard.ParamByName('codecard').Value := ParamCard_number;

    try
      QueryGetParamCard.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере, повторите.'));
      end;
    end;

    QueryGetParamCard.Last;

    if QueryGetParamCard.RecordCount=0 then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(404, 'Карта не найдена', 'Карта не найдена.'));
    end;

    ParamIdCard   :=  QueryGetParamCard.FieldByName('idcard').AsString;

    QueryGetInfoBonus.ParamByName('idCard').Value := ParamIdCard;

    try
      QueryGetInfoBonus.Open;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере, повторите.'));
    end;

    RinfoBonuxCard.idCodeCard :=  ParamIdCard;
    RinfoBonuxCard.barcode :=  ParamCard_number;

    QueryGetInfoBonus.First;

    if QueryGetInfoBonus.RecordCount<>0 then
    begin
      with   QueryGetInfoBonus do
      begin
        RinfoBonuxCard.OstBonus := RoundTo(FieldByName('OstBounus').AsFloat,-2);
        RinfoBonuxCard.OstMoyka := RoundTo(FieldByName('OstMoyka').AsFloat,-2);
      end;
    end else
    begin
      RinfoBonuxCard.OstBonus := 0;
      RinfoBonuxCard.OstMoyka := 0;
    end;



    SMSCode := NewSMSCode();

    SMSParams.Server  :=  SettingProgram.SMSServer;
    SMSParams.Login   :=  SettingProgram.SMSLogin;
    SMSParams.Pass    :=  SettingProgram.SMSPass;

    SMSParams.Phone   :=  ParamPhone;
    SMSParams.SMS     :=  'Яндекс лояльность '+IntToStr(SMSCode);

    ResultSendSMS := SENDSMS(SMSParams, ResultSend);

    if not ResultSendSMS then
       Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка отправки смс подтверждения ' + ResultSend, 'Ошибка отправки смс подтверждения'));

    YandexRegData.dateOfReg := now();
    YandexRegData.phone     := ParamPhone;
    YandexRegData.codecard  := ParamCard_number;
    YandexRegData.SMSCODE   := IntToStr(SMSCode);
    YandexRegData.card_token := ParamIdCard;
    YandexRegData.mask_login := ParamMask_login;
    YandexRegData.confirm   := 0;


    if UpdateMySQL_YandexRegData(YandexRegData, ErrorDescription, FDConnectionYandex) then
     begin
         Result := ResultOkToJSON();
     end
     else
     begin
        Raise Exception.Create(ErrorDescription);
     end;

  finally

    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetInfoBonus);
    FreeAndNil(QueryGetCartListByPhone);
    FreeAndNil(GetBlankCard);
    FreeAndNil(JSON);
    DisConnect;
  end;
end;

function Yandex.updateRegistration(JsonText: String): TJSONObject;
var
  QueryGetCartListByPhone:TFDQuery;
  GetBlankCard:TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  OnlineRegData: TOnlineRegData;
  InfoPersone:TInfoPersone;
  Card:TCard;

  N:integer;
  ParamPhone:string;
  resultText : string;

  SMSParams:TSMSParams;
  ResultSend:string;
  ResultSendSMS:Boolean;
  SMSCode : Integer;
  YandexRegData: TYandexRegData;

  ErrorDescription: AnsiString;
begin

  Connect;

  QueryGetCartListByPhone := TFDQuery.Create(nil);
  QueryGetCartListByPhone.Connection :=  FDConnection;
  QueryGetCartListByPhone.SQL.Text := SqlList['GetCartListByPhone'];

  GetBlankCard := TFDQuery.Create(nil);
  GetBlankCard.Connection :=  FDConnection;
  GetBlankCard.SQL.Text := SqlList['GetBlankCard'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try
    JSonValue := Json.FindValue('phone');
    if JSonValue = nil then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Не указан параметр phone', 'Ошибка на сервере'));
    end;

    ParamPhone := JSonValue.Value;


    QueryGetCartListByPhone.Active := False;
    QueryGetCartListByPhone.Params[0].Value := '%'+AnsiRightStr(ParamPhone, 10)+'%';

    try
      QueryGetCartListByPhone.Open;
      QueryGetCartListByPhone.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;


    if QueryGetCartListByPhone.RecordCount>0 then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'По данному номеру зарегистрирована карта '+QueryGetCartListByPhone.FieldByName('codeCard').AsString, ''));
    end;


    try
      GetBlankCard.Open;
      GetBlankCard.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;

    if GetBlankCard.RecordCount=0 then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Нет свободных карт для регистрации', 'Регистрация временно недоступна'));
    end;



    Card.idcode     :=  GetBlankCard.FieldByName('idcode').AsString;
    Card.idname     :=  GetBlankCard.FieldByName('idname').AsString;
    Card.codecard   :=  GetBlankCard.FieldByName('codcart').AsString;
    Card.rfid       := GetBlankCard.FieldByName('rfid').AsString;
    Card.ownercart  :=  'MR'+Copy(GetBlankCard.FieldByName('idcode').AsString, 3);
    Card.level      :=  GetBlankCard.FieldByName('levelgroup').AsString;
    Card.isOnlineReg :=  GetBlankCard.FieldByName('isOnlineReg').AsInteger;
    Card.guid :=  GetBlankCard.FieldByName('guid').AsString;
    Card.toWrite := 1;

     if Not WriteToMySQL_CardPerson(Card, ErrorDescription, FDConnection) then
     begin
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Не удалось обновить данные карты', 'Ошибка на сервере'));
     end;

    InfoPersone.idCode :=  Card.ownercart;
    InfoPersone.phone :=  ParamPhone;
    InfoPersone.name := 'Онлайн клиент';
    InfoPersone.guid := IntToStr(GetNewUnicode(ErrorDescription, 'Online', 'Registred', FDConnection));
    InfoPersone.toWrite := 1;

    if Not WriteToMySQL_Person(InfoPersone, ErrorDescription, FDConnection) then
     begin
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Не удалось записать данные физ лица', 'Ошибка на сервере'));
     end;

    OnlineRegData.dateOfReg := now;
    OnlineRegData.idCard :=  GetBlankCard.FieldByName('idcode').AsString;
    OnlineRegData.codecard :=  GetBlankCard.FieldByName('codecard').AsString;
    OnlineRegData.phone :=  ParamPhone;

    if WriteToMySQL_OnlineRegData(OnlineRegData, ErrorDescription, FDConnection) then
    begin

      SMSCode := NewSMSCode();
      SMSParams.Server  :=  SettingProgram.SMSServer;
      SMSParams.Login   :=  SettingProgram.SMSLogin;
      SMSParams.Pass    :=  SettingProgram.SMSPass;

      SMSParams.Phone   :=  ParamPhone;
      SMSParams.SMS     :=  'Яндекс лояльность '+IntToStr(SMSCode);

      ResultSendSMS := SENDSMS(SMSParams, ResultSend);

      if not ResultSendSMS then
         Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка отправки смс подтверждения', 'Ошибка отправки СМС'));

      YandexRegData.dateOfReg := now();
      YandexRegData.phone     := ParamPhone;
      YandexRegData.codecard  := OnlineRegData.codecard;
      YandexRegData.SMSCODE   := IntToStr(SMSCode);
      YandexRegData.card_token := OnlineRegData.idCard;

      if UpdateMySQL_YandexRegData(YandexRegData, ErrorDescription, FDConnectionYandex) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorYandexToJSONText(400, ErrorDescription, 'Ошибка на сервере'));
       end;
    end
    else
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, ErrorDescription, 'Ошибка на сервере'));
    end;



  finally
    FreeAndNil(QueryGetCartListByPhone);
    FreeAndNil(GetBlankCard);
    FreeAndNil(JSON);
    DisConnect;
  end;
end;

function Yandex.updateConfirm(JsonText: String): TJSONObject;
var

  QueryGetYandexRegData:TFDQuery;

  YandexRegData:TYandexRegData;

  JSON:TJSONObject;
  JSonValue:TJSONValue;

  N:integer;
  ParamPhone, ParamCard_number, ParamMask_login, SMScode:string;
  ParamIdCard:string;
  resultText : string;

  ErrorDescription: AnsiString;
begin

  Connect;

  QueryGetYandexRegData := TFDQuery.Create(nil);
  QueryGetYandexRegData.Connection :=  FDConnectionYandex;
  QueryGetYandexRegData.SQL.Text := SqlList['GetYandexRegData'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try


    JSonValue := Json.FindValue('card_number');
    if JSonValue <> nil then
    begin
      ParamCard_number := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('phone');
    if JSonValue <> nil then
    begin
      ParamPhone := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('mask_login');
    if JSonValue <> nil then
    begin
      ParamMask_login := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('code');
    if JSonValue <> nil then
    begin
      SMScode := JSonValue.Value;
    end;

    if ((ParamPhone = '') and (ParamCard_number = '')) then
    begin
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Не верные параметры запроса', 'Ошибка на сервере'));
    end;

    QueryGetYandexRegData.Active := False;
    QueryGetYandexRegData.ParamByName('phone').Value        := ParamPhone;
    QueryGetYandexRegData.ParamByName('card_number').Value  := ParamCard_number;
    QueryGetYandexRegData.ParamByName('sms_code').Value     := SMScode;
    try
      QueryGetYandexRegData.Open;
      QueryGetYandexRegData.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;

    if QueryGetYandexRegData.RecordCount>0 then
    begin

      YandexRegData.dateOfReg :=  QueryGetYandexRegData.FieldByName('dateOfReg').AsDateTime;
      YandexRegData.phone     :=  QueryGetYandexRegData.FieldByName('phone').AsString;
      YandexRegData.codecard  :=  QueryGetYandexRegData.FieldByName('card_number').AsString;
      YandexRegData.SMSCODE   :=  QueryGetYandexRegData.FieldByName('sms_code').AsString;
      YandexRegData.idcard    :=  QueryGetYandexRegData.FieldByName('card_token').AsString;
      YandexRegData.mask_login  :=  ParamMask_login;
      YandexRegData.confirm     := 1;
      YandexRegData.card_token  :=  GetNewGuid;

      if UpdateMySQL_YandexRegData(YandexRegData, ErrorDescription, FDConnectionYandex) then
       begin
           Result := YandexConfirmOKJSON(YandexRegData);
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;


    end  else Raise Exception.Create(ErrorYandexToJSONText(400, 'Неверный код подтверждения регистрации', ''));


  finally


    FreeAndNil(QueryGetYandexRegData);
    FreeAndNil(JSON);
    FreeAndNil(JSonValue);

    DisConnect;

  end;
end;

function Yandex.updatebalance(JsonText: String): TJSONObject;
var
 objWebModule: TWebModule;
 ApiKey:string;
 CardToken:string;

 ErrorDescription:AnsiString;

 YandexRegData:TYandexRegData;
 QueryGetInfoBonus:TFDQuery;
 QueryGetYandexRegData:TFDQuery;

 balance, balanceMoyka:Double;
begin
 //the Solution
  objWebModule := GetDataSnapWebModule; //need Datasnap.DSHTTPWebBroker
  //objWebModule.Response.SetCustomHeader('MY-CUSTOM-HEADER','ABCD12324');

  ApiKey := objWebModule.Request.GetFieldByName('X-ApiKey');
  CardToken := objWebModule.Request.GetFieldByName('X-CardToken');
  //do the test using postman, and see on HEADERS

  if ApiKey <> SettingProgram.YandexAPI then
  begin

    objWebModule.Response.StatusCode := 403;
    result := ErrorYandexToJSON(403, 'Неверный ApiKey', 'Неверный ApiKey');
    exit;

  end;

  if CardToken = '' then
  begin
    ErrorDescription := ErrorYandexToJSONText(400, 'Не найден параметр X-CardToken', '');
    Raise Exception.Create(ErrorDescription);
  end;

  Connect;

  QueryGetInfoBonus := TFDQuery.Create(nil);
  QueryGetInfoBonus.Connection :=  FDConnection;
  QueryGetInfoBonus.SQL.Text := SqlList['GetInfoBonusYandex'];

  QueryGetYandexRegData := TFDQuery.Create(nil);
  QueryGetYandexRegData.Connection :=  FDConnectionYandex;
  QueryGetYandexRegData.SQL.Text := SqlList['GetYandexRegDataByCardToken'];

  try

    QueryGetYandexRegData.Active := False;
    QueryGetYandexRegData.ParamByName('card_token').Value    := CardToken;

    try
      QueryGetYandexRegData.Open;
      QueryGetYandexRegData.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;

    if QueryGetYandexRegData.RecordCount>0 then
    begin

      YandexRegData.dateOfReg :=  QueryGetYandexRegData.FieldByName('dateOfReg').AsDateTime;
      YandexRegData.phone     :=  QueryGetYandexRegData.FieldByName('phone').AsString;
      YandexRegData.codecard  :=  QueryGetYandexRegData.FieldByName('card_number').AsString;
      YandexRegData.SMSCODE   :=  QueryGetYandexRegData.FieldByName('sms_code').AsString;
      YandexRegData.idcard    :=  QueryGetYandexRegData.FieldByName('card_id').AsString;
      YandexRegData.card_token  := QueryGetYandexRegData.FieldByName('card_token').AsString;
      YandexRegData.mask_login  := QueryGetYandexRegData.FieldByName('mask_login').AsString;
      YandexRegData.confirm     := QueryGetYandexRegData.FieldByName('confirm').AsInteger;

    end  else Raise Exception.Create(ErrorYandexToJSONText(400, 'Клиент не зарегистирован', ''));


    QueryGetInfoBonus.ParamByName('idCard').Value := YandexRegData.idcard;

    try
      QueryGetInfoBonus.Open;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере, повторите.'));
    end;

    QueryGetInfoBonus.First;

    if QueryGetInfoBonus.RecordCount<>0 then
    begin
      with   QueryGetInfoBonus do
      begin
        balance := RoundTo(FieldByName('OstBounus').AsFloat,-2);
        balanceMoyka := RoundTo(FieldByName('OstMoyka').AsFloat,-2);
      end;
    end else

    begin
      balance := 0;
      balanceMoyka := 0;
    end;



  finally
     FreeAndNil(QueryGetInfoBonus);
     FreeAndNil(QueryGetYandexRegData);
     DisConnect;
  end;



  result := YandexBalanceJSON(balance);
end;

function Yandex.balance: TJSONObject;
begin
  result := updatebalance('{}');
end;

function Yandex.updatepurchase(JsonText: String): TJSONObject;
var
 objWebModule: TWebModule;
 ApiKey:string;
 CardToken:string;

 JSON:TJSONObject;
 JSonValue:TJSONValue;
 FormatSettings: TFormatSettings;

 ErrorDescription:AnsiString;

 YandexRegData:TYandexRegData;
 YandexPurchase:TYandexPurchase;
 YandexPurchaseAnswer:TYandexPurchaseAnswer;

 QueryGetYandexRegData:TFDQuery;
 QueryGetYandexPurchaseData:TFDQuery;

begin
   //the Solution
  objWebModule := GetDataSnapWebModule; //need Datasnap.DSHTTPWebBroker
  //objWebModule.Response.SetCustomHeader('MY-CUSTOM-HEADER','ABCD12324');

  ApiKey := objWebModule.Request.GetFieldByName('X-ApiKey');
  CardToken := objWebModule.Request.GetFieldByName('X-CardToken');
  //do the test using postman, and see on HEADERS

  if ApiKey <> SettingProgram.YandexAPI then
  begin

    objWebModule.Response.StatusCode := 403;
    result := ErrorYandexToJSON(403, 'Неверный ApiKey', 'Неверный ApiKey');
    exit;

  end;

  if CardToken = '' then
  begin
    ErrorDescription := ErrorYandexToJSONText(400, 'Не найден параметр X-CardToken', '');
    Raise Exception.Create(ErrorDescription);
  end;


  if not JSONToTYandexPurchase(JsonText, YandexPurchase) then
  begin
    ErrorDescription := ErrorYandexToJSONText(400, 'Ошибка чтения JSON DATA', 'Ошибка получения данных');
    Raise Exception.Create(ErrorDescription);
  end;




  Connect;

  QueryGetYandexPurchaseData := TFDQuery.Create(nil);
  QueryGetYandexPurchaseData.Connection :=  FDConnectionYandex;
  QueryGetYandexPurchaseData.SQL.Text := SqlList['GetYandexPurchaseData'];

  QueryGetYandexRegData := TFDQuery.Create(nil);
  QueryGetYandexRegData.Connection :=  FDConnectionYandex;
  QueryGetYandexRegData.SQL.Text := SqlList['GetYandexRegDataByCardToken'];

  try

    QueryGetYandexRegData.Active := False;
    QueryGetYandexRegData.ParamByName('card_token').Value    := CardToken;

    try
      QueryGetYandexRegData.Open;
      QueryGetYandexRegData.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;

    if QueryGetYandexRegData.RecordCount>0 then
    begin

      YandexRegData.dateOfReg :=  QueryGetYandexRegData.FieldByName('dateOfReg').AsDateTime;
      YandexRegData.phone     :=  QueryGetYandexRegData.FieldByName('phone').AsString;
      YandexRegData.codecard  :=  QueryGetYandexRegData.FieldByName('card_number').AsString;
      YandexRegData.SMSCODE   :=  QueryGetYandexRegData.FieldByName('sms_code').AsString;
      YandexRegData.idcard    :=  QueryGetYandexRegData.FieldByName('card_id').AsString;
      YandexRegData.card_token  := QueryGetYandexRegData.FieldByName('card_token').AsString;
      YandexRegData.mask_login  := QueryGetYandexRegData.FieldByName('mask_login').AsString;
      YandexRegData.confirm     := QueryGetYandexRegData.FieldByName('confirm').AsInteger;

    end  else Raise Exception.Create(ErrorYandexToJSONText(400, 'Клиент не зарегистирован', ''));


    QueryGetYandexPurchaseData.Active := False;
    QueryGetYandexPurchaseData.ParamByName('orderId').Value   := YandexPurchase.orderId;
    try
      QueryGetYandexPurchaseData.Open;
      QueryGetYandexPurchaseData.First;
    except
      Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка выполнения запроса', 'Ошибка на сервере'));
    end;

    if QueryGetYandexPurchaseData.RecordCount>0 then
    begin
      // Если запрос обработан ранее, возвращаем ответ из БД
      YandexPurchaseAnswer.rewrite            := QueryGetYandexPurchaseData.FieldByName('rewrite').AsInteger;
      YandexPurchaseAnswer.purchaseId         := QueryGetYandexPurchaseData.FieldByName('purchaseId').AsString;
      YandexPurchaseAnswer.bonus              := QueryGetYandexPurchaseData.FieldByName('bonus').AsFloat;
      YandexPurchaseAnswer.errorCode          := QueryGetYandexPurchaseData.FieldByName('errorCode').AsInteger;
      YandexPurchaseAnswer.errorMessage       := QueryGetYandexPurchaseData.FieldByName('errorMessage').AsString;
      YandexPurchaseAnswer.userErrorMessage   := QueryGetYandexPurchaseData.FieldByName('errorMessage').AsString;


      if YandexPurchaseAnswer.errorCode <> 0 then
      begin
        Raise Exception.Create(ErrorYandexToJSONText(YandexPurchaseAnswer.errorCode, YandexPurchaseAnswer.errorMessage, YandexPurchaseAnswer.userErrorMessage));
      end
      else if YandexPurchaseAnswer.rewrite = 0  then
      begin
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Операция в очереди обработки', 'Операция в очереди обработки'));
      end
      else
      begin
        result := YandexPurchaseOKJSON(YandexPurchaseAnswer.purchaseId, YandexPurchaseAnswer.bonus);
      end;
      exit;
    end;

     if WriteMySQL_yandex_transactions_bonus(YandexPurchase, ErrorDescription, FDConnectionYandex) then
     begin
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Операция в очереди обработки', 'Операция в очереди обработки'));
     end
     else
     begin
        Raise Exception.Create(ErrorYandexToJSONText(400, ErrorDescription, 'Ошибка на сервере'));
     end;



  finally

     FreeAndNil(QueryGetYandexRegData);
     FreeAndNil(QueryGetYandexPurchaseData);
     FreeAndNil(JSON);
     FreeAndNil(JSonValue);
     DisConnect;

  end;

   Result := ResultOkToJSON();

end;


constructor Yandex.Create();
begin

 inherited create();

 FDConnection:= TFDConnection.Create(nil);
 FDConnectionYandex:= TFDConnection.Create(nil);

end;

destructor Yandex.Destroy;
begin
  FreeAndNil(FDConnection);
  FreeAndNil(FDConnectionYandex);
  Inherited Destroy;
end;



Procedure Yandex.Connect();

var
  ErrorDescription: AnsiString;
  ResultConnect : Boolean;

begin

  if FDConnection = nil then
    FDConnection:= TFDConnection.Create(nil);

  if not FDConnection.Connected then
  begin
    FClientMySQLSet.ServerAdress:=  SettingProgram.ServerAdressMySQL;
    FClientMySQLSet.Login:=  SettingProgram.LoginMySQL;
    FClientMySQLSet.Uinpromt:=  SettingProgram.PassWordMySQL;
    FClientMySQLSet.DataBase:=  SettingProgram.DataBaseMySQL;
    FClientMySQLSet.Port:=  SettingProgram.PortMySQL;

    ResultConnect :=  ConnectToServer(ErrorDescription, FDConnection, FClientMySQLSet);

    if not ResultConnect then
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка подключения к базе данных', 'Ошибка на сервере'));
  end;

  if FDConnectionYandex = nil then
    FDConnectionYandex:= TFDConnection.Create(nil);

  if not FDConnectionYandex.Connected then
  begin
    FClientYandexMySQLSet.ServerAdress:=  SettingProgram.YandexServerBD;
    FClientYandexMySQLSet.Login:=         SettingProgram.YandexLoginBD;
    FClientYandexMySQLSet.Uinpromt:=      SettingProgram.YandexPassBD;
    FClientYandexMySQLSet.DataBase:=      SettingProgram.YandexNameBD;
    FClientYandexMySQLSet.Port:=          SettingProgram.YandexPortBD;

    ResultConnect :=  ConnectToServer(ErrorDescription, FDConnectionYandex, FClientYandexMySQLSet);

    if not ResultConnect then
        Raise Exception.Create(ErrorYandexToJSONText(400, 'Ошибка подключения к базе данных Yandex', 'Ошибка на сервере'));
  end;


end;

Procedure Yandex.DisConnect;
begin
  FDConnection.Connected := false;
  FreeAndNil(FDConnection);

  FDConnectionYandex.Connected := false;
  FreeAndNil(FDConnectionYandex);
end;


Function GetNewGuid:string;
var
  Xml: TStringList;
  Uid: TGUID;
  S: string;

begin

  if CreateGuid(Uid) = s_OK then
  begin
    s := GUIDToString(Uid);
    s:=Copy(s, 1, length(s)-1);
    Delete(s, 1, 1);
    s:= AnsiLowerCase(s);
  end;
  result := s;

end;

end.
