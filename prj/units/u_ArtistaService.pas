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
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  Data.DB;

type
  TArtistaService = class
  private

  public
    class function GetArtistas(const cWhere: string): TObjectList<TArtista>;
    class function GetArtista(const cArt_id: Integer): TArtista;
    class procedure Post(const AArtista: TArtista);
    class procedure Update(const cArt_id: Integer; const AArtista: TArtista);
    class procedure Delete(const cArt_id: Integer);
  end;

implementation

uses u00_Global, u00_FunPro;

{ TArtistaService }

class function TArtistaService.GetArtistas(const cWhere: string): TObjectList<TArtista>;
var
  FDConexao: TFDConnection;
  TmpDataset: TDataSet;
  AArtista: TArtista;
  StrWhere: string;
begin
  Result := TObjectList<TArtista>.Create;

  FDConexao := TFDConnection.Create(nil);
  try
    if cWhere.Trim.IsEmpty then
      StrWhere := ''
    else
      StrWhere := 'where descricao like ''%' + cWhere + '%''';

    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    FDConexao.ExecSQL('select * from artista ' + StrWhere + ' order by art_id', TmpDataset);

    if not TmpDataset.IsEmpty then
    begin
      TmpDataset.First;
      while not TmpDataset.Eof do
      begin
        AArtista := TArtista.Create;
        AArtista.art_id   := TmpDataset.FieldByName('art_id').AsInteger;
        AArtista.art_nome := TmpDataset.FieldByName('art_nome').AsString;

        Result.Add(AArtista);
        TmpDataset.Next;
      end;
    end
    else
      raise EDatabaseError.Create('Nenhum produto cadastrado na base de dados!');
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
      'select * from artista where art_id=' + cArt_id.ToString,
      TmpDataset
    );

    if not TmpDataset.IsEmpty then
    begin
      Result.art_id        := TmpDataset.FieldByName('ART_ID').AsInteger;
      Result.art_nome      := TmpDataset.FieldByName('ART_NOME').AsString;
    end
    else
      raise EDatabaseError.CreateFmt('Produto "%d" n�o encontrado na base de dados!', [cArt_id]);
  finally
    TmpDataset.Free;
    FDConexao.Free;
  end;
end;

class procedure TArtistaService.Post(const AArtista: TArtista);
var
  FDConexao: TFDConnection;
const
  SQL_INSERT: string =
    'INSERT INTO ARTISTA (                                ' + sLineBreak +
    '  ART_ID, ART_NOME       ' + sLineBreak +
    ') VALUES (                                            ' + sLineBreak +
    '  :art_id, :art_nome ' + sLineBreak +
    ')';
begin
  if AArtista.art_nome.Trim.IsEmpty then
    raise EDatabaseError.Create('Nome do Artista � obrigat�rio');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    FDConexao.ExecSQL(SQL_INSERT,
      [
        AArtista.art_id,
        AArtista.art_nome
      ],
      [
        ftInteger,
        ftString
      ]
    );
  finally
    FDConexao.Free;
  end;
end;

class procedure TArtistaService.Update(const cArt_id: Integer; const AArtista: TArtista);
var
  FDConexao: TFDConnection;
  CountAtu: Integer;

const
  SQL_UPDATE: string =
    'UPDATE ARTISTA SET         ' + sLineBreak +
    '  art_id = :art_id,             ' + sLineBreak +
    '  art_nome = :art_nome                  ' + sLineBreak +
    'WHERE (art_id = :artid)            ';
begin
  if AArtista.art_nome.Trim.IsEmpty then
    raise EDatabaseError.Create('Nome do Artista � obrigat�rio');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;
    CountAtu := FDConexao.ExecSQL(SQL_UPDATE,
      [
        AArtista.art_id,
        AArtista.art_nome,
        cArt_id
      ],
      [
        ftInteger,
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

class procedure TArtistaService.Delete(const cArt_id: Integer);
var
  FDConexao: TFDConnection;
  CountDelete: Integer;
begin
  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_BD;

    CountDelete := FDConexao.ExecSQL(
      'delete from artista where art_id=?',
      [cArt_id],
      [ftInteger]
    );

    if CountDelete = 0 then
      raise EDatabaseError.Create('Nenhum artista foi excluido!');
  finally
    FDConexao.Free;
  end;
end;




end.

