unit uLog;

interface
uses classes, Winapi.Windows, System.SysUtils;

type

  TAddLogForm = procedure(AddString:AnsiString) of object;
  TAddLogFormStrings = procedure(AddString:TStrings) of object;

  TLogFile = class(TObject)
  private
    FLock : TRTLCriticalSection;
    FAddLogForm:TAddLogForm;
    FAddLogFormStrings:TAddLogFormStrings;
    procedure Lock;
    procedure UnLock;
  public
    constructor Create(AddLogForm:TAddLogForm; AddLogFormStrings:TAddLogFormStrings);
    destructor Destroy;
    procedure WriteLogHead(Head: string; Line : AnsiString); overload;
    procedure WriteLogHead(Head: string; var StringList: TStringList); overload;
    Procedure WriteLog(Line: AnsiString);


  end;


var
  LogFile:TLogFile;

implementation

{ TLogFile }

constructor TLogFile.Create(AddLogForm:TAddLogForm; AddLogFormStrings:TAddLogFormStrings);
begin
  //inherited;
  FAddLogForm := AddLogForm;
  FAddLogFormStrings := AddLogFormStrings;
  InitializeCriticalSection(FLock);
end;

destructor TLogFile.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TLogFile.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TLogFile.UnLock;
begin
  LeaveCriticalSection(FLock);
end;

Function GetFileName(Head:string):string;
var
   st: TSystemTime;
begin
   GetLocalTime(st);
   result := GetCurrentDir+'\logs\LogFile_'+Head+'_'+IntToStr(st.wYear)+'-'+IntToStr(st.wMonth)+'-'+IntToStr(st.wDay)+'.log';
end;

Procedure TLogFile.WriteLog(Line: AnsiString);
begin
  WriteLogHead('main',Line);
end;



procedure TLogFile.WriteLogHead(Head: string; var StringList: TStringList);

var FileName : string;
    FileStream : TFileStream;
    I:Integer;

   procedure Write( Str : AnsiString);
   begin
     FileStream.Write(Str[1], Length(Str) );// Length(Str)* SizeOf(Char));
     FileStream.Write(sLineBreak, Length(sLineBreak) );
   end;

   procedure Writeln(Str : string);
   begin
     Write(Str+#13#10);
   end;

begin
  Lock;
  try
    FileName := GetFileName(Head);
    if not FileExists(FileName) then
    try
      try
        FileStream := TFileStream.Create(FileName,fmCreate);
      finally
        FileStream.Free;
      end;
    except

    end;

    try
      try
        FileStream := TFileStream.Create(FileName,fmOpenReadWrite+fmShareDenyNone);
        FileStream.Position := FileStream.Size;
        for I := 0 to StringList.Count - 1 do
        begin
          try
            Write(StringList[I]);
            FAddLogForm(StringList[I]);
          except

          end;
        end;
      finally
        FileStream.Free;
      end;
    except

    end;

  finally
    UnLock;
  end;
end;


procedure TLogFile.WriteLogHead(Head: string; Line : AnsiString);

var FileName : string;
    FileStream : TFileStream;
    LineResult : AnsiString;

   procedure Write( Str : AnsiString);
   begin
     FileStream.Write(Str[1], Length(Str) );// Length(Str)* SizeOf(Char));
     FileStream.Write(sLineBreak, Length(sLineBreak) );
   end;

   procedure Writeln(Str : string);
   begin
     Write(Str+#13#10);
   end;

begin
  Lock;
  try
    LineResult:= DateTimeToStr(Now) + ': ' + Line;
    FileName := GetFileName(Head);
    if not FileExists(FileName) then
    try
      try
        FileStream := TFileStream.Create(FileName,fmCreate);
      finally
        FileStream.Free;
      end;
    except

    end;

    try
      try
        FileStream := TFileStream.Create(FileName,fmOpenReadWrite+fmShareDenyNone);
        FileStream.Position := FileStream.Size;
        Write(LineResult);
      finally
        FileStream.Free;
      end;
    except

    end;


    try
      FAddLogForm(LineResult);
    except

    end;
  finally
    UnLock;
  end;
end;

end.
