unit FunctionMySQL;

interface

uses
  Winapi.Windows, System.Variants, System.SysUtils, System.Classes, Data.DB,
  DateUtils, Math,
  Data.SqlExpr,
  FireDAC.Comp.Client,
  structures,
  IdURI, IdGlobal;

function ConnectToServer(var ErrorDescription: AnsiString; var FDConnection: TFDConnection; ClientMySQLSet: TClientMySQLSet): boolean;
function DisConnectToServer(var ErrorDescription: AnsiString; var FDConnection: TFDConnection): boolean;

// Заполнение данных
Function FillRateBonusAction(var RateBonusCard:TRateBonusCard; var ADOMySQLConnection: TFDConnection):boolean;
// Функции
Function GetNewUnicode(var ErrorDescription: AnsiString; discrprm: string; userloginprm: string; var ADOMySQLConnection: TFDConnection): integer;

implementation



function ConnectToServer(var ErrorDescription: AnsiString; var FDConnection: TFDConnection; ClientMySQLSet: TClientMySQLSet): boolean;
var
  res: string;
begin

  FDConnection.DriverName := 'MySQL';
  FDConnection.Connected := false;
  FDConnection.LoginPrompt := false;

  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=MySQL');
  FDConnection.Params.Add('CharacterSet=utf8');
  FDConnection.Params.Add('Server=' + ClientMySQLSet.ServerAdress);
  FDConnection.Params.Add('Database=' + ClientMySQLSet.DataBase);
  FDConnection.Params.Add('User_Name=' + ClientMySQLSet.Login);
  FDConnection.Params.Add('Password=' + ClientMySQLSet.Uinpromt);
 // FDConnection.Params.Add('LoginTimeout=1');
//  FDConnection.Params.Add('ReadTimeout=60');



  ErrorDescription := '';
  try
    FDConnection.Connected := true;
  Except
    on E: Exception do
    begin
      res := E.Message;
      ErrorDescription := res;
    end;
  end;

  if FDConnection.Connected then
    result := true
  else
    result := false;

end;

function DisConnectToServer(var ErrorDescription: AnsiString; var FDConnection: TFDConnection): boolean;
var
  res: string;
begin
  ErrorDescription := '';

  try
    FDConnection.Connected := false;
    result := true;
  Except
    on E: Exception do
    begin
      res := E.Message;
      ErrorDescription:=res;
      result := false;
    end;
  end;

end;



Function FillRateBonusAction(var RateBonusCard:TRateBonusCard; var ADOMySQLConnection: TFDConnection):boolean;
var
  ADOQueryDiscontList,ADOQueryPersons: TFDQuery;
  ADOQueryGoods,ADOQueryShops: TFDQuery;
  ADOQueryCals: TFDQuery;
  ActionRate,BeforeBonusRate:Double;
  addCondition:String;
  ActionDiscont, extcode:string;
  addConditionNow:Boolean;
  birthday:TDateTime;
  DayYearPerson,DayYearToday:Integer;
  ConditionVal1,ConditionVal2:integer;
  Conditionamt,Conditioncnt:Double;
  ActionId,discontid:integer;
  AmtSales,CntSales:Double;
  BegDate,EndDate:TDateTime;
  ErrorDescription: AnsiString;
begin
  BeforeBonusRate:= RateBonusCard.BonusRate;

  Result:=false;
  extcode :='';

  try



  ADOQueryDiscontList := TFDQuery.Create(nil);
  ADOQueryDiscontList.Connection := ADOMySQLConnection;



  ADOQueryGoods := TFDQuery.Create(nil);
  ADOQueryGoods.Connection := ADOMySQLConnection;

  ADOQueryShops := TFDQuery.Create(nil);
  ADOQueryShops.Connection := ADOMySQLConnection;

  ADOQueryCals := TFDQuery.Create(nil);
  ADOQueryCals.Connection := ADOMySQLConnection;


  ADOQueryDiscontList.SQL.Text :=  'CALL fn_get_list_bonus_disconts();';
  try
    ADOQueryDiscontList.Open;
  except
     on E: Exception do
      begin
         ErrorDescription := E.Message;
         exit;
      end;
  end;

  Result:=true;

  if ADOQueryDiscontList.RecordCount = 0 then
    exit
  else
  begin
    ADOQueryDiscontList.First;
    while not ADOQueryDiscontList.Eof do
    begin

      ActionId:= ADOQueryDiscontList.FieldByName('actionid').AsInteger;
      discontid := ADOQueryDiscontList.FieldByName('discontid').AsInteger;
      ActionRate :=  ADOQueryDiscontList.FieldByName('rate').AsFloat;
      ActionDiscont := ADOQueryDiscontList.FieldByName('action').AsString;
      extcode :=  ADOQueryDiscontList.FieldByName('extcode').AsString;

      // Проверим вхождение номенклатуры в акцию

      ADOQueryGoods.SQL.Text :=

       ' SELECT  '+
       ' idowner, '+
       ' SUM(idall) as idall, '+
       ' SUM(idfind) as idfind  '+
       ' FROM '+
       ' (  '+
       ' SELECT  '+
       '  '+IntToStr(ActionId)+' as idowner,  '+
       ' COUNT(DISTINCT tbrf_types_of_discounts_goods.good) as idall,  '+
       ' 0 as idfind  '+
       ' FROM  '+
       ' tbrf_types_of_discounts_goods '+
       ' WHERE  '+
       ' tbrf_types_of_discounts_goods.`owner` = '+IntToStr(ActionId)+'  '+

       ' UNION ALL  '+

      '  SELECT  '+
      '  '+IntToStr(ActionId)+' as idowner, '+
      '  0 as idall,  '+
      '  COUNT(DISTINCT tbrf_types_of_discounts_goods.good) as idfind  '+
      '  FROM  '+
      '  tbrf_types_of_discounts_goods  '+
      '  WHERE  '+
      '  tbrf_types_of_discounts_goods.`owner` = '+IntToStr(ActionId)+'  AND   '+
      '  tbrf_types_of_discounts_goods.good = '''+RateBonusCard.idGoods+''') as temp   '+
      '  GROUP BY  '+
      '  idowner';



      try
        ADOQueryGoods.Open;
      except
        on E: Exception do
        begin
           ErrorDescription := E.Message;
           ADOQueryDiscontList.Next;
           continue;
        end;

      end;

      if ADOQueryGoods.RecordCount>0 then
      begin
        if (ADOQueryGoods.FieldByName('idall').AsInteger>0) and (ADOQueryGoods.FieldByName('idfind').AsInteger=0) then
        begin
          ADOQueryDiscontList.Next;
          continue;
        end;
      end;


      // Проверим вхождение торговых точек в действие акции

      ADOQueryShops.SQL.Text :=

      'SELECT   '+
      'idowner,  '+
      'SUM(idall) as idall,  '+
      'SUM(idfind) as idfind  '+
      'FROM  '+
      '(  '+
      'SELECT  '+
      ''+IntToStr(discontid)+' as idowner,  '+
      'COUNT(DISTINCT tbdc_enabled_disconts_shops.shop) as idall,  '+
      '0 as idfind  '+
      'FROM  '+
      'tbdc_enabled_disconts_shops  '+
      'WHERE  '+
      'tbdc_enabled_disconts_shops.`owner` = '+IntToStr(discontid)+'  '+
      '  '+
      'UNION ALL  '+
      '  '+
      'SELECT  '+
      ''+IntToStr(discontid)+' as idowner,  '+
      '0 as idall,  '+
      'COUNT(DISTINCT tbdc_enabled_disconts_shops.shop) as idfind  '+
      'FROM  '+
      'tbdc_enabled_disconts_shops  '+
      'WHERE  '+
      'tbdc_enabled_disconts_shops.`owner` = '+IntToStr(discontid)+' AND  '+
      'tbdc_enabled_disconts_shops.shop = '''+RateBonusCard.idShop+''') as temp  '+
      '  '+
      'GROUP BY  '+
      'idowner ';




      try
         ADOQueryShops.Open;
      except
        ADOQueryDiscontList.Next;
        continue;
      end;

      if ADOQueryShops.RecordCount>0 then
      begin
        if (ADOQueryShops.FieldByName('idall').AsInteger>0) and (ADOQueryShops.FieldByName('idfind').AsInteger=0) then
        begin
          ADOQueryDiscontList.Next;
          continue;
        end;
      end;



      // Акции с доп условиями, при не выполнении переходим к следующей
      addConditionNow:=false;
      if ADOQueryDiscontList.FieldByName('add_condition').Value <> Null then
      begin

        addCondition:= ADOQueryDiscontList.FieldByName('add_condition').AsString;
        ConditionVal1:= ADOQueryDiscontList.FieldByName('val1_add_condition').AsInteger;
        ConditionVal2:= ADOQueryDiscontList.FieldByName('val2_add_condition').AsInteger;
        Conditionamt := ADOQueryDiscontList.FieldByName('amt').AsFloat;
        Conditioncnt := ADOQueryDiscontList.FieldByName('cnt').AsFloat;
        /// Если День рождения
        if addCondition = 'birthday' then
        begin
          ADOQueryPersons := TFDQuery.Create(nil);
          ADOQueryPersons.Connection := ADOMySQLConnection;
          ADOQueryPersons.SQL.Text :=

            'SELECT   ' +
            'persons.idname as idname,  ' +
            'persons.birthday as birthday ' +
            'FROM  ' +
            'cartlist  ' +
            'LEFT JOIN persons ON persons.idcode = cartlist.ownercart  ' +
            'WHERE  ' +
            'cartlist.codcart = ''' + RateBonusCard.BarCode + '''  ';
          try
            ADOQueryPersons.Open;
          except
            on E: Exception do
            begin
              ADOQueryDiscontList.Next;
              continue;
            end;
          end;

          if ADOQueryPersons.RecordCount>0 then
          begin
            ADOQueryPersons.First;
            birthday :=  ADOQueryPersons.FieldByName('birthday').AsDateTime;
            DayYearPerson := DayOfTheYear(birthday);
            DayYearToday := DayOfTheYear(Now());
            if IsInLeapYear(birthday)  and (not IsInLeapYear(Now())) then
            begin
              DayYearPerson:=DayYearPerson-1;
            end;
            if ((DayYearPerson>=DayYearToday) and ( DayYearPerson<=(DayYearToday+ConditionVal2)) or
             ((  DayYearPerson<=DayYearToday) and (DayYearPerson>=DayYearToday-ConditionVal1) )) then
             begin
                addConditionNow:=true;
             end;


          end;

        end;

        if addCondition = 'SoldDay' then
        begin

           BegDate:=Date;
           EndDate:=IncDay(Date,ConditionVal1);

           ADOQueryCals.SQL.Text :=
           'SELECT '+
           'ROUND(IFNULL(fn_calc_amt_sales('''+RateBonusCard.BarCode+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',BegDate)+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',EndDate)+''','''+RateBonusCard.idGoods+'''),0),2) as amt';
           try
              ADOQueryCals.Open;
           except
             on E: Exception do
              begin
                ADOQueryDiscontList.Next;
                continue;
              end;
           end;
           ADOQueryCals.First;
           AmtSales :=RateBonusCard.amtSale+ ADOQueryCals.FieldByName('amt').AsFloat;
           ADOQueryCals.Close;

           ADOQueryCals.SQL.Text :=
           'SELECT '+
           'ROUND(IFNULL(fn_calc_cnt_sales('''+RateBonusCard.BarCode+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',BegDate)+''','''+FormatDateTime('yyyy-mm-dd hh:mm:ss',EndDate)+''','''+RateBonusCard.idGoods+'''),0),2) as cnt';
           try
              ADOQueryCals.Open;
           except
             on E: Exception do
              begin
                ADOQueryDiscontList.Next;
                continue;
              end;
           end;
           ADOQueryCals.First;
           CntSales :=RateBonusCard.CntSale+ADOQueryCals.FieldByName('cnt').AsFloat;
           ADOQueryCals.Close;


           if Conditioncnt>0 then
           begin
             if Conditioncnt>CntSales then
             begin
               ADOQueryDiscontList.Next;
               continue;
             end;
           end;

           if Conditionamt>0 then
           begin
             if Conditionamt>AmtSales then
             begin
               ADOQueryDiscontList.Next;
               continue;
             end;
           end;




        end;

        if addConditionNow=false then
        begin
          ADOQueryDiscontList.Next;
          continue;
        end;
      end;

      if ActionDiscont='replace' then
      begin
        if ActionRate>RateBonusCard.BonusRate then
        begin
          RateBonusCard.BonusRate:=ActionRate;
          Result:=true;
        end;

      end;
      if ActionDiscont='combine' then
      begin
        ActionRate:=ActionRate+BeforeBonusRate;
        if ActionRate>RateBonusCard.BonusRate then
        begin
          RateBonusCard.BonusRate:=ActionRate;
          Result:=true;
        end;

      end;
      if ActionDiscont='multiply' then
      begin
        ActionRate:=ActionRate*BeforeBonusRate;
        if ActionRate>RateBonusCard.BonusRate then
        begin
          RateBonusCard.BonusRate:=ActionRate;
          Result:=true;
        end;

      end;

      if ActionDiscont='fix' then
      begin
        RateBonusCard.AmtAction:=ActionRate;
        Result:=true;
      end;
      RateBonusCard.extCodeAction :=  extcode;
      ADOQueryDiscontList.Next;
    end;


  end;


  finally
   ADOQueryDiscontList.Free;
   ADOQueryPersons.Free;
   ADOQueryGoods.Free;
   ADOQueryShops.Free;
   ADOQueryCals.Free;
  end;


end;

Function GetNewUnicode(var ErrorDescription: AnsiString; discrprm: string; userloginprm: string; var ADOMySQLConnection: TFDConnection): integer;
var
  ADOQuerySend: TFDQuery;
  res: string;
begin

  ErrorDescription := '';

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  ADOQuerySend.SQL.Text := 'SELECT funct_newunicode(''' + discrprm + ''',''' + userloginprm + ''') as unicode ';

  try
    ADOQuerySend.Open;
  except
    on E: Exception do
    begin
      result := 0;
      res := E.Message;

      ErrorDescription := res;
      exit;
    end;
  end;

  if ADOQuerySend.RecordCount > 0 then
  begin
    ADOQuerySend.First;
    result := ADOQuerySend.FieldByName('unicode').AsInteger;
  end
  else
    result := 0;

  ADOQuerySend.Free;
end;


end.
