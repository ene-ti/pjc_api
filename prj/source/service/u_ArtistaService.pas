unit u_ArtistaService;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  u00_conexao,
  u_ArtistaClass,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.DApt,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,                //MySql
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, //Firebirdb
  Data.DB;

type
  TArtistaService = class
  private

  public
    class function GetArtistas(const cField, cWhere, cOrderBy, cRegAtual, cQtdReg: string): TObjectList<TArtista>;
    class function GetArtista(const cArt_id: Integer): TArtista;
    class procedure CreateArtista(const AArtista: TArtista);
    class procedure UpdateArtista(const cArt_id: Integer; const AArtista: TArtista);
    class procedure DeleteArtista(const cArt_id: Integer);
  end;

implementation

uses u00_Global, u00_FunPro;

{ TArtistaService }

class function TArtistaService.GetArtistas(const cField, cWhere, cOrderBy, cRegAtual, cQtdReg: string): TObjectList<TArtista>;
var
  FDConexao: TFDConnection;
  TmpDataset: TDataSet;
  AArtista: TArtista;
  vWhereLike, vOrderBy: string;
  vRegAtual, vQtdReg, vIni, vCont: integer;
begin
  Result := TObjectList<TArtista>.Create;

  FDConexao := TFDConnection.Create(nil);
  try
    vRegAtual := StrToIntDef(cRegAtual,0);
    vQtdReg := StrToIntDef(cQtdReg,0);

    if cWhere.Trim.IsEmpty then
      vWhereLike := ' '
    else
      vWhereLike := ' WHERE ' + cField + ' LIKE ''%' + cWhere + '%'' ';

    if cOrderBy.Trim.IsEmpty then
      vOrderBy := ' ORDER BY ART_ID '
    else
      vOrderBy := ' ORDER BY ART_NOME ' + cOrderBy;

    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    FDConexao.ExecSQL('SELECT * FROM ARTISTA ' + vWhereLike + vOrderBy, TmpDataset);

    if not TmpDataset.IsEmpty then
    begin
      TmpDataset.First;
      vIni := 0;
      vCont := 0;
      while not TmpDataset.Eof do
      begin
        vIni := vIni+1;
        if (vRegAtual > 0) and (vIni <= vRegAtual) then
        begin
          TmpDataset.Next;
          Continue;
        end;
        vCont := vCont+1;

        AArtista := TArtista.Create;
        AArtista.art_id   := TmpDataset.FieldByName('ART_ID').AsInteger;
        AArtista.art_nome := TmpDataset.FieldByName('ART_NOME').AsString;
        AArtista.art_categoria := TmpDataset.FieldByName('ART_CATEGORIA').AsString;

        Result.Add(AArtista);
        TmpDataset.Next;
        if (vQtdReg > 0) and (vCont >= vQtdReg) then
        begin
          break;
        end;
      end;
    end
    else
      raise EDatabaseError.Create('Nenhum artista cadastrado na base de dados!');
  finally
    TmpDataset.Free;
    FDConexao.Free;
  end;
end;

class function TArtistaService.GetArtista(const cArt_id: Integer): TArtista;
var
  FDConexao: TFDConnection;
  TmpDataset: TDataSet;
begin
  Result := TArtista.Create;

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;

    FDConexao.ExecSQL(
      'SELECT * FROM ARTISTA WHERE ART_ID = ' + cArt_id.ToString,
      TmpDataset
    );

    if not TmpDataset.IsEmpty then
    begin
      Result.art_id        := TmpDataset.FieldByName('ART_ID').AsInteger;
      Result.art_nome      := TmpDataset.FieldByName('ART_NOME').AsString;
      Result.art_categoria := TmpDataset.FieldByName('ART_CATEGORIA').AsString;
    end
    else
      raise EDatabaseError.CreateFmt('Artista "%d" n�o encontrado na base de dados!', [cArt_id]);
  finally
    TmpDataset.Free;
    FDConexao.Free;
  end;
end;

class procedure TArtistaService.CreateArtista(const AArtista: TArtista);
var
  FDConexao: TFDConnection;
const
  SQL_INSERT: string =
    'INSERT INTO ARTISTA (           ' + sLineBreak +
    '  ART_NOME, ART_CATEGORIA       ' + sLineBreak +
    ') VALUES (                      ' + sLineBreak +
    '  :ART_NOME, :ART_CATEGORIA     ' + sLineBreak +
    ')';
begin
  if AArtista.art_nome.Trim.IsEmpty then
    raise EDatabaseError.Create('Nome do Artista � obrigat�rio');
  if AArtista.art_categoria.Trim.IsEmpty then
    raise EDatabaseError.Create('Categoria do Artista � obrigat�rio');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    FDConexao.ExecSQL(SQL_INSERT,
      [
        AArtista.art_nome,
        AArtista.art_categoria
      ],
      [
        ftString,
        ftString
      ]
    );
  finally
    FDConexao.Free;
  end;
end;

class procedure TArtistaService.UpdateArtista(const cArt_id: Integer; const AArtista: TArtista);
var
  FDConexao: TFDConnection;
  CountAtu: Integer;

const
  SQL_UPDATE: string =
    'UPDATE ARTISTA SET                ' + sLineBreak +
    '  ART_NOME = :ART_NOME,           ' + sLineBreak +
    '  ART_CATEGORIA = :ART_CATEGORIA  ' + sLineBreak +
    'WHERE ART_ID = :ART_ID            ';
begin
  if AArtista.art_nome.Trim.IsEmpty then
    raise EDatabaseError.Create('Nome do Artista � obrigat�rio');
  if AArtista.art_categoria.Trim.IsEmpty then
    raise EDatabaseError.Create('Categoria do Artista � obrigat�rio');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    CountAtu := FDConexao.ExecSQL(SQL_UPDATE,
      [
        AArtista.art_nome,
        AArtista.art_categoria,
        cArt_id
      ],
      [
        ftString,
        ftString,
        ftInteger
      ]
    );

    if CountAtu <= 0 then
      raise Exception.Create('Nenhum artista foi atualizado');
  finally
    FDConexao.Free;
  end;
end;

class procedure TArtistaService.DeleteArtista(const cArt_id: Integer);
var
  FDConexao: TFDConnection;
  CountDelete: Integer;
begin
  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;

    CountDelete := FDConexao.ExecSQL(
      'DELETE FROM ARTISTA WHERE ART_ID = :ART_ID',
      [cArt_id],
      [ftInteger]
    );

    if CountDelete = 0 then
      raise EDatabaseError.Create('Nenhum Artista foi excluido!');
  finally
    FDConexao.Free;
  end;
end;




end.

