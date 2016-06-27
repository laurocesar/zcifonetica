//***************************************************************
{ ZCI Fonética
  ------------
  
  Normalizador de consulta fonética.
  
  Biblioteca nativa compilável em Delphi em Windows; em Lázarus em Windows, Linux e macOS e outros.
  
  Estrutura pronta para ser utilizada como UDF para Firebird. 
  
  github.com/laurocesar/zcifonetica

  Lauro César Araujo,
  04 de junho de 2004 23:10"} 

library ZCIFonetica;
uses
  SysUtils;

type
  TChars = set of Char;

function ib_util_malloc(l: integer): pointer; cdecl; external 'ib_util.dll';

//Tirar acentos
function TirarAcentos(Palavra: PChar): PChar;
begin
 Result:= Palavra;
 if Palavra= nil then
  Exit;
 while Palavra^<> #0 do
 begin
  case Palavra^ of
   'á', 'â', 'ã', 'à', 'ä', 'å', 'Á', 'Â', 'Ã', 'À', 'Ä', 'Å': Palavra^:= 'a';
   'é', 'ê', 'è', 'ë', 'É', 'Ê', 'È', 'Ë': Palavra^:= 'e';
   'í', 'î', 'ì', 'ï', 'Í', 'Î', 'Ì', 'Ï': Palavra^:= 'i';
   'ó', 'ô', 'õ', 'ò', 'ö', 'Ó', 'Ô', 'Õ', 'Ò', 'Ö': Palavra^:= 'o';
   'ú', 'û', 'ù', 'ü', 'Ú', 'Û', 'Ù', 'Ü': Palavra^:= 'u';
   'ç', 'Ç': Palavra^:= 'c';
   'ñ', 'Ñ': Palavra^:= 'n';
   'ý', 'ÿ', 'Ý', 'Ÿ': Palavra^:= 'y';
  else
   if Ord(Palavra^)> 127 then Palavra^ := #32;
  end;

  Inc(Palavra);
 end;
end;

//Filtrar caracteres
function FilterChars(const S: String; const ValidChars: TChars): String;
 var i: Integer;
begin
 Result:= '';
 for i:= 1 to Length(S) do
  if S[i] in ValidChars then
    Result:= Result+S[i];
end;

//Função que recebe um texto e retorna sua string fonética
function fonetica(Texto: PChar): Pchar; cdecl; export;
 var i: Integer;
     S, T, L: String;

 procedure Subst(Procurar, Substituir: String);
  var Posicao: Integer;
 begin
  T:= '';

  Posicao:= pos(Procurar, S);
  if Posicao> 0 then
   repeat
    T:= Copy(S, 1, Posicao-1)+Substituir+
     Copy(S, Posicao+Length(Procurar), Length(S));
    S:= T;
    Posicao:= pos(Procurar, S);
   until (Posicao<= 0)
  else
   T:= S;

  S:= T;
 end;

 procedure SubstSeAntes(Procurar, Substituir: String; AntesDe: TChars);
  var i: Integer;
 begin
  T:= '';

  for i:= 1 to Length(S) do
   if (i+1)<= Length(S) then
    if (S[i]= Procurar) and (S[i+1] in AntesDe) then
     T:= T+Substituir
    else
     T:= T+S[i]
   else
    T:= T+S[i];

  S:= T;
 end;

begin
 S:= String(Texto);

 if (Length(S)> 2) then
 begin
   //Converter Minúsculas
   S:= PChar(LowerCase(S));

   //Substituir Ç por C
   Subst('ç', 'c');

   //Tirar Acentos
   S:= TirarAcentos(PChar(S));

   //Filtra os caracteres considerando apenas letras e números
   S:= FilterChars(S, ['a'..'z', ' ', '0'..'9']);

   //Substituir PH por F
   Subst('ph',  'f');

   //Substituir SCH por C {trocar com X: Ex.: Schimenes
   Subst('sch',  'c');

   //Excluindo H
   Subst('h', '');

   //Substituir Z por S
   Subst('z', 's');

   //Substituir X por C
   Subst('x', 'c');

   //Substituir Y por I
   Subst('y',  'i');

   //Substituir W por V
   Subst('w',  'v');

   //Substituir K por c
   Subst('k',  'c');

   //Substituir QU por C   (Substituir por K)
   Subst('qu',  'c');

   //Substituir irt e ert por iut e eut  (Substituir por ilt e elt) Ex: Airton e Ailton
   Subst('irt',  'iut');
   Subst('ert',  'eut');

   //Tirar G antes de T Ex: em welington
   Subst('gt',  't');

   //Adicionando um espaço no final para as regras a seguir
   S:= S+' ';

   //Retirar de, da, do, dos, das, d'
   Subst(' de ', ' ');
   Subst(' da ', ' ');
   Subst(' do ', ' ');
   Subst(' d ', ' '); // d'  Ex.: d'alva
   Subst(' dos ', ' ');
   Subst(' das ', ' ');

   //Substituir N no final por M
   Subst('n ', 'm ');

   //Substituir C antes de E e I por S Ex. Celina: Selina
   Subst('ce', 'se');
   Subst('ci', 'si');

   //Substituir GIU por JU Ex. Giuliano e Juliano
   Subst('giu', 'ju');

   //Substituir GEO por JO Ex. George e Jorge
   Subst('geo', 'jo');

   //Substituir G antes de E e I por J Ex. Geferson e Jerferson
   Subst('ge', 'je');
   Subst('gi', 'ji');

   //Substituir I e E no final por A Ex: Camili, Camile e Camila
   Subst('e ', 'a ');
   Subst('i ', 'a ');

   //Substituindo UI ou EU no início por VI ou VE. Ex: Wilson -> vilson = uilson
   if Length(S)>= 2 then
    if (Copy(S, 1, 2)= 'ui') or (Copy(S, 1, 2)= 'ue') then
     S:= 'v'+Copy(S, 2, Length(S));

   //Substituir N antes de P e B por M
   Subst('np', 'mp');
   Subst('nb', 'mb');

   //Substituir M antes de consoantes diferente de P e B por n
   SubstSeAntes('m', 'n', ['c', 'd', 'f', 'g', 'h', 'j', 'l',
    'm', 'n', 'q', 'r', 's', 't', 'v', 'x', 'z', 'w', 'k', 'y']);

   //Substituir L antes de consoante, menos L, por U. Ex: Alves e Auves
   SubstSeAntes('l', 'u', ['b', 'c', 'd', 'f', 'g', 'h', 'j',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'x', 'z', 'w', 'k', 'y']);

   //Tira vogais no início dos nomes. Ex. Stela e Estela
   if Length(S)>= 2 then
    if (S[1] in ['a', 'e', 'i', 'o', 'u', 'y']) and
     (S[2] in ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'l',
     'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'x', 'z', 'w', 'k', 'y']) then
     S:= Copy(S, 2, Length(S));

   //Tirar letras dobradas
   if Length(S)>= 2 then
   begin
    T:= S[1];
    L:= S[1];
    for i:= 2 to Length(S) do
     if S[i]<> L[1] then
     begin
      T:= T+S[i];
      L:= S[i];
     end;
    S:= T;
   end;

   //Tirar Espaços
   S:= FilterChars(S, ['a'..'z', '0'..'9']);
 end;

  Result := ib_util_malloc(Length(S) + 1);
  StrPCopy(Result, S);
end;

//Mesma função só que retorna o caracter % antes e depois da string
function foneticaLike(Texto: PChar): Pchar; cdecl; export;
  var S: String;
begin
  S:= String('%'+fonetica(Texto))+'%';

  Result := ib_util_malloc(Length(S) + 1);
  StrPCopy(Result, S);
end;

exports
  fonetica,
  foneticaLike;
begin
end.
