unit dlgInputRD;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

type
  TInputRD = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


type
    miejsce=
      record
        n:   string[30];
        s,d: REAL
      end;
var
  InputRD: TInputRD;

implementation
uses
  Math, Procedures;

{$R *.dfm}
procedure TInputRD.Button1Click(Sender: TObject);
var
  az,wys: real;
begin
  CalcAzH(StrToFloat(Edit1.Text), StrToFloat(Edit2.Text), az,wys);
  Edit3.Text := FloatToStr(az/radInDeg);
  Edit4.Text := FloatToStr(wys/radInDeg);
end;

end.
