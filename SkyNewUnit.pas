{$J+} //Assignable typed constants
//PROGRAM Sky; { 1989-09-19, Piotr Fabian }
unit SkyNewUnit;

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
  Controls, Forms, Dialogs, Buttons, ComCtrls, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    cbTot: TCheckBox;
    cbVis: TCheckBox;
    cbLoc: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    StatusBar1: TStatusBar;
    btnNasaSol: TSpeedButton;
    btnNasaSolDir: TSpeedButton;
    GroupBox1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ComboBox1: TComboBox;
    GroupBox2: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Edit1: TEdit;
    GroupBox3: TPanel;
    Label14: TLabel;
    GroupBox4: TPanel;
    Label9: TLabel;
    Edit2: TEdit;
    GroupBox5: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    GroupBox6: TPanel;
    Label10: TLabel;
    GroupBox7: TPanel;
    cbRef: TCheckBox;
    GroupBox8: TPanel;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    GroupBox10: TPanel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBox1Change(Sender: TObject);
    procedure cbRefClick(Sender: TObject);
    procedure btnNasaSolClick(Sender: TObject);
    procedure btnNasaSolDirClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure cbVisClick(Sender: TObject);
    procedure cbTotClick(Sender: TObject);
    procedure cbLocClick(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
  private
    procedure MyMouseEvent(var Msg: TMsg; var Handled: Boolean);
    procedure UpdateLocation;
    procedure NextPlace(dp:integer);
    procedure ChangeTimeZone(dt:integer);
    procedure Compute;
    procedure NewDate(r,m,d:integer);
    procedure NewTime(h,m,s:integer);
    procedure NewJD(jd:REAL);
    procedure ChangeDateTime(Key: Char);
    procedure SearchLunarEclipse(backward: boolean);
    procedure SearchSolarEclipse(backward: boolean);
    procedure SearchSunriseOrSunset(backward: boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
{$IFnDEF FPC}
  ShellApi,
{$ELSE}
{$ENDIF}
  Math, Procedures, dlgInputRD, frmHelp;

{$R *.dfm}

const
  currentjd=2448568;

TYPE s15=string[15];
const
 dow:array[0..7] OF s15=
   ('Sunday','Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday');
 nmiejsc=68;

var
  rbi,mbi,dbi:integer;
  rpm,mpm,dpm: integer;
  gobi,mibi,sebi: integer;
 miejsca:array[1..nmiejsc] OF miejsce=
(
 (n:'Gliwice - Sikornik'; s:50.27736; d:18.65556),
 (n:'Culcheth';s:53+27/60;d:-(2+31/60)),
 (n:'Gliwice - Politechnika (AEI)'; s:50.28981; d:18.67871),
 (n:'Gliwice - Rynek'; s:50.29491; d:18.666923),
 (n:'Gliwice - k. sw. Bartlomieja'; s:50.328186; d:18.6916),
 (n:'Gliwice - Labedy'; s:50+20.5/60; d:18+38/60),
 (n:'Bedzin'; s:50+19/60; d:19+9/60),
 (n:'Bytom'; s:50+21/60; d:18+53/60),
 (n:'Chorzow'; s:50+21/60; d:18+55/60),
 (n:'Chorzow - Planetarium'; s:50+17.42/60; d:18+59.68/60),
 (n:'Czeladz'; s:50+19/60; d:19+5/60),
 (n:'Czechowice - Dziedzice'; s:50-5/60; d:19),
 (n:'Dabrowa Gornicza'; s:50+19/60; d:19+12/60),
 (n:'Jastrzebie - Zdroj'; s:50-3/60; d:18+36/60),
 (n:'Jezioro Goczalkowickie'; s:50-4/60; d:19-8/60),
 (n:'Katowice - PKP'; s:50.25721; d:19.020312),
 (n:'Knurow'; s:50+13/60; d:18+40/60),
 (n:'Leszczyny'; s:50+10/60; d:18+40/60),
 (n:'Mikolow'; s:50+10/60; d:18+54/60),
 (n:'Myslowice'; s:50+13/60; d:19+8/60),
 (n:'Olkusz'; s:50+17/60; d:19+34/60),
 (n:'Palowice'; s:50+6/60; d:18+44/60),
 (n:'Piekary Slaskie'; s:50+23/60; d:19-3/60),
 (n:'Pszczyna'; s:50-1/60; d:19-3/60),
 (n:'Pustynia Bledowska'; s:50+21/60; d:18+31/60),
 (n:'Pyskowice'; s:50+23.5/60; d:18+37/60),
 (n:'Raciborz'; s:50+5/60; d:18+13/60),
 (n:'Ruda Slaska'; s:50+17/60; d:18+48/60),
 (n:'Rybnik'; s:50+6/60; d:18+33/60),
 (n:'Siemianowice'; s:50+18/60; d:19+2/60),
 (n:'Sosnowiec'; s:50+17/60; d:19+4/60),
 (n:'Swietochlowice'; s:50+18/60; d:18+55/60),
 (n:'Tarnowskie Gory'; s:50+27/60; d:18+52/60),
 (n:'Tychy'; s:50+8/60; d:19-1/60),
 (n:'Zabrze'; s:50+18/60; d:18+46/60),
 (n:'Zawiercie'; s:50+29/60; d:19+26/60),
 (n:'Bielsko Biala'; s:49+49/60; d:19+3/60),
 (n:'Czestochowa - Jasna Gora'; s:50.8120877; d:19.0986938),
 (n:'Gdansk'; s:54+23/60; d:18+37/60),
 (n:'Gorzow Wlkp.'; s:52+44/60; d:15+15/60),
 (n:'Krakow - PKP'; s:50.23289; d:19.950186),
 (n:'Konstantynow - radiost.'; s:52.36747; d:19.80404),
 (n:'Plock - rafineria'; s:52.5906608; d:19.6645711),
 (n:'Poznan'; s:52+25/60; d:16+55/60),
 (n:'Tatry - Morskie Oko'; s:49.1973889; d:20.07175),
 (n:'Tatry - Rysy'; s:49.1798611; d:20.0896916),
 (n:'Warszawa - PKP (Dw.Centr.)'; s:52.228849; d:21.00439),
 (n:'Wisla'; s:49+4/6; d:18+52/60),
 (n:'Amsterdam'; s:52.35; d:4.9),
 (n:'Ankara'; s:39.916; d:32.833),
 (n:'Ateny'; s:38.0; d:23.733),
 (n:'Bagdad'; s:33.35; d:44.416),
 (n:'Bangkok'; s:13.733; d:100.5),
 (n:'Berlin'; s:52.533; d:13.416),
 (n:'Buenos Aires'; s:-34.667; d:-58.5),
 (n:'Essen'; s:51.45; d:6.983333333),
 (n:'Greenwich - obserw.'; s:51.477277; d:0.0),
 (n:'Jerozolima'; s:31.783; d:35.216),
 (n:'Johannesburg'; s:-26.166; d:28.033),
 (n:'Madryt'; s:40.416; d:-3.716),
 (n:'Mainflingen'; s:50.016667; d:9.0),
 (n:'Moskwa'; s:55.75; d:37.583),
 (n:'Paryz'; s:48.867; d:2.33),
 (n:'Pekin'; s:39.916; d:116.433),
 (n:'Praga'; s:50.1; d:14.433),
 (n:'Sydney'; s:-33.916; d:151.16),
 (n:'Tokio'; s:35.66; d:139.75),
 (n:'Wieden'; s:48.216; d:16.33)
);

var
  ii:integer;
  s1,s2: string[15];

function RefInOut(z:REAL):REAL;
const                   (* kier. z Ziemi na zewnatrz *)
a:array[0..12] OF REAL =
(-4.80596719245187E-0006,4.64569647484287E+0002,-4.24792379754272E+0001,
 1.39768776767424E+0000,-1.49632948592414E-0002,-1.61519393297297E-0004,
 3.39934751193432E-0006, 5.55121556842510E-0008,-1.83970118440596E-0009,
 1.57110585046333E-0011,-1.04321790723069E-0014,-5.19524231429322E-0016,
 2.06707051496960E-0018);
var i:integer;
    w:REAL;
begin
  z:=Abs(z*180/Pi);
  if z>90 then begin RefInOut:=0; Exit end;
  if z<=45 then w:=(60.3/60)*sin(z*Pi/180)/cos(z*Pi/180) else
  begin
    w:=a[12];
    FOR i:=11 DOWNTO 0 DO w:=z*w+a[i]
  end;
  RefInOut:=w*(Pi/180/60)
end;

function d2(i:integer):string;
var s:string[2];
begin
  Str(i,s);
  if s[0]=#1 then s:='0'+s;
  d2:=s
end;

function Deg(d:REAL):s15;
var g,m,s:WORD; gr:REAL;
begin
 gr:=d/(2*Pi);
 while gr<0 DO gr:=gr+1;
 gr:=24*(gr-int(gr));
 g:=trunc(gr); gr:=60*(gr-g);
 m:=trunc(gr); gr:=60*(gr-m);
 s:=trunc(gr);
 Deg:=' '+d2(g)+'h'+d2(m)+'m'+d2(s)+'s'
end;

procedure TForm1.UpdateLocation;
var
  akt_m: integer;
begin
  akt_m:=ComboBox1.ItemIndex+1;
  sze:=radInDeg*miejsca[akt_m].s;
  dlu:=radInDeg*miejsca[akt_m].d;
  Label5.Caption:=Format('lat = %2f',[sze/radInDeg]);
  Label6.Caption:=Format('lon = %2f',[dlu/radInDeg]);
  Compute;
end;

procedure TForm1.NextPlace(dp:integer);
var
  x,y:integer;
  akt_m: integer;
begin
  akt_m:=ComboBox1.ItemIndex+1;
  akt_m:=akt_m+dp;
  if akt_m>nmiejsc then akt_m:=1;
  if akt_m<1 then akt_m:=nmiejsc;
  ComboBox1.ItemIndex:=akt_m-1;
  UpdateLocation;
end;

procedure NasaCall(bDirectory: boolean);
var
  link: string;
  CentFrom,CentTo: integer;
begin
  CentFrom:=DivInf((rbi-1),100)*100+1;
  CentTo:=CentFrom+99;
  if LoFaza(1)>0 then
  begin
    if bDirectory then
      link:='http://eclipse.gsfc.nasa.gov/SEcat5/'+Format('SE%.4d-%.4d.html',[CentFrom,CentTo])
    else
      link := 'http://eclipse.gsfc.nasa.gov/SEsearch/SEsearchmap.php?Ecl='+ Format('%.4d%.2d%.2d',[rbi,mbi,dbi]);
  end else
  begin
    if bDirectory then
      link:='http://eclipse.gsfc.nasa.gov/LEcat5/'+Format('LE%.4d-%.4d.html',[CentFrom,CentTo])
    else
      link := 'http://eclipse.gsfc.nasa.gov/5MCLEmap/'+Format('%.4d-%.4d/LE%.4d-%.2d-%.2d%s.gif',
            [CentFrom,CentTo,rbi,mbi,dbi,LunarEclKind]);
  end;
{$ifdef FPC}
  OpenDocument(PChar(link));
{$else}
  ShellExecute(Application.MainForm.Handle, 'open', PChar(link), nil, nil, SW_SHOW);
{$endif}
end;

procedure TForm1.btnNasaSolClick(Sender: TObject);
begin
  NasaCall(false);
end;

procedure TForm1.btnNasaSolDirClick(Sender: TObject);
begin
  NasaCall(true);
end;

procedure TForm1.cbLocClick(Sender: TObject);
begin
  e_loc:=cbLoc.Checked;
end;

procedure TForm1.cbRefClick(Sender: TObject);
begin
  if cbRef.Checked then
    Refr:=1/3
  else
    Refr:=0;
  Compute;
end;

procedure TForm1.cbTotClick(Sender: TObject);
begin
  e_tot:=cbTot.Checked;
end;

procedure TForm1.cbVisClick(Sender: TObject);
begin
  e_vis:=cbVis.Checked;
end;

procedure TForm1.ChangeTimeZone(dt:integer);
var
  timestring,wst: string;
begin
  if (time_zone+dt+13) IN [1..25] then time_zone:=time_zone+dt;
  timestring:='';
  if time_zone=1 then timestring:='CET - Polska';
  if time_zone=0 then timestring:='UTC';
  if time_zone=2 then timestring:='czas letni';
  if time_zone=3 then timestring:='Moskwa, Bagdad';
  if time_zone=-5 then timestring:='ET - New York';
  if time_zone=-8 then timestring:='PT - Pacific Time';
  Label12.Caption:=Format('Timezone %4d',[time_zone]);
  Label13.Caption:=timestring;
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  Label14.Caption:=wst;
end;

{procedure Info;
var c:AnsiCHAR;
begin
 Window(1,1,80,25);
 CLM;
 HighVideo;
 W ('');
 NormVideo;
 WriteLn;
 Write('KEY...');
end;}


{procedure AInfo;
var c:AnsiCHAR; i:integer;
begin
 Window(1,1,80,25);
 CLM;
 HighVideo;
 W ('Co oznaczaj¹ wyniki...');
 NormVideo;
 WriteLn;
 W ('®Object:   nazwa obiektu, którego dotycz¹ wyniki');
 W ('®  WSPO£RZÊDNE BIEGUNOWE:');
 W ('®rect:     rektascensja, ozn. Ó (odpowiada d³ugoœci geograficznej)');
 W ('®decl:     deklinacja, ozn. ë (odpowiada szerokoœci geograficznej)');
 W ('®  WSPO£RZÊDNE HORYZONTALNE:');
 W ('®az:       azymut, liczony w stopniach od kierunku pó³nocnego na wschód');
 W ('®height:   wysokoœæ, liczona w stopniach od horyzontu');
 W ('®distance: odleg³oœæ od œrodka Ziemi do œrodka obiektu w kilometrach');
 W ('®phase:    faza, podawana jako k¹t (w stopniach) miêdzy obiektem a S³oñcem');
 W ('®          (k¹t widziany z punktu obserwacji); E oznacza zaæmienie');
 W ('----------');
end;}

procedure TForm1.NewDate(r,m,d:integer);
const ask: boolean=false;
var
  s:s15;
  wst: string;
begin
  jd:=DataJD(r,m,d);
  Edit1.Text:=IntToStr(r)+'-'+d2(m)+'-'+d2(d);
  s:=dow[weekDay];
  while s[0]<#10 DO s:=' '+s;
  Label8.Caption:=s;
  rbi:=r; mbi:=m; dbi:=d;
  Str(86400*dTT(jd+jDNIA-time_zone/24):7:1,wst);
  Label10.Caption:=wst+' s';
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  Label14.Caption:=wst;
  if r>2343 then if (Random(1000)=0) AND not(ask) then
  begin
    ShowMessage('Does the WORLD still exist?'#10+
                '        Y E S  ?'#10+
                '       It''s nice!');
    ask:=true;
  end;
end;


procedure TForm1.NewJD(jd:REAL);
var
  r,m,d: integer;
  pm: real;
begin
  RokMD(jd,r,m,d,pm);
  NewDate(r,m,d);
end;

procedure TForm1.NewTime(h,m,s: integer);
var
  wst: string;
begin
  jDNIA:=(3600*LONGINT(h)+60*m+s)/86400;
  gobi:=h;
  mibi:=m;
  sebi:=s;
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  Label14.Caption:=wst;
  Str(86400*dTT(jd+jDNIA-time_zone/24):7:1,wst);
  Label10.Caption:=wst+' s';
  Edit2.Text:=IntToStr(gobi)+':'+d2(mibi)+':'+d2(sebi);
end;

function Czas():LONGINT;
var
  DateTime: TDateTime;
  SystemTime: TSystemTime;
begin
  DateTime:=Now();
  DateTimeToSystemTime(DateTime,SystemTime);
  Czas:=SystemTime.wMilliseconds+1000*SystemTime.wSecond +
     1000*60*SystemTime.wMinute+1000*60*60*SystemTime.wHour;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  UpdateLocation;
end;

procedure TForm1.Compute;
var
  t,t1,x1,wysS,wysM: real;
  phMoon: real;
  wst: string;
begin
  t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
  t:=OblJR(t1);
  wysS:=OblSLON(t, t1);
  Label17.Caption:='Sun';
  Edit3.Text:=Deg(SunRectan);
  Edit4.Text:=Format('%.4f',[de/radInDeg]);
  Edit5.Text:=Format('%f',[az/radInDeg]);
  Edit6.Text:=Format('%f',[wysS/radInDeg]);
  Edit7.Text:=Format('%d',[round(dr*149597870)]);
  //
  t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
  wysM:=OblKSIE(t, t1);
  Label18.Caption:='Moon';
  Edit8.Text:=Deg(SunRectan);
  Edit9.Text:=Format('%.4f',[de/radInDeg]);
  Edit10.Text:=Format('%f',[az/radInDeg]);
  Edit11.Text:=Format('%f',[wysM/radInDeg]);
  Edit12.Text:=Format('%d',[round(dr*149597870)]);
  phMoon:=Faza(1);
  Edit13.Text:=Format('%.3f',[ArcCos(LoFaza(1))/radInDeg]);
  if Abs(phMoon)>0.99962 then
  begin
    Edit13.Text:=Edit13.Text+' E';
    btnNasaSol.Enabled:=true;
    btnNasaSolDir.Enabled:=true;
  end else
  begin
    btnNasaSol.Enabled:=false;
    btnNasaSolDir.Enabled:=false;
  end;
  Label25.Caption:=Format('LoDiam(Slonce ) = %.4f'+#176,[LoDiam(0)/radInDeg]);
  Label26.Caption:=Format('LoDiam(Ksiezyc) = %.4f'+#176,[LoDiam(1)/radInDeg]);
  x1:=(LoDiam(1)+LoDiam(0))/2-ArcCos(LoFaza(1));
  if x1>0 then  Label27.Caption:=Format('Zaæmienie S³oñca: %.4f'+#176,[x1/radInDeg])
         else  Label27.Caption:='';
  Edit14.Text:=Format('%.4f',[t1]);
end;

//                         { 1991-01-18 }

procedure TForm1.FormCreate(Sender: TObject);
var
  DateTime: TDateTime;
  SystemTime: TSystemTime;
  i: integer;
  pm: real;
begin
  ComboBox1.Items.BeginUpdate;
  ComboBox1.Clear;
  for i:=1 to nmiejsc do
    ComboBox1.Items.Add(miejsca[i].n);
  ComboBox1.Items.EndUpdate;
  DateTime:=Now();
  DateTimeToSystemTime(DateTime,SystemTime);
// GetDate(pom1,pom2,pom3,pom4);
 jd:=DataJD(SystemTime.wYear,SystemTime.wMonth,SystemTime.wDay);
 jDNIA:=0;
 RokMD(jd,rbi,mbi,dbi,pm);
 if jd>currentjd then NewDate(rbi,mbi,dbi) else
 begin RokMD(currentjd,rbi,mbi,dbi,pm); NewDate(rbi,mbi,dbi) end;
 NewTime(SystemTime.wHour,SystemTime.wMinute,SystemTime.wSecond);
 Paralaksa:=1; Refr:=1/3;
 NextPlace(1);
 ChangeTimeZone(0);
 Compute;
 Application.HintPause:=0;
 Application.HintHidePause:=MaxInt;
{$ifndef FPC}
 Application.OnMessage := MyMouseEvent;
{$endif}
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=ord('A')) and (ssCtrl in Shift) then InputRD.ShowModal;
end;

procedure TForm1.ChangeDateTime(Key: Char);
var
  pm: real;
begin
  case Key of
    'e':
    begin
      rbi:=rbi+100;
      NewDate(rbi,mbi,dbi);
    end;
    'E':
    begin
      rbi:=rbi-100;
      NewDate(rbi,mbi,dbi);
    end;
    'r':
    begin
          if rbi<9900-9 then rbi:=rbi+10;
          if rbi=0 then rbi:=1;
          if (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) then dbi:=28;
          if (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) then
            if dbi<10 then dbi:=4 else dbi:=15;
          NewDate(rbi,mbi,dbi)
    end;
    'R':
    begin
          if rbi>-9900+9 then rbi:=rbi-10;
          if rbi=0 then rbi:=-1;
          if (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) then dbi:=28;
          if (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) then
            if dbi<10 then dbi:=4 else dbi:=15;
          NewDate(rbi,mbi,dbi)
    end;
    'y':
    begin
          if rbi<9900 then rbi:=rbi+1;
          if rbi=0 then rbi:=1;
          if (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) then dbi:=28;
          if (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) then
            if dbi<10 then dbi:=4 else dbi:=15;
          NewDate(rbi,mbi,dbi)
    end;
    'Y':
    begin
          if rbi>-9900 then rbi:=rbi-1;
          if rbi=0 then rbi:=-1;
          if (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) then dbi:=28;
          if (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) then
            if dbi<10 then dbi:=4 else dbi:=15;
          NewDate(rbi,mbi,dbi)
    end;
    'm':
    begin
          mbi:=mbi+1;
          if mbi>12 then mbi:=1;
          jd:=DataJD(rbi,mbi,dbi);
          RokMD(jd,rpm,mpm,dpm,pm);
          if dbi<>dpm then
           begin
             RokMD(DataJD(rbi,mpm,1)-1,rpm,mpm,dpm,pm);
             dbi:=dpm
           end;
          NewDate(rbi,mbi,dbi)
    end;
    'M':
    begin
          mbi:=mbi-1;
          if mbi<1 then mbi:=12;
          jd:=DataJD(rbi,mbi,dbi);
          RokMD(jd,rpm,mpm,dpm,pm);
          if (dpm<>dbi) OR (mpm<>mbi) then
          if dbi<>dpm then
           begin
             RokMD(DataJD(rbi,mpm,1)-1,rpm,mpm,dpm,pm);
             dbi:=dpm
           end;
          NewDate(rbi,mbi,dbi)
    end;
    'd':
    begin
        jd:=DataJD(rbi,mbi,dbi+1);
        RokMD(jd,rpm,mpm,dpm,pm);
        NewDate(rbi,mbi,dpm)
    end;
    'D':
    begin
          jd:=DataJD(rbi,mbi,dbi-1);
          RokMD(jd,rpm,mpm,dpm,pm);
          if dbi<dpm then
           begin
             RokMD(jd-1+40,rpm,mpm,dpm,pm);
             dpm:=39-dpm
           end;
          if (rbi=1582) AND (mbi=10) AND (dbi=15) then dpm:=4;
          NewDate(rbi,mbi,dpm)
    end;
    'j': NewJD(DataJD(rbi,mbi,dbi)+1);
    'J': NewJD(DataJD(rbi,mbi,dbi)-1);
    '0': NewTime(0,0,0);
    'h':
    begin
         gobi:=(gobi+1) mod 24;
         NewTime(gobi,mibi,sebi);
    end;
    'H':
    begin
       gobi:=gobi-1;
       while gobi<0 DO gobi:=gobi+24;
       NewTime(gobi,mibi,sebi)
    end;
    '+':
    begin
          mibi:=mibi+1;
          if mibi=60 then
            begin
              mibi:=0;
              gobi:=gobi+1;
              if gobi=24 then
                begin
                  gobi:=0;
                  NewJD(DataJD(rbi,mbi,dbi+1))
                end
            end;
            NewTime(gobi,mibi,sebi);
    end;
    '-':
    begin
          mibi:=mibi-1;
          if mibi=-1 then
            begin
              mibi:=59;
              gobi:=gobi-1;
              if gobi=-1 then
                begin
                  gobi:=23;
                  NewJD(DataJD(rbi,mbi,dbi-1))
                end
            end;
          NewTime(gobi,mibi,sebi);
    end;
    's':
    begin
          sebi:=sebi+1;
          if sebi=60 then begin sebi:=0;
          mibi:=mibi+1;
          if mibi=60 then
            begin
              mibi:=0;
              gobi:=gobi+1;
              if gobi=24 then
                begin
                  gobi:=0;
                  NewJD(DataJD(rbi,mbi,dbi+1))
                end
            end
            end;
          NewTime(gobi,mibi,sebi);
    end;
    'S':
    begin
          sebi:=sebi-1;
          if sebi=-1 then begin sebi:=59;
          mibi:=mibi-1;
          if mibi=-1 then
            begin
              mibi:=59;
              gobi:=gobi-1;
              if gobi=-1 then
                begin
                  gobi:=23;
                  NewJD(DataJD(rbi,mbi,dbi-1))
                end
            end
            end;
          NewTime(gobi,mibi,sebi);
    end;
  end;
end;

procedure TForm1.SearchLunarEclipse(backward: boolean);
var
  t,t1,Hd_g,hm_g: real;
  wysS,wysM: real;
begin
  repeat
      jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
      jd:=jd+dTT(jd);
      if not backward then jd:=OblZacmKs(jd,1,Hd_g) else jd:=OblZacmKs(jd,-1,Hd_g);
      OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
      NewDate(rbi,mbi,dbi);
      NewTime(gobi,mibi,sebi);
      t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
      if e_tot then if Hd_g<1 then continue;
      if not(e_vis) then break;
      t:=OblJR(t1);
      OblSLON(t, t1);
      wysM:=OblKSIE(t, t1);
      if e_vis AND (wysM<0) then continue; { mialo byc widoczne, a nie jest }
      break;
  until false;
end;

procedure TForm1.SearchSolarEclipse(backward: boolean);
var
  t,t1,Hd_g,hm_g: real;
  wysS,wysM: real;
begin
  repeat
      jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
      jd:=jd+dTT(jd);
      if not backward then jd:=OblZacmSl(jd,1) else jd:=OblZacmSl(jd,-1);
      OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
      NewDate(rbi,mbi,dbi);
      NewTime(gobi,mibi,sebi);
      t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
      if e_tot AND not(e_loc)
         then if e_status<2 then continue; { mialo byc calkowite, a nie jest }
        { jesli e_tot, to obliczono zacm. calkowite }
      t:=OblJR(t1);
      wysS:=OblSLON(t, t1);
      if e_vis AND (wysS<0) then continue; { mialo byc widoczne, a nie jest }
      OblKSIE(t, t1);
      Hd_g:=LoFaza(1);     { cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
      hm_g:=ArcCos(Hd_g);
      if e_loc AND (hm_g>(LoDiam(0)+LoDiam(1))/2) then continue;  { gdzies jest zacm. calkowite, ale nie tu }
      if e_tot AND e_loc then
        if ArcCos(LoFaza(1)) + LoDiam(0) > LoDiam(1) then continue;
        { was if Hd_g>(LoDiam(1)-LoDiam(0))/2 then continue;}
       break;
  until false;
end;

procedure TForm1.SearchSunriseOrSunset(backward: boolean);
var
  t,t1,Hd_g,hm_g: real;
  wysS,wysM: real;
  jd1,jd2,jd3,w1,w2,w3: real;
begin
  jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
  jd:=jd+dTT(jd);

  jd3:=0.5-dlu/(2*Pi);
  jd1:=int(jd)+jd3-2.0;
  while jd1<jd DO jd1:=jd1+0.5; jd1:=jd1-0.5;
  jd2:=jd1+0.5;
  if backward then begin jd1:=jd1-0.5; jd2:=jd2-0.5 end
  else begin jd1:=jd1+0.5; jd2:=jd2+0.5 end;

  t1:=jd1-2451545.0+dTT(jd1);
  t:=OblJR(t1);
  wysS:=OblSLON(t, t1);
  w1:=wysS;
  t1:=jd2-2451545.0+dTT(jd2);
  t:=OblJR(t1);
  wysS:=OblSLON(t, t1);
  w2:=wysS;

  while (Abs(jd1-jd2)>0.00001) AND (w1*w2<=0) DO
    begin
      jd3:=(jd1+jd2)/2;
      t1:=jd3-2451545.0+dTT(jd3);
      t:=OblJR(t1);
      wysS:=OblSLON(t, t1);
      w3:=wysS;
      if w1*w3<0 then
        begin jd2:=jd3; w2:=w3 end
      else
        begin jd1:=jd3; w1:=w3 end
    end;
    jd3:=(jd1+jd2)/2;
    OblGodz(jd3+dTT(jd3),rbi,mbi,dbi,gobi,mibi,sebi);
    NewDate(rbi,mbi,dbi);
    NewTime(gobi,mibi,sebi);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  SearchSolarEclipse(true);
  StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' S³oñca';
  Compute;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  SearchSolarEclipse(false);
  StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' S³oñca';
  Compute;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  SearchLunarEclipse(true);
  StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' Ksiê¿yca';
  Compute;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  SearchLunarEclipse(false);
  StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' Ksiê¿yca';
  Compute;
end;

procedure TurnHint(MainControl: TWinControl; turnOn: boolean);
var
  i: integer;
  Control: TControl;
begin
  for i:=0 to MainControl.ControlCount-1 do
  begin
    Control:=MainControl.Controls[i];
    if Control.Hint<>'' then
      Control.ShowHint:=turnOn;
    if Control is TWinControl then TurnHint(Control as TWinControl, turnOn);
  end;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  Screen.Cursor:=crHelp;
  TurnHint(Form1, true);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
  HelpForm.PageControl1.ActivePageIndex:=2;
  HelpForm.ShowModal;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
  DateTime: TDateTime;
  SystemTime: TSystemTime;
  pm: real;
begin
  StatusBar1.Panels[0].Text:='';
  Label28.Caption:='';
  if Upcase(Key)='C' then
  begin
   DateTime:=Now();
   DateTimeToSystemTime(DateTime,SystemTime);
   jd:=DataJD(SystemTime.wYear,SystemTime.wMonth,SystemTime.wDay);
   RokMD(jd,rpm,mpm,dpm,pm);
   if jd>currentjd then
     NewDate(rpm,mpm,dpm)
     else
   begin
      RokMD(currentjd,rbi,mbi,dbi,pm);
      NewDate(rbi,mbi,dbi)
   end;
   NewTime(SystemTime.wHour,SystemTime.wMinute,SystemTime.wSecond);
  end
  else if Key in ['e','E','r','R','y','Y','m','M','d','D','j','J','0','h','H','+','-','s','S'] then ChangeDateTime(key)
   else if Key='z' then
     ChangeTimeZone( 1)
   else if Key='Z' then
     ChangeTimeZone(-1)
   else if (Key='f')or(Key='F') then
   begin
            jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
            jd:=jd+dTT(jd);
            if Key='f' then jd:=OblFAZE(jd,1) else jd:=OblFAZE(jd,-1);
            OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
            NewDate(rbi,mbi,dbi);
            NewTime(gobi,mibi,sebi);
            Label28.Caption:=infs;
   end

  else if (Key='1')or(Key='2') then
  begin
    SearchSolarEclipse(Key='1');
    StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' S³oñca';
  end
  else if (Key='3')or(Key='4') then
  begin  { 1992-08-31 }
    SearchLunarEclipse(Key='3');
    StatusBar1.Panels[0].Text:='Zaæmienie '+infs+' Ksiê¿yca';
  end
  else if (Key='w')or(Key='W') then
  begin  { sunrise or sunset }
    SearchSunriseOrSunset(Key='W');
  end
  else if Key='n' then
      NextPlace(1)
  else if Key='N' then
      NextPlace(-1)
  else if Key='5' then cbVis.Checked:=not(cbVis.Checked)
  else if Key='6' then cbTot.Checked:=not(cbTot.Checked)
  else if Key='7' then cbLoc.Checked:=not(cbLoc.Checked)
  else if (Key='a')or(Key='A') then
    cbRef.Checked:=not cbRef.Checked;
  Compute;
end;

procedure TForm1.MyMouseEvent(var Msg: TMsg; var Handled: Boolean);
begin
  case Msg.message of
    wm_LButtonDown,WM_RBUTTONDOWN:
    begin
      TurnHint(Form1, false);
      Screen.Cursor:=crDefault;
    end;
  end;
  inherited;
end;

end.
