# zcifonetica

Função de normalização fonética para português brasileiro.

Código escrito como biblioteca nativa para uso em aplicações Windows, Linux, macOS ou outros. Neste código, a biblioteca é implementada para ser usada diretamente com banco de dados [Firebird 1 ou superior](http://www.firebirdsql.org). 

Compilável com Delphi em Windows e com [FreePascal](http://www.freepascal.org/) e [Lazarus](http://www.lazarus-ide.org/) em qualquer sistema operacional aceito pela linguagem.

## Uso como UDF para Firebird

1. Compile o código
2. Adicione o arquivo gerado (`ZCIFonetica.dll` ou `ZCIFonetica.so`) ao diretório `UDF` do Firebird
3. Adicione as funções ao banco de dados:
```SQL
DECLARE EXTERNAL FUNCTION FONETICALIKE
    CSTRING(254)
RETURNS CSTRING(254)
ENTRY_POINT 'foneticaLike' MODULE_NAME 'ZCIFonetica.dll';

DECLARE EXTERNAL FUNCTION FONETICA
    CSTRING(254)
RETURNS CSTRING(254)
ENTRY_POINT 'fonetica' MODULE_NAME 'ZCIFonetica.dll';
```
* Use a função `Fonetica` em igualdades:
```SQL
SELECT NOME FROM CLIENTES
  WHERE Fonetica(NOME) = Fonetica(:parametro)
  ORDER BY NOME 
```
* Use a função `FoneticaLike` jundamente com o operador `LIKE`:
```SQL
SELECT NOME FROM CLIENTES
  WHERE FoneticaLike(NOME) LIKE FoneticaLike(:parametro)
  ORDER BY NOME 
```
