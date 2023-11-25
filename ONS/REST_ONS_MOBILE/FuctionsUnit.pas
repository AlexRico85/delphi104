unit FuctionsUnit;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TDataOperation = record
    Operation: Byte;
    StatusOperation: Byte;
    DataOperation: WORD;
    TickMany: integer;
    GlobalID: integer;
    OnDate: TDateTime;
    OffDate: TDateTime;
    IdPost: WORD;
    sec: integer;
  end;


Function ControlNumberEan13(BarCode: string): string;
// 177,35742
Function ReadTestEMarine(RFID: string): boolean;
Function ReadTestINN(INN: string): boolean;

function ReadTestBarCodeEAN13(BarCode: string): boolean;

Function DeleteSymbols(RFID: string): string;

function HexToInt(HexStr: string): Int64;

function UnixToDateTime(USec: Longint): TDateTime;

Procedure DecodeHexToStrings(HexTex: string; var Strings: TStringList);
Function DecodeParamString(Param: string; TextParam: string): string;
Function ByteHexDownUP(HexTex: string): String;
Function DecodeHexStringToOperation(HexTex: string): TDataOperation;
Function DecodeParamStrings(Param: string; StringParam: TStringList; ForTo, ForDo: integer): string;

function convertir_utf8_ansi(const Source: string): string;

function DecToch(Flot: string): string;
function DecComma(Flot: string): string;
Function DeleteSymbolFromName(Str: string): string;

Function ToCompareTwoStrings(template: string; target: string): integer;

function ClearDenySymbol(var Input: string; EArray: string; Action: integer): string;

function BoolToIntSTR(b: boolean): String;
function IntSTRToBool(b: string): Boolean;

function IntToBool(b: Integer): Boolean;

Function StrToStrInt(str: string): String;


const
  idgroupfuel: string = '00000000028';

implementation

const
  // Sets UnixStartDate to TDateTime of 01/01/1970
  UnixStartDate: TDateTime = 25569.0;

Function ControlNumberEan13(BarCode: string): string;
var
  Numbers: array [1 .. 12] of integer;
  I: integer;
  TempA: integer;
  TempB: integer;
  TempC: integer;
  TempE: integer;
  TempF: integer;
begin
  if Length(BarCode) < 12 then
  begin
    result := '0';
  end;

  for I := 1 to 12 do
    Numbers[I] := StrToInt(Copy(BarCode, I, 1));

  TempA := Numbers[2] + Numbers[4] + Numbers[6] + Numbers[8] + Numbers[10] + Numbers[12];
  TempB := Numbers[1] + Numbers[3] + Numbers[5] + Numbers[7] + Numbers[9] + Numbers[11];
  TempC := (TempA * 3) + TempB;
  TempE := Trunc(Int(TempC / 10) * 10) + 10;
  TempF := TempE - TempC;

  result := IntToStr(TempF);

end;

function ReadTestBarCodeEAN13(BarCode: string): boolean;
var
  I: integer;
begin
  result := true;
  if Length(BarCode) <> 13 then
  begin
    result := False;
  end;

  for I := 1 to 13 do
  begin
    if (BarCode[I] <> '1') and
      (BarCode[I] <> '2') and
      (BarCode[I] <> '3') and
      (BarCode[I] <> '4') and
      (BarCode[I] <> '5') and
      (BarCode[I] <> '6') and
      (BarCode[I] <> '7') and
      (BarCode[I] <> '8') and
      (BarCode[I] <> '9') and
      (BarCode[I] <> '0') then
    begin
      result := False;
    end;

  end;

end;

Function ReadTestINN(INN: string): boolean;
var
  I: integer;
begin
  result := true;

  if Length(INN) < 10 then
  begin
    result := False;
    exit;
  end;

  for I := 1 to Length(INN) do
  begin
    if (INN[I] <> '1') and
      (INN[I] <> '2') and
      (INN[I] <> '3') and
      (INN[I] <> '4') and
      (INN[I] <> '5') and
      (INN[I] <> '6') and
      (INN[I] <> '7') and
      (INN[I] <> '8') and
      (INN[I] <> '9') and
      (INN[I] <> '0') then
    begin
      result := False;
    end;

  end;

end;

Function ReadTestEMarine(RFID: string): boolean;
var
  I: integer;
begin
  result := true;
  if Length(RFID) = 7 then
  begin
    RFID := '0' + RFID;
  end;
  if Length(RFID) < 8 then
  begin
    result := False;
    exit;
  end;

  for I := 1 to Length(RFID) do
  begin
    if (RFID[I] <> '1') and
      (RFID[I] <> '2') and
      (RFID[I] <> '3') and
      (RFID[I] <> '4') and
      (RFID[I] <> '5') and
      (RFID[I] <> '6') and
      (RFID[I] <> '7') and
      (RFID[I] <> '8') and
      (RFID[I] <> '9') and
      (RFID[I] <> '0') then
    begin
      result := False;
    end;

  end;

end;

Function StrToStrInt(str: string): String;
var
  I: integer;
  ResultStr: String;
begin
  ResultStr := '';
  for I := 1 to Length(str) do
  begin
    if (str[I] = '1') or
      (str[I] = '1') or
      (str[I] = '2') or
      (str[I] = '3') or
      (str[I] = '4') or
      (str[I] = '5') or
      (str[I] = '6') or
      (str[I] = '7') or
      (str[I] = '8') or
      (str[I] = '9') or
      (str[I] = '0') then
    begin
      ResultStr := ResultStr+str[I];
    end;

  end;
  Result := ResultStr;
end;

Function DeleteSymbols(RFID: string): string;
begin
  While pos(',', RFID) > 0 do
  begin
    Delete(RFID, pos(',', RFID), 1);
  end;

  While pos('.', RFID) > 0 do
  begin
    Delete(RFID, pos('.', RFID), 1);
  end;

  While pos(' ', RFID) > 0 do
  begin
    Delete(RFID, pos(' ', RFID), 1);
  end;

  if Length(RFID) = 7 then
  begin
    RFID := '0' + RFID;
  end;

  result := RFID;
end;

function HexToInt(HexStr: string): Int64;
var
  RetVar: Int64;
  I: Byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[Length(HexStr)] = 'H' then
    Delete(HexStr, Length(HexStr), 1);
  RetVar := 0;

  for I := 1 to Length(HexStr) do
  begin
    RetVar := RetVar shl 4;
    if HexStr[I] in ['0' .. '9'] then
      RetVar := RetVar + (Byte(HexStr[I]) - 48)
    else
      if HexStr[I] in ['A' .. 'F'] then
      RetVar := RetVar + (Byte(HexStr[I]) - 55)
    else
    begin
      RetVar := 0;
      break;
    end;
  end;

  result := RetVar;
end;

function UnixToDateTime(USec: Longint): TDateTime;
begin
  // Example: UnixToDateTime(1003187418);
  // Result := ((Usec +10800) / 86400) + UnixStartDate;
  result := ((USec) / 86400) + UnixStartDate;
end;

Procedure DecodeHexToStrings(HexTex: string; var Strings: TStringList);
var
  TempA: string;
  I: integer;
begin
  while HexTex <> '' do
  begin
    TempA := '';
    TempA := Copy(HexTex, 1, 44);
    Strings.Add(TempA);
    Delete(HexTex, 1, 44);
  end;
end;

Function DecodeParamString(Param: string; TextParam: string): string;
var
  numparam: integer;
begin
  numparam := pos(Param + '=', TextParam);
  if numparam = 0 then
  begin
    result := 'null';
    exit;
  end;

  result := Copy(TextParam, numparam + Length(Param + '='), Length(TextParam) - Length(Param + '='));

end;

Function DecodeParamStrings(Param: string; StringParam: TStringList; ForTo, ForDo: integer): string;
var
  I: integer;
  temp: string;
begin
  result := '';
  for I := ForTo to ForDo do
  begin
    temp := DecodeParamString(Param, StringParam[I]);
    if temp <> 'null' then
      result := temp;
  end;

end;

Function ByteHexDownUP(HexTex: string): String;
var
  TempA: string;
  I: integer;
  UpHex: integer;
begin
  UpHex := Length(HexTex) div 2;
  TempA := '';
  for I := UpHex downto 1 do
  begin
    TempA := TempA + Copy(HexTex, I * 2 - 1, 2);
  end;
  result := TempA;
end;

Function DecodeHexStringToOperation(HexTex: string): TDataOperation;
var
  DataOperation: TDataOperation;
  TempA: string;
  TIMESTAMPON, TIMESTAMPOFF: integer;
begin

  TempA := ByteHexDownUP(Copy(HexTex, 1, 2)); // 1-2
  DataOperation.Operation := HexToInt(TempA);

  if DataOperation.Operation <5 then
  begin

   { 0 байт -  BYTE - Операция - 1 - зачисление монеты, 2 - зачисление купюры, 3 – программы, 4 - события
    1 байт -  BYTE - Статус операции 1- готово к отправке 200 - отправлено  - служебная внутренняя информация
    2-3 байты- WORD - Данные - Деньги, номер программы, номер события
    4-7 байты -  DWORD – Счетчик денег
    8 -11 байты - DWORD - Глобальный ID
    12-15 байты - ToD - Date_and_time on формат время+дата
    16-19 байты - ToD - Date_and_time off формат время+дата
    20-21 – байты –WORD  - номер поста   }


    TempA := ByteHexDownUP(Copy(HexTex, 3, 2)); // 3-4
    DataOperation.StatusOperation := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 5, 4)); // 5-8
    DataOperation.DataOperation := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 9, 8)); // 9-16
    DataOperation.TickMany := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 17, 8)); // 17-24
    DataOperation.GlobalID := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 25, 8)); // 25-32
    TIMESTAMPON := HexToInt(TempA);
    DataOperation.OnDate := UnixToDateTime(TIMESTAMPON);

    TempA := ByteHexDownUP(Copy(HexTex, 33, 8)); // 33-40
    TIMESTAMPOFF := HexToInt(TempA);
    DataOperation.OffDate := UnixToDateTime(TIMESTAMPOFF);

    TempA := ByteHexDownUP(Copy(HexTex, 41, 4)); // 41-44
    DataOperation.IdPost := HexToInt(TempA);

  end else
  if DataOperation.Operation =5 then
  begin
      {Удачное списание баланса:
      0 байт - 5

      1 байт - 1
      2-3 байт - сумма списания
      4-7 байт - ID Операции списания (получаем от сервера)
      8-11 байт - Номер карты Rfid
      12-15 байт - Время операции
      16-19 байт - Время операции
      20-21 байт - Номер поста

      Ошибка, возникшая при попытке списать баланс:
      0 байт - 5

      1 байт - 2
      2-3 байт - сумма списания
      4-7 байт - Номер карты Rfid
      8-11 байт -  Ошибка, возникшая при попытке списать баланс
      12-15 байт - Время операции
      16-19 байт - Время операции
      20-21 байт - Номер поста  }

    TempA := ByteHexDownUP(Copy(HexTex, 3, 2)); // 3-4 символ, 1 байт - 1
    DataOperation.StatusOperation := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 5, 4)); // 5-8 символ, 2-3 байт - сумма списания
    DataOperation.DataOperation := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 9, 8)); // 9-16 , 4-7 байт - ID Операции списания (получаем от сервера)
    DataOperation.TickMany := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 17, 8)); // 17-24, 8-11 байт - Номер карты Rfid
    DataOperation.GlobalID := HexToInt(TempA);

    TempA := ByteHexDownUP(Copy(HexTex, 25, 8)); // 25-32, 12-15 байт - Время операции
    TIMESTAMPON := HexToInt(TempA);
    DataOperation.OnDate := UnixToDateTime(TIMESTAMPON);

    TempA := ByteHexDownUP(Copy(HexTex, 33, 8)); // 33-40 ,16-19 байт - Время операции
    TIMESTAMPOFF := HexToInt(TempA);
    DataOperation.OffDate := UnixToDateTime(TIMESTAMPOFF);

    TempA := ByteHexDownUP(Copy(HexTex, 41, 4)); // 41-44, 20-21 байт - Номер поста
    DataOperation.IdPost := HexToInt(TempA);
  end;

    DataOperation.sec := TIMESTAMPOFF - TIMESTAMPON;

  result := DataOperation;
end;

function convertir_utf8_ansi(const Source: string): string;
var
  Iterator, SourceLength, FChar, NChar: integer;
begin
  result := '';
  Iterator := 0;
  SourceLength := Length(Source);
  while Iterator < SourceLength do
  begin
    Inc(Iterator);
    FChar := Ord(Source[Iterator]);
    if FChar >= $80 then
    begin
      Inc(Iterator);
      if Iterator > SourceLength then
        break;
      FChar := FChar and $3F;
      if (FChar and $20) <> 0 then
      begin
        FChar := FChar and $1F;
        NChar := Ord(Source[Iterator]);
        if (NChar and $C0) <> $80 then
          break;
        FChar := (FChar shl 6) or (NChar and $3F);
        Inc(Iterator);
        if Iterator > SourceLength then
          break;
      end;
      NChar := Ord(Source[Iterator]);
      if (NChar and $C0) <> $80 then
        break;
      result := result + WideChar((FChar shl 6) or (NChar and $3F));
    end
    else
      result := result + WideChar(FChar);
  end;
end;

function DecToch(Flot: string): string;
begin
  result := StringReplace(Flot, ',', '.', []);
end;

function DecComma(Flot: string): string;
begin
  result := StringReplace(Flot, '.', ',', []);
end;

Function DeleteSymbolFromName(Str: string): string;
var
  temp: string;
  res: integer;
begin
  temp := Str;
  while AnsiPos('''', temp) > 0 do
  begin
    res := AnsiPos('''', temp);
    Delete(temp, res, 1);
  end;

  while AnsiPos('`', temp) > 0 do
  begin
    Delete(temp, AnsiPos('`', temp), 1);
  end;

  while AnsiPos('"', temp) > 0 do
  begin
    Delete(temp, AnsiPos('"', temp), 1);
  end;

  while AnsiPos('\', temp) > 0 do
  begin
    Delete(temp, AnsiPos('\', temp), 1);
  end;

  while AnsiPos('/', temp) > 0 do
  begin
    Delete(temp, AnsiPos('/', temp), 1);
  end;

  result := temp;
end;

Function ToCompareTwoStrings(template: string; target: string): integer;
var
  I: integer;
begin
  template := LowerCase(TRIM(template));
  target := LowerCase(TRIM(target));
  {for I := 0 to Length() do
  begin

  end;}
end;


{ **** UBPFD *********** by delphibase.endimus.com ****
>> Функция для удаления из строки "лишних" символов.

Функция для удаления из строки "лишних" символов.
Входные параметры:
Input - входная строка, которую необходимо очистить от лишних символов
EArray - строка, содержащая набор разрешенных или запрещеных символов
в зависимости от Action
Action - указывает на то, что из себя представляет массив EArray.

Action может принимать следующие значения:
1 - массив EArray представляет собой строку разрешенных символов
2 - EArray - массив запрещенных символов.

Зависимости: делал в Д5, 6 под Win9x
Автор:       Ru, DiVo_Ru@rambler.ru, Одесса
Copyright:   DiVo 2002, creator Ru
Дата:        11 ноября 2002 г.
***************************************************** }

function ClearDenySymbol(var Input: string; EArray: string; Action: integer): string;
begin
  case Action of
    1:
      begin
        while length(Input) <> 0 do
        begin
          if pos(Input[1], EArray) = 0 then
            delete(Input, 1, 1)
          else
          begin
            result := result + Input[1];
            delete(Input, 1, 1);
          end;
        end;
      end;
    2:
      begin
        while length(Input) <> 0 do
        begin
          if pos(Input[1], EArray) <> 0 then
            delete(Input, 1, 1)
          else
          begin
            result := result + Input[1];
            delete(Input, 1, 1);
          end;
        end;
      end;
  end;
end;

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


end.
