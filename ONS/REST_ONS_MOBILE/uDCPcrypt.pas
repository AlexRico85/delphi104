unit uDCPcrypt;

interface
uses
  DCPrijndael, DCPsha1;

function EncryptString(Source: string): string;
function DecryptString(Source: string): string;

const
  keypassword = 'shla sasha po ulke zolotoy';

implementation



function EncryptString(Source: string): string;
var
  DCP_rijndael2: TDCP_rijndael;
begin
  DCP_rijndael2 := TDCP_rijndael.Create(nil);   // создаём объект
  DCP_rijndael2.InitStr(keypassword, TDCP_sha1);    // инициализируем
  Result := DCP_rijndael2.EncryptString(Source); // шифруем
  DCP_rijndael2.Burn;                            // стираем инфо о ключе
  DCP_rijndael2.Free;                            // уничтожаем объект
end;

function DecryptString(Source: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // создаём объект
  DCP_rijndael1.InitStr(keypassword, TDCP_sha1);    // инициализируем
  Result := DCP_rijndael1.DecryptString(Source); // дешифруем
  DCP_rijndael1.Burn;                            // стираем инфо о ключе
  DCP_rijndael1.Free;                            // уничтожаем объект
end;


end.
