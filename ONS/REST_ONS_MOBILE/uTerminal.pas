unit uTerminal;

interface
uses
  System.SysUtils, System.StrUtils, System.Math, FireDAC.Comp.Client, System.Classes, structures, System.JSON, FireDAC.DApt,
  Datasnap.DSAuth;

  type
  {$METHODINFO ON}
  [TRoleAuth('admin')]
  Terminal = class(TComponent)
    FDConnection: TFDConnection;
  private
    FClientMySQLSet:TClientMySQLSet;
    Procedure Connect();
    Procedure DisConnect();
  public
    { Public declarations }
    function updateGetPaymentMoyka(JsonText: String): TJSONObject;
    function updateGetPaymentMoykaCheckList(JsonText: String): TJSONObject;

  end;
{$METHODINFO OFF}

implementation

uses FunctionMySQL, JsonSerialization, uLog, uSqlList, frmSettingUnit, uWriteDataSQL;

{ Terminal }

procedure Terminal.Connect;
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

procedure Terminal.DisConnect;
begin
  FDConnection.Connected := false;
  FreeAndNil(FDConnection);
end;

{ Terminal Public }

function Terminal.updateGetPaymentMoyka(JsonText: String): TJSONObject;
var
  QueryGetPaymentMoyka:TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  N:integer;
  begdate, codeterminal:string;
  resultText : string;
  PaymentMoykaTotal:TPaymentMoykaTotal;

  koef:double;
begin

  Connect;
  QueryGetPaymentMoyka := TFDQuery.Create(nil);
  QueryGetPaymentMoyka.Connection :=  FDConnection;
  QueryGetPaymentMoyka.SQL.Text := SqlList['Get_payment_moyka'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  try

    JSonValue := Json.FindValue('begdate');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    begdate := JSonValue.Value;

    JSonValue := Json.FindValue('codeterminal');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    codeterminal := JSonValue.Value;

    koef := 1;

    QueryGetPaymentMoyka.Active := False;
    QueryGetPaymentMoyka.Params[0].Value := codeterminal;
    QueryGetPaymentMoyka.Params[1].Value := begdate;


    try
      QueryGetPaymentMoyka.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetPaymentMoyka.Last;
    N:=0;
    SetLength(PaymentMoykaTotal, QueryGetPaymentMoyka.RecordCount);
    QueryGetPaymentMoyka.First;
    while not QueryGetPaymentMoyka.Eof do
    begin
      with QueryGetPaymentMoyka do
      begin
        PaymentMoykaTotal[N].iddevice       := FieldByName('iddevice').AsString;
        PaymentMoykaTotal[N].TotalMoney     := FieldByName('TotalMoney').AsFloat;
        PaymentMoykaTotal[N].NotCheckMoney  := FieldByName('NotCheckMoney').AsFloat;
        PaymentMoykaTotal[N].isBank         := FieldByName('isBank').AsInteger;

        if PaymentMoykaTotal[N].isBank = 0 then
        begin
          PaymentMoykaTotal[N].TotalMoney     := PaymentMoykaTotal[N].TotalMoney * koef;
          PaymentMoykaTotal[N].NotCheckMoney  := PaymentMoykaTotal[N].NotCheckMoney * koef;
        end;

      end;

      QueryGetPaymentMoyka.Next;

      N:=N+1;
    end;

  finally
    FreeAndNil(QueryGetPaymentMoyka);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := PaymentMoykaTotalToJSON(0, 'ОК', PaymentMoykaTotal);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;


function Terminal.updateGetPaymentMoykaCheckList(JsonText: String): TJSONObject;
var
  QueryGetPaymentMoyka:TFDQuery;
  JSON:TJSONObject;
  JSonValue:TJSONValue;

  N:integer;
  begdate, codeterminal:string;
  resultText : string;
  PaymentMoykalist:TPaymentMoykalist;

  koef:double;
begin

  Connect;
  QueryGetPaymentMoyka := TFDQuery.Create(nil);
  QueryGetPaymentMoyka.Connection :=  FDConnection;
  QueryGetPaymentMoyka.SQL.Text := SqlList['Get_payment_moyka_check_list'];

  JSON:=TJSONObject.ParseJSONValue(JsonText, False, True) as TJSONObject;
  try

    JSonValue := Json.FindValue('begdate');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    begdate := JSonValue.Value;

    JSonValue := Json.FindValue('codeterminal');
    if JSonValue = nil then
    begin
      Raise Exception.Create('Не верные параметры запроса');
    end;

    codeterminal := JSonValue.Value;

    koef := 1;

    QueryGetPaymentMoyka.Active := False;
    QueryGetPaymentMoyka.Params[0].Value := codeterminal;
    QueryGetPaymentMoyka.Params[1].Value := begdate;


    try
      QueryGetPaymentMoyka.Open;
    except
      Raise Exception.Create('Ошибка выполнения запроса');
    end;

    QueryGetPaymentMoyka.Last;
    N:=0;
    SetLength(PaymentMoykalist, QueryGetPaymentMoyka.RecordCount);
    QueryGetPaymentMoyka.First;
    while not QueryGetPaymentMoyka.Eof do
    begin
      with QueryGetPaymentMoyka do
      begin
        PaymentMoykalist[N].id             := FieldByName('id').AsInteger;
        PaymentMoykalist[N].iddevice       := FieldByName('iddevice').AsString;
        PaymentMoykalist[N].dateadd        := FieldByName('dateadd').AsDateTime;
        PaymentMoykalist[N].money          := FieldByName('money').AsFloat;
        PaymentMoykalist[N].isBank         := FieldByName('isBank').AsInteger;
        PaymentMoykalist[N].check          := FieldByName('oncheck').AsInteger;

        if PaymentMoykalist[N].isBank = 0 then
        begin
          PaymentMoykalist[N].money     := PaymentMoykalist[N].money * koef;
        end;

      end;

      QueryGetPaymentMoyka.Next;

      N:=N+1;
    end;

  finally
    FreeAndNil(QueryGetPaymentMoyka);
    FreeAndNil(JSON);
    DisConnect;
  end;

  resultText := PaymentMoykalistToJSON(0, 'ОК', PaymentMoykalist);
  Result := TJSONObject.ParseJSONValue(resultText, False, True) as TJSONObject;

end;

end.
