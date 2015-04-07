(*************************)

PROGRAM Sky; { 1989-09-19, Piotr Fabian }
{$F+}
Uses Crt, Dos, Printer;

CONST
  currentjd=2448568;

TYPE s15=STRING[15];
     funrr=FUNCTION(x:REAL):REAL;
CONST
 dow:ARRAY[0..7] OF s15=
   ('Sunday','Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday');


VAR jd,t1,t,dl,db,dr,dlr,lr,t2,ep,dbr,epr,x1,x2,x3,x4,x5,x6,al,de,gr:REAL;
    jr:ARRAY[1..33] OF REAL; pm,kierunek,p4,p5,p6,az,wys,ttt,jdata,Refr:REAL;
    kk,jj,Opcje,Obiekt,Paralaksa,rpm,mpm,dpm,gd,md,sd,dt,gobi,mibi,sebi,
    rbi,mbi,dbi:INTEGER;
    ch,ch1,cpres:CHAR;
    jDNIA,xob,yob,zob, sze, dlu :REAL;
    timestring,infs:STRING[30];
    hm_g,Hd_g:REAL;
    e_status:INTEGER;
    wst:STRING[255];
    czasy:ARRAY[0..10] OF LONGINT;
    mn:LONGINT;
    obliczoneobiekty:ARRAY[0..10] OF BOOLEAN;
    pom1,pom2,pom3,pom4: WORD;
    reg: Registers;
    MousePresent,MousePressed,MP1:BOOLEAN;
    xmouse,ymouse,Button,MouseDel: INTEGER;
    Coor,LoCoor: ARRAY [0..10,'w'..'z'] OF REAL;
    ask:BOOLEAN;
    jd1,jd2,jd3,w1,w2,w3:REAL;


TYPE S3=STRING[3];S9=STRING[9];S10=STRING[10];
    miejsce=
      RECORD
        n:   STRING[30];
        s,d: REAL
      END;
    txtscr=ARRAY[0..4096] OF BYTE;
VAR tsmo: txtscr ABSOLUTE $B000:0;
    tsco: txtscr ABSOLUTE $B800:0;
    ts1m,ts1c: txtscr;

CONST dtyg:ARRAY[1..7]OF S3=('Pon','Wt ','Sr ','Czw','Pia','Sob','N');
      Pi:REAL=3.141592653589793238;s:REAL=0.017453292519943295769;
CONST Nazwa:ARRAY[0..1]OF s9=('Slonce','Ksiezyc');
      druk:BOOLEAN=FALSE; { ekran i drukarka / tylko drukarka }
      all:BOOLEAN=FALSE;  { wschod i zachod + 3 kierunki / tylko wschod i zach. }
      time_zone:INTEGER=1;  { 1 dla CSE, 2 - czas letni }
      e_vis:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko widoczne zacmienia }
      e_tot:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko calkowite zacmienia }
      e_loc:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko widoczne w wybranym miejscu calkowite zacmienia Slonca }
      nmiejsc=68;
 miejsca:ARRAY[1..nmiejsc] OF miejsce=
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

akt_m:INTEGER=0;  { aktualne miejsce }

VAR da_g,gUT,gUTC:S10;

FUNCTION Int1(x:REAL):REAL;
BEGIN
  IF x>=0 THEN Int1:=int(x)
ELSE
  IF x=int(x) THEN Int1:=x ELSE Int1:=int(x)-1
END;

FUNCTION Frac(x:REAL):REAL;
BEGIN
  IF x<0 THEN Frac:=x+int1(-x) ELSE Frac:=x-int1(x)
END;

FUNCTION Sgn(x:REAL):INTEGER;
BEGIN
  IF x>0 THEN Sgn:=1 ELSE IF x=0 THEN Sgn:=0 ELSE Sgn:=-1
END;

PROCEDURE WatchSP(x:REAL);
VAR xx,yy:BYTE;
BEGIN
  xx:=WhereX;
  yy:=WhereY;
  Window(1,25,80,25);
  GotoXY(65,1);
  Write(x:14:7);
  Window(1,5,80,24);
  GotoXY(xx,yy)
END;


FUNCTION Angle(x,y:REAL):REAL;
VAR a:REAL;
BEGIN
 IF Abs(x)<1e-8 THEN
 BEGIN
  a:=Pi/2;
  IF y<0 THEN a:=a+Pi;
  IF Abs(y)<1e-8 THEN a:=0
 END
 ELSE
  BEGIN
   a:=ArcTan(y/x);
   IF x<0 THEN a:=a+Pi;
  END;
 Angle:=a
END;

FUNCTION ArcSin(x:REAL):REAL;
BEGIN
IF Abs(x)>1 THEN WriteLn('Bledny argument ArcSin')
ELSE
IF Abs(x)=1.0 THEN ArcSin:=x*Pi/2
ELSE ArcSin:=ArcTan(x/Sqrt(1-x*x))
END;

Function ArcCos(x:REAL):REAL;
BEGIN
ArcCos:=Pi/2-ArcSin(x)
END;

PROCEDURE minimum(a,b,d:REAL; VAR x:REAL; f:funrr);  { zloty podzial }
          { a,b - przedzial, d - dokladnosc, x - wartosc x, f - funkcja }
VAR gkl,gkp,gk1l,gk1p,
    akl,akp,ak1l,ak1p,
    qakl,qakp,qak1l,qak1p:REAL;
CONST zp=1.6180339887498948482045868343656381177203091798057;
BEGIN
  IF (a>=b) THEN BEGIN x:=a; Exit END;
  IF d<=0 THEN Exit;
  gkl:=a; gkp:=b;
  akl:=gkp-(gkp-gkl)/zp;   akp:=gkl+(gkp-gkl)/zp;
  qakl:=f(akl); qakp:=f(akp);
  WHILE gkp-gkl>d DO
  BEGIN
    IF qakl>qakp THEN { minimum w prawym przedziale }
      BEGIN
        gk1l:=akl;
        gk1p:=gkp;
        ak1l:=akp;
        ak1p:=gk1l+(gk1p-gk1l)/zp;
        qak1l:=qakp;
        qak1p:=f(ak1p)
      END
    ELSE              { minimum w lewym przedziale }
      BEGIN
        gk1l:=gkl;
        gk1p:=akp;
        ak1p:=akl;
        ak1l:=gk1p-(gk1p-gk1l)/zp;
        qak1l:=f(ak1l);
        qak1p:=qakl
      END;
    gkl:=gk1l; gkp:=gk1p;
    akl:=ak1l; akp:=ak1p;
    qakl:=qak1l; qakp:=qak1p
  END;
  x:=gkl+(gkp-gkl)/2
END;



PROCEDURE RokMD(jd: REAL; VAR r,m,d:INTEGER; VAR gr:REAL);
VAR w,x,u,z,y,a,b,c,e,f:REAL;
BEGIN
 gr:=jd-int1(jd-0.5)-0.5;
 w:=int(jd+0.5)+0.5; x:=int(w); u:=w-x;
 y:=int((x+32044.5)/36524.25); z:=x+y-int(y/4)-38;
 IF jd<2299160.5 THEN z:=x;
 a:=z+1524; b:=int((a-122.1)/365.25); c:=a-365*b-int(b/4);
 e:=int(c/30.61);
 f:=int(e/14);
 r:=round(b-4716+f); m:=round(e-1-12*f); d:=trunc(c+u-int(153*e/5)-0.5);
 IF r<=0 THEN r:=pred(r);
 dt:=round(jd+1.1-7*int((jd+1.1)/7));
 WHILE dt<0 DO dt:=dt+7
END;

FUNCTION DataJD(r,m,d:REAL):REAL;
VAR a,b,c,e:REAL;
BEGIN
IF r<0 THEN r:=r+1;
a:=4716+r+int((m+9)/12);
b:=1729279.5+367*r+int(275*m/9)-int(7*a/4)+d;
c:=int((a+83)/100);
e:=int(3*(c+1)/4);
a:=b+38-e;
IF a<2299160.5 THEN a:=b;
DataJD:=a;
dt:=round(a+1.1-7*int((a+1.1)/7));
WHILE dt<0 DO dt:=dt+7
END;

PROCEDURE HideCursor;
  {kasuje kursor}
BEGIN
 reg.AX:=2;
 Intr(51,Reg);
END;

PROCEDURE SetCursor(x,y:INTEGER);
 {Ustawia kursor myszy na pozycji X,Y}
BEGIN
 reg.AX:=4;
 reg.CX:=x;
 reg.DX:=y;
 Intr(51,Reg);
END;

FUNCTION InitMouse:BOOLEAN; { TRUE jesli mysz zainstalowana }
BEGIN
  reg.AX:=0;
  Intr($33,reg);
  IF INTEGER(reg.AX)=-1 THEN BEGIN InitMouse:=TRUE; HideCursor END
  ELSE InitMouse:=FALSE
END;

PROCEDURE GetDiff(VAR dx,dy:INTEGER);
BEGIN
  reg.AX:=11;
  Intr($33,reg);
  dy:=-INTEGER(reg.DX);
  dx:=INTEGER(reg.CX)
END;

PROCEDURE ShowCursor;
BEGIN
  reg.AX:=1;
  Intr($33,reg)
END;

PROCEDURE MousePos(VAR x,y,Button:INTEGER);
 {Zwraca pozycje kursora myszy i stan przyciskow}
BEGIN
 reg.AX:=3;
 Intr(51,Reg);
 x:=reg.CX shr 3;
 y:=reg.DX shr 3;
   if reg.BX=4 then Button:=3 else Button:=reg.BX;
end; {MousePos}


VAR ii:INTEGER; s1,s2:STRING[15];

PROCEDURE NastI(c:CHAR);
BEGIN
s2:=''; ii:=succ(ii);
WHILE (s1[ii]<>c) AND (ii<15) DO BEGIN s2:=s2+s1[ii]; ii:=succ(ii) END;
END;

PROCEDURE ReadDate(VAR r,m,d:INTEGER);
VAR x:REAL; a,a1,r1,m1,d1,y:INTEGER; ok:BOOLEAN;
    year,month,day,DayOfWeek: WORD;
BEGIN
WRITELN;
REPEAT
y:=WhereY;
GetDate(year,month,day,dayofweek);
WriteLn('Aktualna data: ',year:4,'-',month:2,'-',day:2);
Write  ('Podaj date    (RRRR-MM-DD) '); ReadLn(s1);
IF s1<>'' THEN
  BEGIN
    WHILE s1[0]<#15 DO s1:=s1+#32;
    ii:=0; a:=1; IF s1[1]='-' THEN BEGIN a:=-1; ii:=1 END;
    NastI('-'); Val(s2,r,a1); r:=a*r; a:=a1;
    NastI('-'); Val(s2,m,a1); a1:=a1+a;
    NastI(' '); Val(s2,d,a1); a1:=a1+a;
  END
ELSE
  BEGIN
    a:=0;
    r:=INTEGER(year);
    m:=INTEGER(month);
    d:=INTEGER(day)
  END;
jdata:=DataJD(r,m,d);
RokMD(jdata,r1,m1,d1,x);
ok:=(r1=r) AND (m1=m) AND (d1=d) AND (a=0);
IF NOT ok THEN WRITELN(#10#13' Nie ma takiej daty...');
UNTIL ok; GotoXY(40,y); WriteLn(' , ',dtyg[dt]);
END;

FUNCTION dTT(jd:REAL):REAL; { UT-UTC }
CONST w:ARRAY[0..12] OF REAL=
 (-0.000014,0.001148,0.003357,-0.012462,-0.022542,0.062971,0.079441,
  -0.146960,-0.149279,0.161416,0.145932,-0.067471,-0.058091);
VAR t,y,d,p:REAL; i:INTEGER;

BEGIN
 t:=(jd-2415019.0)/36524.22; { czas w stuleciach od roku 1900 }
 y:=1900+100*t;
 IF (y>=1800) and (y<=1987) THEN
 BEGIN
  d:=0; p:=1;
  FOR i:=0 TO 12 DO BEGIN d:=d+w[i]*p; p:=p*t END
 END;
 IF (y>2010) or (y<1800) THEN d:=0.00084*t+0.000347*t*t;
 IF (y>1987) and (y<=2010) THEN d:=(20.31*t*t+47.8415*t-1)/86400.0;
 IF y<1800 THEN d:=d+56.6/86400;
 IF y>2010 THEN d:=d-39.9/86400;
 dtt:=d
END;

FUNCTION RefInOut(z:REAL):REAL;
CONST                   (* kier. z Ziemi na zewnatrz *)
a:ARRAY[0..12] OF REAL =
(-4.80596719245187E-0006,4.64569647484287E+0002,-4.24792379754272E+0001,
 1.39768776767424E+0000,-1.49632948592414E-0002,-1.61519393297297E-0004,
 3.39934751193432E-0006, 5.55121556842510E-0008,-1.83970118440596E-0009,
 1.57110585046333E-0011,-1.04321790723069E-0014,-5.19524231429322E-0016,
 2.06707051496960E-0018);
VAR i:INTEGER;
    w:REAL;
BEGIN
  z:=Abs(z*180/Pi);
  IF z>90 THEN BEGIN RefInOut:=0; Exit END;
  IF z<=45 THEN w:=(60.3/60)*sin(z*Pi/180)/cos(z*Pi/180) ELSE
  BEGIN
    w:=a[12];
    FOR i:=11 DOWNTO 0 DO w:=z*w+a[i]
  END;
  RefInOut:=w*(Pi/180/60)
END;

FUNCTION RefOutIn(z:REAL):REAL;
CONST                   (* z zewnatrz do Ziemi *)
a:ARRAY[0..12] OF REAL =
(6.17532024891163E-0007, 1.47508478517093E+0002,-1.50589412223534E+0001,
 5.96265061954045E-0001,-1.04467452128348E-0002, 3.75265200899070E-0005,
 1.20302337255595E-0006,-8.54011026535937E-0009,-1.77543620549324E-0010,
 2.28935309220368E-0012, 2.09672302916566E-0015,-1.43471082000615E-0016,
 5.71661985389035E-0019);
VAR i:INTEGER;
    w:REAL;
BEGIN
  z:=Abs(z*180/Pi);
  IF z>90.7 THEN BEGIN RefOutIn:=0; Exit END;
  IF z<=45 THEN w:=(60.3/60)*sin(z*Pi/180)/cos(z*Pi/180) ELSE
  BEGIN
    w:=a[12];
    FOR i:=11 DOWNTO 0 DO w:=z*w+a[i]
  END;
  RefOutIn:=w*(Pi/180/60)
END;



PROCEDURE ReadGodz(VAR g,m,s:INTEGER);
VAR r,r1:INTEGER;
BEGIN
REPEAT
Write('Podaj UTC (GG:MM:SS) '); ReadLn(s1); WHILE s1[0]<#15 DO s1:=s1+#32;
ii:=0;
NastI(':'); Val(s2,g,r1); r:=r1;
NastI(':'); Val(s2,m,r1); r1:=r1+r;
NastI(' '); Val(s2,s,r1); r1:=r1+r;
IF (g<0) OR (g>23) OR (m<0) OR (m>59) OR (s<0) OR (s>59) THEN r:=1;
UNTIL r=0;
gr:=(g-time_zone)/24.0+m/1440.0+s/86400.0;
END;

PROCEDURE OblGodz(jd:REAL;VAR rb,mb,db,g,m,s:INTEGER);
VAR gr:REAL;
BEGIN
 RokMD(jd+time_zone/24-dTT(jd),rb,mb,db,gr);
 gr:=24*(gr-int(gr));
 g:=trunc(gr); gr:=60*(gr-g);
 m:=trunc(gr); gr:=60*(gr-m);
 s:=trunc(gr);
END;

FUNCTION d2(i:INTEGER):STRING;
VAR s:STRING[2];
BEGIN
  Str(i,s);
  IF s[0]=#1 THEN s:='0'+s;
  d2:=s
END;


FUNCTION Deg(d:REAL):s15;
VAR g,m,s:WORD; gr:REAL;
BEGIN
 gr:=d/(2*Pi);
 WHILE gr<0 DO gr:=gr+1;
 gr:=24*(gr-int(gr));
 g:=trunc(gr); gr:=60*(gr-g);
 m:=trunc(gr); gr:=60*(gr-m);
 s:=trunc(gr);
 Deg:=' '+d2(g)+'h'+d2(m)+'m'+d2(s)+'s'
END;


FUNCTION OblRect(f:REAL):s15;
VAR g,m,s:INTEGER;
BEGIN

 g:=trunc(f); gr:=60*(f-g);
 m:=trunc(f); gr:=60*(f-m);
 s:=trunc(f);

END;



PROCEDURE OblJR;
VAR pom:REAL;
BEGIN
GotoXY(62,22); Write('t1=',t1:13:4);
jr[ 1]:=0.606434+0.03660110129*t1;
jr[ 2]:=0.374897+0.03629164709*t1;
jr[ 3]:=0.259091+0.03674819520*t1;
jr[ 4]:=0.827362+0.03386319198*t1;
jr[ 5]:=0.347343-0.00014709391*t1-1;  { ??? < ??? }
jr[ 6]:=0;
jr[ 7]:=0.779072+0.00273790931*t1;
jr[ 8]:=0.993126+0.00273777850*t1;
jr[ 9]:=0.700695+0.01136771400*t1;
jr[10]:=0.485541+0.01136759566*t1;
jr[11]:=0.566441+0.01136762384*t1;
jr[12]:=0.505498+0.00445046867*t1;
jr[13]:=0.140023+0.00445036173*t1;
jr[14]:=0.292498+0.00445040017*t1;
jr[15]:=0.987353+0.00145575328*t1;
jr[16]:=0.053856+0.00145561327*t1;
jr[17]:=0.849694+0.00145569465*t1;
pom:=0.00023080893*t1;
jr[18]:=0.089608+pom;
jr[19]:=0.056531+pom;
jr[20]:=0.814794+pom;
pom:=0.00009294371*t1;
jr[21]:=0.133295+pom;
jr[22]:=0.882987+pom;
jr[23]:=0.821218+pom;
pom:=0.00003269438*t1;
jr[24]:=0.870169+pom;
jr[25]:=0.400589+pom;
jr[26]:=0.664614+0.00003265562*t1;
pom:=0.00001672092*t1;
jr[27]:=0.846912+pom;
jr[28]:=0.725368+pom;
jr[29]:=0.480856+0.00001663715*t1;
jr[30]:=0;
jr[31]:=0.663854+0.00001115482*t1;
pom:=0.00001104864*t1;
jr[32]:=0.041020+pom;
jr[33]:=0.357355+pom;
FOR ii:=1 TO 33 DO jr[ii]:=2*Pi*Frac(jr[ii]);
t:=t1/36525.0+1;
END;

PROCEDURE OblSLON;
CONST tab2:ARRAY[1..12]OF S9=
('@s@@@A@@@','@s@@@B@@@','As@@@A@@@','@c@@@A@@?','@sA@?@@@@','@s@@@D@8C',
 '@c@@@B>@@','@s@@@A?@@','@c@@@D@8C','@s@@@B>@@','@s@@@@@@A','@s@@@B@@>');
CONST tab2i:ARRAY[1..12]OF INTEGER=(6910,72,-17,-7,6,5,-5,-4,4,3,-3,-3);
CONST tb:ARRAY[3..9]OF BYTE=(1,5,7,8,13,16,19);
VAR i,j,wsp:INTEGER; p,w,godz,si,co:REAL; c:CHAR; ss:S9;
BEGIN
dl:=0; godz:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
 {Write('SP OblSLON: t1=',t1:6:8,#13);   WatchSP(t1);}
FOR i:=1 TO 12 DO
 BEGIN
 ss:=tab2[i];
 p:=tab2i[i]; w:=0;
 IF ss[1]>'@' THEN FOR c:='A' TO ss[1] DO p:=p*t;
 FOR j:=3 TO 9 DO
  BEGIN wsp:=(ord(ss[j])-64);
  IF ss[j]<>'@' THEN w:=w+(ord(ss[j])-64)*jr[tb[j]];
  END;
 IF ss[2]='s' THEN w:=p*sin(w) ELSE w:=p*cos(w);
 dl:=dl+w
 END;                                                        { ??? V ??? }
db:=0;
dr:=1.00014-0.01675*cos(jr[tb[6]])+0.00014*cos(2*jr[tb[6]])  -0.000328851;
t2:=(t1+36525.0)/36525.0;
ep:=23.452294-0.0130125*t2-1.64e-6*t2*t2+5.03e-7*t2*t2*t2;
lr:=(dl/3600)*s+jr[7]-17*sin(jr[5])/3600*s;
dbr:=(db/3600)*s; epr:=ep*s; co:=cos(dbr);
x1:=dr*co*cos(lr);
x2:=dr*co*sin(lr);
x3:=dr*sin(dbr);
x4:=x1; co:=cos(epr); si:=sin(epr);
x5:=x2*co-x3*si;
x6:=x2*si+x3*co;
xob:=x4;yob:=x5;zob:=x6;
Coor[0,'x']:=xob; Coor[0,'y']:=yob; Coor[0,'z']:=zob;
   { obliczenie wsp. biegunowych }
al:=Angle(x4,x5);
de:=Angle(Sqrt(x4*x4+x5*x5),x6);
   { obliczenie wsp. horyzontalnych }
az:=-2*Pi*godz-dlu-jr[7]+Pi; si:=sin(az); co:=cos(az);
x1:=x4*co-x5*si; x2:=x4*si+x5*co; x3:=x6; si:=sin(-sze); co:=cos(-sze);
x4:=x1*co-x3*si; x6:=x1*si+x3*co; x5:=x2;
x4:=x4-Paralaksa*4.259e-5;
LoCoor[0,'x']:=x4; LoCoor[0,'y']:=x5; LoCoor[0,'z']:=x6;
LoCoor[0,'w']:=Sqrt(x4*x4+x5*x5+x6*x6)*149597870.0;
az:=Pi/2-Angle(x5,x6); wys:=Angle(Sqrt(x5*x5+x6*x6),x4);
IF Refr<>0 THEN wys:=wys+RefOutIn(Pi/2-wys);
END;


PROCEDURE OblKSIE;
CONST skl:REAL=4.26352e-5;
CONST tab3:ARRAY[1..123]OF S9=
(
'@sA@@@@@@','@sA@>@@@@','@s@@B@@@@','@sB@@@@@@','@s@@@@@A@','@s@B@@@@@',
'@sB@>@@@@','@sA@>@@A@','@sA@B@@@@','@s@@B@@?@','@sA@@@@?@','@s@@A@@@@',
'@sA@@@@A@','@sAB@@@@@','@sAB@@@@@','@sA>@@@@@','@sA@<@@@@','@sC@@@@@@',
'@sB@<@@@@','@sA@>@@?@','@s@@B@@A@','@sA@?@@@@','@s@@A@@A@','@sA@B@@?@',
'@sB@B@@@@','@s@@D@@@@','@sC@>@@@@','@sA@@@P@.','@sB@@@@?@','@sA>>@@@@',
'@cA@@@P@.','@sB@>@@A@','@sA@A@@@@','@s@@B@@>@','@sB@@@@A@','@s@@@@@B@',
'@sA@>@@B@','@s@@@A@@@','@sA>B@@@@','@s@BB@@@@','@sA@<@@A@','@cA@@@P@.',
'@sBB@@@@@','@sA@@@P@.','@sA@=@@@@','@sA@B@@A@','@sB@<@@A@','@sA@@@@>@',
'@sA@>@@>@','@sB@>@@?@','@s@B>@@A@','@sA@D@@@@','@sD@@@@@@','@s@@D@@?@',
'@sB@?@@@@','@s@A@@@@@','@sAA@@@@@','@sA?@@@@@','@s@A>@@@@','@sA?>@@@@',
'@sAA>@@@@','@s@AB@@@@','@sBA@@@@@','@sA?B@@@@','@sB?@@@@@','@s@A>@@A@',
'@sBA>@@@@','@sAAB@@@@','@s@A>@@?@','@sA?>@@A@','@s@A@A@@@','@s@AB@@?@',
'@sAA>@@A@','@sAA@@@?@','@sAA<@@@@','@s@A@@@A@','@s@C@@@@@','@sA?@@@?@',
'@s@AA@@@@','@sAA@@@A@','@sA?@@@A@','@s@A@@@?@','@s@A?@@@@','@sCA@@@@@',
'@s@A<@@@@','@sA?<@@@@','@sA=@@@@@','@sB?<@@@@','@s@C>@@@@','@sB?B@@@@',
'@sA?B@@?@','@sB?>@@@@','@sC?@@@@@','@c@@@@@@@','@cA@@@@@@','@cA@>@@@@',
'@c@@B@@@@','@cB@@@@@@','@cB@>@@@@','@c@@B@@?@','@cA@B@@@@','@cA@>@@A@',
'@cA@@@@?@','@c@@A@@@@','@cA@@@@A@','@cA>@@@@@','@c@@@@@A@','@c@@B@@A@',
'@cA@<@@@@','@cA@>@@?@','@cC@@@@@@','@cB@<@@@@','@c@@A@@A@','@cC@>@@@@',
'@cA@B@@?@','@c@B>@@@@','@c@@B@@>@','@cAB>@@@@','@c@@D@@@@','@cB@>@@A@',
'@cA@<@@A@','@cB@B@@@@','@cB@@@@?@'
);
CONST tab3i:ARRAY[1..93]OF INTEGER=
(22640,-4586,2370,769,-668,-412,-212,-206,192,165,148,-125,-110,-55,-45,
40,-38,36,-31,28,-24,19,18,15,14,14,-13,-11,10,9,9,-9,-8,8,-8,-7,-7,7,
-6,-6,-4,4,-4,4,3,-3,-3,3,3,-2,-2,2,2,2,2,18461,1010,1000,-624,-199,
-167,117,62,33,32,-30,-16,15,12,-9,-8,8,-7,7,-7,-6,-6,6,-5,-5,-5,5,5,
4,-4,-3,3,-2,-2,2,2,2,2);
CONST tab3r:ARRAY[94..123]OF REAL=
(60.36298,-3.27746,-0.57994,-0.46357,-0.08904,0.03865,-0.03237,-0.02688,
-0.02358,-0.02030,0.01719,0.01671,0.01247,0.00704,0.00529,0.00524,0.00398,
-0.00366,-0.00295,-0.00263,0.00249,-0.00221,0.00185,-0.00161,0.00147,
-0.00142,0.00139,-0.00118,-0.00116,-0.001100);
CONST tb:ARRAY[3..9]OF BYTE=(2,3,4,5,7,8,12);
VAR i,j:INTEGER; p,w,godz,si,co:REAL; c:CHAR; ss:S9;
BEGIN
dl:=0; db:=0; dr:=0; godz:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
{Write('SP OblKSIE: t1=',t1:6:8,#13);}
FOR i:=1 TO 55 DO
 BEGIN
 ss:=tab3[i];
 p:=tab3i[i]; w:=0;
 IF ss[1]>'@' THEN FOR c:='A' TO ss[1] DO p:=p*t;
 FOR j:=3 TO 9 DO w:=w+(ord(ss[j])-64)*jr[tb[j]];
 IF ss[2]='s' THEN w:=p*sin(w) ELSE w:=p*cos(w);
 dl:=dl+w
 END;
FOR i:=56 TO 93 DO
 BEGIN
 ss:=tab3[i];
 p:=tab3i[i]; w:=0;
 IF ss[1]>'@' THEN FOR c:='A' TO ss[1] DO p:=p*t;
 FOR j:=3 TO 9 DO w:=w+(ord(ss[j])-64)*jr[tb[j]];
 IF ss[2]='s' THEN w:=p*sin(w) ELSE w:=p*cos(w);
 db:=db+w
 END;
FOR i:=94 TO 123 DO
 BEGIN
 ss:=tab3[i];
 p:=tab3r[i]; w:=0;
 IF ss[1]>'@' THEN FOR c:='A' TO ss[1] DO p:=p*t;
 FOR j:=3 TO 9 DO w:=w+(ord(ss[j])-64)*jr[tb[j]];
 IF ss[2]='s' THEN w:=p*sin(w) ELSE w:=p*cos(w);
 dr:=dr+w
 END;

t2:=(t1+36525.0)/36525.0;
ep:=23.452294-0.0130125*t2-1.64e-6*t2*t2+5.03e-7*t2*t2*t2;
lr:=(dl/3600)*s+jr[1]-17*sin(jr[5])/3600*s;
dbr:=(db/3600)*s; epr:=ep*s; co:=cos(dbr);
x1:=dr*co*cos(lr);
x2:=dr*co*sin(lr);
x3:=dr*sin(dbr);
x4:=x1; co:=cos(epr); si:=sin(epr);
x5:=x2*co-x3*si;
x6:=x2*si+x3*co;
dr:=dr*skl; x4:=x4*skl; x5:=x5*skl; x6:=x6*skl;
xob:=x4;yob:=x5;zob:=x6;
Coor[1,'x']:=xob; Coor[1,'y']:=yob; Coor[1,'z']:=zob;
(* obliczenie wsp. biegunowych *)
al:=Angle(x4,x5);
de:=Angle(Sqrt(x4*x4+x5*x5),x6);
   (* obliczenie wsp. horyzontalnych *)
az:=-2*Pi*godz-dlu-jr[7]+Pi; si:=sin(az); co:=cos(az);
x1:=x4*co-x5*si; x2:=x4*si+x5*co; x3:=x6; si:=sin(-sze); co:=cos(-sze);
x4:=x1*co-x3*si; x6:=x1*si+x3*co; x5:=x2;
x4:=x4-Paralaksa*4.259e-5;
LoCoor[1,'x']:=x4; LoCoor[1,'y']:=x5; LoCoor[1,'z']:=x6;
LoCoor[1,'w']:=Sqrt(x4*x4+x5*x5+x6*x6)*149597870;
az:=Pi/2-Angle(x5,x6); wys:=Angle(Sqrt(x5*x5+x6*x6),x4);
IF Refr<>0 THEN wys:=wys+RefOutIn(Pi/2-wys);
END;

PROCEDURE OblOBIEKT;
BEGIN
IF Obiekt=1 THEN OblKSIE
ELSE OblSLON
END;

FUNCTION Faza(obiekt:BYTE):REAL;
BEGIN
  Faza:=
  (Coor[0,'x']*Coor[obiekt,'x']+Coor[0,'y']*Coor[obiekt,'y']+
  Coor[0,'z']*Coor[obiekt,'z'])/
  (Sqrt(Coor[0,'x']*Coor[0,'x']+
   Coor[0,'y']*Coor[0,'y']+
   Coor[0,'z']*Coor[0,'z'])*
   Sqrt(Coor[obiekt,'x']*Coor[obiekt,'x']+
   Coor[obiekt,'y']*Coor[obiekt,'y']+
   Coor[obiekt,'z']*Coor[obiekt,'z']))
END;

FUNCTION LoFaza(obiekt:BYTE):REAL;
BEGIN
  LoFaza:=
  (LoCoor[0,'x']*LoCoor[obiekt,'x']+LoCoor[0,'y']*LoCoor[obiekt,'y']+
  LoCoor[0,'z']*LoCoor[obiekt,'z'])/
  (Sqrt(LoCoor[0,'x']*LoCoor[0,'x']+
   LoCoor[0,'y']*LoCoor[0,'y']+
   LoCoor[0,'z']*LoCoor[0,'z'])*
   Sqrt(LoCoor[obiekt,'x']*LoCoor[obiekt,'x']+
   LoCoor[obiekt,'y']*LoCoor[obiekt,'y']+
   LoCoor[obiekt,'z']*LoCoor[obiekt,'z']))
END;

FUNCTION LoDiam(obiekt:BYTE):REAL; { srednica katowa }
BEGIN
  CASE obiekt OF
    0: { Slonce } LoDiam:=2*ArcSin(696000.0/LoCoor[0,'w']);
    1: { Ksiezyc } LoDiam:=2*ArcSin(1738.0/LoCoor[1,'w'])
    ELSE LoDiam:=0
  END
END;



FUNCTION OblFAZE(jd:REAL;dir:INTEGER):REAL;  { Patrz Mlody Technik 12/1985, s.48 }
VAR k,t,tr,M,M1,F,ss,jd1:REAL; i,dk:INTEGER;
BEGIN
jd1:=jd;
i:=0;
REPEAT
k:=12.3685*(jd-2415020.75933)/365.2422;
k:=int(4*k+dir)/4;
IF i>0 THEN k:=k+dir*0.2;
dk:=round(4*(k-int(k)));
WHILE dk<0 DO dk:=dk+4;
{k:=Int(k-dk/4)+dk/4;}
t:=k/1236.85;
jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
tr:=s*(166.56+132.87*t-0.009173*t*t);
jd:=jd+0.00033*sin(tr);
M :=s*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
M1:=s*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
F :=s*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
IF (dk=0) OR (dk=2) THEN
jd:=jd+(0.1734-0.000393*t)*sin(M)+0.0021*sin(2*M)-0.4068*sin(M1)+
    0.0161*sin(2*M1)-0.0004*sin(3*M1)+0.0104*sin(2*F)-
    0.0051*sin(M+M1)-0.0074*sin(M-M1)+0.0004*sin(2*F+M)-
    0.0004*sin(2*F-M)-0.0006*sin(2*F+M1)+0.001*sin(2*F-M1)+0.0005*sin(M+2*M1)
ELSE
jd:=jd+(0.1721-0.0004*t)*sin(M)+0.0021*sin(2*M)-0.628*sin(M1)+
    0.0089*sin(2*M1)-0.0004*sin(3*M1)+0.0079*sin(2*F)-0.0119*sin(M+M1)-
    0.0047*sin(M-M1)+0.0003*sin(2*F+M)-0.0004*sin(2*F-M)-
    0.0006*sin(2*F+M1)+0.0021*sin(2*F-M1)+0.0003*sin(M+2*M1)+
    0.0004*sin(M-2*M1)-0.0003*sin(2*M+M1);
IF dk=1 THEN jd:=jd+0.0028-0.0004*cos(M)+0.0003*cos(M1);
IF dk=3 THEN jd:=jd+0.0004*cos(M)-0.0003*cos(M1);
jd:=jd-dTT(jd);
i:=i+1;
UNTIL Abs(jd-jd1)>1e-4;
CASE dk OF
 0: infs:='now';
 1: infs:='I kwadra';
 2: infs:='pelnia';
 3: infs:='ost.kw.'
END;
OblFAZE:=jd;
END;


FUNCTION SunAng(jd:REAL):REAL;
VAR pom:REAL;
BEGIN
  t1:=jd-2451545.0+dTT(jd);
  OblJR;
  OblSLON;
  OblKSIE;
  SunAng:=-LoFaza(1);     { - cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
END;

FUNCTION MoonAng(jd:REAL):REAL;
BEGIN
  t1:=jd-2451545.0+dTT(jd);
  OblJR;
  OblSLON;
  OblKSIE;
  MoonAng:=Faza(1);    { cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
END;


FUNCTION OblZacmKs(jd:REAL;dir:INTEGER):REAL;  { Patrz Mlody Technik 8/1986, s.92 }
LABEL LOOP, ENDLOOP;
VAR cc,k,k1,kp,gamma,Hd,hm,u,t,tr,M,M1,F,ss,jd1:REAL; i,dk:INTEGER;
BEGIN
  jd1:=jd;
  i:=0;

  k:=12.3685*(jd-2415020.75933)/365.2422; kp:=k;

  k1:=int(k+0.5)+2.5;
  IF dir=1 THEN
    BEGIN WHILE k1>=k DO k1:=k1-1.0; k1:=k1+1.0 END;
  IF dir=-1 THEN
    BEGIN k1:=k1-5.0; WHILE k1<=k DO k1:=k1+1.0; k1:=k1-1.0 END;
  k:=k1-dir;

{  WHILE Abs(kp-k)>1.1 DO k:=k+Sgn(kp-k); }
  IF Abs(kp-k-dir)<0.05 THEN k:=k+dir;
  LOOP:
    k:=k+dir;
    t:=k/1236.85;
    F:=s*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
    IF Abs(sin(F))>0.35837 THEN GoTo LOOP;
    M :=s*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
    M:=M-2*Pi*int(M/(2*Pi));
    M1:=s*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
    M1:=M1-2*Pi*int(M1/(2*Pi));
    ss:=5.19595-0.0048*cos(M)+0.002*cos(2*M)-0.3283*cos(M1)-0.006*cos(M+M1)+
        0.0041*cos(M-M1);
    cc:=0.207*sin(M)+0.0024*sin(2*M)-0.039*sin(M1)+0.0115*sin(2*M1)-
        0.0073*sin(M+M1)-0.0067*sin(M-M1)+0.0117*sin(2*F);
    u:=0.0059+0.0046*cos(M)-0.0182*cos(M1)+0.0004*cos(2*M1)-0.0005*cos(M+M1);
    gamma:=ss*sin(F)+cc*cos(F);
    Hd:=(1.0129-u-Abs(gamma))/0.545;  { maksymalna faza zacmienia dla cienia }
    hm:=(1.5572+u-Abs(gamma))/0.545;  { ...i dla polcienia }
    IF hm<=0 THEN GoTo LOOP;
    Hd_g:=Hd;
    hm_g:=hm;
    IF Hd<0 THEN infs:='polcieniowe';
    IF (Hd>=0) AND (Hd<1) THEN infs:='cieniowe czesciowe';
    IF Hd>=1 THEN infs:='calkowite';
    jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
    tr:=s*(166.56+132.87*t-0.009173*t*t);
    jd:=jd+0.00033*sin(tr);
    jd:=jd+(0.1734-0.000393*t)*sin(M)+
        0.0021*sin(2*M)-0.4068*sin(M1)+
        0.0161*sin(2*M1)-0.0051*sin(M+M1)-0.0074*sin(M-M1)-0.0104*sin(2*F);
    {
    0.4068*sin(M1)+0.0161*sin(2*M1)+
    0.0104*sin(2*F)-0.0051*sin(M+M1)-0.0074*sin(M-M1)+0.001*sin(2*F-M1)+
    0.0021*sin(2*M)-0.0004*sin(3*M1)+0.0004*(sin(2*F+M)-sin(2*F-M))-
    0.0006*sin(2*F+M1)+0.0005*sin(M+2*M1)
    }
    { 1993-05-21 }    IF e_loc THEN minimum(jd-0.3,jd+0.3,0.00005,jd,MoonAng);
    Delay(1);
    jd:=jd+dTT(jd); { was -dTT... why? }
    IF Abs(jd-jd1)<0.01 THEN GoTo LOOP;
  ENDLOOP:
  OblZacmKs:=jd;
END;

FUNCTION OblZacmSl(jd:REAL;dir:INTEGER):REAL;  { Patrz Mlody Technik 9/1986, s.80 }
LABEL LOOP, ENDLOOP;
VAR cc,k,k1,kp,gamma,Hd,hm,u,t,tr,M,M1,F,ss,jd1:REAL; i,dk:INTEGER;
BEGIN
  jd1:=jd;
  i:=0;

  k:=12.3685*(jd-2415020.75933)/365.2422; kp:=k;

  k1:=int(k);
  IF dir=1 THEN
    BEGIN WHILE k1>=k DO k1:=k1-1.0; k1:=k1+1.0 END;
  IF dir=-1 THEN
    BEGIN k1:=k1-5.0; WHILE k1<=k DO k1:=k1+1.0; k1:=k1-1.0 END;
  k:=k1-dir;
  IF Abs(kp-k-dir)<0.05 THEN k:=k+dir;
  LOOP:
    k:=k+dir;
    t:=k/1236.85;
    F:=s*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
    IF Abs(sin(F))>0.35837 THEN GoTo LOOP;
    M :=s*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
    M:=M-2*Pi*int(M/(2*Pi));
    M1:=s*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
    M1:=M1-2*Pi*int(M1/(2*Pi));
    ss:=5.19595-0.0048*cos(M)+0.002*cos(2*M)-0.3283*cos(M1)-0.006*cos(M+M1)+
        0.0041*cos(M-M1);
    cc:=0.207*sin(M)+0.0024*sin(2*M)-0.039*sin(M1)+0.0115*sin(2*M1)-
        0.0073*sin(M+M1)-0.0067*sin(M-M1)+0.0117*sin(2*F);
    u:=0.0059+0.0046*cos(M)-0.0182*cos(M1)+0.0004*cos(2*M1)-0.0005*cos(M+M1);
    gamma:=ss*sin(F)+cc*cos(F);
    IF Abs(gamma)>1.5432 THEN GoTo LOOP;
    IF (0.9972+Abs(u)<Abs(gamma)) AND (Abs(gamma)<1.5432+u) THEN
      e_status:=1  { niecentralne czesciowe }
    ELSE IF (0.9972<Abs(gamma)) AND (Abs(gamma)<0.9972+Abs(u)) THEN
      e_status:=2  { niecentralne calkowite lub niecentralne obraczkowe }
    ELSE IF Abs(gamma)<0.9972 THEN
      IF u<0 THEN e_status:=3  { centralne calkowite }
    ELSE IF u>0.00464*Sqrt(1-gamma*gamma) THEN
      e_status:=4   { centralne obraczkowe }
    ELSE e_status:=5 { centralne obraczkowo-calkowite };

    CASE e_status OF
     1: infs:='niecentralne czesciowe';
     2: infs:='niecentralne calkowite lub obraczkowe';
     3: infs:='centralne calkowite';
     4: infs:='centralne obraczkowe';
     5: infs:='centralne obraczkowo-calkowite'
    END;
    jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
    tr:=s*(166.56+132.87*t-0.009173*t*t);
    jd:=jd+0.00033*sin(tr);
    jd:=jd+(0.1734-0.000393*t)*sin(M)+
        0.0021*sin(2*M)-0.4068*sin(M1)+
        0.0161*sin(2*M1)-0.0051*sin(M+M1)-0.0074*sin(M-M1)-0.0104*sin(2*F);
    { 1993-05-21 }    IF e_loc THEN
                          minimum(jd-0.2,jd+0.2,0.00005,jd,SunAng);
    Delay(1);
    jd:=jd+dTT(jd); { was -dTT... why? }
    IF Abs(jd-jd1)<0.01 THEN GoTo LOOP;
  ENDLOOP:
  OblZacmSl:=jd;
END;




FUNCTION ss(q,x:REAL):INTEGER;
VAR x1,x2:REAL;
BEGIN
  IF x>Pi THEN BEGIN x1:=x-Pi; x2:=x END
          ELSE BEGIN x1:=x; x2:=x+Pi END;
  ss:=1;
  IF (q=x1) OR (q=x2) THEN ss:=0
  ELSE IF (q<x1) OR (q>x2) THEN ss:=-1
END;

FUNCTION vw: INTEGER;
VAR q:REAL;
BEGIN
  q:=az; IF q<0 THEN q:=q+2*Pi;
  CASE ch1 OF
  'H': vw:=Sgn(wys+Refr);
  'W': vw:=ss(q,6*Pi/4);
  'E': vw:=ss(q,Pi/2);
  'S': vw:=ss(q,Pi);
  'N': vw:=ss(q,0);
  'A': vw:=ss(q,kierunek)
  END
END;

PROCEDURE OblWSCH(tb:REAL);
VAR g,t11,t12:REAL; s,s1,s2:INTEGER; v:BOOLEAN;
BEGIN
t11:=tb; t12:=tb+0.5; { t11:polnoc, t12:poludnie }
t1:=t11; OblJR; OblOBIEKT; s1:=vw; { vw to funkcja! }
t1:=t12; OblJR; OblOBIEKT; s2:=vw;
v := s1=s2; IF v THEN WriteLn('Cos tu sie nie zgadza...');
IF not(v) THEN REPEAT
tb:=t11+(t12-t11)/2; t1:=tb; OblJR; OblOBIEKT;
s:=vw;
IF s=s2 THEN  BEGIN t12:=tb; s2:=s END
        ELSE  BEGIN t11:=tb; s1:=s END;
UNTIL Abs(t12-t11)<1e-5;
ttt:=t11+(t12-t11)/2;
END;

PROCEDURE NextPlace(dp:INTEGER);
VAR x,y:INTEGER;
BEGIN
 x:=WhereX;
 y:=WhereY;
 Window(1,1,80,25);
 akt_m:=akt_m+dp;
 IF akt_m>nmiejsc THEN akt_m:=1;
 IF akt_m<1 THEN akt_m:=nmiejsc;
 GotoXY(3,2);
 Write('Location: '); Write(miejsca[akt_m].n); ClrEol;
 GotoXY(1,2); Write('º'); GotoXY(79,2); WriteLn('º');
 sze:=s*miejsca[akt_m].s;
 dlu:=s*miejsca[akt_m].d;
 GotoXY(44,2);
 Write('lat = ',sze/s:0:2,'ø   lon = ',dlu/s:0:2,'ø');
 ClrEol;
 GotoXY(1,1);
 WriteLn('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
 GotoXY(1,2); Write('º'); GotoXY(79,2); WriteLn('º');
 WriteLn('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
 GotoXY(x,y)
END;

PROCEDURE CLM;
VAR i:INTEGER;
BEGIN
 IF Random(2)=0 THEN
 FOR i:=0 TO 13 DO
  BEGIN
   Window(1,1,80,12);
   InsLine;
   Delay(2);
   Window(1,13,80,25);
   DelLine
  END
 ELSE
 FOR i:=0 TO 39 DO
  BEGIN
   Window(2*i+1,1,2*i+2,25);
   Delay(2);
   ClrScr
  END;
 Window(1,1,80,25);
END;

PROCEDURE W(s:STRING);
VAR i,j,x,y,dx:INTEGER;
BEGIN
  IF s[1]='®' THEN
   BEGIN s:=Copy(s,2,pred(Length(s))); WHILE s[0]<#79 DO s:=s+' ' END;
  x:=40-Length(s) div 2;
  y:=WhereY;
  IF odd(y+1) THEN BEGIN j:=Length(s); x:=80-x; dx:=-1 END
              ELSE BEGIN dx:=1; j:=1 END;
  FOR i:=1 TO Length(s) DO
    BEGIN
      GotoXY(x,y);
      Write(s[j]);
      x:=x+dx;
      j:=j+dx;
      Sound(10000);
      NoSound;
      Delay(2)
    END;
  WriteLn
END;

PROCEDURE nie_obliczono;
VAR i:INTEGER;
BEGIN
  FOR i:=0 TO 10 DO obliczoneobiekty[i]:=FALSE;
  {Window(12,15,79,22);
  ClrScr;
  Window(1,1,80,25);}
END;

PROCEDURE ChangeTimeZone(dt:INTEGER);
BEGIN
  IF (time_zone+dt+13) IN [1..25] THEN time_zone:=time_zone+dt;
  timestring:='';
  IF time_zone=1 THEN timestring:='CET - Polska ';
  IF time_zone=0 THEN timestring:='UTC ';
  IF time_zone=2 THEN timestring:='czas letni';
  IF time_zone=3 THEN timestring:='Moskwa, Bagdad';
  IF time_zone=-5 THEN timestring:='ET - New York';
  IF time_zone=-8 THEN timestring:='PT - Pacific Time';
  GotoXY(34,8);
  Write(time_zone:3,'    ');
  GotoXY(34,9);
  WHILE timestring[0]<#17 DO timestring:=' '+timestring;
  Write(timestring);
  GotoXY(8,9);
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  wst[0]:=#12;
  Write(wst);
  nie_obliczono
END;

PROCEDURE Info;
VAR c:CHAR;
BEGIN
 Window(1,1,80,25);
 CLM;
 HighVideo;
 W ('Kr¢tka informacja o programie SKY');
 NormVideo;
 WriteLn;
 W ('Program SKY oblicza poˆo¾enia Sˆoäca i Ksi©¾yca na niebie z dokˆadno˜ci¥');
 W ('1 minuty k¥towej w przedziale ñ300 lat od chwili obecnej. U¾ytkownik mo¾e');
 W ('wybra† dowoln¥ stref© czasow¥ i jedno z wpisanych w programie miejsc na');
 W ('˜wiecie (program mo¾na uzupeˆni† o nowe wsp¢ˆrz©dne - zawiera je tablica');
 W ('MIEJSCA). Uwzgl©dniana mo¾e by† refrakcja atmosferyczna. Na ekranie');
 W ('wy˜wietlane s¥ informacje o wybranym miejscu obserwacji, data, godzina,');
 W ('strefa czasowa, data julianska; dT oznacza r¢¾nic© UT-UTC dla wybranej');
 W ('daty (w sekundach). Po upˆywie 0.1 sekundy od czasu naci˜ni©cia klawisza');
 W ('obliczane sa pozycje Sˆoäca i Ksi©¾yca. Wy˜wietlane s¥: ich deklinacja,');
 W ('rektascensja, azymut (od p¢ˆnocy na wsch¢d), wysoko˜† nad horyzontem (wszystko');
 W ('w stopniach) oraz odlegˆo˜† od Ziemi w kilometrach.');
 W ('Ustawianie daty odbywa sie klawiszami Y,M,D (zwi©kszenie o 1 roku, miesi¥ca,');
 W ('dnia miesi¥ca), tymi samymi klawiszami z klawiszem SHIFT (odp. zmiejszenie');
 W ('o jeden); ust. godziny: H,+,-,S (uwaga: +,-,S zmieniaj¥ czas w spos¢b ci¥gˆy,');
 W ('H pozostaje w obr©bie wybranego dnia); ñ1 dzieä: J; zmiana strefy');
 W ('czasowej: Z; zmiana miejsca obserwacji: N; uwzgl©dnianie refrakcji: A;');
 W ('ustawienie aktualnej daty i czasu: C; obja˜nienia otrzymywanych wynik¢w: E;');
 W ('fazy Ksi©¾yca: F.');

 GotoXY(73,25);
 Write('KEY...');
END;


PROCEDURE AInfo;
VAR c:CHAR; i:INTEGER;
BEGIN
 Window(1,1,80,25);
 CLM;
 HighVideo;
 W ('Co oznaczaj¥ wyniki...');
 NormVideo;
 WriteLn;
 W ('®Object:   nazwa obiektu, kt¢rego dotycz¥ wyniki');
 W ('®  WSPORZ¨DNE BIEGUNOWE:');
 W ('®rect:     rektascensja, ozn. à (odpowiada dˆugo˜ci geograficznej)');
 W ('®decl:     deklinacja, ozn. ë (odpowiada szeroko˜ci geograficznej)');
 W ('®  WSPORZ¨DNE HORYZONTALNE:');
 W ('®az:       azymut, liczony w stopniach od kierunku p¢ˆnocnego na wsch¢d');
 W ('®height:   wysoko˜†, liczona w stopniach od horyzontu');
 W ('®distance: odlegˆo˜† od ˜rodka Ziemi do ˜rodka obiektu w kilometrach');
 W ('®phase:    faza, podawana jako k¥t (w stopniach) mi©dzy obiektem a Sˆoäcem');
 W ('®          (k¥t widziany z punktu obserwacji); E oznacza za†mienie');
 W ('----------');



 GotoXY(73,25);
 Write('KEY...');
 REPEAT UNTIL KeyPressed;
 c:=ReadKey
END;

PROCEDURE Ramka(x0,y0,lx,ly:INTEGER);
VAR i:INTEGER;
BEGIN
  GotoXY(x0,y0); Write(#218);
  GotoXY(x0+lx-1,y0); Write(#191);
  GotoXY(x0,y0+ly-1); Write(#192);
  GotoXY(x0+lx-1,y0+ly-1); Write(#217);
  GotoXY(x0+1,y0); FOR i:=x0+1 TO x0+lx-2 DO Write(#196);
  GotoXY(x0+1,y0+ly-1); FOR i:=x0+1 TO x0+lx-2 DO Write(#196);
  FOR i:=y0+1 TO y0+ly-2 DO
    BEGIN
      GotoXY(x0,i); Write(#179);
      GotoXY(x0+lx-1,i); Write(#179)
    END
END;


PROCEDURE NewDate(r,m,d:INTEGER);
VAR s:s15;
BEGIN
  jd:=DataJD(r,m,d);
  GotoXY(9,5);
  Write(r:5,'-',d2(m),'-',d2(d));
  s:=dow[dt];
  WHILE s[0]<#10 DO s:=' '+s;
  GotoXY(10,6);
  Write(s);
  rbi:=r; mbi:=m; dbi:=d;
  GotoXY(50,5);
  Str(86400*dTT(jd+jDNIA-time_zone/24):7:1,wst);
  wst[0]:=#7;
  Write(wst,'s');
  GotoXY(8,9);
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  wst[0]:=#12;
  Write(wst);
  nie_obliczono;
  IF r>2343 THEN IF (Random(1000)=0) AND not(ask) THEN
    BEGIN
      ts1m:=tsmo; ts1c:=tsco;
      CLM;
      GotoXY(1,10);
      W ('Does the WORLD still exist?');
      Delay(1500);
      WriteLn;
      W ('Y E S  ?');
      Delay(2000);
      WriteLn;
      W ('It''s nice!');
      Delay(1000);
      tsmo:=ts1m; tsco:=ts1c;
      ask:=TRUE
    END;
END;

PROCEDURE NewJD(jd:REAL);
VAR r,m,d:INTEGER;
BEGIN
  RokMD(jd,r,m,d,pm);
  NewDate(r,m,d);
  nie_obliczono;

END;

PROCEDURE NewTime(h,m,s:INTEGER);
BEGIN
  jDNIA:=(3600*LONGINT(h)+60*m+s)/86400;
  gobi:=h;
  mibi:=m;
  sebi:=s;
  GotoXY(8,9);
  Str(jd+jDNIA-time_zone/24:12:4,wst);
  wst[0]:=#12;
  Write(wst);
  GotoXY(50,5);
  Str(86400*dTT(jd+jDNIA-time_zone/24):7:1,wst);
  wst[0]:=#7;
  Write(wst,'s');
  GotoXY(33,5);
  Write(gobi:2,':',d2(mibi),':',d2(sebi));
  nie_obliczono
END;

PROCEDURE ReadMouse(VAR c:CHAR);
VAR x,y,B:INTEGER;
  FUNCTION zn(ch:CHAR;i:INTEGER):CHAR;
  BEGIN
    IF i=2 THEN zn:=ch ELSE zn:=UpCase(ch)
  END;
BEGIN
  ShowCursor;
  IF MP1 THEN Delay(MouseDel);
  MousePos(x,y,B);
  IF MP1 AND (B>0) THEN
    BEGIN
      IF MouseDel>50 THEN MouseDel:={MouseDel-30;}34;
    END;
  IF not(MP1) AND (B>0) THEN MouseDel:=400;
  MousePressed:=FALSE;
  MP1:=FALSE;
  IF B=3 THEN BEGIN c:='c'; MP1:=TRUE; MousePressed:=TRUE END;
  IF not(B IN [1,2]) THEN Exit;
  CASE y OF
  1: c:=zn('n',B);
  4: BEGIN
       IF x IN [9..12] THEN c:=zn('y',B);
       IF x IN [14,15] THEN c:=zn('m',B);
       IF x IN [17,18] THEN c:=zn('d',B);
       IF x IN [32,33] THEN c:=zn('h',B);
       IF x IN [35,36] THEN IF B=2 THEN c:='+' ELSE c:='-';
       IF x IN [38,39] THEN c:=zn('s',B);
     END;
  7,8: BEGIN
         IF x IN [22..49] THEN c:=zn('z',B);
         IF (y=8) AND (x IN [1..19]) THEN c:=zn('j',B);
         IF x IN [52..57] THEN c:='a'
       END;
  14:  BEGIN
         IF x IN [48..53] THEN c:=zn('w',B)  { sunrise or sunset }
       END;
  15:  BEGIN
         IF x IN [66..74] THEN c:=zn('f',B)
       END;
  23:  BEGIN  { 1992-08-31 }
         IF x IN [12..16] THEN c:=zn('1',B);
         IF x IN [24..28] THEN c:=zn('2',B);
         IF x IN [36..40] THEN c:=zn('3',B);
         IF x IN [49..53] THEN c:=zn('4',B);
         IF x IN [57..61] THEN c:=zn('5',B);
         IF x IN [62..66] THEN c:=zn('6',B);
         IF x IN [67..71] THEN c:=zn('7',B)
       END;
END;
MousePressed:=TRUE;
MP1:=TRUE;
END;



PROCEDURE RysujRamki;
BEGIN

{ DateFrame }
  Ramka(1,4,21,4);
  GotoXY(3,5);
  Write('Date: ');
  Ramka(1,8,21,3);
  GotoXY(3,9);
  Write('JD = ');

{ TimeFrame }
  Ramka(22,4,21,3);
  GotoXY(24,5);
  Write('Time: ');

{ dTT Frame }
  Ramka(43,4,17,3);
  GotoXY(45,5);
  Write('dT = ');

{ TimeZone }
  Ramka(22,7,30,4);
  GotoXY(24,8);
  Write('Timezone: ');

{ Ref }
  Ramka(52,7,8,4);
  GotoXY(54,8);
  Write('Ref');
  GotoXY(54,9);
  Write('YES');

  Ramka(1,11,80,3);
  GotoXY(3,12);
  Write('Object':10,'  ','rect. à':10,'decl. ë':10,'az':10,'height':10,'distance':10,'phase':10);


  Ramka(1,14,80,10);
  Ramka(60,4,20,7);
  GotoXY(62,5);
  Write('Control keys:');
  GotoXY(63,6);
  Write('Date: (R),Y,M,D');
  GotoXY(63,7);
  Write('Time: H,+,-,S,Z');
  GotoXY(63,8);
  Write('JD: J; Loc.: N');
  GotoXY(63,9);
  Write('SHIFT');
  GotoXY(1,24);
  Write('Eclipses:   <<<<<  SUN  >>>>>       <<<<<  MOON  >>>>>   ');
  IF e_vis THEN BEGIN HighVideo; Write(' VIS '); LowVideo END ELSE Write(' vis ');
  IF e_tot THEN BEGIN HighVideo; Write(' TOT '); LowVideo END ELSE Write(' tot ');
  IF e_loc THEN BEGIN HighVideo; Write(' LOC '); LowVideo END ELSE Write(' loc ');
END;


FUNCTION Czas:LONGINT;
VAR h,m,s,s100:WORD;
BEGIN
  GetTime(h,m,s,s100);
  Czas:=s100+100*longint(s)+100*60*longint(m)+100*60*longint(60*h);
END;

FUNCTION Minelo(i:INTEGER):LONGINT;
VAR t:LONGINT;
BEGIN
  t:=Czas-czasy[i];
  WHILE t<0 DO t:=t+8640000;
  Minelo:=t
END;


PROCEDURE Main1;
LABEL LOOP1,ENDLOOP1,LOOP2,ENDLOOP2;
VAR c:CHAR;

BEGIN
 Randomize;
 ClrScr;
 GotoXY(1,10);
 HighVideo;
 W ('SKY - oblicza poˆo¾enie Sˆoäca i Ksi©¾yca');
 NormVideo;
 WriteLn;
 W ('Wedˆug InforMik-a 2/1989 napisaˆ Piotr Fabian');
 WriteLn;
 W ('Gliwice, VIII 1989 .. X 1992'#10);
 { 1991-08-29 .. 1991-09-18 }
 { 1992-08-31 .. ???        }
 GotoXY(73,25);
 Write('KEY...');
 REPEAT UNTIL KeyPressed;
 c:=ReadKey;


 Info; ask:=FALSE;
 MousePresent:=InitMouse;
 GotoXY(1,22);
 IF MousePresent THEN
   BEGIN
    W ('You have a mouse !');
    W ('Press left button to decrease, right button to increase');
    W ('The middle button copies the current time...')
   END
 ELSE
    W ('Unfortunately you have no mouse, so you have to use the keyboard...');
 GotoXY(78,25);

 REPEAT UNTIL KeyPressed;
 c:=ReadKey;

 CLM;
 NextPlace(1);
 ChangeTimeZone(0);

 MousePresent:=InitMouse;
 IF MousePresent THEN
   BEGIN
     SetCursor(1,1);
     ShowCursor
   END;
 MP1:=FALSE;

 ASM
   mov ah,1
   mov ch,10 {crsr start}
   mov cl,10 {end}
   int $10
 END;

 GetDate(pom1,pom2,pom3,pom4);
 jd:=DataJD(pom1,pom2,pom3);
 jDNIA:=0;
 RokMD(jd,rbi,mbi,dbi,pm);
 IF jd>currentjd THEN NewDate(rbi,mbi,dbi) ELSE
 BEGIN RokMD(currentjd,rbi,mbi,dbi,pm); NewDate(rbi,mbi,dbi) END;

 GetTime(pom1,pom2,pom3,pom4);
 NewTime(pom1,pom2,pom3);

 Window(1,1,80,25);



 RysujRamki;
 czasy[0]:=Czas;
 Paralaksa:=1; Refr:=1/3;


 REPEAT
  IF KeyPressed THEN c:=ReadKey ELSE c:=' ';
  IF MousePresent THEN ReadMouse(c);

  IF UpCase(c)='C' THEN
  BEGIN
   HideCursor;
   Sound(5000);Delay(3);NoSound;
   czasy[0]:=Czas;
   Czasy[0]:=Czas-100;
   GetDate(pom1,pom2,pom3,pom4);
   jd:=DataJD(pom1,pom2,pom3);
   RokMD(jd,rpm,mpm,dpm,pm);
   IF jd>currentjd THEN NewDate(rpm,mpm,dpm) ELSE
   BEGIN RokMD(currentjd,rbi,mbi,dbi,pm); NewDate(rbi,mbi,dbi) END;
   GetTime(pom1,pom2,pom3,pom4);
   NewTime(pom1,pom2,pom3);
   ShowCursor;
  END;

  IF UpCase(c) IN ['F','E','A','S','J','R','Y','N','M','+','-','D','H','Z','1'..'7','W',#27,#1] THEN
  BEGIN
   Sound(5000);Delay(3);NoSound;
   GoToXY(1,25); ClrEol;
   czasy[0]:=Czas;
   HideCursor;


   CASE c OF

   'd': BEGIN
          jd:=DataJD(rbi,mbi,dbi+1);
          RokMD(jd,rpm,mpm,dpm,pm);
          NewDate(rbi,mbi,dpm)
        END;

   'D': BEGIN
          jd:=DataJD(rbi,mbi,dbi-1);
          RokMD(jd,rpm,mpm,dpm,pm);
          IF dbi<dpm THEN
           BEGIN
             RokMD(jd-1+40,rpm,mpm,dpm,pm);
             dpm:=39-dpm
           END;
          IF (rbi=1582) AND (mbi=10) AND (dbi=15) THEN dpm:=4;
          NewDate(rbi,mbi,dpm)
        END;

   'm': BEGIN
          mbi:=mbi+1;
          IF mbi>12 THEN mbi:=1;
          jd:=DataJD(rbi,mbi,dbi);
          RokMD(jd,rpm,mpm,dpm,pm);
          IF dbi<>dpm THEN
           BEGIN
             RokMD(DataJD(rbi,mpm,1)-1,rpm,mpm,dpm,pm);
             dbi:=dpm
           END;
          NewDate(rbi,mbi,dbi)
        END;

   'M': BEGIN
          mbi:=mbi-1;
          IF mbi<1 THEN mbi:=12;
          jd:=DataJD(rbi,mbi,dbi);
          RokMD(jd,rpm,mpm,dpm,pm);
          IF (dpm<>dbi) OR (mpm<>mbi) THEN
          IF dbi<>dpm THEN
           BEGIN
             RokMD(DataJD(rbi,mpm,1)-1,rpm,mpm,dpm,pm);
             dbi:=dpm
           END;
          NewDate(rbi,mbi,dbi)
        END;

   'y': BEGIN
          IF rbi<9900 THEN rbi:=rbi+1;
          IF rbi=0 THEN rbi:=1;
          IF (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) THEN dbi:=28;
          IF (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) THEN
            IF dbi<10 THEN dbi:=4 ELSE dbi:=15;
          NewDate(rbi,mbi,dbi)
        END;

   'Y': BEGIN
          IF rbi>-9900 THEN rbi:=rbi-1;
          IF rbi=0 THEN rbi:=-1;
          IF (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) THEN dbi:=28;
          IF (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) THEN
            IF dbi<10 THEN dbi:=4 ELSE dbi:=15;
          NewDate(rbi,mbi,dbi)
        END;

   'r': BEGIN
          IF rbi<9900-9 THEN rbi:=rbi+10;
          IF rbi=0 THEN rbi:=1;
          IF (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) THEN dbi:=28;
          IF (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) THEN
            IF dbi<10 THEN dbi:=4 ELSE dbi:=15;
          NewDate(rbi,mbi,dbi)
        END;

   'R': BEGIN
          IF rbi>-9900+9 THEN rbi:=rbi-10;
          IF rbi=0 THEN rbi:=-1;
          IF (rbi mod 4 <> 0) AND
             not((rbi>1582) AND ((rbi mod 100)=0) AND (((rbi div 100) mod 4)>0)) AND
             (mbi=2) AND (dbi=29) THEN dbi:=28;
          IF (rbi=1582) AND (mbi=10) AND (dbi>4) AND (dbi<15) THEN
            IF dbi<10 THEN dbi:=4 ELSE dbi:=15;
          NewDate(rbi,mbi,dbi)
        END;

   'j': NewJD(DataJD(rbi,mbi,dbi)+1);
   'J': NewJD(DataJD(rbi,mbi,dbi)-1);


   'h': BEGIN
          gobi:=(gobi+1) mod 24;
          NewTime(gobi,mibi,sebi);
        END;
   'H': BEGIN
          gobi:=gobi-1;
          WHILE gobi<0 DO gobi:=gobi+24;
          NewTime(gobi,mibi,sebi)
        END;
   '+': BEGIN
          mibi:=mibi+1;
          IF mibi=60 THEN
            BEGIN
              mibi:=0;
              gobi:=gobi+1;
              IF gobi=24 THEN
                BEGIN
                  gobi:=0;
                  NewJD(DataJD(rbi,mbi,dbi+1))
                END
            END;
          NewTime(gobi,mibi,sebi);
        END;
   '-': BEGIN
          mibi:=mibi-1;
          IF mibi=-1 THEN
            BEGIN
              mibi:=59;
              gobi:=gobi-1;
              IF gobi=-1 THEN
                BEGIN
                  gobi:=23;
                  NewJD(DataJD(rbi,mbi,dbi-1))
                END
            END;
          NewTime(gobi,mibi,sebi);
        END;
   's': BEGIN
          sebi:=sebi+1;
          IF sebi=60 THEN BEGIN sebi:=0;
          mibi:=mibi+1;
          IF mibi=60 THEN
            BEGIN
              mibi:=0;
              gobi:=gobi+1;
              IF gobi=24 THEN
                BEGIN
                  gobi:=0;
                  NewJD(DataJD(rbi,mbi,dbi+1))
                END
            END
            END;
          NewTime(gobi,mibi,sebi);
        END;
   'S': BEGIN
          sebi:=sebi-1;
          IF sebi=-1 THEN BEGIN sebi:=59;
          mibi:=mibi-1;
          IF mibi=-1 THEN
            BEGIN
              mibi:=59;
              gobi:=gobi-1;
              IF gobi=-1 THEN
                BEGIN
                  gobi:=23;
                  NewJD(DataJD(rbi,mbi,dbi-1))
                END
            END
            END;
          NewTime(gobi,mibi,sebi);
        END;

   'e','E': BEGIN
             ts1m:=tsmo; ts1c:=tsco; AInfo; tsmo:=ts1m; tsco:=ts1c
            END;

   'f','F': BEGIN
            jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
            jd:=jd+dTT(jd);
            IF c='f' THEN jd:=OblFAZE(jd,1) ELSE jd:=OblFAZE(jd,-1);
            OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
            NewDate(rbi,mbi,dbi);
            NewTime(gobi,mibi,sebi);
            GotoXY(65,16); Write(infs:10,'  ');
       END;


   'n': BEGIN NextPlace(1); nie_obliczono END;
   'N': BEGIN NextPlace(-1); nie_obliczono END;
   'a','A': BEGIN GotoXY(54,9); IF Refr=0 THEN
             BEGIN Refr:=1/3; Write('YES') END
             ELSE BEGIN Refr:=0; Write(' NO') END; nie_obliczono END;
   'z': BEGIN ChangeTimeZone( 1); nie_obliczono END;
   'Z': BEGIN ChangeTimeZone(-1); nie_obliczono END;

   '3','4': BEGIN  { 1992-08-31 }
          ch:=c;
          GotoXY(69,25); Write('PLEASE WAIT');
          LOOP1:
            jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
            jd:=jd+dTT(jd);
            IF ch='4' THEN jd:=OblZacmKs(jd,1) ELSE jd:=OblZacmKs(jd,-1);
            OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
            NewDate(rbi,mbi,dbi);
            NewTime(gobi,mibi,sebi);
            t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
            IF e_tot THEN IF Hd_g<1 THEN GoTo LOOP1;
            IF not(e_vis) THEN GoTo ENDLOOP1;
            OblJR;
            OblSLON;
            OblKSIE;
            IF wys<0 THEN GoTo LOOP1;
          ENDLOOP1:
          nie_obliczono;
          GotoXY(1,25); ClrEol; Write('Za†mienie ',infs,' Ksi©¾yca');
        END;
   '1','2': BEGIN
          ch:=c;
          GotoXY(69,25); Write('PLEASE WAIT');
          cpres:=' ';
          LOOP2:
            if KeyPressed then cpres:=ReadKey;
            if cpres=#27 then
              begin
                GotoXY(69,25); Write('INTERRUPTED');
                Sound(40); Delay(200); NoSound;
                GoTo ENDLOOP2
              end;
            jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
            jd:=jd+dTT(jd);
            IF ch='2' THEN jd:=OblZacmSl(jd,1) ELSE jd:=OblZacmSl(jd,-1);
            OblGodz(jd,rbi,mbi,dbi,gobi,mibi,sebi);
            NewDate(rbi,mbi,dbi);
            NewTime(gobi,mibi,sebi);
            t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
            IF e_tot AND not(e_loc)
               THEN IF e_status<2 THEN GoTo LOOP2; { mialo byc calkowite, a nie jest }
              { jesli e_tot, to obliczono zacm. calkowite }
            {IF not(e_vis) THEN GoTo ENDLOOP2;}
            OblJR;
            OblSLON;
            IF e_vis AND (wys<0) THEN GoTo LOOP2; { mialo byc widoczne, a nie jest }
            OblKSIE;
            Hd_g:=LoFaza(1);     { cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
            hm_g:=ArcCos(Hd_g);
            IF e_loc AND (hm_g>(LoDiam(0)+LoDiam(1))/2) THEN GoTo LOOP2;  { gdzies jest zacm. calkowite, ale nie tu }
            IF e_tot AND e_loc THEN
              if ArcCos(LoFaza(1)) + LoDiam(0) > LoDiam(1) then goto LOOP2;
              { was IF Hd_g>(LoDiam(1)-LoDiam(0))/2 THEN GoTo LOOP2;}

          ENDLOOP2:
          nie_obliczono;
          GotoXY(1,25); ClrEol; Write('Za†mienie ',infs,' Sˆoäca');
        END;
   '5': BEGIN e_vis:=not(e_vis); RysujRamki END;
   '6': BEGIN e_tot:=not(e_tot); RysujRamki END;
   '7': BEGIN e_loc:=not(e_loc); RysujRamki END;
   'w','W': BEGIN  { sunrise or sunset }
          ch:=c;
          GotoXY(69,25); Write('PLEASE WAIT');
          jd:=DataJD(rbi,mbi,dbi)+(gobi+mibi/60+sebi/3600-time_zone)/24;
          jd:=jd+dTT(jd);

          jd3:=0.5-dlu/(2*Pi);
          jd1:=int(jd)+jd3-2.0;
          WHILE jd1<jd DO jd1:=jd1+0.5; jd1:=jd1-0.5;
          jd2:=jd1+0.5;
          IF c='W' THEN BEGIN jd1:=jd1-0.5; jd2:=jd2-0.5 END;
          IF c='w' THEN BEGIN jd1:=jd1+0.5; jd2:=jd2+0.5 END;

          t1:=jd1-2451545.0+dTT(jd1);
          OblJR; OblSLON; w1:=wys;
          t1:=jd2-2451545.0+dTT(jd2);
          OblJR; OblSLON; w2:=wys;

          WHILE (Abs(jd1-jd2)>0.00001) AND (w1*w2<=0) DO
            BEGIN
              jd3:=(jd1+jd2)/2;
              t1:=jd3-2451545.0+dTT(jd3);
              OblJR; OblSLON; w3:=wys;
              IF w1*w3<0 THEN
                BEGIN jd2:=jd3; w2:=w3 END
              ELSE
                BEGIN jd1:=jd3; w1:=w3 END
            END;
            jd3:=(jd1+jd2)/2;
            OblGodz(jd3+dTT(jd3),rbi,mbi,dbi,gobi,mibi,sebi);
            NewDate(rbi,mbi,dbi);
            NewTime(gobi,mibi,sebi);
{            t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);}
            nie_obliczono;
            GotoXY(1,25); ClrEol;
        END;

    ^A: BEGIN
          ts1m:=tsmo; ts1c:=tsco;
          CLM;
          t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
          OblJR;
          p4:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
          Write('Podaj rektascensje: '); ReadLn(al); al:=al*s;
          Write('Podaj deklinacje  : '); ReadLn(de); de:=de*s;
          x4:=1000; x5:=sin(al)/cos(al);
          x6:=Sqrt(x4*x4+x5*x5)*sin(de)/cos(de);
          az:=-2*Pi*p4-dlu-jr[7]+Pi; p5:=sin(az); p6:=cos(az);
          x1:=x4*p6-x5*p5; x2:=x4*p5+x5*p6; x3:=x6; p5:=sin(-sze); p6:=cos(-sze);
          x4:=x1*p6-x3*p5; x6:=x1*p5+x3*p6; x5:=x2;
          x4:=x4-Paralaksa*4.259e-5;
          az:=Pi/2-Angle(x5,x6); wys:=Angle(Sqrt(x5*x5+x6*x6),x4);
          IF Refr<>0 THEN wys:=wys+RefOutIn(Pi/2-wys);
          WriteLn;
          WriteLn('Azymut   = ',az/s:15:5);
          WriteLn('Wysokosc = ',wys/s:15:5);
          REPEAT UNTIL KeyPressed;
          c:=ReadKey;
          tsmo:=ts1m; tsco:=ts1c
        END;


    ^]:  {};
  END { CASE }
 END { IF c IN .. }
 ELSE
   BEGIN
     mn:=Minelo(0)+90;
     IF (mn>100) AND not(obliczoneobiekty[0]) AND not(KeyPressed) THEN
       BEGIN
         t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
         ShowCursor;
         OblJR;
         OblSLON;
         GotoXY(3,15);
         Write('Sun');

         GotoXY(15,15);
         HideCursor;
         Write(Deg(al),de/s:10:2,az/s:10:2,wys/s:10:2,dr*149597870:10:0);
         obliczoneobiekty[0]:=TRUE;
       END;
     IF ((mn>100) AND not(obliczoneobiekty[1]) AND not(KeyPressed))
        OR (UpCase(c)='C') THEN
       BEGIN
         t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
         ShowCursor;
         OblKSIE;
         GotoXY(3,16);
         Write('Moon');

         GotoXY(15,16);
         HideCursor;
         pm:=Faza(1);
         Write(Deg(al),de/s:10:2,az/s:10:2,wys/s:10:2,dr*149597870:10:0,ArcCos(LoFaza(1))/s:10:3);
         IF Abs(pm)>0.999962 THEN Write(' E') ELSE Write('  ');
         obliczoneobiekty[1]:=TRUE;


         GotoXY(3,18); WriteLn('LoDiam(Slonce ) = ',LoDiam(0)/s:7:4,'ø');
         GotoXY(3,19); WriteLn('LoDiam(Ksiezyc) = ',LoDiam(1)/s:7:4,'ø');
         GotoXY(3,20);
         x1:=(LoDiam(1)+LoDiam(0))/2-ArcCos(LoFaza(1));
         IF x1>0 THEN  WriteLn('Za†mienie Sˆoäca: ',(x1/s):7:4,'ø')
                 ELSE  WriteLn('                                   ');

       END;


     Str(mn:10,wst);
     IF wst[9]=' ' THEN wst[9]:='0';
     IF wst[8]=' ' THEN wst[8]:='0';
     GotoXY(68,9);
     Write(Copy(wst,1,8),'.',Copy(wst,9,1));
     GotoXY(80,25)
   END;
   ShowCursor

 UNTIL c=#27;
 HideCursor;

END;

BEGIN
  Main1;
END.                         { 1991-01-18 }




