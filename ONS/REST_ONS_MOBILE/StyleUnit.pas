unit StyleUnit;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls;

type
  TDM_Style = class(TDataModule)
    StyleBook1: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM_Style: TDM_Style;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
