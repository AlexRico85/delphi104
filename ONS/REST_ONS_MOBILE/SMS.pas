unit SMS;

interface

uses
  IdHTTP,IdURI, StrUtils, System.SysUtils,System.Classes,Winapi.Windows;

type

 TSMSParams = record
    Server: string;
    Login: string;
    Pass: string;
    Phone: string;
    SMS: string;
  end;

Function SENDSMS(SMSParams:TSMSParams; var ResultOperation:String):boolean;
Function NewSMSCode():Integer;

implementation

Function DecodeParamString(Param:string;TextParam:string):string;

var
  numparam:integer;
begin
  numparam:=AnsiPos(Param+' = ',TextParam);
  if numparam=0 then
  begin
    result := 'null';
    exit;
  end;
  result := Copy(TextParam, numparam+Length(Param+' = '), Length(TextParam));
end;

Function DecodeParamStrings(Param:string;StringParam:TStringList):string;
 var
  I:integer;
  temp:string;
 begin
   result:='null';
   for I := 0 to StringParam.Count-1 do
   begin
      temp := DecodeParamString(Param,StringParam[i]);
      if temp<>'null' then
        result:= temp;
   end;
 end;

Function SENDSMS(SMSParams:TSMSParams; var ResultOperation:String):boolean;
Var
  IdHTTPGetImage:TIdHTTP;
  SMSEncode:string;
  resGet:string;
  ResultStrings:TStringList;
  ErrorCode, StatusGet:string;
  queryGet:String;
begin

   resGet:='';
   SMSEncode := IdURI.TIdURI.ParamsEncode(SMSParams.SMS);

   queryGet := SMSParams.Server+'?login='+SMSParams.Login+'&psw='+SMSParams.Pass+'&phones='+SMSParams.Phone+'&mes='+SMSEncode;

   IdHTTPGetImage := TIdHTTP.Create(nil);
   IdHTTPGetImage.ConnectTimeout:=1000;
   try
      try
        resGet := IdHTTPGetImage.Get(queryGet);
      except
        on E:Exception do
        begin
          result:=False;
          exit;
        end;
      end;
   finally
     IdHTTPGetImage.Free;
   end;

   Try
     ResultStrings:=TStringList.Create;
     ResultStrings.StrictDelimiter := True;
     ResultStrings.Delimiter:=',';
     ResultStrings.DelimitedText:=resGet;

     ErrorCode := AnsiLeftStr(resGet, 2);

     if ErrorCode <> 'OK' then
     begin

       ResultOperation := DecodeParamStrings('ERROR',ResultStrings);
       ErrorCode :=  AnsiLeftStr (ResultOperation, 1);
       result := false;

     end else
     Begin

        ResultOperation := resGet;
        Result := true;

     End;

   Finally

     FreeAndNil(ResultStrings);

   End;



end;

Function NewSMSCode():Integer;
begin
  Randomize;
  result := 1 + Random(9999);
end;


end.
