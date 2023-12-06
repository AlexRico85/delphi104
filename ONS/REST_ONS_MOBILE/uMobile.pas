unit uMobile;

interface

uses
  System.SysUtils, System.StrUtils, System.Math, FireDAC.Comp.Client, System.Classes, structures, System.JSON, FireDAC.DApt,
  Datasnap.DSAuth;
type
    {$METHODINFO ON}
  [TRoleAuth('admin')]
  Mobile = class(TComponent)
    FDConnection: TFDConnection;
  private
    FClientMySQLSet:TClientMySQLSet;
    Procedure Connect();
    Procedure DisConnect();
  public
    { Public declarations }
    function updateGetCardListByPhone(JsonText: String): TJSONObject;
    function updateGetCardByPhone(JsonText: String): TJSONObject;
    function updateGetCardByCode(JsonText: String): TJSONObject;
    function updateGetTransactionListBonus(JsonText: String): TJSONObject;
    function updateGetInfoBonusCard(JsonText: String): TJSONObject;
    function updateRegisteringNewCard(JsonText: String): TJSONObject;
    function updateGetBonusRateTable(JsonText: String): TJSONObject;
    function updateGetTransactionListBonusByCard(JsonText: String): TJSONObject;
    function updatePrepaymentCarWash(JsonText: String): TJSONObject;
    function updateGetLastSales10Minutes(JsonText: String): TJSONObject;
    function updateGetSalesForLastMonth(JsonText: String): TJSONObject;
    function updateGetSalesForCurrentYear(JsonText: String): TJSONObject;
    function updateGetSalesForCurrentWeek(JsonText: String): TJSONObject;
    function updateStatisticSalesOfCardsForWeek(JsonText: String): TJSONObject;
    [TRoleAuth('admin')]
    function updateUpdate_person_addInfo(JsonText: String): TJSONObject;
  end;
{$METHODINFO OFF}

implementation

uses FunctionMySQL, JsonSerialization, uLog, uSqlList,
  frmSettingUnit, uWriteDataSQL;

{ Mobile }

function Mobile.updateGetBonusRateTable(JsonText: String): TJSONObject;
var
  QueryGetBonusRateTable:TFDQuery;
//  JSON:TJSONObject;
//  JSonPhone:TJSONValue;

  BonusRateTable: TBonusRateTable;

  N:integer;
  resultText : string;
begin
  Connect;
  QueryGetBonusRateTable := TFDQuery.Create(nil);
  QueryGetBonusRateTable.Connection :=  FDConnection;
  QueryGetBonusRateTable.SQL.Text := SqlList['GetBonusRateTable'];

  //JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try


    try
      QueryGetBonusRateTable.Open;
      QueryGetBonusRateTable.Last;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;



    if QueryGetBonusRateTable.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    N:=0;
    SetLength(BonusRateTable, QueryGetBonusRateTable.RecordCount);
    QueryGetBonusRateTable.First;

    while not QueryGetBonusRateTable.Eof do
    begin

      BonusRateTable[N].NameGoods   :=  QueryGetBonusRateTable.FieldByName('NameGoods').AsString;
      BonusRateTable[N].idCoogs     :=  QueryGetBonusRateTable.FieldByName('idCoogs').AsString;
      BonusRateTable[N].downAmt     :=  QueryGetBonusRateTable.FieldByName('downAmt').AsFloat;
      BonusRateTable[N].upAmt       :=  QueryGetBonusRateTable.FieldByName('upAmt').AsFloat;
      BonusRateTable[N].rate        :=  QueryGetBonusRateTable.FieldByName('rate').AsFloat;
      BonusRateTable[N].periodType  :=  QueryGetBonusRateTable.FieldByName('periodType').AsInteger;

      if BonusRateTable[N].periodType = 0  then
        BonusRateTable[N].periodStr   :=  'За весь период'
      else if BonusRateTable[N].periodType = 1  then
        BonusRateTable[N].periodStr   :=  'Прошлый месяц'
      else
        BonusRateTable[N].periodStr   :=  'Не определен';


      QueryGetBonusRateTable.Next;

      N:=N+1;
    end;

  finally
    FreeAndNil(QueryGetBonusRateTable);
   // FreeAndNil(JSON);
    DisConnect;
  end;

  resultText:= BonusRateTableToJSON(0, 'OK', BonusRateTable);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;

function Mobile.updateGetCardByPhone(JsonText: String): TJSONObject;
var
  QueryGetCartListByPhone:TFDQuery;
  JSON:TJSONObject;
  JSonPhone:TJSONValue;
  ErrorDescription: AnsiString;
  ParamPhone:string;
  RecordCard: TRecordCardList;
  resultText : string;
begin
  Connect;
  QueryGetCartListByPhone := TFDQuery.Create(nil);
  QueryGetCartListByPhone.Connection :=  FDConnection;
  QueryGetCartListByPhone.SQL.Text := SqlList['GetCartListByPhone'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  JSonPhone := Json.FindValue('phone');
  try
    if JSonPhone = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamPhone := JSonPhone.Value;

    QueryGetCartListByPhone.Active := False;
    QueryGetCartListByPhone.Params[0].Value := '%'+AnsiRightStr(ParamPhone, 10)+'%';

    try
      QueryGetCartListByPhone.Open;
    except
      Raise Exception.Create('Нет подключения к серверу базы данных');
    end;


    if QueryGetCartListByPhone.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetCartListByPhone.First;
    while not QueryGetCartListByPhone.Eof do
    begin

      RecordCard.idOwner :=  QueryGetCartListByPhone.FieldByName('idOwner').AsString;
      RecordCard.phone   :=  QueryGetCartListByPhone.FieldByName('phone').AsString;
      RecordCard.f       :=  QueryGetCartListByPhone.FieldByName('f').AsString;
      RecordCard.i       :=  QueryGetCartListByPhone.FieldByName('i').AsString;
      RecordCard.o       :=  QueryGetCartListByPhone.FieldByName('o').AsString;
      RecordCard.Email   :=  QueryGetCartListByPhone.FieldByName('EMail').AsString;
      RecordCard.birthday :=  QueryGetCartListByPhone.FieldByName('birthday').AsDateTime;
      RecordCard.idCard   :=  QueryGetCartListByPhone.FieldByName('idCard').AsString;
      RecordCard.codeCard :=  QueryGetCartListByPhone.FieldByName('codeCard').AsString;
      RecordCard.dateOfUse   := QueryGetCartListByPhone.FieldByName('DateOfUSE').AsDateTime;
      RecordCard.sendReceipt := QueryGetCartListByPhone.FieldByName('sendReceipt').AsInteger;
      RecordCard.ReferralCode := QueryGetCartListByPhone.FieldByName('ReferralCode').AsInteger;
      RecordCard.ReferralCodeInvitation := QueryGetCartListByPhone.FieldByName('ReferralCodeInvitation').AsInteger;
       break;
    end;

  finally
    FreeAndNil(QueryGetCartListByPhone);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText:= CardInfoToJSON(0, 'OK', RecordCard);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Mobile.updateGetCardByCode(JsonText: String): TJSONObject;
var
  GetCartListByCode:TFDQuery;
  JSON:TJSONObject;
  JSonPhone:TJSONValue;
  ErrorDescription: AnsiString;
  ParamCodeCard:string;
  RecordCard: TRecordCardList;
  resultText : string;
begin
  Connect;
  GetCartListByCode := TFDQuery.Create(nil);
  GetCartListByCode.Connection :=  FDConnection;
  GetCartListByCode.SQL.Text := SqlList['GetCartListByCode'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  JSonPhone := Json.FindValue('codecard');
  try
    if JSonPhone = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamCodeCard := JSonPhone.Value;

    GetCartListByCode.Active := False;
    GetCartListByCode.ParamByName('CodeCard').Value := '%'+ParamCodeCard+'%';

    try
      GetCartListByCode.Open;
    except
      Raise Exception.Create('Нет подключения к серверу базы данных');
    end;


    if GetCartListByCode.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    GetCartListByCode.First;
    while not GetCartListByCode.Eof do
    begin

      RecordCard.idOwner :=  GetCartListByCode.FieldByName('idOwner').AsString;
      RecordCard.phone   :=  GetCartListByCode.FieldByName('phone').AsString;
      RecordCard.f       :=  GetCartListByCode.FieldByName('f').AsString;
      RecordCard.i       :=  GetCartListByCode.FieldByName('i').AsString;
      RecordCard.o       :=  GetCartListByCode.FieldByName('o').AsString;
      RecordCard.Email   :=  GetCartListByCode.FieldByName('EMail').AsString;
      RecordCard.birthday :=  GetCartListByCode.FieldByName('birthday').AsDateTime;
      RecordCard.idCard   :=  GetCartListByCode.FieldByName('idCard').AsString;
      RecordCard.codeCard :=  GetCartListByCode.FieldByName('codeCard').AsString;
      RecordCard.dateOfUse   := GetCartListByCode.FieldByName('DateOfUSE').AsDateTime;
      RecordCard.sendReceipt := GetCartListByCode.FieldByName('sendReceipt').AsInteger;
      RecordCard.ReferralCode := GetCartListByCode.FieldByName('ReferralCode').AsInteger;
      RecordCard.ReferralCodeInvitation := GetCartListByCode.FieldByName('ReferralCodeInvitation').AsInteger;
       break;
    end;

  finally
    FreeAndNil(GetCartListByCode);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText:= CardInfoToJSON(0, 'OK', RecordCard);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Mobile.updateGetCardListByPhone(JsonText: String): TJSONObject;
var
  QueryGetCartListByPhone:TFDQuery;
  JSON:TJSONObject;
  JSonPhone:TJSONValue;

  ParamPhone:string;
  CardList: TCardList;
  N:integer;
  resultText : string;
begin
  Connect;
  QueryGetCartListByPhone := TFDQuery.Create(nil);
  QueryGetCartListByPhone.Connection :=  FDConnection;
  QueryGetCartListByPhone.SQL.Text := SqlList['GetCartListByPhone'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  JSonPhone := Json.FindValue('phone');
  try
    if JSonPhone = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamPhone := JSonPhone.Value;

    QueryGetCartListByPhone.Active := False;
    QueryGetCartListByPhone.Params[0].Value := '%'+ParamPhone+'%';

    try
      QueryGetCartListByPhone.Open;
    except
      Raise Exception.Create('Нет подключения к серверу базы данных');
    end;

    QueryGetCartListByPhone.Last;

    if QueryGetCartListByPhone.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    N:=0;
    SetLength(CardList, QueryGetCartListByPhone.RecordCount);
    QueryGetCartListByPhone.First;
    while not QueryGetCartListByPhone.Eof do
    begin
      CardList[N].idOwner :=  QueryGetCartListByPhone.FieldByName('idOwner').AsString;
      CardList[N].phone   :=  QueryGetCartListByPhone.FieldByName('phone').AsString;
      CardList[N].f       :=  QueryGetCartListByPhone.FieldByName('f').AsString;
      CardList[N].i       :=  QueryGetCartListByPhone.FieldByName('i').AsString;
      CardList[N].o       :=  QueryGetCartListByPhone.FieldByName('o').AsString;
      CardList[N].Email   :=  QueryGetCartListByPhone.FieldByName('EMail').AsString;
      CardList[N].birthday :=  QueryGetCartListByPhone.FieldByName('birthday').AsDateTime;
      CardList[N].idCard   :=  QueryGetCartListByPhone.FieldByName('idCard').AsString;
      CardList[N].codeCard :=  QueryGetCartListByPhone.FieldByName('codeCard').AsString;
      CardList[N].dateOfUse := QueryGetCartListByPhone.FieldByName('DateOfUSE').AsDateTime;
      CardList[N].sendReceipt := QueryGetCartListByPhone.FieldByName('sendReceipt').AsInteger;

      N:=N+1;
      QueryGetCartListByPhone.Next;

    end;

  finally
    FreeAndNil(QueryGetCartListByPhone);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText:= CardListToJSON(0, 'OK', CardList);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;

function Mobile.updateGetInfoBonusCard(JsonText: String): TJSONObject;
var
  QueryGetParamCard:TFDQuery;
  QueryGetInfoBonus:TFDQuery;
  QueryLastPurchases:TFDQuery;
  QueryLastYearPurchases:TFDQuery;
  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamIdCard, ParamCodeCard, ParamIdGroup :string;
  RinfoBonuxCard: TinfoBonuxCard;
  resultText : string;
begin

  ParamIdCard := '';
  ParamCodeCard := '';
  ParamIdGroup := '';

  Connect;
  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetInfoBonus := TFDQuery.Create(nil);
  QueryGetInfoBonus.Connection :=  FDConnection;
  QueryGetInfoBonus.SQL.Text := SqlList['GetInfoBonusMobile'];

  QueryLastPurchases := TFDQuery.Create(nil);
  QueryLastPurchases.Connection :=  FDConnection;
  QueryLastPurchases.SQL.Text := SqlList['LastMonthSasolinePurchases'];

  QueryLastYearPurchases := TFDQuery.Create(nil);
  QueryLastYearPurchases.Connection :=  FDConnection;
  QueryLastYearPurchases.SQL.Text := SqlList['LastYearSasolinePurchases'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

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
      Raise Exception.Create('Не верные параметры запроса');
    end;

    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';

    if ParamCodeCard='' then
       ParamCodeCard := '999999999999999999999999999999';

    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');


    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    QueryGetInfoBonus.Active := False;
    QueryGetInfoBonus.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetInfoBonus.Params.FindParam('IDCARD').Value := ParamIdCard;
    QueryGetInfoBonus.Params.FindParam('IDGROUPGOODS').Value := ParamIdGroup;

    try
      QueryGetInfoBonus.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetInfoBonus.Last;

    if QueryGetInfoBonus.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetInfoBonus.First;

    with   QueryGetInfoBonus do
    begin

      RinfoBonuxCard.OstBonus := RoundTo(FieldByName('OstBounus').AsFloat, -2);
      RinfoBonuxCard.OstMoyka := RoundTo(FieldByName('OstMoyka').AsFloat, 0);
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


    QueryLastPurchases.Active := False;
    QueryLastPurchases.Params.FindParam('IDCARD').Value := ParamIdCard;


    try
      QueryLastPurchases.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryLastPurchases.Last;

    if QueryLastPurchases.RecordCount>0 then
    begin

      QueryLastPurchases.First;
      with   QueryLastPurchases do
      begin
        RinfoBonuxCard.LitersFuelMonth  := FieldByName('quantity').AsFloat;
        RinfoBonuxCard.SumFuelMonth     := FieldByName('summa').AsFloat;
      end;
    end else

    begin
       RinfoBonuxCard.LitersFuelMonth  := 0;
       RinfoBonuxCard.SumFuelMonth     := 0;
    end;

    QueryLastYearPurchases.Active := False;
    QueryLastYearPurchases.Params.FindParam('IDCARD').Value := ParamIdCard;


    try
      QueryLastYearPurchases.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryLastYearPurchases.Last;

    if QueryLastYearPurchases.RecordCount>0 then
    begin

      QueryLastYearPurchases.First;
      with   QueryLastYearPurchases do
      begin
        RinfoBonuxCard.LitersFuelYear  := FieldByName('quantityYear').AsFloat;
        RinfoBonuxCard.SumFuelYear     := FieldByName('summaYear').AsFloat;
      end;
    end else

    begin
       RinfoBonuxCard.LitersFuelYear  := 0;
       RinfoBonuxCard.SumFuelYear     := 0;
    end;



  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetInfoBonus);
    FreeAndNil(QueryLastPurchases);
    FreeAndNil(QueryLastYearPurchases);
    DisConnect;
    FreeAndNil(JSON);
  end;
  resultText := TinfoBonuxCardToJSON(0,'OK', RinfoBonuxCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;

function Mobile.updateGetTransactionListBonus(JsonText: String): TJSONObject;
var
  QueryGetTransactionListBonus:TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  N:integer;
  begdate, enddate:string;
  resultText : string;
  TransactionLog:TTransactionLog;
begin
  Connect;
  QueryGetTransactionListBonus := TFDQuery.Create(nil);
  QueryGetTransactionListBonus.Connection :=  FDConnection;
  QueryGetTransactionListBonus.SQL.Text := SqlList['GetTransactionListBonus'];

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



    QueryGetTransactionListBonus.Active := False;
    QueryGetTransactionListBonus.Params[0].Value := begdate;
    QueryGetTransactionListBonus.Params[1].Value := enddate;


    try
      QueryGetTransactionListBonus.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;


    QueryGetTransactionListBonus.Last;
    N:=0;
    SetLength(TransactionLog, QueryGetTransactionListBonus.RecordCount);
    QueryGetTransactionListBonus.First;
    while not QueryGetTransactionListBonus.Eof do
    begin
      with QueryGetTransactionListBonus do
      begin
        TransactionLog[N].datedoc       := FieldByName('datedoc').AsDateTime;
        TransactionLog[N].numberdoc     := FieldByName('numberdoc').AsString;
        TransactionLog[N].guiddoc       := FieldByName('guiddoc').AsString;
        TransactionLog[N].guidreceipt   := FieldByName('guidreceipt').AsString;
        TransactionLog[N].idcard        := FieldByName('idcard').AsString;
        TransactionLog[N].codecard      := FieldByName('codecard').AsString;
        TransactionLog[N].idshop        := FieldByName('idshop').AsString;
        TransactionLog[N].idgood  := FieldByName('idgood').AsString;
        TransactionLog[N].namegood  := FieldByName('namegood').AsString;
        TransactionLog[N].fullnamegood  := FieldByName('fullnamegood').AsString;
        TransactionLog[N].quantity    := RoundTo(FieldByName('quantity').AsFloat, -3);
        TransactionLog[N].sumsale    := RoundTo(FieldByName('sumsale').AsFloat, -2);
        TransactionLog[N].sumbonus    := RoundTo(FieldByName('sumbonus').AsFloat, -2);
        TransactionLog[N].basePrice    := FieldByName('BasePrice').AsFloat;
        TransactionLog[N].price    := 0;
        if TransactionLog[N].quantity > 0  then
        begin
          try
            TransactionLog[N].price    := RoundTo(TransactionLog[N].sumsale / TransactionLog[N].quantity, -2) ;
          except
            TransactionLog[N].price    := 0 ;
          end;
        end;
      end;

      QueryGetTransactionListBonus.Next;

      N:=N+1;
    end;

  finally
    FreeAndNil(QueryGetTransactionListBonus);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := TransactionLogToJSON(0, 'ОК', TransactionLog);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;


function Mobile.updateRegisteringNewCard(JsonText: String): TJSONObject;
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
      Raise Exception.Create('Не верные параметры запроса');
    end;

    ParamPhone := JSonValue.Value;


    QueryGetCartListByPhone.Active := False;
    QueryGetCartListByPhone.Params[0].Value := '%'+AnsiRightStr(ParamPhone, 10)+'%';

    try
      QueryGetCartListByPhone.Open;
      QueryGetCartListByPhone.First;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;


    if QueryGetCartListByPhone.RecordCount>0 then
    begin


      Raise Exception.Create('По данному номеру зарегистрирована карта '+QueryGetCartListByPhone.FieldByName('codeCard').AsString);
    end;


    try
      GetBlankCard.Open;
      GetBlankCard.First;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    if GetBlankCard.RecordCount=0 then
    begin
      Raise Exception.Create('Нет свободных карт для регистрации');
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
        Raise Exception.Create('Не удалось обновить данные карты');
     end;

    InfoPersone.idCode :=  Card.ownercart;
    InfoPersone.phone :=  ParamPhone;
    InfoPersone.name := 'Онлайн клиент';
    InfoPersone.guid := IntToStr(GetNewUnicode(ErrorDescription, 'Online', 'Registred', FDConnection));
    InfoPersone.toWrite := 1;

    if Not WriteToMySQL_Person(InfoPersone, ErrorDescription, FDConnection) then
     begin
        Raise Exception.Create('Не удалось записать данные физ лица');
     end;

    OnlineRegData.dateOfReg := now;
    OnlineRegData.idCard :=  GetBlankCard.FieldByName('idcode').AsString;
    OnlineRegData.codecard :=  GetBlankCard.FieldByName('codecard').AsString;
    OnlineRegData.phone :=  ParamPhone;

    if WriteToMySQL_OnlineRegData(OnlineRegData, ErrorDescription, FDConnection) then
    begin
       resultText := OnlineRegDataToJSON(0, 'OK', OnlineRegData);
       result :=  TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
    end
    else
    begin
      Raise Exception.Create(ErrorDescription);
    end;

  finally
    FreeAndNil(QueryGetCartListByPhone);
    FreeAndNil(GetBlankCard);
    FreeAndNil(JSON);
    DisConnect;
  end;
end;


function Mobile.updateGetTransactionListBonusByCard(JsonText: String): TJSONObject;
var

  QueryGetTransactionListBonus:TFDQuery;
  QueryGetParamCard:TFDQuery;

  JSON:TJSONObject;
  JSonValue:TJSONValue;

  N:integer;
  begdate, enddate:string;
  ParamIdCard, ParamCodeCard :string;
  resultText : string;
  TransactionLog:TTransactionLog;
begin
  Connect;

  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetTransactionListBonus := TFDQuery.Create(nil);
  QueryGetTransactionListBonus.Connection :=  FDConnection;
  QueryGetTransactionListBonus.SQL.Text := SqlList['GetTransactionListBonusByCard'];

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

    JSonValue := Json.FindValue('codecard');
    if JSonValue <> nil then
    begin
      ParamCodeCard := JSonValue.Value;
    end;

    JSonValue := Json.FindValue('idCard');
    if JSonValue <> nil then
    begin
      ParamIdCard := JSonValue.Value;
    end;

    if ((ParamIdCard = '') and (ParamCodeCard = '')) then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');

    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;


    QueryGetTransactionListBonus.Params.FindParam('IDCARD').Value := ParamIdCard;
    QueryGetTransactionListBonus.Params.FindParam('BegDate').Value := begdate;
    QueryGetTransactionListBonus.Params.FindParam('EndDate').Value := enddate;



    try
      QueryGetTransactionListBonus.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;


    QueryGetTransactionListBonus.Last;
    N:=0;
    SetLength(TransactionLog, QueryGetTransactionListBonus.RecordCount);
    QueryGetTransactionListBonus.First;
    while not QueryGetTransactionListBonus.Eof do
    begin
      with QueryGetTransactionListBonus do
      begin
        TransactionLog[N].datedoc := FieldByName('datedoc').AsDateTime;
        TransactionLog[N].numberdoc  := FieldByName('numberdoc').AsString;
        TransactionLog[N].guiddoc  := FieldByName('guiddoc').AsString;
        TransactionLog[N].guidreceipt   := FieldByName('guidreceipt').AsString;
        TransactionLog[N].idcard  := FieldByName('idcard').AsString;
        TransactionLog[N].codecard  := FieldByName('codecard').AsString;
        TransactionLog[N].idshop  := FieldByName('idshop').AsString;
        TransactionLog[N].idgood  := FieldByName('idgood').AsString;
        TransactionLog[N].namegood  := FieldByName('namegood').AsString;
        TransactionLog[N].fullnamegood  := FieldByName('fullnamegood').AsString;
        TransactionLog[N].quantity    := RoundTo(FieldByName('quantity').AsFloat, -3);
        TransactionLog[N].sumsale    := RoundTo(FieldByName('sumsale').AsFloat, -2);
        TransactionLog[N].sumbonus    := RoundTo(FieldByName('sumbonus').AsFloat, -2);
        TransactionLog[N].basePrice    := FieldByName('BasePrice').AsFloat;
        TransactionLog[N].price    := 0;
        if TransactionLog[N].quantity > 0  then
        begin
          try
            TransactionLog[N].price    := RoundTo(TransactionLog[N].sumsale / TransactionLog[N].quantity, -2) ;
          except
            TransactionLog[N].price    := 0 ;
          end;
        end;
      end;

      QueryGetTransactionListBonus.Next;

      N:=N+1;
    end;

  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetTransactionListBonus);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := TransactionLogToJSON(0, 'ОК', TransactionLog);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;


function Mobile.updatePrepaymentCarWash(JsonText: String): TJSONObject;
var
  QueryGetParamCard:TFDQuery;
  QueryGetInfoBonus:TFDQuery;
  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamIdCard, ParamCodeCard, ParamAmount, ParamIdPost :string;
  Amount:Integer;
  RinfoBonuxCard: TinfoBonuxCard;
  resultText : string;
  ErrorDescription: AnsiString;
  MoykaRecord: TPrepayment_MoykaRecord;

begin

  ParamIdCard := '';
  ParamCodeCard := '';
  ParamAmount := '';
  ParamIdPost := '';
  Amount:=0;

  Connect;
  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetInfoBonus := TFDQuery.Create(nil);
  QueryGetInfoBonus.Connection :=  FDConnection;
  QueryGetInfoBonus.SQL.Text := SqlList['GetInfoBonusMobile'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

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

    JSonVaue := Json.FindValue('amount');
    if JSonVaue <> nil then
    begin
      ParamAmount := JSonVaue.Value;
    end;

    JSonVaue := Json.FindValue('idPost');
    if JSonVaue <> nil then
    begin
      ParamIdPost := JSonVaue.Value;
    end;

    if ((ParamIdCard = '') and (ParamCodeCard = '')) or (ParamAmount='') then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    try
      Amount :=  StrToInt(ParamAmount);
    except
      Raise Exception.Create('Ошибка в параметре amount');
    end;

    try
      MoykaRecord.idpost :=  StrToInt(ParamIdPost);
    except
      Raise Exception.Create('Ошибка в параметре idPost');
    end;



    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';

    if ParamCodeCard='' then
       ParamCodeCard := '999999999999999999999999999999';

    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');


    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    RinfoBonuxCard.rfid :=  QueryGetParamCard.FieldByName('rfid').AsString;
    RinfoBonuxCard.barcode :=  QueryGetParamCard.FieldByName('codecard').AsString;
    RinfoBonuxCard.idCodeCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    MoykaRecord.rfid := RinfoBonuxCard.barcode;
    MoykaRecord.money := Amount;

    QueryGetInfoBonus.Active := False;
    QueryGetInfoBonus.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetInfoBonus.Params.FindParam('IDCARD').Value := ParamIdCard;
    QueryGetInfoBonus.Params.FindParam('IDGROUPGOODS').Value := '';

    try
      QueryGetInfoBonus.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetInfoBonus.Last;

    if QueryGetInfoBonus.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetInfoBonus.First;

    with   QueryGetInfoBonus do
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

    if (RinfoBonuxCard.OstBonus + RinfoBonuxCard.OstMoyka) < Amount then
        Raise Exception.Create('Доступный баланс меньше суммы <' + FloatToStr(Amount)+'>');



    if WriteToMySQL_PrepaymentCarWash(MoykaRecord, ErrorDescription, FDConnection) then
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
    DisConnect;
    FreeAndNil(JSON);
  end;
end;

function Mobile.updateUpdate_person_addInfo(JsonText: String): TJSONObject;
var
  PersoneAddInfo: TPersoneAddInfo;
  ErrorDescription: AnsiString;
  GetOwnerCardByCode:TFDQuery;
begin
  PersoneAddInfo.idCode := '';
  PersoneAddInfo.codecard := '';

  Connect;
  try
    if JSONToTPersoneAddInfo(JsonText, PersoneAddInfo) then
    begin
       PersoneAddInfo.rewrite := 1;
       if (PersoneAddInfo.idCode = '') and (PersoneAddInfo.codecard <> '') then
       begin
          try
            GetOwnerCardByCode := TFDQuery.Create(nil);
            GetOwnerCardByCode.Connection :=  FDConnection;
            GetOwnerCardByCode.SQL.Text := SqlList['GetOwnerCardByCode'];
            GetOwnerCardByCode.Active := False;
            GetOwnerCardByCode.Params.FindParam('CodeCard').Value := PersoneAddInfo.codecard;
            try
              GetOwnerCardByCode.Open;
            except
              Raise Exception.Create('Ошибка выполнения запроса');
            end;

            GetOwnerCardByCode.Last;

            if GetOwnerCardByCode.RecordCount>0 then
            begin
               PersoneAddInfo.idCode := GetOwnerCardByCode.FieldByName('idOwner').AsString;
            end else
              Raise Exception.Create('Нет данных по карте '+PersoneAddInfo.codecard);

          finally
             FreeAndNil(GetOwnerCardByCode);
          end;

       end;

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

function Mobile.updateGetLastSales10Minutes(JsonText: String): TJSONObject;
var
  QueryGetLastSales:TFDQuery;

  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamCodeCard:string;
  TransactionLog:TTransactionLog;
  resultText : string;
  N:integer;
begin
  Connect;
  QueryGetLastSales := TFDQuery.Create(nil);
  QueryGetLastSales.Connection :=  FDConnection;
  QueryGetLastSales.SQL.Text := SqlList['LastSales10Minutes'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  ParamCodeCard := '';

  try
      JSonVaue := Json.FindValue('codeCard');
      if JSonVaue <> nil then
      begin
        ParamCodeCard := JSonVaue.Value;
      end;

      if (ParamCodeCard = '')then
      begin
        Raise Exception.Create('Не верные параметры запроса');
      end;

      QueryGetLastSales.Active := False;
      QueryGetLastSales.Params.FindParam('CODECARD').Value := ParamCodeCard;


      try
        QueryGetLastSales.Open;
      except
        on E: Exception do
        begin
          Raise Exception.Create('Ошибка выполнения запроса');
        end;
      end;


      N:=0;
      QueryGetLastSales.Last;

      SetLength(TransactionLog, QueryGetLastSales.RecordCount);

      QueryGetLastSales.First;

      while not QueryGetLastSales.Eof do
      begin
        with QueryGetLastSales do
        begin
          TransactionLog[N].datedoc       := FieldByName('datedoc').AsDateTime;
          TransactionLog[N].numberdoc     := FieldByName('numberdoc').AsString;
          TransactionLog[N].guiddoc       := FieldByName('guiddoc').AsString;
          TransactionLog[N].guidreceipt   := FieldByName('guidreceipt').AsString;
          TransactionLog[N].idcard        := FieldByName('idcard').AsString;
          TransactionLog[N].codecard      := FieldByName('codecard').AsString;
          TransactionLog[N].idshop        := FieldByName('idshop').AsString;
          TransactionLog[N].idgood        := FieldByName('idgood').AsString;
          TransactionLog[N].namegood      := FieldByName('namegood').AsString;
          TransactionLog[N].fullnamegood  := FieldByName('fullnamegood').AsString;
          TransactionLog[N].quantity      := RoundTo(FieldByName('quantity').AsFloat, -3);
          TransactionLog[N].sumsale       := RoundTo(FieldByName('sumsale').AsFloat, -2);
          TransactionLog[N].sumbonus      := RoundTo(FieldByName('sumbonus').AsFloat, -2);
          TransactionLog[N].basePrice     := FieldByName('BasePrice').AsFloat;
          TransactionLog[N].price         := 0;
          if TransactionLog[N].quantity > 0  then
          begin
            try
              TransactionLog[N].price    := RoundTo(TransactionLog[N].sumsale / TransactionLog[N].quantity, -2) ;
            except
              TransactionLog[N].price    := 0 ;
            end;
          end;
        end;

        QueryGetLastSales.Next;

        N:=N+1;
      end;

  finally
      FreeAndNil(QueryGetLastSales);
      FreeAndNil(JSON);
      DisConnect;
  end;

  resultText := TransactionLogToJSON(0, 'ОК', TransactionLog);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Mobile.updateGetSalesForLastMonth(JsonText: String): TJSONObject;
var
  QueryGetParamCard:TFDQuery;
  QueryGetSales:TFDQuery;

  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamIdCard, ParamCodeCard :string;
  salesBonusCard: TsalesBonusCard;
  resultText : string;
begin

  ParamIdCard := '';
  ParamCodeCard := '';

  Connect;

  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetSales := TFDQuery.Create(nil);
  QueryGetSales.Connection :=  FDConnection;
  QueryGetSales.SQL.Text := SqlList['SalesForLastMonth'];


  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try



    JSonVaue := Json.FindValue('codeCard');
    if JSonVaue <> nil then
    begin
      ParamCodeCard := JSonVaue.Value;
    end;

    if (ParamCodeCard = '')  then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';


    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');


    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    salesBonusCard.idCodeCard := ParamIdCard;
    salesBonusCard.barcode := ParamCodeCard;

    QueryGetSales.Active := False;
    QueryGetSales.Params.FindParam('IDCARD').Value := ParamIdCard;


    try
      QueryGetSales.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetSales.Last;

    if QueryGetSales.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetSales.First;

    with   QueryGetSales do
    begin

      salesBonusCard.quantityFuel     := RoundTo(FieldByName('quantityFuel').AsFloat, -2);
      salesBonusCard.sumFuel          := RoundTo(FieldByName('sumFuel').AsFloat, -2);
      salesBonusCard.quantityService  := RoundTo(FieldByName('quantityService').AsFloat, -2);
      salesBonusCard.sumService       := RoundTo(FieldByName('sumService').AsFloat, -2);
      salesBonusCard.quantityTobacco  := RoundTo(FieldByName('quantityTobacco').AsFloat, -2);
      salesBonusCard.sumTobacco       := RoundTo(FieldByName('sumTobacco').AsFloat, -2);
      salesBonusCard.quantityGoods    := RoundTo(FieldByName('quantityGoods').AsFloat, -2);
      salesBonusCard.sumGoods         := RoundTo(FieldByName('sumGoods').AsFloat, -2);

    end;





  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetSales);
    DisConnect;
    FreeAndNil(JSON);
  end;
  resultText := TsalesBonusCardToJSON(0, 'OK', salesBonusCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;

function Mobile.updateGetSalesForCurrentYear(JsonText: String): TJSONObject;
var
  QueryGetParamCard:TFDQuery;
  QueryGetSales:TFDQuery;

  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamIdCard, ParamCodeCard :string;
  salesBonusCard: TsalesBonusCard;
  resultText : string;
begin

  ParamIdCard := '';
  ParamCodeCard := '';

  Connect;

  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetSales := TFDQuery.Create(nil);
  QueryGetSales.Connection :=  FDConnection;
  QueryGetSales.SQL.Text := SqlList['SalesForCurrentYear'];


  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try



    JSonVaue := Json.FindValue('codeCard');
    if JSonVaue <> nil then
    begin
      ParamCodeCard := JSonVaue.Value;
    end;

    if (ParamCodeCard = '')  then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';


    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');


    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    salesBonusCard.idCodeCard := ParamIdCard;
    salesBonusCard.barcode := ParamCodeCard;

    QueryGetSales.Active := False;
    QueryGetSales.Params.FindParam('IDCARD').Value := ParamIdCard;


    try
      QueryGetSales.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetSales.Last;

    if QueryGetSales.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetSales.First;

    with   QueryGetSales do
    begin

      salesBonusCard.quantityFuel     := RoundTo(FieldByName('quantityFuel').AsFloat, -2);
      salesBonusCard.sumFuel          := RoundTo(FieldByName('sumFuel').AsFloat, -2);
      salesBonusCard.quantityService  := RoundTo(FieldByName('quantityService').AsFloat, -2);
      salesBonusCard.sumService       := RoundTo(FieldByName('sumService').AsFloat, -2);
      salesBonusCard.quantityTobacco  := RoundTo(FieldByName('quantityTobacco').AsFloat, -2);
      salesBonusCard.sumTobacco       := RoundTo(FieldByName('sumTobacco').AsFloat, -2);
      salesBonusCard.quantityGoods    := RoundTo(FieldByName('quantityGoods').AsFloat, -2);
      salesBonusCard.sumGoods         := RoundTo(FieldByName('sumGoods').AsFloat, -2);

    end;





  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetSales);
    DisConnect;
    FreeAndNil(JSON);
  end;
  resultText := TsalesBonusCardToJSON(0, 'OK', salesBonusCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;


function Mobile.updateGetSalesForCurrentWeek(JsonText: String): TJSONObject;
var
  QueryGetParamCard:TFDQuery;
  QueryGetSales:TFDQuery;

  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamIdCard, ParamCodeCard :string;
  salesBonusCard: TsalesBonusCard;
  resultText : string;
begin

  ParamIdCard := '';
  ParamCodeCard := '';

  Connect;

  QueryGetParamCard := TFDQuery.Create(nil);
  QueryGetParamCard.Connection :=  FDConnection;
  QueryGetParamCard.SQL.Text := SqlList['GetParamCardMobile'];

  QueryGetSales := TFDQuery.Create(nil);
  QueryGetSales.Connection :=  FDConnection;
  QueryGetSales.SQL.Text := SqlList['SalesForCurrentWeek'];


  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try



    JSonVaue := Json.FindValue('codeCard');
    if JSonVaue <> nil then
    begin
      ParamCodeCard := JSonVaue.Value;
    end;

    if (ParamCodeCard = '')  then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    if ParamIdCard='' then
       ParamIdCard := '999999999999999999999999999999';


    QueryGetParamCard.Active := False;
    QueryGetParamCard.Params.FindParam('CODECARD').Value := ParamCodeCard;
    QueryGetParamCard.Params.FindParam('IDCODE').Value := ParamIdCard;

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
      Raise Exception.Create('Карта не найдена ');


    ParamCodeCard :=  QueryGetParamCard.FieldByName('codecard').AsString;
    ParamIdCard :=  QueryGetParamCard.FieldByName('idcard').AsString;

    salesBonusCard.idCodeCard := ParamIdCard;
    salesBonusCard.barcode := ParamCodeCard;

    QueryGetSales.Active := False;
    QueryGetSales.Params.FindParam('IDCARD').Value := ParamIdCard;


    try
      QueryGetSales.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetSales.Last;

    if QueryGetSales.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    QueryGetSales.First;

    with   QueryGetSales do
    begin

      salesBonusCard.quantityFuel     := RoundTo(FieldByName('quantityFuel').AsFloat, -2);
      salesBonusCard.sumFuel          := RoundTo(FieldByName('sumFuel').AsFloat, -2);
      salesBonusCard.quantityService  := RoundTo(FieldByName('quantityService').AsFloat, -2);
      salesBonusCard.sumService       := RoundTo(FieldByName('sumService').AsFloat, -2);
      salesBonusCard.quantityTobacco  := RoundTo(FieldByName('quantityTobacco').AsFloat, -2);
      salesBonusCard.sumTobacco       := RoundTo(FieldByName('sumTobacco').AsFloat, -2);
      salesBonusCard.quantityGoods    := RoundTo(FieldByName('quantityGoods').AsFloat, -2);
      salesBonusCard.sumGoods         := RoundTo(FieldByName('sumGoods').AsFloat, -2);

    end;





  finally
    FreeAndNil(QueryGetParamCard);
    FreeAndNil(QueryGetSales);
    DisConnect;
    FreeAndNil(JSON);
  end;
  resultText := TsalesBonusCardToJSON(0, 'OK', salesBonusCard);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;


function Mobile.updateStatisticSalesOfCardsForWeek(JsonText: String): TJSONObject;
var
  QueryGetSales:TFDQuery;

  JSON:TJSONObject;

  JSonVaue:TJSONValue;
  ParamConditionWhere :string;
  salesBonusCardList: TsalesBonusCardList;
  SQLText:string;
  resultText : string;
  N:integer;
begin

  ParamConditionWhere := '';
  N := 0;

  Connect;


  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;

  try



    JSonVaue := Json.FindValue('conditionWhere');
    if JSonVaue <> nil then
    begin
      ParamConditionWhere := JSonVaue.Value;
    end;


    SQLText := SqlList['StatisticSalesOfCardsForWeek'];
    SQLText := StringReplace(SQLText, '#conditionWhere', ParamConditionWhere, [rfReplaceAll, rfIgnoreCase]);

    QueryGetSales := TFDQuery.Create(nil);
    QueryGetSales.Connection :=  FDConnection;
    QueryGetSales.SQL.Text := SQLText;
    QueryGetSales.Active := False;


    try
      QueryGetSales.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetSales.Last;

    if QueryGetSales.RecordCount=0 then
    begin
      Raise Exception.Create('Нет данных');
    end;

    SetLength(salesBonusCardList, QueryGetSales.RecordCount);

    QueryGetSales.First;
    while not QueryGetSales.Eof do
    begin

        with   QueryGetSales do
        begin
          salesBonusCardList[N].idCodeCard      := FieldByName('idCard').AsString;
          salesBonusCardList[N].barcode         := FieldByName('codeCard').AsString;
          salesBonusCardList[N].quantityFuel    := RoundTo(FieldByName('quantityFuel').AsFloat, -2);
          salesBonusCardList[N].sumFuel         := RoundTo(FieldByName('sumFuel').AsFloat, -2);
          salesBonusCardList[N].quantityService := RoundTo(FieldByName('quantityService').AsFloat, -2);
          salesBonusCardList[N].sumService      := RoundTo(FieldByName('sumService').AsFloat, -2);
          salesBonusCardList[N].quantityTobacco := RoundTo(FieldByName('quantityTobacco').AsFloat, -2);
          salesBonusCardList[N].sumTobacco      := RoundTo(FieldByName('sumTobacco').AsFloat, -2);
          salesBonusCardList[N].quantityGoods   := RoundTo(FieldByName('quantityGoods').AsFloat, -2);
          salesBonusCardList[N].sumGoods        := RoundTo(FieldByName('sumGoods').AsFloat, -2);

        end;
      N := N + 1;
      QueryGetSales.Next;
    end;



  finally
    FreeAndNil(QueryGetSales);
    DisConnect;
    FreeAndNil(JSON);
  end;
  resultText := TsalesBonusCardListToJSON(0, 'OK', salesBonusCardList);

  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;
end;



Procedure Mobile.Connect();

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

Procedure Mobile.DisConnect;
begin
  FDConnection.Connected := false;
  FreeAndNil(FDConnection);
end;

end.
