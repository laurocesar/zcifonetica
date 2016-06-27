{
  TBUDF - Tecnobyte UDF for InterBase and FireBird

  Author...: Daniel Pereira Guimarães
  E-mail...: tecnobyte@ulbrajp.com.br
  Home-Page: www.ulbrajp.com.br/~tecnobyte

  This library is Open-Source!
}

unit ibutil;

interface

uses
  sysutils, consts;

type
  TIBDate = integer;
  TIBTime = Cardinal;
  TIBTimeStamp = packed record
    Date: TIBDate;
    Time: TIBTime;
  end;

  PIBDate = ^TIBDate;
  PIBTime = ^TIBTime;
  PIBTimeStamp = ^TIBTimeStamp;

procedure IBDecodeTime(IBTime: TIBTime; var Hour, Min, Sec: SmallInt);
function IBEncodeTime(Hour, Min, Sec: SmallInt): TIBTime;
procedure IBDecodeDate(IBDate: TIBDate; var Year, Month, Day: SmallInt);
function IBEncodeDate(Year, Month, Day: SmallInt): TIBDate;
function IBTimeSpan(T1, T2: TIBTimeStamp): int64;
function IBTimeAsSec(IBTime: TIBTime): integer;

implementation

procedure IBDecodeTime(IBTime: TIBTime; var Hour, Min, Sec: SmallInt);
  { In InterBase: 1 second = 10000 }
var
  TotalSeconds: Cardinal;
begin
  TotalSeconds := IBTime div ISC_TIME_SECONDS_PRECISION;

  Hour := TotalSeconds div SECONDS_PER_HOUR;
  Min := (TotalSeconds div SECONDS_PER_MINUTE) mod SECONDS_PER_MINUTE;
  Sec := TotalSeconds mod SECONDS_PER_MINUTE;
end;

function IBEncodeTime(Hour, Min, Sec: SmallInt): TIBTime;
begin
  Result := (Hour * SECONDS_PER_HOUR + Min * SECONDS_PER_MINUTE + Sec)
    * ISC_TIME_SECONDS_PRECISION;
end;

procedure IBDecodeDate(IBDate: TIBDate; var Year, Month, Day: SmallInt);
  { The IBDecodeDate procedure is based in ndate() function of 
    gds.cpp (FireBird API) }
var
  Century, Y, M, D: integer;
begin
  IBDate := IBDate - (1721119 - 2400001);
  Century := (4 * IBDate - 1) div 146097;
  IBDate := 4 * IBDate - 1 - 146097 * Century;
  D := IBDate div 4;
  IBDate := (4 * D + 3) div 1461;
  D := 4 * D + 3 - 1461 * IBDate;
  D := (D + 4) div 4;
  M := (5 * D - 3) div 153;
  D := 5 * D - 3 - 153 * M;
  D := (D + 5) div 5;
  Y := 100 * Century + IBDate;

  if M < 10 then
    M := M + 3
  else begin
    M := M - 9;
    Y := Y + 1;
  end;

  Year := Y;
  Month := M;
  Day := D;
end;

function IBEncodeDate(Year, Month, Day: SmallInt): TIBDate;
  { The IBEncodeDate function is based in nday() function of
    gds.cpp (FireBird API) }
var
  Century, ShortYear: integer;
begin
  if Month > 2 then
    Month := Month - 3
  else begin
    Month := Month + 9;
    Year := Year - 1;
  end;

  Century := Year div 100;
  ShortYear := Year - 100 * Century;

  Result :=
    (146097 * Century) div 4 +
    (1461 * ShortYear) div 4 +
    (153 * Month + 2) div 5 + Day + 1721119 - 2400001;
end;

function IBTimeSpan(T1, T2: TIBTimeStamp): int64;
var
  Days, Seconds: integer;
begin
  if T1.Date < T2.Date then begin
    Days := T2.Date - T1.Date - 1;
    Seconds := SECONDS_PER_DAY - IBTimeAsSec(T1.Time) + IBTimeAsSec(T2.Time);
  end else if T1.Date > T2.Date then begin
    Days := T1.Date - T2.Date - 1;
    Seconds := SECONDS_PER_DAY - IBTimeAsSec(T1.Time) + IBTimeAsSec(T1.Time);
  end else begin { T1.Date = T2.Date }
    Days := 0;
    if T1.Time < T2.Time then
      Seconds := IBTimeAsSec(T2.Time) - IBTimeAsSec(T1.Time)
    else
      Seconds := IBTimeAsSec(T1.Time) - IBTimeAsSec(T2.Time);
  end;
  Result := int64(Days) * SECONDS_PER_DAY + int64(Seconds);
end;

function IBTimeAsSec(IBTime: TIBTime): integer;
begin
  Result := IBTime div ISC_TIME_SECONDS_PRECISION;
end;

end.
