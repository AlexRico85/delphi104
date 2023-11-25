unit mURI;

interface

function URLEncode(const S: string): string;
function URLDecode(const S: string): string;
function utf16decode(const encode:string):string;

implementation

function DigitToHex(Digit: Integer): Char;
begin
  case Digit of
    0 .. 9:
      Result := Chr(Digit + Ord('0'));
    10 .. 15:
      Result := Chr(Digit - 10 + Ord('A'));
  else
    Result := '0';
  end;
end; // DigitToHex

function URLEncode(const S: string): string;
var
  i, idx, len: Integer;
begin
  len := 0;
  for i := 1 to Length(S) do
    if ((S[i] >= '0') and (S[i] <= '9')) or ((S[i] >= 'A') and (S[i] <= 'Z')) or
      ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or (S[i] = '_') or
      (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
      len := len + 1
    else
      len := len + 3;
  SetLength(Result, len);
  idx := 1;
  for i := 1 to Length(S) do
    if S[i] = ' ' then
    begin
      Result[idx] := '+';
      idx := idx + 1;
    end
    else if ((S[i] >= '0') and (S[i] <= '9')) or
      ((S[i] >= 'A') and (S[i] <= 'Z')) or ((S[i] >= 'a') and (S[i] <= 'z')) or
      (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
    begin
      Result[idx] := S[i];
      idx := idx + 1;
    end
    else
    begin
      Result[idx] := '%';
      Result[idx + 1] := DigitToHex(Ord(S[i]) div 16);
      Result[idx + 2] := DigitToHex(Ord(S[i]) mod 16);
      idx := idx + 3;
    end;
end; // URLEncode

function URLDecode(const S: string): string;
var
  i, idx, len, n_coded: Integer;
  function WebHexToInt(HexChar: Char): Integer;
  begin
    if HexChar < '0' then
      Result := Ord(HexChar) + 256 - Ord('0')
    else if HexChar <= Chr(Ord('A') - 1) then
      Result := Ord(HexChar) - Ord('0')
    else if HexChar <= Chr(Ord('a') - 1) then
      Result := Ord(HexChar) - Ord('A') + 10
    else
      Result := Ord(HexChar) - Ord('a') + 10;
  end;

begin
  len := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
        n_coded := 0;
    end
    else
    begin
      len := len + 1;
      if S[i] = '%' then
        n_coded := 1;
    end;
  SetLength(Result, len);
  idx := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
      begin
        Result[idx] := Chr((WebHexToInt(S[i - 1]) * 16 + WebHexToInt(S[i])
          ) mod 256);
        n_coded := 0;
      end;
    end
    else
    begin
      idx := idx + 1;
      if S[i] = '%' then
        n_coded := 1;
      if S[i] = '+' then
        Result[idx] := ' '
      else
        Result[idx] := S[i];
    end;
end; // URLDecode


function utf16decode(const encode:string):string;
var
presult,psource:PChar;
s:string;
buf,code:Integer;
begin
try
SetLength(result, length(encode));
presult:=pchar(result);
psource:=pchar(encode);

while psource^<>#0 do
begin
if (psource^='\') then
begin
  inc(psource);
  if psource^='u' then
  begin
    psource^:='x';
    SetString(s,psource,5);
    Val(s,buf,code);
    if buf>=$100 then
    begin
      s:=WideChar(buf);
      presult^:=s[1];
    end
    else
      presult^:=chr(buf);
    Inc(psource,5);
  end
  else
    presult^:='\';
end
else
begin
  presult^:=psource^;
  Inc(psource);
end;

Inc(presult);
end;
SetLength(result, presult - pchar(Result));
except
result:='error';
end;
end;

end.
