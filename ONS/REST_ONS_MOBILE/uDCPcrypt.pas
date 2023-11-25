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
  DCP_rijndael2 := TDCP_rijndael.Create(nil);   // ������ ������
  DCP_rijndael2.InitStr(keypassword, TDCP_sha1);    // ��������������
  Result := DCP_rijndael2.EncryptString(Source); // �������
  DCP_rijndael2.Burn;                            // ������� ���� � �����
  DCP_rijndael2.Free;                            // ���������� ������
end;

function DecryptString(Source: string): string;
var
  DCP_rijndael1: TDCP_rijndael;
begin
  DCP_rijndael1 := TDCP_rijndael.Create(nil);   // ������ ������
  DCP_rijndael1.InitStr(keypassword, TDCP_sha1);    // ��������������
  Result := DCP_rijndael1.DecryptString(Source); // ���������
  DCP_rijndael1.Burn;                            // ������� ���� � �����
  DCP_rijndael1.Free;                            // ���������� ������
end;


end.
