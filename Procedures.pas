unit Procedures;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

function DivInf(n,d: integer): integer;
procedure CalcAzH(al,de: real; out az,wys: real);
function LoDiam(obiekt:byte):real; { srednica katowa }
function dTT(jd:real):real; { UT-UTC }
function OblJR(t1: real): real;
function DataJD(r,m,d:real):real;
procedure RokMD(jd: real; var r,m,d:integer; var gr:real);
procedure OblGodz(jd:real;var rb,mb,db,g,m,s:integer);
function OblSLON(t,t1: real):real;
function OblKSIE(t,t1: real):real;
function Faza(obiekt:byte):real;
function LoFaza(obiekt:byte):real;
function OblFAZE(jd:real;dir:integer):real;  { Patrz Mlody Technik 12/1985, s.48 }
function OblZacmKs(jd:real;dir:integer; out Hd_g: real):real;  { Patrz Mlody Technik 8/1986, s.92 }
function OblZacmSl(jd:real;dir:integer):real;  { Patrz Mlody Technik 9/1986, s.80 }

const
  radInDeg:real=Pi/180;
var
  e_vis:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko widoczne zacmienia }
  e_tot:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko calkowite zacmienia }
  e_loc:BOOLEAN=FALSE;  { TRUE jesli liczyc tylko widoczne w wybranym miejscu calkowite zacmienia Slonca }
var
  e_status:integer;
  time_zone:integer=1;  { 1 dla CSE, 2 - czas letni }
  dlu,sze: real;
  jd,jDNIA: real;
  weekDay: integer;
  SunRectan,de,az: real;
  dr: real;
  Paralaksa: integer;
  Refr: real;
  infs: string[40];
  LunarEclKind: char;

implementation
uses
  Math;
type
  S3 = string[3];
  S9 = string[9];
  S10 = string[10];
  funrr = function(x:real):real;

var
  Coor,LoCoor: array [0..10,'w'..'z'] of real;
  jr:array[1..33] of real;

function DivInf(n,d: integer): integer;
var
  m: integer;
begin
  result:=n div d;
  if (n<0) or (d<0) then
  begin
    m:=n mod d;
    if m<>0 then
    begin
      if n<0 then
      begin
        if d>0 then dec(result)
        else inc(result);
      end;
    end;
  end;
end;

function RefOutIn(z:real):real;
const                   (* z zewnatrz do Ziemi *)
a:array[0..12] of real =
(6.17532024891163E-0007, 1.47508478517093E+0002,-1.50589412223534E+0001,
 5.96265061954045E-0001,-1.04467452128348E-0002, 3.75265200899070E-0005,
 1.20302337255595E-0006,-8.54011026535937E-0009,-1.77543620549324E-0010,
 2.28935309220368E-0012, 2.09672302916566E-0015,-1.43471082000615E-0016,
 5.71661985389035E-0019);
var i:integer;
    w:real;
begin
  z:=Abs(z*180/Pi);
  if z>90.7 then begin RefOutIn:=0; Exit end;
  if z<=45 then w:=(60.3/60)*sin(z*Pi/180)/cos(z*Pi/180) else
  begin
    w:=a[12];
    for i:=11 DOWNTO 0 do w:=z*w+a[i]
  end;
  RefOutIn:=w*(Pi/180/60)
end;

procedure CalcAzH(al,de: real; out az,wys: real);
var
  t,t1,x1,x2,x3,x4,x5,x6,p4,p5,p6: real;
begin
  t1:=jd+jDNIA-time_zone/24-2451545.0+dTT(jd);
  t:=OblJR(t1);
  p4:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
  al:=al*radInDeg;
  de:=de*radInDeg;
  x4:=1000; x5:=sin(al)/cos(al);
  x6:=Sqrt(x4*x4+x5*x5)*sin(de)/cos(de);
  az:=-2*Pi*p4-dlu-jr[7]+Pi; p5:=sin(az); p6:=cos(az);
  x1:=x4*p6-x5*p5;
  x2:=x4*p5+x5*p6;
  x3:=x6;
  p5:=sin(-sze);
  p6:=cos(-sze);
  x4:=x1*p6-x3*p5; x6:=x1*p5+x3*p6; x5:=x2;
  x4:=x4-Paralaksa*4.259e-5;
  az:=Pi/2-ArcTan2(x6,x5);
  wys:=ArcTan2(x4,Sqrt(x5*x5+x6*x6));
  if Refr<>0 then wys:=wys+RefOutIn(Pi/2-wys);
end;

function LoDiam(obiekt:byte):real; { srednica katowa }
begin
  case obiekt of
    0: { Slonce } LoDiam:=2*ArcSin(696000.0/LoCoor[0,'w']);
    1: { Ksiezyc } LoDiam:=2*ArcSin(1738.0/LoCoor[1,'w'])
    else LoDiam:=0
  end
end;

function dTT(jd:real):real; { UT-UTC }
const w:array[0..12] of real=
 (-0.000014,0.001148,0.003357,-0.012462,-0.022542,0.062971,0.079441,
  -0.146960,-0.149279,0.161416,0.145932,-0.067471,-0.058091);
var
  t,y,d,p:real; i:integer;
begin
 t:=(jd-2415019.0)/36524.22; { czas w stuleciach od roku 1900 }
 y:=1900+100*t;
 d:=0;
 if (y>=1800) and (y<=1987) then
 begin
  d:=0; p:=1;
  for i:=0 to 12 do begin d:=d+w[i]*p; p:=p*t end
 end;
 if (y>2010) or (y<1800) then d:=0.00084*t+0.000347*t*t;
 if (y>1987) and (y<=2010) then d:=(20.31*t*t+47.8415*t-1)/86400.0;
 if y<1800 then d:=d+56.6/86400;
 if y>2010 then d:=d-39.9/86400;
 result:=d
end;

function OblJR(t1: real): real;
var
  pom:real;
  ii: integer;
begin
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
  for ii:=1 to 33 do jr[ii]:=2*Pi*Frac(jr[ii]);
    result:=t1/36525.0+1;
end;

function DataJD(r,m,d:real):real;
var
  a,b,c,e:real;
begin
  if r<0 then r:=r+1;
  a:=4716+r+int((m+9)/12);
  b:=1729279.5+367*r+int(275*m/9)-int(7*a/4)+d;
  c:=int((a+83)/100);
  e:=int(3*(c+1)/4);
  a:=b+38-e;
  if a<2299160.5 then a:=b;
  DataJD:=a;
  weekDay:=round(a+1.1-7*int((a+1.1)/7));
  while weekDay<0 do weekDay:=weekDay+7
end;

procedure RokMD(jd: real; var r,m,d:integer; var gr:real);
var w,x,u,z,y,a,b,c,e,f:real;
begin
 gr:=jd-Floor(jd-0.5)-0.5;
 w:=int(jd+0.5)+0.5; x:=int(w); u:=w-x;
 y:=int((x+32044.5)/36524.25); z:=x+y-int(y/4)-38;
 if jd<2299160.5 then z:=x;
 a:=z+1524; b:=int((a-122.1)/365.25); c:=a-365*b-int(b/4);
 e:=int(c/30.61);
 f:=int(e/14);
 r:=round(b-4716+f); m:=round(e-1-12*f); d:=trunc(c+u-int(153*e/5)-0.5);
 if r<=0 then r:=pred(r);
 weekDay:=round(jd+1.1-7*int((jd+1.1)/7));
 while weekDay<0 do weekDay:=weekDay+7
end;

procedure OblGodz(jd:real;var rb,mb,db,g,m,s:integer);
var gr:real;
begin
 RokMD(jd+time_zone/24-dTT(jd),rb,mb,db,gr);
 gr:=24*(gr-int(gr));
 g:=trunc(gr); gr:=60*(gr-g);
 m:=trunc(gr); gr:=60*(gr-m);
 s:=trunc(gr);
end;

function OblSLON(t,t1: real): real;
const tab2:array[1..12]of S9 =
('@s@@@A@@@','@s@@@B@@@','As@@@A@@@','@c@@@A@@?','@sA@?@@@@','@s@@@D@8C',
 '@c@@@B>@@','@s@@@A?@@','@c@@@D@8C','@s@@@B>@@','@s@@@@@@A','@s@@@B@@>');
const tab2i:array[1..12]of integer=(6910,72,-17,-7,6,5,-5,-4,4,3,-3,-3);
const tb:array[3..9]of byte=(1,5,7,8,13,16,19);
var
  i,j:integer;
  p,w,godz,si,co:real;
  c:AnsiCHAR;
  ss:S9;
  x1,x2,x3,x4,x5,x6: real;
  db,epr,dl,lr,dbr: real;
  t2,ep,xob,yob,zob: real;
begin
  dl:=0; godz:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
   {Write('SP OblSLON: t1=',t1:6:8,#13);   WatchSP(t1);}
  for i:=1 to 12 do
  begin
    ss:=tab2[i];
    p:=tab2i[i]; w:=0;
    if ss[1]>'@' then for c:='A' to ss[1] do p:=p*t;
    for j:=3 to 9 do
    begin
      if ss[j]<>'@' then w:=w+(ord(ss[j])-64)*jr[tb[j]];
    end;
    if ss[2]='s' then w:=p*sin(w) else w:=p*cos(w);
    dl:=dl+w
  end;                                                        { ??? V ??? }
  db:=0;
  dr:=1.00014-0.01675*cos(jr[tb[6]])+0.00014*cos(2*jr[tb[6]])  -0.000328851;
  t2:=(t1+36525.0)/36525.0;
  ep:=23.452294-0.0130125*t2-1.64e-6*t2*t2+5.03e-7*t2*t2*t2;
  lr:=(dl/3600)*radInDeg+jr[7]-17*sin(jr[5])/3600*radInDeg;
  dbr:=(db/3600)*radInDeg;
  epr:=ep*radInDeg; co:=cos(dbr);
  x1:=dr*co*cos(lr);
  x2:=dr*co*sin(lr);
  x3:=dr*sin(dbr);
  x4:=x1; co:=cos(epr); si:=sin(epr);
  x5:=x2*co-x3*si;
  x6:=x2*si+x3*co;
  xob:=x4; yob:=x5; zob:=x6;
  Coor[0,'x']:=xob; Coor[0,'y']:=yob; Coor[0,'z']:=zob;
     { obliczenie wsp. biegunowych }
  SunRectan:=ArcTan2(x5,x4);
  de:=ArcTan2(x6, Sqrt(x4*x4+x5*x5));
     { obliczenie wsp. horyzontalnych }
  az:=-2*Pi*godz-dlu-jr[7]+Pi; si:=sin(az); co:=cos(az);
  x1:=x4*co-x5*si; x2:=x4*si+x5*co; x3:=x6; si:=sin(-sze); co:=cos(-sze);
  x4:=x1*co-x3*si; x6:=x1*si+x3*co; x5:=x2;
  x4:=x4-Paralaksa*4.259e-5;
  LoCoor[0,'x']:=x4; LoCoor[0,'y']:=x5; LoCoor[0,'z']:=x6;
  LoCoor[0,'w']:=Sqrt(x4*x4+x5*x5+x6*x6)*149597870.0;
  az:=Pi/2-ArcTan2(x6, x5);
  result:=ArcTan2(x4, Sqrt(x5*x5+x6*x6));
  if Refr<>0 then result:=result+RefOutIn(Pi/2-result);
end;

function OblKSIE(t,t1: real): real;
const skl:real=4.26352e-5;
const tab3:array[1..123] of S9=
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
const tab3i:array[1..93] of integer=
(22640,-4586,2370,769,-668,-412,-212,-206,192,165,148,-125,-110,-55,-45,
40,-38,36,-31,28,-24,19,18,15,14,14,-13,-11,10,9,9,-9,-8,8,-8,-7,-7,7,
-6,-6,-4,4,-4,4,3,-3,-3,3,3,-2,-2,2,2,2,2,18461,1010,1000,-624,-199,
-167,117,62,33,32,-30,-16,15,12,-9,-8,8,-7,7,-7,-6,-6,6,-5,-5,-5,5,5,
4,-4,-3,3,-2,-2,2,2,2,2);
const tab3r:array[94..123] of real=
(60.36298,-3.27746,-0.57994,-0.46357,-0.08904,0.03865,-0.03237,-0.02688,
-0.02358,-0.02030,0.01719,0.01671,0.01247,0.00704,0.00529,0.00524,0.00398,
-0.00366,-0.00295,-0.00263,0.00249,-0.00221,0.00185,-0.00161,0.00147,
-0.00142,0.00139,-0.00118,-0.00116,-0.001100);
const tb:array[3..9] of byte=(2,3,4,5,7,8,12);
var i,j:integer; p,w,godz,si,co:real; c:AnsiCHAR; ss:S9;
    x1,x2,x3,x4,x5,x6: real;
    db,epr,dl,lr,dbr: real;
    t2,ep,xob,yob,zob: real;
begin
  dl:=0; db:=0; dr:=0; godz:=t1-int(t1+0.5)+0.5-dTT(t1+2451545.0);
  for i:=1 to 55 do
  begin
    ss:=tab3[i];
    p:=tab3i[i]; w:=0;
    if ss[1]>'@' then for c:='A' to ss[1] do p:=p*t;
    for j:=3 to 9 do w:=w+(ord(ss[j])-64)*jr[tb[j]];
    if ss[2]='s' then w:=p*sin(w) else w:=p*cos(w);
    dl:=dl+w
  end;
  for i:=56 to 93 do
  begin
    ss:=tab3[i];
    p:=tab3i[i]; w:=0;
    if ss[1]>'@' then for c:='A' to ss[1] do p:=p*t;
    for j:=3 to 9 do w:=w+(ord(ss[j])-64)*jr[tb[j]];
    if ss[2]='s' then w:=p*sin(w) else w:=p*cos(w);
    db:=db+w
  end;
  for i:=94 to 123 do
  begin
    ss:=tab3[i];
    p:=tab3r[i]; w:=0;
    if ss[1]>'@' then for c:='A' to ss[1] do p:=p*t;
    for j:=3 to 9 do w:=w+(ord(ss[j])-64)*jr[tb[j]];
    if ss[2]='s' then w:=p*sin(w) else w:=p*cos(w);
    dr:=dr+w
  end;

  t2:=(t1+36525.0)/36525.0;
  ep:=23.452294-0.0130125*t2-1.64e-6*t2*t2+5.03e-7*t2*t2*t2;
  lr:=(dl/3600)*radInDeg+jr[1]-17*sin(jr[5])/3600*radInDeg;
  dbr:=(db/3600)*radInDeg;
  epr:=ep*radInDeg; co:=cos(dbr);
  x1:=dr*co*cos(lr);
  x2:=dr*co*sin(lr);
  x3:=dr*sin(dbr);
  x4:=x1; co:=cos(epr); si:=sin(epr);
  x5:=x2*co-x3*si;
  x6:=x2*si+x3*co;
  dr:=dr*skl; x4:=x4*skl; x5:=x5*skl; x6:=x6*skl;
  xob:=x4; yob:=x5; zob:=x6;
  Coor[1,'x']:=xob; Coor[1,'y']:=yob; Coor[1,'z']:=zob;
  (* obliczenie wsp. biegunowych *)
  SunRectan:=ArcTan2(x5,x4);
  de:=ArcTan2(x6,Sqrt(x4*x4+x5*x5));
     (* obliczenie wsp. horyzontalnych *)
  az:=-2*Pi*godz-dlu-jr[7]+Pi; si:=sin(az); co:=cos(az);
  x1:=x4*co-x5*si; x2:=x4*si+x5*co; x3:=x6; si:=sin(-sze); co:=cos(-sze);
  x4:=x1*co-x3*si; x6:=x1*si+x3*co; x5:=x2;
  x4:=x4-Paralaksa*4.259e-5;
  LoCoor[1,'x']:=x4; LoCoor[1,'y']:=x5; LoCoor[1,'z']:=x6;
  LoCoor[1,'w']:=Sqrt(x4*x4+x5*x5+x6*x6)*149597870;
  az:=Pi/2-ArcTan2(x6,x5);
  result:=ArcTan2(x4,Sqrt(x5*x5+x6*x6));
  if Refr<>0 then result:=result+RefOutIn(Pi/2-result);
end;

function Faza(obiekt:byte):real;
begin
  Faza:=
  (Coor[0,'x']*Coor[obiekt,'x']+Coor[0,'y']*Coor[obiekt,'y']+
  Coor[0,'z']*Coor[obiekt,'z'])/
  (Sqrt(Coor[0,'x']*Coor[0,'x']+
   Coor[0,'y']*Coor[0,'y']+
   Coor[0,'z']*Coor[0,'z'])*
   Sqrt(Coor[obiekt,'x']*Coor[obiekt,'x']+
   Coor[obiekt,'y']*Coor[obiekt,'y']+
   Coor[obiekt,'z']*Coor[obiekt,'z']))
end;

function LoFaza(obiekt:byte):real;
begin
  LoFaza:=
  (LoCoor[0,'x']*LoCoor[obiekt,'x']+LoCoor[0,'y']*LoCoor[obiekt,'y']+
  LoCoor[0,'z']*LoCoor[obiekt,'z'])/
  (Sqrt(LoCoor[0,'x']*LoCoor[0,'x']+
   LoCoor[0,'y']*LoCoor[0,'y']+
   LoCoor[0,'z']*LoCoor[0,'z'])*
   Sqrt(LoCoor[obiekt,'x']*LoCoor[obiekt,'x']+
   LoCoor[obiekt,'y']*LoCoor[obiekt,'y']+
   LoCoor[obiekt,'z']*LoCoor[obiekt,'z']))
end;

function OblFAZE(jd:real;dir:integer):real;  { Patrz Mlody Technik 12/1985, s.48 }
var
  k,t,tr,M,M1,F,jd1:real;
  i,dk:integer;
begin
  jd1:=jd;
  i:=0;
  repeat
      k:=12.3685*(jd-2415020.75933)/365.2422;
      k:=int(4*k+dir)/4;
      if i>0 then k:=k+dir*0.2;
      dk:=round(4*(k-int(k)));
      while dk<0 do dk:=dk+4;
      {k:=Int(k-dk/4)+dk/4;}
      t:=k/1236.85;
      jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
      tr:=radInDeg*(166.56+132.87*t-0.009173*t*t);
      jd:=jd+0.00033*sin(tr);
      M :=radInDeg*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
      M1:=radInDeg*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
      F :=radInDeg*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
      if (dk=0) OR (dk=2) then
      jd:=jd+(0.1734-0.000393*t)*sin(M)+0.0021*sin(2*M)-0.4068*sin(M1)+
          0.0161*sin(2*M1)-0.0004*sin(3*M1)+0.0104*sin(2*F)-
          0.0051*sin(M+M1)-0.0074*sin(M-M1)+0.0004*sin(2*F+M)-
          0.0004*sin(2*F-M)-0.0006*sin(2*F+M1)+0.001*sin(2*F-M1)+0.0005*sin(M+2*M1)
      else
      jd:=jd+(0.1721-0.0004*t)*sin(M)+0.0021*sin(2*M)-0.628*sin(M1)+
          0.0089*sin(2*M1)-0.0004*sin(3*M1)+0.0079*sin(2*F)-0.0119*sin(M+M1)-
          0.0047*sin(M-M1)+0.0003*sin(2*F+M)-0.0004*sin(2*F-M)-
          0.0006*sin(2*F+M1)+0.0021*sin(2*F-M1)+0.0003*sin(M+2*M1)+
          0.0004*sin(M-2*M1)-0.0003*sin(2*M+M1);
      if dk=1 then jd:=jd+0.0028-0.0004*cos(M)+0.0003*cos(M1);
      if dk=3 then jd:=jd+0.0004*cos(M)-0.0003*cos(M1);
      jd:=jd-dTT(jd);
      i:=i+1;
  until Abs(jd-jd1)>1e-4;
  case dk of
    0: infs:='now';
    1: infs:='I kwadra';
    2: infs:='pelnia';
    3: infs:='ost.kw.'
  end;
  OblFAZE:=jd;
end;


procedure minimum(a,b,d:real; var x:real; f:funrr);  { zloty podzial }
          { a,b - przedzial, d - dokladnosc, x - wartosc x, f - funkcja }
var gkl,gkp,gk1l,gk1p,
    akl,akp,ak1l,ak1p,
    qakl,qakp,qak1l,qak1p:real;
const zp=1.6180339887498948482045868343656381177203091798057;
begin
  if (a>=b) then begin x:=a; Exit end;
  if d<=0 then Exit;
  gkl:=a; gkp:=b;
  akl:=gkp-(gkp-gkl)/zp;   akp:=gkl+(gkp-gkl)/zp;
  qakl:=f(akl); qakp:=f(akp);
  while gkp-gkl>d do
  begin
    if qakl>qakp then { minimum w prawym przedziale }
      begin
        gk1l:=akl;
        gk1p:=gkp;
        ak1l:=akp;
        ak1p:=gk1l+(gk1p-gk1l)/zp;
        qak1l:=qakp;
        qak1p:=f(ak1p)
      end
    else              { minimum w lewym przedziale }
      begin
        gk1l:=gkl;
        gk1p:=akp;
        ak1p:=akl;
        ak1l:=gk1p-(gk1p-gk1l)/zp;
        qak1l:=f(ak1l);
        qak1p:=qakl
      end;
    gkl:=gk1l; gkp:=gk1p;
    akl:=ak1l; akp:=ak1p;
    qakl:=qak1l; qakp:=qak1p
  end;
  x:=gkl+(gkp-gkl)/2
end;

function MoonAng(jd:real):real;
var
  t,t1: real;
begin
  t1:=jd-2451545.0+dTT(jd);
  t:=OblJR(t1);
  OblSLON(t, t1);
  OblKSIE(t, t1);
  MoonAng:=Faza(1);    { cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
end;

function OblZacmKs(jd:real;dir:integer; out Hd_g: real):real;  { Patrz Mlody Technik 8/1986, s.92 }
label LOOP, ENDLOOP;
var
  cc,k,k1,kp,gamma,Hd,hm,u,t,tr,M,M1,F,ss,jd1:real;
begin
  jd1:=jd;
  k:=12.3685*(jd-2415020.75933)/365.2422; kp:=k;
  k1:=int(k+0.5)+2.5;
  if dir=1 then
    begin while k1>=k do k1:=k1-1.0; k1:=k1+1.0 end;
  if dir=-1 then
    begin k1:=k1-5.0; while k1<=k do k1:=k1+1.0; k1:=k1-1.0 end;
  k:=k1-dir;

{  while Abs(kp-k)>1.1 do k:=k+Sgn(kp-k); }
  if Abs(kp-k-dir)<0.05 then k:=k+dir;
  LOOP:
    k:=k+dir;
    t:=k/1236.85;
    F:=radInDeg*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
    if Abs(sin(F))>0.35837 then GoTo LOOP;
    M :=radInDeg*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
    M:=M-2*Pi*int(M/(2*Pi));
    M1:=radInDeg*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
    M1:=M1-2*Pi*int(M1/(2*Pi));
    ss:=5.19595-0.0048*cos(M)+0.002*cos(2*M)-0.3283*cos(M1)-0.006*cos(M+M1)+
        0.0041*cos(M-M1);
    cc:=0.207*sin(M)+0.0024*sin(2*M)-0.039*sin(M1)+0.0115*sin(2*M1)-
        0.0073*sin(M+M1)-0.0067*sin(M-M1)+0.0117*sin(2*F);
    u:=0.0059+0.0046*cos(M)-0.0182*cos(M1)+0.0004*cos(2*M1)-0.0005*cos(M+M1);
    gamma:=ss*sin(F)+cc*cos(F);
    Hd:=(1.0129-u-Abs(gamma))/0.545;  { maksymalna faza zacmienia dla cienia }
    hm:=(1.5572+u-Abs(gamma))/0.545;  { ...i dla polcienia }
    if hm<=0 then GoTo LOOP;
    Hd_g:=Hd;
    if Hd<0 then begin infs:='polcieniowe';LunarEclKind:='N'; end
    else if Hd<1 then begin infs:='cieniowe czesciowe'; LunarEclKind:='P'; end
    else begin infs:='calkowite';LunarEclKind:='T'; end;
    jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
    tr:=radInDeg*(166.56+132.87*t-0.009173*t*t);
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
    { 1993-05-21 }    if e_loc then minimum(jd-0.3,jd+0.3,0.00005,jd,MoonAng);
    jd:=jd+dTT(jd); { was -dTT... why? }
    if Abs(jd-jd1)<0.01 then GoTo LOOP;
  ENDLOOP:
  OblZacmKs:=jd;
end;

function SunAng(jd:real):real;
var
  t,t1:real;
begin
  t1:=jd-2451545.0+dTT(jd);
  t:=OblJR(t1);
  OblSLON(t, t1);
  OblKSIE(t, t1);
  SunAng:=-LoFaza(1);     { - cosinus kata miedzy Sloncem a Ksiezycem (z miejsca obserwacji) }
end;


function OblZacmSl(jd:real;dir:integer):real;  { Patrz Mlody Technik 9/1986, s.80 }
label LOOP, ENDLOOP;
var
  cc,k,k1,kp,gamma,u,t,tr,M,M1,F,ss,jd1: real;
begin
  jd1:=jd;
  k:=12.3685*(jd-2415020.75933)/365.2422; kp:=k;
  k1:=int(k);
  if dir=1 then
    begin while k1>=k do k1:=k1-1.0; k1:=k1+1.0 end;
  if dir=-1 then
    begin k1:=k1-5.0; while k1<=k do k1:=k1+1.0; k1:=k1-1.0 end;
  k:=k1-dir;
  if Abs(kp-k-dir)<0.05 then k:=k+dir;
  LOOP:
    k:=k+dir;
    t:=k/1236.85;
    F:=radInDeg*(21.2964+390.67050646*k-0.0016528*t*t-0.00000239*t*t*t);
    if Abs(sin(F))>0.35837 then GoTo LOOP;
    M :=radInDeg*(359.2242+29.10535608*k-0.0000333*t*t-0.00000347*t*t*t);
    M:=M-2*Pi*int(M/(2*Pi));
    M1:=radInDeg*(306.0253+385.81691806*k+0.0107306*t*t+0.00001236*t*t*t);
    M1:=M1-2*Pi*int(M1/(2*Pi));
    ss:=5.19595-0.0048*cos(M)+0.002*cos(2*M)-0.3283*cos(M1)-0.006*cos(M+M1)+
        0.0041*cos(M-M1);
    cc:=0.207*sin(M)+0.0024*sin(2*M)-0.039*sin(M1)+0.0115*sin(2*M1)-
        0.0073*sin(M+M1)-0.0067*sin(M-M1)+0.0117*sin(2*F);
    u:=0.0059+0.0046*cos(M)-0.0182*cos(M1)+0.0004*cos(2*M1)-0.0005*cos(M+M1);
    gamma:=ss*sin(F)+cc*cos(F);
    if Abs(gamma)>1.5432 then GoTo LOOP;
    if (0.9972+Abs(u)<Abs(gamma)) AND (Abs(gamma)<1.5432+u) then
      e_status:=1  { niecentralne czesciowe }
    else if (0.9972<Abs(gamma)) AND (Abs(gamma)<0.9972+Abs(u)) then
      e_status:=2  { niecentralne calkowite lub niecentralne obraczkowe }
    else if Abs(gamma)<0.9972 then
      if u<0 then e_status:=3  { centralne calkowite }
    else if u>0.00464*Sqrt(1-gamma*gamma) then
      e_status:=4   { centralne obraczkowe }
    else e_status:=5 { centralne obraczkowo-calkowite };

    case e_status of
     1: infs:='niecentralne czesciowe';
     2: infs:='niecentralne calkowite lub obraczkowe';
     3: infs:='centralne calkowite';
     4: infs:='centralne obraczkowe';
     5: infs:='centralne obraczkowo-calkowite'
    end;
    jd:=2415020.75933+29.53058868*k+0.0001178*t*t-0.000000155*t*t*t;
    tr:=radInDeg*(166.56+132.87*t-0.009173*t*t);
    jd:=jd+0.00033*sin(tr);
    jd:=jd+(0.1734-0.000393*t)*sin(M)+
        0.0021*sin(2*M)-0.4068*sin(M1)+
        0.0161*sin(2*M1)-0.0051*sin(M+M1)-0.0074*sin(M-M1)-0.0104*sin(2*F);
    { 1993-05-21 }    if e_loc then
                          minimum(jd-0.2,jd+0.2,0.00005,jd,SunAng);
    //Delay(1);
    jd:=jd+dTT(jd); { was -dTT... why? }
    if Abs(jd-jd1)<0.01 then GoTo LOOP;
  ENDLOOP:
  OblZacmSl:=jd;
end;

function ss(q,x:real):integer;
var x1,x2:real;
begin
  if x>Pi then begin x1:=x-Pi; x2:=x end
          else begin x1:=x; x2:=x+Pi end;
  ss:=1;
  if (q=x1) OR (q=x2) then ss:=0
  else if (q<x1) OR (q>x2) then ss:=-1
end;

end.

//Not used:
function vw: integer;
var q:real;
begin
  q:=az; if q<0 then q:=q+2*Pi;
  case ch1 of
  'H': vw:=Sgn(wys+Refr);
  'W': vw:=ss(q,6*Pi/4);
  'E': vw:=ss(q,Pi/2);
  'S': vw:=ss(q,Pi);
  'N': vw:=ss(q,0);
  'A': vw:=ss(q,kierunek)
  end
end;

procedure OblWSCH(tb:real);
var g,t11,t12:real; s,s1,s2:integer; v:BOOLEAN;
begin
  t11:=tb; t12:=tb+0.5; { t11:polnoc, t12:poludnie }
  t1:=t11; t:=OblJR; OblOBIEKT; s1:=vw(); { vw to funkcja! }
  t1:=t12; t:=OblJR; OblOBIEKT; s2:=vw();
  v := s1=s2; if v then WriteLn('Cos tu sie nie zgadza...');
  if not(v) then
  repeat
    tb:=t11+(t12-t11)/2; t1:=tb; OblJR; OblOBIEKT;
    s:=vw();
    if s=s2 then  begin t12:=tb; s2:=s end
            else  begin t11:=tb; s1:=s end;
  until Abs(t12-t11)<1e-5;
  ttt:=t11+(t12-t11)/2;
end;
