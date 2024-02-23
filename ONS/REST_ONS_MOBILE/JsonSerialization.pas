unit JsonSerialization;

interface
uses
     System.Classes,
     System.SysUtils,
     System.DateUtils,
     System.JSON.Builders,
     System.JSON.Types,
     System.JSON.Writers,
     System.JSON.Readers,
     System.JSON,
     Writers,
     System.Variants,
     IdURI,
     structures;
    // System.Rtti;


  function DescriptionErrorToJSON(ErrorCode: Integer; DescriptionError:AnsiString): TJSONObject; overload
  function DescriptionErrorToJSON(ErrorCode: Integer; DescriptionError:AnsiString; LogError:AnsiString): TJSONObject; overload
  function DescriptionErrorToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;
  function ContentErrorToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;
  function ContentErrorYandexToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;
  function ErrorYandexToJSONText(ErrorCode: Integer; DescriptionError:AnsiString; DescriptionErrorUser:AnsiString): AnsiString;
  function ErrorYandexToJSON(ErrorCode: Integer; DescriptionError:AnsiString; DescriptionErrorUser:AnsiString): TJSONObject;

  function ResultOkToJSON(): TJSONObject;

  function TJurParnerListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TJurParnerList): string;
  function TransactionLogOfCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TTransactionLogOfCard): string;
  function TransactionLogToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TTransactionLog): string;

  function TinfoBonuxCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TinfoBonuxCard): string;
  function TInfoPersoneToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TInfoPersone): string;
  function RateBonusCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TRateBonusCard): string;
  function CardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TCardList): string;
  function CardInfoToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TRecordCardList): string;
  function OnlineRegDataToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TOnlineRegData): string;
  function BonusRateTableToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TBonusRateTable): string;
  function PersonListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersonList): string;
  function PersonCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersonCardList): string;
  function PersoneAddInfoListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersoneAddInfoList): string;
  function OnlineRegDataListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TOnlineRegDataList): string;
  function YandexRegDataToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TYandexRegData): string;
  function YandexConfirmOKJSON(Data:TYandexRegData): TJSONObject;
  function YandexBalanceJSON(balance:Double): TJSONObject;
  function YandexPurchaseOKJSON(purchaseId:string; bonus:Double): TJSONObject;
  function YandexPurchaseListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data: TYandexPurchaseList): string;
  function PaymentMoykaTotalToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPaymentMoykaTotal): string;
  function PaymentMoykalistToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPaymentMoykaList): string;
  function TsalesBonusCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TsalesBonusCard): string;
  function TsalesBonusCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TsalesBonusCardList): string;
  function TBirthdayCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TBirthdayCardList): string;
  function Tdc_EngineFixCardsListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:Tdc_EngineFixCardsList): string;
  // JSON TO STRUCTURE

  Function JSONToTypeQuery(AJson:String):AnsiString;
  Function JSONToTdc_engine_pay_moyka(AJson:String; var dc_engine_pay_moyka :Tdc_engine_pay_moyka):boolean;
  Function JSONToTdc_enginecards(AJson:String; var dc_enginecards :Tdc_enginecards):boolean;
  Function JSONToTCard(AJson:String; var Card :TCard):boolean;
  Function JSONToTInfoPersone(AJson:String; var InfoPersone :TInfoPersone):boolean;
  Function JSONToTPersoneAddInfo(AJson:String; var PersoneAddInfo :TPersoneAddInfo):boolean;
  Function JSONToTOnlineRegData(AJson:String; var OnlineRegData :TOnlineRegData):boolean;
  Function JSONToTYandexPurchase(AJson:String; var YandexPurchase :TYandexPurchase):boolean;
  Function JSONToTYandexPurchaseAnswer(AJson:String; var YandexPurchaseAnswer :TYandexPurchaseAnswer):boolean;
  Function JSONToTdc_enginefixcards_moyka(AJson:String; var dc_enginefixcards_moyka :Tdc_enginefixcards_moyka):boolean;
  Function JSONToTdc_enginefixcards(AJson:String; var dc_enginefixcards :Tdc_enginefixcards):boolean;
  Function JSONToTdc_enginedebit_moyka(AJson:String; var dc_enginedebit_moyka :Tdc_enginedebit_moyka):boolean;
  Function JSONToTInfoGoods(AJson:String; var infoGoods :TInfoGoods):boolean;
  Function JSONToTInfoGroupGoods(AJson:String; var infoGroupGoods :TInfoGroupGoods):boolean;
  Function JSONToTEnginefixcardsAnswer(AJson:String; var EnginefixcardsAnswer :TEnginefixcardsAnswer):boolean;



implementation

uses uLog;

function BoolToIntSTR(b: boolean): String;
begin
  if b then result:='1' else result:='0';
end;

function IntSTRToBool(b: string): Boolean;
begin
  if b='1' then result:=TRUE else result:=False;
end;

function IntToBool(b: Integer): Boolean;
begin
  if b = 1 then result:=TRUE else result:=False;
end;


function JSONDate_To_Datetime(JSONDate: string): TDatetime;
var Year, Month, Day, Hour, Minute, Second, Millisecond: Word;
begin
  Year        := StrToInt(Copy(JSONDate, 1, 4));
  Month       := StrToInt(Copy(JSONDate, 6, 2));
  Day         := StrToInt(Copy(JSONDate, 9, 2));
  Hour        := StrToInt(Copy(JSONDate, 12, 2));
  Minute      := StrToInt(Copy(JSONDate, 15, 2));
  Second      := StrToInt(Copy(JSONDate, 18, 2));
  Millisecond := 0;//Round(StrToFloat(Copy(JSONDate, 19, 4)));

  Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Millisecond);
end;

function DescriptionErrorToJSON(ErrorCode: Integer; DescriptionError:AnsiString): TJSONObject;

begin
  result := TJSONObject.ParseJSONValue('{"ErrorCode": '+IntToStr(ErrorCode)+', "Result": "'+DescriptionError+'"}', False, True) as TJSONObject;
end;


function DescriptionErrorToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;

begin
  result := '{"ErrorCode": '+IntToStr(ErrorCode)+', "Result": "'+DescriptionError+'"}';
end;

function ContentErrorToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;
var
  JSONObject:TJSONObject;
  JSonVaue:TJSONValue;
begin

  JSONObject :=  TJSONObject.ParseJSONValue(DescriptionError, False, True) as TJSONObject;
  try
    JSonVaue := JSONObject.FindValue('error');
    if JSonVaue <> nil then
    begin
      result := '{"ErrorCode": '+IntToStr(ErrorCode)+', "Result": "'+JSonVaue.Value+'"}';
    end else
      result := '{"ErrorCode": '+IntToStr(ErrorCode)+', "Result": "Неизвестная ошибка"}';

  finally
    FreeAndNil(JSONObject);
  end;

end;


function ContentErrorYandexToJSONText(ErrorCode: Integer; DescriptionError:AnsiString): AnsiString;
var
  JSONObject:TJSONObject;
  JSonVaue:TJSONValue;
begin

  JSONObject :=  TJSONObject.ParseJSONValue(DescriptionError, False, True) as TJSONObject;
  try
    JSonVaue := JSONObject.FindValue('error');
    if JSonVaue <> nil then
    begin
      result := JSonVaue.Value;
    end else
      result := '{"errorCode": '+IntToStr(ErrorCode)+', "errorMessage": "Неизвестная ошибка", "userErrorMessage": "Неизвестная ошибка"}';

  finally
    FreeAndNil(JSONObject);
  end;

end;

function ErrorYandexToJSONText(ErrorCode: Integer; DescriptionError:AnsiString; DescriptionErrorUser:AnsiString): AnsiString;

begin
    if DescriptionErrorUser <> '' then
    begin
      result := '{"errorCode": '+IntToStr(ErrorCode)+', "errorMessage": "'+DescriptionError+'", "userErrorMessage": "'+DescriptionErrorUser+'"}';
    end else
      result := '{"errorCode": '+IntToStr(ErrorCode)+', "errorMessage": "'+DescriptionError+'", "userErrorMessage": "'+DescriptionError+'"}';

end;

function ErrorYandexToJSON(ErrorCode: Integer; DescriptionError:AnsiString; DescriptionErrorUser:AnsiString): TJSONObject;

var
 JSONText:string;

begin
    if DescriptionErrorUser <> '' then
    begin
      JSONText := '{"errorCode": '+IntToStr(ErrorCode)+', "errorMessage": "'+DescriptionError+'", "userErrorMessage": "'+DescriptionErrorUser+'"}';
    end else
      JSONText := '{"errorCode": '+IntToStr(ErrorCode)+', "errorMessage": "'+DescriptionError+'", "userErrorMessage": "'+DescriptionError+'"}';

   result := TJSONObject.ParseJSONValue(JSONText, False, True) as TJSONObject;
end;



function DescriptionErrorToJSON(ErrorCode: Integer; DescriptionError:AnsiString; LogError:AnsiString): TJSONObject;

begin

  LogFile.WriteLogHead('Error', LogError);

  result := TJSONObject.ParseJSONValue('{"ErrorCode": '+IntToStr(ErrorCode)+', "Result": "'+DescriptionError+'"}', False, True) as TJSONObject;
end;

function ResultOkToJSON(): TJSONObject;

begin
  result := TJSONObject.ParseJSONValue('{"ErrorCode": 0, "Result": "OK"}', False, True) as TJSONObject;
end;

function TJurParnerListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TJurParnerList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject.Add('dateCreate',Data[I].dateCreate)
         .Add('codeCard',Data[I].codeCard)
         .Add('codePartner',Data[I].codePartner)
         .Add('amount',Data[I].amount)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function TinfoBonuxCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TinfoBonuxCard): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;

    Pairs.Add('ErrorCode',ErrorCode)
        .Add('Result',DescriptionError)
        .Add('idCard',Data.idCodeCard)
        .Add('codeCard',Data.barcode)
        .Add('balance',Data.OstBonus)
        .Add('balanceMoyka',Data.OstMoyka)
        .Add('discount',Data.Discont)
        .Add('bonusRate',Data.BonusRate)
        .Add('actionIdBonRate',Data.ActionIdBonusRate)
        .Add('totalAmount',Data.sumDeb)
        .Add('LitersFuelMonth', Data.LitersFuelMonth)
        .Add('SumFuelMonth', Data.SumFuelMonth)
        .Add('LitersFuelYear', Data.LitersFuelYear)
        .Add('SumFuelYear', Data.SumFuelYear);


    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function TInfoPersoneToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TInfoPersone): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('ErrorDescription',DescriptionError)
      .BeginObject('Data')
        .Add('name',IdURI.TIdURI.ParamsEncode(Data.name))
        .Add('idCode',IdURI.TIdURI.ParamsEncode(Data.idCode))
        .Add('phone',Data.phone)
        .Add('f',IdURI.TIdURI.ParamsEncode(Data.f))
        .Add('i',IdURI.TIdURI.ParamsEncode(Data.i))
        .Add('o',IdURI.TIdURI.ParamsEncode(Data.o))
        .Add('Email',IdURI.TIdURI.ParamsEncode(Data.Email))
        .Add('birthday',DateTimeToStr(Data.birthday))
        .Add('changed',Data.changed)
      .EndObject;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function TransactionLogOfCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TTransactionLogOfCard): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('ErrorDescription',DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject.Add('typeDoc',Data[I].typeDoc)
         .Add('guidDoc',Data[I].guidDoc)
         .Add('datetime',DateTimeToStr(Data[I].datetime))
         .Add('nameShop',Data[I].nameShop)
         .Add('bonus',Data[I].value)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function TransactionLogToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TTransactionLog): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject
         .Add('datedoc',    DateTimeToStr(Data[I].datedoc))
         .Add('numberdoc',  Data[I].numberdoc)
         .Add('guiddoc',    Data[I].guiddoc)
         .Add('guidreceipt',    Data[I].guidreceipt)
         .Add('idcard',     Data[I].idcard)
         .Add('codecard',   Data[I].codecard)
         .Add('idshop',     Data[I].idshop)
         .Add('idgood',     Data[I].idgood)
         .Add('namegood',   Data[I].namegood)
         .Add('fullnamegood',   Data[I].fullnamegood)
         .Add('quantity',   Data[I].quantity)
         .Add('sumsale',   Data[I].sumsale)
         .Add('sumbonus',   Data[I].sumbonus)
         .Add('price',      Data[I].Price)
         .Add('basePrice',   Data[I].BasePrice)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function RateBonusCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TRateBonusCard): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError)

    .Add('BarCode',Data.BarCode)
    .Add('idGoods',Data.idGoods)
    .Add('idShop',Data.idShop)
    .Add('BonusRate',Data.BonusRate)
    .Add('ActionId',Data.ActionId)
    .Add('extCodeAction',Data.extCodeAction)
    .Add('AmtSale',Data.AmtSale)
    .Add('CntSale',Data.CntSale)
    .Add('AmtBonus',Data.AmtBonus)
    .Add('AmtAction',Data.AmtAction);


    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


Function JSONToTypeQuery(AJson:String):AnsiString;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

begin
  result := 'error';

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    if Json.Next('TypeQuery') then
       Result := Json.AsString;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
 end;

end;

Function JSONToTdc_engine_pay_moyka(AJson:String; var dc_engine_pay_moyka :Tdc_engine_pay_moyka):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

  idtbdc_Moyka:integer;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         dc_engine_pay_moyka.guiddoc := Json.AsString;

       if JSON.Key='Registr' then
         dc_engine_pay_moyka.Registr  := IntToBool(Json.AsInteger);

       if JSON.Key='guidInteger' then
         dc_engine_pay_moyka.guiddocInteger := Json.AsString;

       if JSON.Key='idcode' then
          dc_engine_pay_moyka.idcode := Json.AsString;

       if JSON.Key='iddate' then
          dc_engine_pay_moyka.iddate := Json.AsString;

       if JSON.Key='comment' then
          dc_engine_pay_moyka.comment := Json.AsString;

       if JSON.Key='count_tbdc_Moyka' then
          dc_engine_pay_moyka.count_tbdc_Moyka := Json.AsInteger;


       if JSON.Key='tbdc_Moyka' then
       begin

          SetLength(dc_engine_pay_moyka.tbdc_Moyka, dc_engine_pay_moyka.count_tbdc_Moyka);
          idtbdc_Moyka := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_engine_pay_moyka.tbdc_Moyka[idtbdc_Moyka].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_engine_pay_moyka.tbdc_Moyka[idtbdc_Moyka].guiddocInteger := Json.AsString;

                     if JSON.Key='card' then
                        dc_engine_pay_moyka.tbdc_Moyka[idtbdc_Moyka].card := Json.AsString;

                     if JSON.Key='moyka' then
                        dc_engine_pay_moyka.tbdc_Moyka[idtbdc_Moyka].moyka := Json.AsDouble;

                     if JSON.Key='bonus' then
                        dc_engine_pay_moyka.tbdc_Moyka[idtbdc_Moyka].bonus := Json.AsDouble;

                   end;

                   Json.Return;
                end;
                idtbdc_Moyka:=idtbdc_Moyka+1;
             end;

             Json.Return;
          end;
      end;
    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;


Function JSONToTdc_enginecards(AJson:String; var dc_enginecards :Tdc_enginecards):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

  idtbdc_enginecardnac:integer;
  idtbdc_enginecardspis:integer;
  idtbdc_enginecards_share:integer;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         dc_enginecards.guiddoc := Json.AsString;

       if JSON.Key='Registr' then
         dc_enginecards.Registr  := IntToBool(Json.AsInteger);

       if JSON.Key='guidInteger' then
         dc_enginecards.guiddocInteger := Json.AsString;

       if JSON.Key='uniid' then
         dc_enginecards.uniid := Json.AsString;

       if JSON.Key='idcode' then
          dc_enginecards.idcode := Json.AsString;

       if JSON.Key='iddate' then
          dc_enginecards.iddate := Json.AsString;

       if JSON.Key='datecreate' then
          dc_enginecards.datecreate := Json.AsString;

       if JSON.Key='card' then
          dc_enginecards.card := Json.AsString;

       if JSON.Key='shop' then
          dc_enginecards.shop := Json.AsString;

       if JSON.Key='comment' then
          dc_enginecards.comment := Json.AsString;

       if JSON.Key='count_tbdc_enginecardnac' then
          dc_enginecards.count_tbdc_enginecardnac := Json.AsInteger;

       if JSON.Key='count_tbdc_enginecardspis' then
          dc_enginecards.count_tbdc_enginecardspis := Json.AsInteger;

       if JSON.Key='count_tbdc_enginecards_share' then
          dc_enginecards.count_tbdc_enginecards_share := Json.AsInteger;


       if JSON.Key='tbdc_enginecardnac' then
       begin

          SetLength(dc_enginecards.tbdc_enginecardnac, dc_enginecards.count_tbdc_enginecardnac);
          idtbdc_enginecardnac := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].guiddocInteger := Json.AsString;

                     if JSON.Key='date' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].date := Json.AsString;

                     if JSON.Key='iddoc' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].iddoc := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].card := Json.AsString;

                     if JSON.Key='goods' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].goods := Json.AsString;

                     if JSON.Key='quantity' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].quantity := Json.AsDouble;

                     if JSON.Key='sum' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].sum := Json.AsDouble;

                     if JSON.Key='bonus' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].bonus := Json.AsDouble;

                     if JSON.Key='actionextcode' then
                        dc_enginecards.tbdc_enginecardnac[idtbdc_enginecardnac].actionextcode := Json.AsString;
                   end;

                   Json.Return;
                end;
                idtbdc_enginecardnac := idtbdc_enginecardnac + 1;
             end;

             Json.Return;
          end;
      end;

      if JSON.Key='tbdc_enginecardspis' then
       begin

          SetLength(dc_enginecards.tbdc_enginecardspis, dc_enginecards.count_tbdc_enginecardspis);
          idtbdc_enginecardspis := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].guiddocInteger := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].card := Json.AsString;

                     if JSON.Key='date' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].date := Json.AsString;

                     if JSON.Key='iddoc' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].iddoc := Json.AsString;

                     if JSON.Key='goods' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].goods := Json.AsString;

                     if JSON.Key='quantity' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].quantity := Json.AsDouble;

                     if JSON.Key='bonus' then
                        dc_enginecards.tbdc_enginecardspis[idtbdc_enginecardspis].bonus := Json.AsDouble;


                   end;

                   Json.Return;
                end;
                idtbdc_enginecardspis := idtbdc_enginecardspis + 1;
             end;

             Json.Return;
          end;
      end;

      if JSON.Key='tbdc_enginecards_share' then
       begin

          SetLength(dc_enginecards.tbdc_enginecards_share, dc_enginecards.count_tbdc_enginecards_share);
          idtbdc_enginecards_share := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].guiddocInteger := Json.AsString;

                     if JSON.Key='date' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].date := Json.AsString;

                     if JSON.Key='iddoc' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].iddoc := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].card := Json.AsString;

                     if JSON.Key='goods' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].goods := Json.AsString;

                     if JSON.Key='share' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].share := Json.AsString;

                     if JSON.Key='value' then
                        dc_enginecards.tbdc_enginecards_share[idtbdc_enginecards_share].value := Json.AsDouble;

                   end;

                   Json.Return;
                end;
                idtbdc_enginecards_share := idtbdc_enginecards_share + 1;
             end;

             Json.Return;
          end;
      end;


    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;


Function JSONToTdc_enginefixcards_moyka(AJson:String; var dc_enginefixcards_moyka :Tdc_enginefixcards_moyka):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

  idtddc_enginefixcards_moyka:integer;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         dc_enginefixcards_moyka.guiddoc := Json.AsString;

       if JSON.Key='Registr' then
         dc_enginefixcards_moyka.Registr  := IntToBool(Json.AsInteger);

       if JSON.Key='guidInteger' then
         dc_enginefixcards_moyka.guiddocInteger := Json.AsString;

       if JSON.Key='uniid' then
         dc_enginefixcards_moyka.uniid := Json.AsString;

       if JSON.Key='idcode' then
          dc_enginefixcards_moyka.idcode := Json.AsString;

       if JSON.Key='iddate' then
          dc_enginefixcards_moyka.iddate := Json.AsString;

       if JSON.Key='comment' then
          dc_enginefixcards_moyka.comment := Json.AsString;

       if JSON.Key='count_tddc_enginefixcards_moyka' then
          dc_enginefixcards_moyka.count_tddc_enginefixcards_moyka := Json.AsInteger;



       if JSON.Key='tddc_enginefixcards_moyka' then
       begin

          SetLength(dc_enginefixcards_moyka.tddc_enginefixcards_moyka, dc_enginefixcards_moyka.count_tddc_enginefixcards_moyka);
          idtddc_enginefixcards_moyka := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].guiddocInteger := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].card := Json.AsString;

                     if JSON.Key='bonus' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].bonus := Json.AsDouble;

                     if JSON.Key='value' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].value := Json.AsDouble;

                     if JSON.Key='share' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].share := Json.AsString;

                     if JSON.Key='dateOf' then
                        dc_enginefixcards_moyka.tddc_enginefixcards_moyka[idtddc_enginefixcards_moyka].dateOf := Json.AsString;
                   end;

                   Json.Return;
                end;
                idtddc_enginefixcards_moyka := idtddc_enginefixcards_moyka + 1;
             end;

             Json.Return;
          end;
      end;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;


Function JSONToTdc_enginefixcards(AJson:String; var dc_enginefixcards :Tdc_enginefixcards):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

  idtddc_enginefixcards:integer;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         dc_enginefixcards.guiddoc := Json.AsString;

       if JSON.Key='Registr' then
         dc_enginefixcards.Registr  := IntToBool(Json.AsInteger);

       if JSON.Key='guidInteger' then
         dc_enginefixcards.guiddocInteger := Json.AsString;

       if JSON.Key='idcode' then
          dc_enginefixcards.idcode := Json.AsString;

       if JSON.Key='iddate' then
          dc_enginefixcards.iddate := Json.AsString;

       if JSON.Key='comment' then
          dc_enginefixcards.comment := Json.AsString;

       if JSON.Key='count_tddc_enginefixcards' then
          dc_enginefixcards.count_tddc_enginefixcards := Json.AsInteger;



       if JSON.Key='tddc_enginefixcards' then
       begin

          SetLength(dc_enginefixcards.tddc_enginefixcards, dc_enginefixcards.count_tddc_enginefixcards);
          idtddc_enginefixcards := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginefixcards.tddc_enginefixcards[idtddc_enginefixcards].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginefixcards.tddc_enginefixcards[idtddc_enginefixcards].guiddocInteger := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginefixcards.tddc_enginefixcards[idtddc_enginefixcards].card := Json.AsString;

                     if JSON.Key='bonus' then
                        dc_enginefixcards.tddc_enginefixcards[idtddc_enginefixcards].bonus := Json.AsDouble;

                     if JSON.Key='iddoc' then
                        dc_enginefixcards.tddc_enginefixcards[idtddc_enginefixcards].iddoc := Json.AsString;

                   end;

                   Json.Return;
                end;
                idtddc_enginefixcards := idtddc_enginefixcards + 1;
             end;

             Json.Return;
          end;
      end;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;


Function JSONToTdc_enginedebit_moyka(AJson:String; var dc_enginedebit_moyka :Tdc_enginedebit_moyka):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

  id_tddc_enginedebit_moyka:integer;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         dc_enginedebit_moyka.guiddoc := Json.AsString;

       if JSON.Key='Registr' then
         dc_enginedebit_moyka.Registr  := IntToBool(Json.AsInteger);

       if JSON.Key='guidInteger' then
         dc_enginedebit_moyka.guiddocInteger := Json.AsString;

       if JSON.Key='idcode' then
          dc_enginedebit_moyka.idcode := Json.AsString;

       if JSON.Key='iddate' then
          dc_enginedebit_moyka.iddate := Json.AsString;

       if JSON.Key='comment' then
          dc_enginedebit_moyka.comment := Json.AsString;

       if JSON.Key='count_tddc_enginedebit_moyka' then
          dc_enginedebit_moyka.count_tddc_enginedebit_moyka := Json.AsInteger;



       if JSON.Key='tddc_enginedebit_moyka' then
       begin

          SetLength(dc_enginedebit_moyka.tddc_enginedebit_moyka, dc_enginedebit_moyka.count_tddc_enginedebit_moyka);
          id_tddc_enginedebit_moyka := 0;
          if Json.Recurse then
          begin
             while JSON.Next do
             begin
                if Json.Recurse then
                begin

                   while JSON.Next do
                   begin
                     if JSON.Key='guiddoc' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].guiddoc := Json.AsString;

                     if JSON.Key='guiddocInteger' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].guiddocInteger := Json.AsString;

                     if JSON.Key='card' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].card := Json.AsString;

                     if JSON.Key='bonusDebit' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].bonusDebit := Json.AsDouble;

                     if JSON.Key='bonusCredit' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].bonusCredit := Json.AsDouble;

                     if JSON.Key='value' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].value := Json.AsDouble;

                     if JSON.Key='share' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].share := Json.AsString;

                     if JSON.Key='dateOf' then
                        dc_enginedebit_moyka.tddc_enginedebit_moyka[id_tddc_enginedebit_moyka].dateOf := Json.AsString;
                   end;

                   Json.Return;
                end;
                id_tddc_enginedebit_moyka := id_tddc_enginedebit_moyka + 1;
             end;

             Json.Return;
          end;
      end;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;

Function JSONToTCard(AJson:String; var Card :TCard):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         Card.guid := Json.AsString;

       if JSON.Key='idcode' then
         Card.idcode  := Json.AsString;

       if JSON.Key='idname' then
         Card.idname := Json.AsString;

       if JSON.Key='idgroup' then
          Card.idgroup := Json.AsString;

       if JSON.Key='codecard' then
          Card.codecard := Json.AsString;

       if JSON.Key='rfid' then
          Card.rfid := Json.AsString;

       if JSON.Key='ownercart' then
          Card.ownercart := Json.AsString;

       if JSON.Key='level' then
          Card.level := Json.AsString;

       if JSON.Key='isOnlineReg' then
          Card.isOnlineReg := Json.AsInteger;

       if JSON.Key='NameClient' then
          Card.NameClient := Json.AsString;

        if JSON.Key='PinCode' then
          Card.PinCode := Json.AsString;

        if JSON.Key='periodlimit' then
          Card.periodlimit := Json.AsInteger;

        if JSON.Key='typelimit' then
          Card.typelimit := Json.AsInteger;

        if JSON.Key='typeClient' then
          Card.typeClient := Json.AsInteger;

        if JSON.Key='dateonlimit' then
          Card.dateonlimit := Json.AsDateTime;

        if JSON.Key='limitmany' then
          Card.limitmany := Json.AsDouble;

        if JSON.Key='limitfuel' then
          Card.limitfuel := Json.AsDouble;

        if JSON.Key='typeCard' then
          Card.typeCard := Json.AsInteger;

        if JSON.Key='Discont' then
          Card.Discont := Json.AsDouble;

        if JSON.Key='limitMoyka' then
          Card.limitMoyka := Json.AsDouble;
    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;

end;


Function JSONToTInfoPersone(AJson:String; var InfoPersone :TInfoPersone):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin
   TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);
  try
    while JSON.Next do
    begin
       if JSON.Key='guid' then
         InfoPersone.guid := Json.AsString;

       if JSON.Key='idcode' then
         InfoPersone.idcode  := Json.AsString;

       if JSON.Key='idname' then
         InfoPersone.name := Json.AsString;

       if JSON.Key='f' then
         InfoPersone.f := Json.AsString;

       if JSON.Key='i' then
         InfoPersone.i := Json.AsString;

       if JSON.Key='o' then
         InfoPersone.o := Json.AsString;

       if JSON.Key='idgroup' then
          InfoPersone.idgroup := Json.AsString;

       if JSON.Key='phone' then
          InfoPersone.phone := Json.AsString;

       if JSON.Key='birthday' then
          InfoPersone.birthday := JSONDate_To_Datetime(Json.AsString);

       if JSON.Key='sex' then
          InfoPersone.sex := Json.AsString;

       if JSON.Key='ReferralCode' then
          InfoPersone.ReferralCode := StrToInt(Json.AsString);

       if JSON.Key='ReferralCodeInvitation' then
          InfoPersone.ReferralCodeInvitation := StrToInt(Json.AsString);

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;


Function JSONToTPersoneAddInfo(AJson:String; var PersoneAddInfo :TPersoneAddInfo):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='idcode' then
         PersoneAddInfo.idCode := Json.AsString;

       if JSON.Key='codecard' then
         PersoneAddInfo.codecard := Json.AsString;

       if JSON.Key='idOwner' then
         PersoneAddInfo.idCode := Json.AsString;

       if JSON.Key='EMail' then
         PersoneAddInfo.Email  := Json.AsString;

       if JSON.Key='phone' then
         PersoneAddInfo.phone  := Json.AsString;

       if JSON.Key='sendReceipt' then
         PersoneAddInfo.sendReceipt := Json.AsInteger;

       if JSON.Key='CityOfResidence' then
          PersoneAddInfo.CityOfResidence := Json.AsString;

       if JSON.Key='ReferralCodeInvitation' then
          PersoneAddInfo.ReferralCodeInvitation := Json.AsInteger;
    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;




function CardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TCardList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject

         .Add('idOwner',  Data[I].idOwner)
         .Add('phone',    Data[I].phone)
         .Add('f',        Data[I].f)
         .Add('i',        Data[I].i)
         .Add('o',        Data[I].o)
         .Add('Email',    Data[I].Email)
         .Add('birthday', DateTimeToStr(Data[I].birthday))
         .Add('idCard',   Data[I].idCard)
         .Add('codeCard', Data[I].codeCard)
         .Add('dateOfUse', Data[I].dateOfUse)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function CardInfoToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TRecordCardList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    Pairs.Add('idOwner',  Data.idOwner);
    Pairs.Add('phone',    Data.phone);
    Pairs.Add('f',        Data.f);
    Pairs.Add('i',        Data.i);
    Pairs.Add('o',        Data.o);
    Pairs.Add('Email',    Data.Email);
    Pairs.Add('birthday', DateTimeToStr(Data.birthday));
    Pairs.Add('idCard',   Data.idCard);
    Pairs.Add('codeCard', Data.codeCard);
    Pairs.Add('dateOfUse', Data.dateOfUse);
    Pairs.Add('sendReceipt', Data.sendReceipt);
    Pairs.Add('ReferralCode', Data.ReferralCode);
    Pairs.Add('ReferralCodeInvitation', Data.ReferralCodeInvitation);
    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function OnlineRegDataToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TOnlineRegData): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);

  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;

  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result',   DescriptionError);
    Pairs.Add('idCard',   Data.idCard);
    Pairs.Add('codeCard',   Data.codecard);
    Pairs.Add('phone',    Data.phone);
    Pairs.Add('dateOfReg', DateTimeToStr(Data.dateOfReg));
    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;

end;


function BonusRateTableToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TBonusRateTable): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject

         .Add('NameGoods',   Data[I].NameGoods)
         .Add('idCoogs',     Data[I].idCoogs)
         .Add('downAmt',     Data[I].downAmt)
         .Add('upAmt',       Data[I].upAmt)
         .Add('rate',        Data[I].rate)
         .Add('periodType',  Data[I].periodType)
         .Add('periodStr',   Data[I].periodStr)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;




function PersonListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersonList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject
         .Add('idCode',     Data[I].idCode)
         .Add('idGroup',    Data[I].idGroup)
         .Add('name',       Data[I].name)
         .Add('f',          Data[I].f)
         .Add('i',          Data[I].i)
         .Add('o',          Data[I].o)
         .Add('Email',      Data[I].Email)
         .Add('sex',        Data[I].sex)
         .Add('phone',      Data[I].phone)
         .Add('birthday',   Data[I].birthday)
         .Add('guid',       Data[I].guid)
         .Add('ReferralCode',                 Data[I].ReferralCode)
         .Add('ReferralCodeInvitation',       Data[I].ReferralCodeInvitation)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;



function PersonCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersonCardList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject
         .Add('idcode',     Data[I].idcode)
         .Add('idname',     Data[I].idname)
         .Add('codecard',   Data[I].codecard)
         .Add('ownercart',  Data[I].ownercart)
         .Add('rfid',       Data[I].rfid)
         .Add('idgroup',    Data[I].idgroup)
         .Add('level',      Data[I].level)
         .Add('isOnlineReg', Data[I].isOnlineReg)
         .Add('guid',       Data[I].guid)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function PersoneAddInfoListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPersoneAddInfoList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject
         .Add('idcode',         Data[I].idcode)
         .Add('phone',          Data[I].phone)
         .Add('Email',          Data[I].Email)
         .Add('sendReceipt',    Data[I].sendReceipt)
         .Add('CityOfResidence',Data[I].CityOfResidence)
         .Add('rewrite',        Data[I].rewrite)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function OnlineRegDataListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TOnlineRegDataList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject
         .Add('idCard',      Data[I].idCard)
         .Add('dateOfReg',   Data[I].dateOfReg)
         .Add('phone',       Data[I].phone)
         .Add('codecard',    Data[I].codecard)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

Function JSONToTOnlineRegData(AJson:String; var OnlineRegData :TOnlineRegData):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;

begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='idCard' then
         OnlineRegData.idCard := Json.AsString;

       if JSON.Key='dateOfReg' then
         OnlineRegData.dateOfReg  := JSONDate_To_Datetime(Json.AsString);

       if JSON.Key='phone' then
         OnlineRegData.phone  := Json.AsString;

       if JSON.Key='codecard' then
         OnlineRegData.codecard := Json.AsString;
    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;

Function JSONToTYandexPurchase(AJson:String; var YandexPurchase :TYandexPurchase):boolean;
var
  Json: TJSONIterator;
  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='cardNo' then
         YandexPurchase.cardNo := Json.AsString;

       if JSON.Key='orderId' then
         YandexPurchase.orderId  := Json.AsString;

       if JSON.Key='orderExtendedId' then
         YandexPurchase.orderExtendedId  := Json.AsString;

       if JSON.Key='stationExtendedId' then
         YandexPurchase.stationExtendedId := Json.AsString;

       if JSON.Key='fuelId' then
         YandexPurchase.fuelId   := Json.AsString;

       if JSON.Key='cost' then
         YandexPurchase.cost   := Json.AsDouble;

       if JSON.Key='count' then
         YandexPurchase.count   := Json.AsDouble;

       if JSON.Key='price' then
         YandexPurchase.price   := Json.AsDouble;

       if JSON.Key='orderDateUtc' then
         YandexPurchase.orderDateUtc  := JSONDate_To_Datetime(Json.AsString);

       if JSON.Key='orderDateLocal' then
         YandexPurchase.orderDateLocal  := JSONDate_To_Datetime(Json.AsString);
    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;


Function JSONToTYandexPurchaseAnswer(AJson:String; var YandexPurchaseAnswer :TYandexPurchaseAnswer):boolean;
var
  Json: TJSONIterator;
  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='rewrite' then
         YandexPurchaseAnswer.rewrite := Json.AsInteger;

       if JSON.Key='orderId' then
         YandexPurchaseAnswer.orderId  := Json.AsString;

       if JSON.Key='purchaseId' then
         YandexPurchaseAnswer.purchaseId  := Json.AsString;

       if JSON.Key='bonus' then
         YandexPurchaseAnswer.bonus  := Json.AsDouble;

       if JSON.Key='errorCode' then
         YandexPurchaseAnswer.errorCode := Json.AsInteger;

       if JSON.Key='errorMessage' then
         YandexPurchaseAnswer.errorMessage   := Json.AsString;

       if JSON.Key='userErrorMessage' then
         YandexPurchaseAnswer.userErrorMessage   := Json.AsString;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;




function YandexRegDataToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TYandexRegData): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('dateOfReg', Data.dateOfReg);
    Pairs.Add('phone',     Data.phone);
    Pairs.Add('codecard',     Data.codecard);
    Pairs.Add('smscode',     Data.SMSCODE);
    Pairs.EndObject;

    result := StringBuilder.ToString;

  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function YandexConfirmOKJSON(Data:TYandexRegData): TJSONObject;

begin

  result := TJSONObject.ParseJSONValue('{"card_token": "'+Data.card_token+'", "card_number": "'+Data.codecard+'"}', False, True) as TJSONObject;


end;

function YandexBalanceJSON(balance:Double): TJSONObject;
var
  FormatSettings: TFormatSettings;
begin

FormatSettings.DecimalSeparator := '.';

result := TJSONObject.ParseJSONValue('{"balance": "'+ FloatToStr(balance, FormatSettings)+'"}', False, True) as TJSONObject;

end;


function YandexPurchaseOKJSON(purchaseId:string; bonus:Double): TJSONObject;
var
  FormatSettings: TFormatSettings;
begin

FormatSettings.DecimalSeparator := '.';

result := TJSONObject.ParseJSONValue('{"purchaseId": "'+purchaseId+'","bonus": "'+ FloatToStr(bonus, FormatSettings)+'"}', False, True) as TJSONObject;

end;

function YandexPurchaseListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data: TYandexPurchaseList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode', ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin
         arrayPair.BeginObject
         .Add('cardNo',            Data[I].cardNo)
         .Add('orderId',           Data[I].orderId)
         .Add('orderExtendedId',   Data[I].orderExtendedId)
         .Add('stationExtendedId', Data[I].stationExtendedId)
         .Add('fuelId',            Data[I].fuelId)
         .Add('cost',             Data[I].cost)
         .Add('count',            Data[I].count)
         .Add('price',            Data[I].price)
         .Add('orderDateUtc',     Data[I].orderDateUtc)
         .Add('orderDateLocal',   Data[I].orderDateLocal)
         .EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function PaymentMoykaTotalToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPaymentMoykaTotal): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
  FormatSettings: TFormatSettings;
begin

  FormatSettings.DecimalSeparator := '.';

  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject
         .Add('iddevice',       Data[I].iddevice)
         .Add('TotalMoney',     Data[I].TotalMoney)
         .Add('NotCheckMoney',  Data[I].NotCheckMoney)
         .Add('isBank',         Data[I].isBank)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function PaymentMoykalistToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TPaymentMoykaList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
  FormatSettings: TFormatSettings;
begin

  FormatSettings.DecimalSeparator := '.';

  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject
         .Add('id',           Data[I].id)
         .Add('iddevice',     Data[I].iddevice)
         .Add('money',        Data[I].money)
         .Add('dateadd',      DateTimeToStr(Data[I].dateadd))
         .Add('check',        Data[I].check)
         .Add('isBank',       Data[I].isBank)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function TsalesBonusCardToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TsalesBonusCard): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;

    Pairs.Add('ErrorCode',      ErrorCode)
        .Add('Result',          DescriptionError)
        .Add('idCard',          Data.idCodeCard)
        .Add('codeCard',        Data.barcode)
        .Add('quantityFuel',    Data.quantityFuel)
        .Add('sumFuel',         Data.sumFuel)
        .Add('quantityService', Data.quantityService)
        .Add('sumService',      Data.sumService)
        .Add('quantityTobacco', Data.quantityTobacco)
        .Add('sumTobacco',      Data.sumTobacco)
        .Add('quantityGoods',   Data.quantityGoods)
        .Add('sumGoods',        Data.sumGoods);



    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;


function TsalesBonusCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TsalesBonusCardList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
  FormatSettings: TFormatSettings;
begin
  result := '';
  FormatSettings.DecimalSeparator := '.';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;

    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject
        .Add('idCard',          Data[I].idCodeCard)
        .Add('codeCard',        Data[I].barcode)
        .Add('quantityFuel',    Data[I].quantityFuel)
        .Add('sumFuel',         Data[I].sumFuel)
        .Add('quantityService', Data[I].quantityService)
        .Add('sumService',      Data[I].sumService)
        .Add('quantityTobacco', Data[I].quantityTobacco)
        .Add('sumTobacco',      Data[I].sumTobacco)
        .Add('quantityGoods',   Data[I].quantityGoods)
        .Add('sumGoods',        Data[I].sumGoods)
        .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function TBirthdayCardListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:TBirthdayCardList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  I:integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

         arrayPair.BeginObject
         .Add('birthday',      DateTimeToStr(Data[I].birthday))
         .Add('namePerson',    Data[I].namePerson)
         .Add('codecard',      Data[I].codecard)
         .Add('idCard',       Data[I].idCard)
         .EndObject;

      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

function Tdc_EngineFixCardsListToJSON(ErrorCode: Integer; DescriptionError:AnsiString; Data:Tdc_EngineFixCardsList): string;
var
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  Builder: TJSONObjectBuilder;
  Pairs, DocumentHeader: TJSONObjectBuilder.TPairs;
  arrayPair:TJSONObjectBuilder.TElements;
  DocumentTable:TJSONObjectBuilder.TElements;
  I:integer;
  J: Integer;
begin
  result := '';
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    Pairs:=Builder.BeginObject;
    Pairs.Add('ErrorCode',ErrorCode);
    Pairs.Add('Result', DescriptionError);
    if Data<>nil then
    begin
      arrayPair := Pairs.BeginArray('Data');
      for I := Low(Data) to High(Data) do
      begin

           DocumentHeader := arrayPair.BeginObject
                             .Add('Registr',      BoolToIntSTR(Data[I].Registr))
                             .Add('guiddoc',      Data[I].guiddoc)
                             .Add('idrecord',     Data[I].idrecord)
                             .Add('idcode',       Data[I].idcode)
                             .Add('iddate',       Data[I].iddate)
                             .Add('datecreate',   Data[I].datecreate)
                             .Add('comment',      Data[I].comment)
                             .Add('count_tddc_enginefixcards',      Data[I].count_tddc_enginefixcards);

           DocumentTable :=  DocumentHeader.BeginArray('tddc_enginefixcards');
           for J := Low(Data[I].tddc_enginefixcards) to High(Data[I].tddc_enginefixcards) do
           begin
               DocumentTable.BeginObject
                            .Add('guiddoc', Data[I].tddc_enginefixcards[J].guiddoc)
                            .Add('guiddocInteger', '')
                            .Add('card', Data[I].tddc_enginefixcards[J].card)
                            .Add('bonus', Data[I].tddc_enginefixcards[J].bonus)
                            .EndObject;
           end;
           DocumentTable.EndArray;

          DocumentHeader.EndObject;
      end;
      arrayPair.EndArray;
    end;

    Pairs.EndObject;
    result := StringBuilder.ToString;
  finally
    FreeAndNil(Writer);
    FreeAndNil(StringWriter);
    FreeAndNil(StringBuilder);
    FreeAndNil(Builder);
  end;
end;

Function JSONToTInfoGoods(AJson:String; var infoGoods :TInfoGoods):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='idcode' then
         infoGoods.idCode := Json.AsString;

       if JSON.Key='article' then
         infoGoods.article  := Json.AsString;

       if JSON.Key='name' then
         infoGoods.idName := Json.AsString;

       if JSON.Key='namefull' then
         infoGoods.fullName := Json.AsString;

       if JSON.Key='unit' then
         infoGoods.unitCode := Json.AsString;

       if JSON.Key='nds' then
         infoGoods.nds := Json.AsInteger;

       if JSON.Key='idgroup' then
          infoGoods.idGroup := Json.AsString;

       if JSON.Key='level' then
          infoGoods.level := Json.AsInteger;

       if JSON.Key='is_service' then
          infoGoods.is_service := Json.AsInteger;

       if JSON.Key='is_fuel' then
          infoGoods.is_fuel := Json.AsInteger;

       if JSON.Key='is_tobacco' then
          infoGoods.is_tobacco := Json.AsInteger;

       if JSON.Key='guid' then
          infoGoods.guid := Json.AsInteger;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;


Function JSONToTInfoGroupGoods(AJson:String; var infoGroupGoods :TInfoGroupGoods):boolean;
var
  Json: TJSONIterator;

  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='idcode' then
         infoGroupGoods.idCode := Json.AsString;

       if JSON.Key='name' then
         infoGroupGoods.idName := Json.AsString;

       if JSON.Key='idgroup' then
          infoGroupGoods.idGroup := Json.AsString;

       if JSON.Key='level' then
          infoGroupGoods.level := Json.AsInteger;

       if JSON.Key='guid' then
          infoGroupGoods.guid := Json.AsInteger;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;

Function JSONToTEnginefixcardsAnswer(AJson:String; var EnginefixcardsAnswer :TEnginefixcardsAnswer):boolean;
var
  Json: TJSONIterator;
  TextReader: TStringReader;
  Reader: TJsonTextReader;
begin

  TextReader:=TStringReader.Create(AJson);
  Reader:=TJsonTextReader.Create(TextReader);
  Json:=TJSONIterator.Create(Reader);

  try
    while JSON.Next do
    begin
       if JSON.Key='towrite' then
         EnginefixcardsAnswer.toWrite := Json.AsInteger;

       if JSON.Key='idrecord' then
         EnginefixcardsAnswer.idrecord  := Json.AsString;

       if JSON.Key='idcode' then
         EnginefixcardsAnswer.idcode  := Json.AsString;

       if JSON.Key='iddate' then
         EnginefixcardsAnswer.iddate  := Json.AsString;

    end;

  finally
    Json.Free;
    Reader.Free;
    TextReader.Free;
  end;

  result := true;
end;

end.
