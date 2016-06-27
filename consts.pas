{
  TBUDF - Tecnobyte UDF for InterBase and FireBird

  Author...: Daniel Pereira Guimarães
  E-mail...: tecnobyte@ulbrajp.com.br
  Home-Page: www.ulbrajp.com.br/~tecnobyte

  This library is Open-Source!
}

unit consts;

interface

const
  MONTH_DAYS: array[1..12] of byte = (31,28,31,30,31,30,31,31,30,31,30,31);

  SECONDS_PER_MINUTE = 60;
  SECONDS_PER_HOUR = 3600;
  SECONDS_PER_DAY = 86400;

  DAYS_PER_WEEK = 7;
  MONTHS_PER_YEAR = 12;

  APPROX_DAYS_PER_MONTH = 30.4375;
  APPROX_DAYS_PER_YEAR = 365.25;

  ISC_TIME_SECONDS_PRECISION = 10000;

implementation

end.
