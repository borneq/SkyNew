program au;

uses
  Classes, SysUtils;

procedure Info;
begin
  writeln('program convert project between Ansi and UTF8');
  writeln('convert *.dpr, *.pas and *.dfm in current directory');
  writeln('usage: au paramneter');
  writeln('ansi convert to Ansi');
  writeln('utf8 convert to UTF8');
end;

//from SynEdit
type
  TSaveFormat = (sfUTF16LSB, sfUTF16MSB, sfUTF8, sfUTF8NoBOM, sfAnsi);

const
  UTF8BOM: array[0..2] of Byte = ($EF, $BB, $BF);
  UTF16BOMLE: array[0..1] of Byte = ($FF, $FE);
  UTF16BOMBE: array[0..1] of Byte = ($FE, $FF);
  UTF32BOMLE: array[0..3] of Byte = ($FF, $FE, $00, $00);
  UTF32BOMBE: array[0..3] of Byte = ($00, $00, $FE, $FF);

function DetectBOM(Stream: TStream): TSaveFormat;
var
  ByteOrderMask: array[0..3] of Byte;
  BytesRead: Integer;
begin
  Stream.Position:=0;
  BytesRead := Stream.Read(ByteOrderMask[0], SizeOf(ByteOrderMask));
  if (BytesRead >= 2) and (ByteOrderMask[0] = UTF16BOMLE[0])
  and (ByteOrderMask[1] = UTF16BOMLE[1]) then
    result:=sfUTF16LSB
  else
  if (BytesRead >= 2) and (ByteOrderMask[0] = UTF16BOMBE[0])
  and (ByteOrderMask[1] = UTF16BOMBE[1]) then
    result:=sfUTF16MSB
  else
  if (BytesRead >= 3) and (ByteOrderMask[0] = UTF8BOM[0])
  and (ByteOrderMask[1] = UTF8BOM[1]) and (ByteOrderMask[2] = UTF8BOM[2]) then
    result:=sfUTF8
  else result:=sfAnsi;
end;

procedure ConvertAnsiToUTF8(Filename:string);
var
  SA: AnsiString;
  SW: UnicodeString;
  Stream: TFileStream;
  Size: integer;
begin
  Stream := TFileStream.Create(Filename, fmOpenRead);
  Size := Stream.Size - Stream.Position;
  SetLength(SA, Size div SizeOf(AnsiChar));
  Stream.Read(SA[1], Size);
  Stream.Free;
  SW := SA;
  SA := UTF8Encode(SW);
  Stream:=TFileStream.Create(Filename, fmCreate);
  Stream.WriteBuffer(UTF8BOM[0], SizeOf(UTF8BOM));
  Stream.WriteBuffer(SA[1], Length(SA) * SizeOf(AnsiChar));
  Stream.Free;
  writeln(Filename,' - converted Ansi -> UTF8 with BOM');
end;

procedure ConvertUTF8ToAnsi(Filename:string);
var
  SA: AnsiString;
  SW: UnicodeString;
  Stream: TFileStream;
  Size: integer;
  Len: integer;
begin
  Stream := TFileStream.Create(Filename, fmOpenRead);
  Stream.Position := SizeOf(UTF8BOM);
  Size := Stream.Size - Stream.Position;
  SetLength(SA, Size div SizeOf(AnsiChar));
  Stream.Read(SA[1], Size);
  Stream.Free;
  SW := UTF8Decode(SA);
  SA := SW;
  Stream:=TFileStream.Create(Filename, fmCreate);
  Len := Length(SA);
  Stream.WriteBuffer(SA[1], Len * SizeOf(AnsiChar));
  Stream.Free;
  writeln(Filename,' - converted UTF8 with BOM -> Ansi');
end;

procedure ProcessFile(Filename:string; toUTF8:boolean);
var
  Stream: TFileStream;
  Bom: TSaveFormat;
begin
  Stream:=TFileStream.Create(Filename, fmOpenRead);
  Bom:=DetectBOM(Stream);
  Stream.Free;
  if (Bom<>sfUTF8)and(Bom<>sfAnsi) then
    writeln(Filename,' detect 16 bit Unicode BOM, no changes')
  else
  begin
     if (Bom=sfUTF8)and toUTF8 then
       writeln(Filename,' already has UTF8 BOM')
     else if (Bom=sfAnsi)and not toUTF8 then
       writeln(Filename,' has no UTF8 BOM')
     else if toUTF8 then
        ConvertAnsiToUTF8(Filename)
     else
        ConvertUTF8ToAnsi(Filename);
  end;
end;

procedure ScanDir(toUTF8: boolean);
var
  SearchResult : TSearchRec;
  extstr: string;
  strings: TStringList;
  i: integer;
begin
  strings:=TStringList.Create;
  if FindFirst('*', faAnyFile, SearchResult) = 0 then
  begin
    repeat
      extstr := LowerCase(ExtractFileExt(SearchResult.Name));
      if (extstr='.dpr')or(extstr='.pas')or(extstr='.dfm') then
      strings.Add(SearchResult.Name);
    until FindNext(SearchResult) <> 0;
    FindClose(searchResult);
  end;
  for i:=0 to strings.Count-1 do
    ProcessFile(strings[i], toUTF8);
  strings.Free;
end;

begin
  if (ParamCount=1)and((ParamStr(1)='ansi') or (ParamStr(1)='utf8'))
  then
    ScanDir(ParamStr(1)='utf8')
  else
    Info;
end.

