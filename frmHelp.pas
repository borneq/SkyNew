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
  rmemo.SelText := 'SKY - oblicza po³o¿enie S³oñca i Ksiê¿yca'#10#10;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlack;
  rmemo.SelAttributes.Style := [];
{$endif}
  rmemo.SelText := 'Wed³ug InforMik-a 2/1989 napisa³ Piotr Fabian'#10#10;
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
  rmemo.SelText := 'Krótka informacja o programie SKY'#10#10;
{$ifndef FPC}
  rmemo.SelAttributes.Color := clBlack;
  rmemo.SelAttributes.Style := [];
{$endif}
  rmemo.SelText := 'Program SKY oblicza po³o¿enia S³oñca i Ksiê¿yca na niebie z dok³adnoœci¹ ';
  rmemo.SelText := '1 minuty k¹towej w przedziale +-300 lat od chwili obecnej.'#10'U¿ytkownik mo¿e ';
  rmemo.SelText := 'wybraæ dowoln¹ strefê czasow¹ i jedno z wpisanych w programie miejsc na ';
  rmemo.SelText := 'œwiecie (program mo¿na uzupe³niæ o nowe wspó³rzêdne - zawiera je tablica ';
  rmemo.SelText := 'MIEJSCA).'#10'Uwzglêdniana mo¿e byæ refrakcja atmosferyczna.'#10'Na ekranie ';
  rmemo.SelText := 'wyœwietlane s¹ informacje o wybranym miejscu obserwacji, data, godzina, ';
  rmemo.SelText := 'strefa czasowa, data julianska; dT oznacza ró¿nicê UT-UTC dla wybranej ';
  rmemo.SelText := 'daty (w sekundach).'#10'Po naciœniêciu klawisza ';
  rmemo.SelText := 'obliczane sa pozycje S³oñca i Ksiê¿yca. Wyœwietlane s¹: ich deklinacja, ';
  rmemo.SelText := 'rektascensja, azymut (od pó³nocy na wschód), wysokoœæ nad horyzontem (wszystko ';
  rmemo.SelText := 'w stopniach) oraz odleg³oœæ od Ziemi w kilometrach.'#10;
  rmemo.SelText := 'Ustawianie daty odbywa sie klawiszami Y,M,D (zwiêkszenie o 1 roku, miesi¹ca, ';
  rmemo.SelText := 'dnia miesi¹ca), tymi samymi klawiszami z klawiszem SHIFT (odp. zmiejszenie ';
  rmemo.SelText := 'o jeden); ust. godziny: H,+,-,S (uwaga: +,-,S zmieniaj¹ czas w sposób ci¹g³y, ';
  rmemo.SelText := 'H pozostaje w obrêbie wybranego dnia); ñ1 dzieñ: J; zmiana strefy ';
  rmemo.SelText := 'czasowej: Z; zmiana miejsca obserwacji: N; uwzglêdnianie refrakcji: A; ';
  rmemo.SelText := 'ustawienie aktualnej daty i czasu: C; objaœnienia otrzymywanych wyników: E; ';
  rmemo.SelText := 'fazy Ksiê¿yca: F.';
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
