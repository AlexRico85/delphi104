unit SessionUnit;

interface

uses classes, Winapi.Windows, System.SysUtils;

Type
  TSessions = class(TObject)
  private
    FLock : TRTLCriticalSection;
    FActiveSession:integer;
    procedure Lock;
    procedure UnLock;
  public
    property ActiveSession:integer read FActiveSession;
    constructor Create();
    destructor Destroy;
    procedure StartSession();
    procedure EndSession();

  end;

  var
    Sessions:TSessions;

implementation



{ TSessions }

constructor TSessions.Create;
begin
  InitializeCriticalSection(FLock);
  FActiveSession:=0;
end;

destructor TSessions.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TSessions.EndSession();
begin
  Lock;
  try
    FActiveSession:=FActiveSession-1;
  finally
     UnLock;
  end;
end;

procedure TSessions.Lock;
begin
   EnterCriticalSection(FLock);
end;

procedure TSessions.StartSession();
begin
  Lock;
  try
    FActiveSession:=FActiveSession+1;
  finally
     UnLock;
  end;
end;

procedure TSessions.UnLock;
begin
  LeaveCriticalSection(FLock);
end;

end.
