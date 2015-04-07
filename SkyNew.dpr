program SkyNew;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  SkyNewUnit in 'SkyNewUnit.pas' {Form1},
  dlgInputRD in 'dlgInputRD.pas' {InputRD},
  Procedures in 'Procedures.pas',
  frmHelp in 'frmHelp.pas' {HelpForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TInputRD, InputRD);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
