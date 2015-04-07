unit frmHelp;

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
  Controls, Forms, Dialogs, ComCtrls, StdCtrls;

type
  THelpForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ListView1: TListView;
    Button1: TButton;
    TabSheet3: TTabSheet;
    procedure FormCreate(Sender: TObject);
  private
    procedure FillAbout;
    procedure FillDesc;
    procedure AddKey(s0,s1: string);
    procedure FillKeyInfo;
  public
{$ifdef FPC}
    Memo1: TMemo;
    Memo2: TMemo;
{$else}
    RichEdit1: TRichEdit;
    RichEdit2: TRichEdit;
{$endif}
  end;

var
  HelpForm: THelpForm;

implementation

{$R *.dfm}

procedure THelpForm.AddKey(s0, s1: string);
var
  item: TListItem;
begin
  item:=ListView1.Items.Add;
  item.Caption:=s0;
  item.SubItems.Add(s1);
end;

procedure THelpForm.FillAbout;
var
{$ifdef FPC}
  rmemo: TMemo;
{$else}
  rmemo: TRichEdit;
{$endif}
begin
{$ifdef FPC}
  rmemo:=Memo1;
{$else}
  rmemo:=RichEdit1;
{$endif}
  rmemo.Font.Size:=12;
  rmemo.Clear;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlue;
  rmemo.SelAttributes.Style := [fsBold];
{$endif}
  rmemo.SelText := 'SKY - oblicza po�o�enie S�o�ca i Ksi�yca'#10#10;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlack;
  rmemo.SelAttributes.Style := [];
{$endif}
  rmemo.SelText := 'Wed�ug InforMik-a 2/1989 napisa� Piotr Fabian'#10#10;
  rmemo.SelText := 'Gliwice, VIII 1989 .. X 1992';
 { 1991-08-29 .. 1991-09-18 }
 { 1992-08-31 .. ???        }
end;

procedure THelpForm.FillDesc;
var
{$ifdef FPC}
  rmemo: TMemo;
{$else}
  rmemo: TRichEdit;
{$endif}
begin
{$ifdef FPC}
    rmemo:=Memo2;
{$else}
    rmemo:=RichEdit2;
{$endif}
  rmemo.Font.Size:=10;
  rmemo.Clear;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlue;
  rmemo.SelAttributes.Style := [fsBold];
{$endif}
  rmemo.SelText := 'Kr�tka informacja o programie SKY'#10#10;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlack;
  rmemo.SelAttributes.Style := [];
{$endif}
  rmemo.SelText := 'Program SKY oblicza po�o�enia S�o�ca i Ksi�yca na niebie z dok�adno�ci� ';
  rmemo.SelText := '1 minuty k�towej w przedziale +-300 lat od chwili obecnej.'#10'U�ytkownik mo�e ';
  rmemo.SelText := 'wybra� dowoln� stref� czasow� i jedno z wpisanych w programie miejsc na ';
  rmemo.SelText := '�wiecie (program mo�na uzupe�ni� o nowe wsp�rz�dne - zawiera je tablica ';
  rmemo.SelText := 'MIEJSCA).'#10'Uwzgl�dniana mo�e by� refrakcja atmosferyczna.'#10'Na ekranie ';
  rmemo.SelText := 'wy�wietlane s� informacje o wybranym miejscu obserwacji, data, godzina, ';
  rmemo.SelText := 'strefa czasowa, data julianska; dT oznacza r�nic� UT-UTC dla wybranej ';
  rmemo.SelText := 'daty (w sekundach).'#10'Po naci�ni�ciu klawisza ';
  rmemo.SelText := 'obliczane sa pozycje S�o�ca i Ksi�yca. Wy�wietlane s�: ich deklinacja, ';
  rmemo.SelText := 'rektascensja, azymut (od p�nocy na wsch�d), wysoko�� nad horyzontem (wszystko ';
  rmemo.SelText := 'w stopniach) oraz odleg�o�� od Ziemi w kilometrach.'#10;
  rmemo.SelText := 'Ustawianie daty odbywa sie klawiszami Y,M,D (zwi�kszenie o 1 roku, miesi�ca, ';
  rmemo.SelText := 'dnia miesi�ca), tymi samymi klawiszami z klawiszem SHIFT (odp. zmiejszenie ';
  rmemo.SelText := 'o jeden); ust. godziny: H,+,-,S (uwaga: +,-,S zmieniaj� czas w spos�b ci�g�y, ';
  rmemo.SelText := 'H pozostaje w obr�bie wybranego dnia); �1 dzie�: J; zmiana strefy ';
  rmemo.SelText := 'czasowej: Z; zmiana miejsca obserwacji: N; uwzgl�dnianie refrakcji: A; ';
  rmemo.SelText := 'ustawienie aktualnej daty i czasu: C; obja�nienia otrzymywanych wynik�w: E; ';
  rmemo.SelText := 'fazy Ksi�yca: F.';
end;

procedure THelpForm.FillKeyInfo;
begin
  ListView1.Clear;
  AddKey('c,C','set time to current');
  AddKey('0','set time to zero, date unchanged');
  AddKey('s,S','increment/decrement seconds');
  AddKey('+,-','increment/decrement minutes');
  AddKey('h,H','increment/decrement hours');
  AddKey('d,D','increment/decrement dayd');
  AddKey('j,J','increment/decrement Julian days');
  AddKey('m,M','increment/decrement months');
  AddKey('y,Y','increment/decrement years');
  AddKey('r,R','increment/decrement tens of years');
  AddKey('e,E','increment/decrement 100 of years');
  AddKey('z,Z','change Timezone');
  AddKey('f,F','search Moon phases');
  AddKey('1,2','search solar eclipses');
  AddKey('3,4','search moon eclipses');
  AddKey('w,W','search sunrise or sunset');
  AddKey('n,N','change location');
  AddKey('5','change vis checkbox');
  AddKey('6','change tot checkbox');
  AddKey('7','change loc checkbox');
  AddKey('a','change Refraction checkbox');
end;

procedure THelpForm.FormCreate(Sender: TObject);
begin
{$ifdef FPC}
  Memo1 := TMemo.Create(Self);
  with Memo1 do
{$else}
  RichEdit1 := TRichEdit.Create(Self);
  with RichEdit1 do
{$endif}
  begin
    Parent := TabSheet1;
    Align := alClient;
  end;
{$ifdef FPC}
  Memo2 := TMemo.Create(Self);
  with Memo2 do
{$else}
  RichEdit2 := TRichEdit.Create(Self);
  with RichEdit2 do
{$endif}
  begin
    Parent := TabSheet2;
    Align := alClient;
  end;
  FillAbout;
  FillDesc;
  FillKeyInfo;
end;

end.
