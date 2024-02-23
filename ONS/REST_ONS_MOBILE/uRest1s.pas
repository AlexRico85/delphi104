unit uRest1s;

interface

uses
  System.SysUtils, System.Math, FireDAC.Comp.Client, System.Classes, structures, System.JSON,
   Datasnap.DSAuth;


type
  {$METHODINFO ON}
  [TRoleAuth('admin')]
  Rest1s = class(TPersistent)
    FDConnection: TFDConnection;
    FDConnectionYandex: TFDConnection;
  private
    FClientMySQLSet:TClientMySQLSet;
    FClientYandexMySQLSet:TClientMySQLSet;
  public
    Procedure Connect();
    Procedure DisConnect();

    Procedure ConnectYandex();
    Procedure DisConnectYandex();

    function GetNewUnicode(const phone: string): TJSONObject;
    function updateGetNewUnicode(JsonText: String): TJSONObject;

    function GetBalanseBonusCard(JsonText: String): TJSONObject;
    function updateGetBalanseBonusCard(JsonText: String): TJSONObject;

    function Get_Partners_jurnal(JsonText: String): TJSONObject;
    function updateGet_Partners_jurnal(JsonText: String): TJSONObject;

    function GetRateBonus(JsonText: String): TJSONObject;
    function updateGetRateBonus(JsonText: String): TJSONObject;

    function Write_dc_engine_pay_moyka(JsonText: String): TJSONObject;
    function updateWrite_dc_engine_pay_moyka(JsonText: String): TJSONObject;

    function Write_dc_enginecards(JsonText: String): TJSONObject;
    function updateWrite_dc_enginecards(JsonText: String): TJSONObject;

    function Write_dc_enginefixcards_moyka(JsonText: String): TJSONObject;
    function updateWrite_dc_enginefixcards_moyka(JsonText: String): TJSONObject;

    function Write_dc_enginedebit_moyka(JsonText: String): TJSONObject;
    function updateWrite_dc_enginedebit_moyka(JsonText: String): TJSONObject;

    function Write_CardPerson(JsonText: String): TJSONObject;
    function updateWrite_CardPerson(JsonText: String): TJSONObject;

    function updateWrite_Person(JsonText: String): TJSONObject;
    function updateWrite_Person_AddInfo(JsonText: String): TJSONObject;
    function updateWrite_OnlineRegData(JsonText: String): TJSONObject;

    function updateGetChangesPersonList(JsonText: String): TJSONObject;

    function updateGetOnlineRegData(JsonText: String): TJSONObject;

    function updateGetYandexPurchaseList(JsonText: String): TJSONObject;
    function updateWrite_YandexPurchaseAnswer(JsonText: String): TJSONObject;

    function GetReferralCode(const JsonText: string): TJSONObject;
    function updateGetReferralCode(JsonText: String): TJSONObject;

    function updateWrite_Goods(JsonText: String): TJSONObject;
    function updateWrite_GroupGoods(JsonText: String): TJSONObject;

    [TRoleAuth('admin')]
    function updateGetChangesCardList(JsonText: String): TJSONObject;

    function updateUpload_paymentreceipt(JsonText: string): TJSONObject;

    function updateGetChangesPersonsAddinfo(JsonText: String): TJSONObject;

    function updateGetBirthdayList(JsonText: String): TJSONObject;

    constructor Create();
    Destructor Destroy;
  end;

  {$METHODINFO OFF}

var
   iRest1s:Rest1s;
implementation

uses FunctionMySQL, JsonSerialization, uLog, uSqlList,
  frmSettingUnit, uWriteDataSQL , IdURI, EncdDecd;

constructor Rest1s.Create();
begin

 inherited create();

  FDConnection:= TFDConnection.Create(nil);

end;

destructor Rest1s.Destroy;
begin
  FreeAndNil(FDConnection);
  Inherited Destroy;
end;


function Rest1s.GetBalanseBonusCard(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.GetNewUnicode(const phone: string): TJSONObject;
begin
   Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.GetRateBonus(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.Get_Partners_jurnal(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;


function Rest1s.Write_CardPerson(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.Write_dc_engine_pay_moyka(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.Write_dc_enginecards(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.Write_dc_enginefixcards_moyka(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.Write_dc_enginedebit_moyka(JsonText: String): TJSONObject;
begin
  Result := DescriptionErrorToJSON(2, 'use POST query');
end;




function Rest1s.updateGetBalanseBonusCard(JsonText: String): TJSONObject;
 var
  JSON:TJSONObject;
  JSonVaue:TJSONValue;
  ErrorDescription: AnsiString;
  ParamIdCard, ParamCodeCard, ParamIdGroup :string;
  RinfoBonuxCard: TinfoBonuxCard;
  resultText : string;

  QueryGetParamCard: TFDQuery;
  QueryGetBalanseBonusCard: TFDQuery;

begin
  Connect();

  ErrorDescription := '';
  ParamIdCard := '';
  ParamCodeCard := '';
  ParamIdGroup := '';

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetBalanseBonusCard := TFDQuery.Create(nil);

  try

    JSonVaue := Json.FindValue('idCard');
    if JSonVaue <> nil then
    begin
      ParamIdCard := JSonVaue.Value;
    end;

    JSonVaue := Json.FindValue('codeCard');
    if JSonVaue <> nil then
    begin
      ParamCodeCard := JSonVaue.Value;
    end;

    JSonVaue := Json.FindValue('idGroupGoods');
    if JSonVaue <> nil then
    begin
      ParamIdGroup := JSonVaue.Value;
    end;

    if ((ParamIdCard = '') and (ParamCodeCard = '')) or (ParamIdGroup='') then
    begin
//      Result := DescriptionErrorToJSON(2, 'Неверные параметры запроса');
      Raise Exception.Create('Неверные параметры запроса');
     // exit;
    end;

    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';

    if ParamCodeCard='' then
       ParamCodeCard := '999999999999999999999999999999';


    QueryGetParamCard.Connection :=  FDConnection;
    QueryGetParamCard.SQL.Text := SqlList['GetParamCard'];


    QueryGetBalanseBonusCard.Connection :=  FDConnection;
    QueryGetBalanseBonusCard.SQL.Text := SqlList['GetBalanseBonusCard'];


    QueryGetParamCard.ParamByName('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.ParamByName('IDCODE').Value := ParamIdCard;

    try
      QueryGetParamCard.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;

    QueryGetParamCard.Last;

    if QueryGetParamCard.RecordCount=0 then
    begin
      Raise Exception.Create('Карта не найдена');
    end;

    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard   :=  QueryGetParamCard.FieldByName('idcard').AsString;

    QueryGetBalanseBonusCard.Active := False;
    QueryGetBalanseBonusCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetBalanseBonusCard.Params.FindParam('IDCARD').Value := ParamIdCard;
    QueryGetBalanseBonusCard.Params.FindParam('IDGROUPGOODS').Value := ParamIdGroup;

    try
      QueryGetBalanseBonusCard.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;

    QueryGetBalanseBonusCard.Last;

    if QueryGetBalanseBonusCard.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetBalanseBonusCard.First;

    with   QueryGetBalanseBonusCard do
    begin

      RinfoBonuxCard.OstBonus := RoundTo(FieldByName('OstBounus').AsFloat,-2);
      RinfoBonuxCard.OstMoyka := RoundTo(FieldByName('OstMoyka').AsFloat,-2);
      if FieldByName('action').AsInteger > 0 then
      begin
        RinfoBonuxCard.ActionId      := FieldByName('action').AsInteger;
        RinfoBonuxCard.guiddocaction := FieldByName('actionguid').AsInteger;
      end
      else  RinfoBonuxCard.ActionId := 0;

      if RinfoBonuxCard.OstBonus < 0 then
        RinfoBonuxCard.OstBonus := 0;
      if RinfoBonuxCard.OstMoyka < 0 then
        RinfoBonuxCard.OstMoyka := 0;

      RinfoBonuxCard.Discont    := FieldByName('discontrate').AsFloat;
      RinfoBonuxCard.idCodeCard := FieldByName('codecard').AsString;
      RinfoBonuxCard.barcode    := ParamCodeCard;
      RinfoBonuxCard.BonusRate  := FieldByName('BonusRate').AsFloat;
      RinfoBonuxCard.SumDeb     := FieldByName('sumDeb').AsFloat;

      // ------------------ АКЦИИ БОНУСЫ-----------------------------------

      RinfoBonuxCard.ActionIdBonusRate := 0; //
      RinfoBonuxCard.guiddocaction := 0;
    end;
  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetBalanseBonusCard);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := TinfoBonuxCardToJSON(0,'OK', RinfoBonuxCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;

function Rest1s.updateGetNewUnicode(JsonText: String): TJSONObject;
var
  QueryGetNewUnicode: TFDQuery;

  JSON:TJSONObject;
  JSonValue:TJSONValue;
  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  ParamDiscrprm, ParamUserloginprm:string;
  unicode:integer;
begin

  Connect();
  QueryGetNewUnicode :=  TFDQuery.Create(nil);
  QueryGetNewUnicode.Connection :=  FDConnection;
  QueryGetNewUnicode.SQL.Text := SqlList['GetNewUnicode'];
  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try

    JSonValue := Json.FindValue('discrprm');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;
    ParamDiscrprm := JSonValue.Value;

    JSonValue := Json.FindValue('userloginprm');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamUserloginprm := JSonValue.Value;

    QueryGetNewUnicode.Active := False;
    QueryGetNewUnicode.ParamByName('Discrprm').Value := ParamDiscrprm;
    QueryGetNewUnicode.ParamByName('Userloginprm').Value := ParamUserloginprm;

    try
      QueryGetNewUnicode.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;

    QueryGetNewUnicode.Last;

    if QueryGetNewUnicode.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetNewUnicode.First;
    unicode := QueryGetNewUnicode.FieldByName('unicode').AsInteger;


    resultText :=  '{"ErrorCode": 0'+
                    ', "Result": "OK"' +
                    ', "unicode": '+IntToStr(unicode)+'' +
                    '}';
  finally
    FreeAndNil(QueryGetNewUnicode);
    FreeAndNil(JSON);
    DisConnect;
  end;

  result := TJSONObject.ParseJSONValue( resultText, False, True) as TJSONObject;



end;



function Rest1s.updateGetRateBonus(JsonText: String): TJSONObject;
var
  Queryfn_in_group_goods: TFDQuery;
  QueryListidGroup: TFDQuery;
  Queryfn_get_bonus_rate: TFDQuery;

  JSON:TJSONObject;
  JSonValue:TJSONValue;
  ErrorDescription: AnsiString;
  N:integer;

  resultText : string;
  RateBonusCard:TRateBonusCard;

  ParamCodeCard, ParamProduct_id, ParamShop_id:string;
  tempidgroup, idgroup:String;
  resInGroup:Integer;
begin
  Connect();

  ErrorDescription := '';
  idgroup:='';

  Queryfn_in_group_goods:= TFDQuery.Create(nil);
  Queryfn_in_group_goods.Connection :=  FDConnection;
  Queryfn_in_group_goods.SQL.Text := SqlList['fn_in_group_goods'];

  QueryListidGroup:= TFDQuery.Create(nil);
  QueryListidGroup.Connection :=  FDConnection;
  QueryListidGroup.SQL.Text := SqlList['QueryListidGroup'];

  Queryfn_get_bonus_rate:= TFDQuery.Create(nil);
  Queryfn_get_bonus_rate.Connection :=  FDConnection;
  Queryfn_get_bonus_rate.SQL.Text := SqlList['Queryfn_get_bonus_rate'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  try

    JSonValue := Json.FindValue('codeCard');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;
    ParamCodeCard := JSonValue.Value;

    JSonValue := Json.FindValue('product_id');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;
    ParamProduct_id := JSonValue.Value;

    JSonValue := Json.FindValue('shop_id');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamShop_id := JSonValue.Value;

    RateBonusCard.BarCode :=  ParamCodeCard;
    RateBonusCard.idGoods :=  ParamProduct_id;
    RateBonusCard.idShop :=  ParamShop_id;
    RateBonusCard.BonusRate := 0;
    RateBonusCard.AmtAction:=0;
    RateBonusCard.AmtSale:=0;
    RateBonusCard.ActionId :=0;
    RateBonusCard.extCodeAction := '';
    RateBonusCard.BonusRate := 0;


    try
      QueryListidGroup.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Нет подключения к серверу базы данных');
      end;
    end;

    QueryListidGroup.Last;
    if QueryListidGroup.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;



      QueryListidGroup.First;

      while not QueryListidGroup.Eof do
      begin
        tempidgroup:=   QueryListidGroup.FieldByName('idgroup').AsString;
        resInGroup:=0;

        Queryfn_in_group_goods.SQL.Text := 'SELECT fn_in_group_goods('''+ParamProduct_id+''','''+tempidgroup+''') as res ';

        try
          Queryfn_in_group_goods.Open;
          Queryfn_in_group_goods.First;
          resInGroup := Queryfn_in_group_goods.FieldByName('res').AsInteger;
        except
          Raise Exception.Create('Нет данных');
        end;

        if resInGroup=1 then
        begin
          idgroup:= tempidgroup;
          break;
        end;

        QueryListidGroup.Next;
      end;


    if idgroup<>'' then
    begin

      Queryfn_get_bonus_rate.ParamByName('codeCard').Value := ParamCodeCard;
      Queryfn_get_bonus_rate.ParamByName('idgroup').Value := idgroup;

      try
        Queryfn_get_bonus_rate.Open;
      except
        on E: Exception do
        begin
           Raise Exception.Create('Ошибка выполнения запроса');
        end;
      end;

      Queryfn_get_bonus_rate.First;

      if Queryfn_get_bonus_rate.RecordCount > 0  then
        RateBonusCard.BonusRate := Queryfn_get_bonus_rate.FieldByName('rate').AsFloat;

    end else

    begin

      RateBonusCard.BonusRate :=0;

    end;

  finally
    FreeAndNil(Queryfn_in_group_goods);
    FreeAndNil(QueryListidGroup);
    FreeAndNil(Queryfn_get_bonus_rate);
    FreeAndNil(JSON);
    DisConnect;
  end;


  FillRateBonusAction(RateBonusCard, FDConnection);

  resultText := RateBonusCardToJSON(0, 'OK', RateBonusCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;

function Rest1s.updateGet_Partners_jurnal(JsonText: String): TJSONObject;
var
  QueryGet_Partners_jurnal: TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  begdate, enddate:string;
  JurPartner:TJurParnerList;
begin
  Connect;
  ErrorDescription := '';

  QueryGet_Partners_jurnal:= TFDQuery.Create(nil);
  QueryGet_Partners_jurnal.Connection :=  FDConnection;
  QueryGet_Partners_jurnal.SQL.Text := SqlList['Get_Partners_jurnal'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try
    JSonValue := Json.FindValue('begdate');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;
    begdate := JSonValue.Value;

    JSonValue := Json.FindValue('enddate');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    enddate := JSonValue.Value;

    QueryGet_Partners_jurnal.Active := False;
    QueryGet_Partners_jurnal.ParamByName('begdate').Value := begdate;
    QueryGet_Partners_jurnal.ParamByName('enddate').Value := enddate;


    try
      QueryGet_Partners_jurnal.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    QueryGet_Partners_jurnal.Last;
    SetLength(JurPartner, QueryGet_Partners_jurnal.RecordCount);
    N:=0;

    QueryGet_Partners_jurnal.First;

     with QueryGet_Partners_jurnal do
     begin
        while not Eof do
        begin
          JurPartner[N].dateCreate    := FieldByName('datecreate').AsDateTime;
          JurPartner[N].codeCard      := FieldByName('codecard').AsString;
          JurPartner[N].codePartner   := FieldByName('codepartner').AsString;
          JurPartner[N].amount        := FieldByName('amount').AsFloat;
          Next;
          N:=N+1;
        end;
     end;

  finally
    FreeAndNil(QueryGet_Partners_jurnal);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := TJurParnerListToJSON(0, 'ОК', JurPartner);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;



function Rest1s.updateWrite_dc_engine_pay_moyka(JsonText: String): TJSONObject;
var
  dc_engine_pay_moyka: Tdc_engine_pay_moyka;
  ErrorDescription: AnsiString;
begin

  JsonText := IdURI.TIdURI.URLDecode(JsonText);

  Connect;
  try
    if JSONToTdc_engine_pay_moyka(JsonText, dc_engine_pay_moyka) then
    begin

       if WriteToMySQL_dc_engine_pay_moyka(dc_engine_pay_moyka, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin
      Raise Exception.Create('Ошибка чтения контекста');
    end;

  finally
      DisConnect;
  end;



end;


function Rest1s.updateWrite_dc_enginecards(JsonText: String): TJSONObject;
var
  dc_enginecards: Tdc_enginecards;
  ErrorDescription: AnsiString;
begin

  JsonText := IdURI.TIdURI.URLDecode(JsonText);

  Connect;
  try
    if JSONToTdc_enginecards(JsonText, dc_enginecards) then
    begin

       if WriteToMySQL_ddc_enginecards(dc_enginecards, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin
      Raise Exception.Create('Ошибка чтения контекста');
    end;

  finally
      DisConnect;
  end;



end;



function Rest1s.updateWrite_dc_enginefixcards_moyka( JsonText: String): TJSONObject;
var
  dc_enginefixcards_moyka: Tdc_enginefixcards_moyka;
  ErrorDescription: AnsiString;
begin

  JsonText := IdURI.TIdURI.URLDecode(JsonText);

  Connect;
  try
    if JSONToTdc_enginefixcards_moyka(JsonText, dc_enginefixcards_moyka) then
    begin

       if WriteToMySQL_dc_enginefixcards_moyka(dc_enginefixcards_moyka, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin
      Raise Exception.Create('Ошибка чтения контекста');
    end;

  finally
      DisConnect;
  end;

end;

function Rest1s.updateWrite_dc_enginedebit_moyka( JsonText: String): TJSONObject;
var
  dc_enginedebit_moyka: Tdc_enginedebit_moyka;
  ErrorDescription: AnsiString;
begin

  JsonText := IdURI.TIdURI.URLDecode(JsonText);

  Connect;
  try
    if JSONToTdc_enginedebit_moyka(JsonText, dc_enginedebit_moyka) then
    begin

       if WriteToMySQL_dc_enginedebit_moyka(dc_enginedebit_moyka, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin
      Raise Exception.Create('Ошибка чтения контекста');
    end;

  finally
      DisConnect;
  end;

end;





function Rest1s.updateWrite_Person(JsonText: String): TJSONObject;
var
  InfoPersone: TInfoPersone;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    InfoPersone.toWrite := 0;
    if JSONToTInfoPersone(JsonText, InfoPersone) then
    begin

       if WriteToMySQL_Person(InfoPersone, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;

end;

function Rest1s.updateWrite_Person_AddInfo(JsonText: String): TJSONObject;
var
  PersoneAddInfo: TPersoneAddInfo;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    if JSONToTPersoneAddInfo(JsonText, PersoneAddInfo) then
    begin
       PersoneAddInfo.rewrite := 0;
       if WriteToMySQL_PersoneAddInfo(PersoneAddInfo, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;

end;


function Rest1s.updateWrite_CardPerson(JsonText: String): TJSONObject;
var
  Card: TCard;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    if JSONToTCard(JsonText, Card) then
    begin
       Card.toWrite := 0;
       if WriteToMySQL_CardPerson(Card, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;
end;

function Rest1s.updateWrite_Goods(JsonText: String): TJSONObject;
var
  infoGoods: TInfoGoods;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    if JSONToTInfoGoods(JsonText, infoGoods) then
    begin

       if WriteToMySQL_Goods(infoGoods, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;

end;


function Rest1s.updateWrite_GroupGoods(JsonText: String): TJSONObject;
var
  infoGroupGoods: TInfoGroupGoods;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    if JSONToTInfoGroupGoods(JsonText, infoGroupGoods) then
    begin

       if WriteToMySQL_GroupGoods(infoGroupGoods, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;

end;



function Rest1s.updateGetChangesPersonList(JsonText: String): TJSONObject;
var
  QueryGetChangesPersonList: TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  PersonList:TPersonList;
begin
  Connect;
  ErrorDescription := '';

  QueryGetChangesPersonList:= TFDQuery.Create(nil);
  QueryGetChangesPersonList.Connection :=  FDConnection;
  QueryGetChangesPersonList.SQL.Text := SqlList['GetChangesPersonList'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try

    QueryGetChangesPersonList.Active := False;

    try
      QueryGetChangesPersonList.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    QueryGetChangesPersonList.Last;
    SetLength(PersonList, QueryGetChangesPersonList.RecordCount);
    N:=0;

    QueryGetChangesPersonList.First;

     with QueryGetChangesPersonList do
     begin
        while not Eof do
        begin
          PersonList[N].idcode  := FieldByName('idcode').AsString;
          PersonList[N].name    := FieldByName('idname').AsString;
          PersonList[N].phone   := FieldByName('phone').AsString;
          PersonList[N].f       := FieldByName('f').AsString;
          PersonList[N].i       := FieldByName('i').AsString;
          PersonList[N].o       := FieldByName('o').AsString;
          PersonList[N].birthday       := FieldByName('birthday').AsDateTime;
          PersonList[N].sex     := FieldByName('sex').AsString;
          PersonList[N].idGroup := FieldByName('idgroup').AsString;
          PersonList[N].guid    := FieldByName('guid').AsString;
          PersonList[N].ReferralCode    := FieldByName('ReferralCode').AsInteger;
          PersonList[N].ReferralCodeInvitation    := FieldByName('ReferralCodeInvitation').AsInteger;

          Next;
          N:=N+1;
        end;
     end;

  finally
    FreeAndNil(QueryGetChangesPersonList);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := PersonListToJSON(0, 'ОК', PersonList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Rest1s.updateGetChangesCardList(JsonText: String): TJSONObject;
var
  QueryGetChangesPersonCardList: TFDQuery;


  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  PersonCardList:TPersonCardList;
begin
  Connect;
  ErrorDescription := '';

  QueryGetChangesPersonCardList:= TFDQuery.Create(nil);
  QueryGetChangesPersonCardList.Connection :=  FDConnection;
  QueryGetChangesPersonCardList.SQL.Text := SqlList['GetChangesPersonCardList'];



  try

    QueryGetChangesPersonCardList.Active := False;

    try
      QueryGetChangesPersonCardList.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    QueryGetChangesPersonCardList.Last;
    SetLength(PersonCardList, QueryGetChangesPersonCardList.RecordCount);
    N:=0;

    QueryGetChangesPersonCardList.First;

     with QueryGetChangesPersonCardList do
     begin
        while not Eof do
        begin
          PersonCardList[N].idcode    := FieldByName('idcode').AsString;
          PersonCardList[N].idname    := FieldByName('idname').AsString;
          PersonCardList[N].codecard  := FieldByName('codcart').AsString;
          PersonCardList[N].ownercart := FieldByName('ownercart').AsString;
          PersonCardList[N].rfid      := FieldByName('rfid').AsString;
          PersonCardList[N].idgroup   := FieldByName('idgroup').AsString;
          PersonCardList[N].level     := FieldByName('level').AsString;
          PersonCardList[N].isOnlineReg     := FieldByName('isOnlineReg').AsInteger;
          PersonCardList[N].guid    := FieldByName('guid').AsString;

          Next;
          N:=N+1;
        end;
     end;

  finally
    FreeAndNil(QueryGetChangesPersonCardList);

    DisConnect;
  end;

  resultText := PersonCardListToJSON(0, 'ОК', PersonCardList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Rest1s.updateUpload_paymentreceipt(JsonText: string): TJSONObject;
var
  resultText : string;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  UploadedData : AnsiString;
  Fs : TFileStream;
  FileName : String;
  BytesFile:TBytes;
begin
  try
    JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

    JSonValue := Json.FindValue('filename');
    if JSonValue <> nil then
    begin
      FileName := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('UploadedData');
    if JSonValue <> nil then
    begin
      UploadedData := JSonValue.Value;
    end;

  finally
    FreeAndNil(JSON);
  end;

  CreateDir(GetCurrentDir() + dirReceiptFiles);

  FileName := GetCurrentDir() + dirReceiptFiles + '\' +FileName;
  if not FileExists(FileName) then
    Fs := TFileStream.Create(FileName, fmCreate)
  else
   Fs := TFileStream.Create(FileName, fmOpenWrite);

  BytesFile := DecodeBase64(UploadedData);

  //UploadedData := DecodeString(Trim(UploadedData));

  try
    Fs.Write(BytesFile, Length(BytesFile));
  finally
    FreeAndNil(Fs);
  end;


  Result := ResultOkToJSON();
end;




function Rest1s.updateGetOnlineRegData(JsonText: String): TJSONObject;
var
  QueryGetOnlineRegData: TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  OnlineRegDataList:TOnlineRegDataList;
begin
  Connect;
  ErrorDescription := '';

  QueryGetOnlineRegData:= TFDQuery.Create(nil);
  QueryGetOnlineRegData.Connection :=  FDConnection;
  QueryGetOnlineRegData.SQL.Text := SqlList['GetOnlineRegData'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try

    QueryGetOnlineRegData.Active := False;

    try
      QueryGetOnlineRegData.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    QueryGetOnlineRegData.Last;
    SetLength(OnlineRegDataList, QueryGetOnlineRegData.RecordCount);
    N:=0;

    QueryGetOnlineRegData.First;

     with QueryGetOnlineRegData do
     begin
        while not Eof do
        begin
          OnlineRegDataList[N].idCard       := FieldByName('idCard').AsString;
          OnlineRegDataList[N].dateOfReg    := FieldByName('dateOfReg').AsDateTime;
          OnlineRegDataList[N].phone        := FieldByName('phone').AsString;
          OnlineRegDataList[N].codecard     := FieldByName('codecard').AsString;

          Next;
          N:=N+1;

        end;
     end;

  finally
    FreeAndNil(QueryGetOnlineRegData);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := OnlineRegDataListToJSON(0, 'ОК', OnlineRegDataList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;

function Rest1s.updateWrite_OnlineRegData(JsonText: String): TJSONObject;
var
  OnlineRegData: TOnlineRegData;
  ErrorDescription: AnsiString;
begin

  Connect;
  try
    if JSONToTOnlineRegData(JsonText, OnlineRegData) then
    begin

       if UpdateMySQL_OnlineRegData(OnlineRegData, ErrorDescription, FDConnection) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnect;
  end;

end;


function Rest1s.updateGetYandexPurchaseList(JsonText: String): TJSONObject;
 var
  GetYandexPurchaseNotReWrite: TFDQuery;

  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  YandexPurchaseList:TYandexPurchaseList;
begin

  ConnectYandex;
  ErrorDescription := '';

  GetYandexPurchaseNotReWrite:= TFDQuery.Create(nil);
  GetYandexPurchaseNotReWrite.Connection :=  FDConnectionYandex;
  GetYandexPurchaseNotReWrite.SQL.Text := SqlList['GetYandexPurchaseNotReWrite'];



  try

    GetYandexPurchaseNotReWrite.Active := False;

    try
      GetYandexPurchaseNotReWrite.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    GetYandexPurchaseNotReWrite.Last;
    SetLength(YandexPurchaseList, GetYandexPurchaseNotReWrite.RecordCount);
    N:=0;

    GetYandexPurchaseNotReWrite.First;

     with GetYandexPurchaseNotReWrite do
     begin
        while not Eof do
        begin
          YandexPurchaseList[N].cardNo                := FieldByName('cardNo').AsString;
          YandexPurchaseList[N].orderId               := FieldByName('orderId').AsString;
          YandexPurchaseList[N].orderExtendedId       := FieldByName('orderExtendedId').AsString;
          YandexPurchaseList[N].stationExtendedId     := FieldByName('stationExtendedId').AsString;
          YandexPurchaseList[N].fuelId                := FieldByName('fuelId').AsString;
          YandexPurchaseList[N].cost            := FieldByName('cost').AsFloat;
          YandexPurchaseList[N].count           := FieldByName('count').AsFloat;
          YandexPurchaseList[N].orderDateUtc    := FieldByName('orderDateUtc').AsDateTime;
          YandexPurchaseList[N].orderDateLocal  := FieldByName('orderDateLocal').AsDateTime;


          Next;
          N:=N+1;
        end;
     end;

  finally
    FreeAndNil(GetYandexPurchaseNotReWrite);

    DisConnectYandex;
  end;

  resultText := YandexPurchaseListToJSON(0, 'ОК', YandexPurchaseList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;


function Rest1s.updateWrite_YandexPurchaseAnswer(JsonText: String): TJSONObject;
var
  YandexPurchaseAnswer: TYandexPurchaseAnswer;
  ErrorDescription: AnsiString;
begin

  ConnectYandex;
  try
    if JSONToTYandexPurchaseAnswer(JsonText, YandexPurchaseAnswer) then
    begin
       if UpdateMySQL_YandexPurchaseAnswer(YandexPurchaseAnswer, ErrorDescription, FDConnectionYandex) then
       begin
           Result := ResultOkToJSON();
       end
       else
       begin
          Raise Exception.Create(ErrorDescription);
       end;

    end else

    begin

      Raise Exception.Create('Ошибка чтения контекста');

    end;

  finally
    DisConnectYandex;
  end;

end;

function Rest1s.updateGetChangesPersonsAddinfo(JsonText: String): TJSONObject;
var
  QueryGetChangesPersonsAddinfo: TFDQuery;


  ErrorDescription: AnsiString;
  N:integer;
  resultText : string;

  PersoneAddInfoList:TPersoneAddInfoList;
begin
  Connect;
  ErrorDescription := '';

  QueryGetChangesPersonsAddinfo:= TFDQuery.Create(nil);
  QueryGetChangesPersonsAddinfo.Connection :=  FDConnection;
  QueryGetChangesPersonsAddinfo.SQL.Text := SqlList['GetChangesPersonsAddinfo'];



  try

    QueryGetChangesPersonsAddinfo.Active := False;

    try
      QueryGetChangesPersonsAddinfo.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;


    QueryGetChangesPersonsAddinfo.Last;
    SetLength(PersoneAddInfoList, QueryGetChangesPersonsAddinfo.RecordCount);
    N:=0;

    QueryGetChangesPersonsAddinfo.First;

     with QueryGetChangesPersonsAddinfo do
     begin
        while not Eof do
        begin
          PersoneAddInfoList[N].idCode      := FieldByName('idCode').AsString;
          PersoneAddInfoList[N].phone       := FieldByName('phone').AsString;
          PersoneAddInfoList[N].Email       := FieldByName('EMail').AsString;
          PersoneAddInfoList[N].sendReceipt := FieldByName('sendReceipt').AsInteger;
          PersoneAddInfoList[N].CityOfResidence      := FieldByName('CityOfResidence').AsString;
          Next;
          N:=N+1;
        end;
     end;

  finally
    FreeAndNil(QueryGetChangesPersonsAddinfo);

    DisConnect;
  end;

  resultText := PersoneAddInfoListToJSON(0, 'ОК', PersoneAddInfoList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;

function Rest1s.GetReferralCode(const JsonText: string): TJSONObject;
begin
   Result := DescriptionErrorToJSON(2, 'use POST query');
end;

function Rest1s.updateGetReferralCode(JsonText: String): TJSONObject;
var
  QueryGetReferralCode: TFDQuery;
  JSON:TJSONObject;
  ReferralCode:integer;
  resultText : string;
begin

  Connect();
  QueryGetReferralCode :=  TFDQuery.Create(nil);
  QueryGetReferralCode.Connection :=  FDConnection;
  QueryGetReferralCode.SQL.Text := SqlList['GetReferralCode'];


  try



    QueryGetReferralCode.Active := False;

    try
      QueryGetReferralCode.Open;
    except
      on E: Exception do
      begin
        Raise Exception.Create('Ошибка выполнения запроса');
      end;
    end;

    QueryGetReferralCode.Last;

    if QueryGetReferralCode.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetReferralCode.First;
    ReferralCode := QueryGetReferralCode.FieldByName('unicode').AsInteger;


    resultText :=  '{"ErrorCode": 0'+
                    ', "Result": "OK"' +
                    ', "ReferralCode": '+IntToStr(ReferralCode)+'' +
                    '}';
  finally
    FreeAndNil(QueryGetReferralCode);
    DisConnect;
  end;

  result := TJSONObject.ParseJSONValue( resultText, False, True) as TJSONObject;



end;

Function Rest1s.updateGetBirthdayList(JsonText: String): TJSONObject;
var
  QueryBirthdayList: TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  paramDateQuery : string;
  N:integer;
  BirthdayCardList:TBirthdayCardList;
  resultText : string;
begin

  Connect;
  QueryBirthdayList := TFDQuery.Create(nil);
  QueryBirthdayList.Connection :=  FDConnection;
  QueryBirthdayList.SQL.Text := SqlList['GetBirthdayList'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  try
      JSonValue := Json.FindValue('datequery');
      if JSonValue = nil then
      begin
        Raise Exception.Create('Не верные параметры запроса');
      end;
      paramDateQuery := JSonValue.Value;

      QueryBirthdayList.Active := False;
      QueryBirthdayList.Params[0].Value := paramDateQuery;
      try
        QueryBirthdayList.Open;
      except
        Raise Exception.Create('Ошибка выполнения запроса');
      end;

      QueryBirthdayList.Last;

      N:=0;
      SetLength(BirthdayCardList, QueryBirthdayList.RecordCount);
      QueryBirthdayList.First;
      while not QueryBirthdayList.Eof do
      begin
        with QueryBirthdayList do
        begin
            BirthdayCardList[N].birthday       := FieldByName('birthday').AsDateTime;
            BirthdayCardList[N].namePerson     := FieldByName('PersonName').AsString;
            BirthdayCardList[N].codecard       := FieldByName('CodeCard').AsString;
            BirthdayCardList[N].idCard         := FieldByName('idCard').AsString;


        end;

        QueryBirthdayList.Next;

        N:=N+1;
      end;


  finally
     FreeAndNil(QueryBirthdayList);
     FreeAndNil(JSON);
     DisConnect;
  end;

  resultText := TBirthdayCardListToJSON(0, 'ОК', BirthdayCardList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


Procedure Rest1s.Connect();

var
  ErrorDescription: AnsiString;
  ResultConnect : Boolean;

begin

  if FDConnection = nil then
  FDConnection:= TFDConnection.Create(nil);

  if FDConnection.Connected then
  begin
    exit;
  end;

  FClientMySQLSet.ServerAdress:=  SettingProgram.ServerAdressMySQL;
  FClientMySQLSet.Login:=  SettingProgram.LoginMySQL;
  FClientMySQLSet.Uinpromt:=  SettingProgram.PassWordMySQL;
  FClientMySQLSet.DataBase:=  SettingProgram.DataBaseMySQL;
  FClientMySQLSet.Port:=  SettingProgram.PortMySQL;

  ResultConnect :=  ConnectToServer(ErrorDescription, FDConnection, FClientMySQLSet);

  if not ResultConnect then
      Raise Exception.Create('Ошибка подключения к базе данных');
end;

Procedure Rest1s.DisConnect;
begin
  FDConnection.Connected := false;
  FreeAndNil(FDConnection);
end;


Procedure Rest1s.ConnectYandex();

var
  ErrorDescription: AnsiString;
  ResultConnect : Boolean;

begin

  if FDConnectionYandex = nil then
  FDConnectionYandex:= TFDConnection.Create(nil);

  if FDConnectionYandex.Connected then
  begin
    exit;
  end;

  FClientYandexMySQLSet.ServerAdress:=  SettingProgram.YandexServerBD;
  FClientYandexMySQLSet.Login:=         SettingProgram.YandexLoginBD;
  FClientYandexMySQLSet.Uinpromt:=      SettingProgram.YandexPassBD;
  FClientYandexMySQLSet.DataBase:=      SettingProgram.YandexNameBD;
  FClientYandexMySQLSet.Port:=          SettingProgram.YandexPortBD;

  ResultConnect :=  ConnectToServer(ErrorDescription, FDConnectionYandex, FClientYandexMySQLSet);

  if not ResultConnect then
      Raise Exception.Create('Ошибка подключения к базе данных Yandex');
end;

Procedure Rest1s.DisConnectYandex;
begin
  FDConnectionYandex.Connected := false;
  FreeAndNil(FDConnectionYandex);
end;






end.
