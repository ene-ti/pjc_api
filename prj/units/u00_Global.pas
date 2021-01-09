unit u00_Global;
{*********************************************************************}
{                                                                     }
{   Unit de declaração de Constantes Utilizadas em todo o Sistema     }
{                                                                     }
{*********************************************************************}
interface

uses
   Graphics;

const
  NOME_CONEXAO_BD = 'CONEXAO_SERVIDOR_BD';

const
  C_versao_aplicacao = '1.0';
  C_nome_aplicacao   = 'PJC_API_ArtAlbum';
  C_desc_aplicacao   = 'PJC_API_ArtAlbum (API de controle de Artista x Album)';
  C_data_compilacao  = '10/01/2021 11:45';

  C_nome_Arq_Ini      = C_nome_aplicacao + '.ini';

var
  vgAppWebPorta : String;
  vgPathAplicacao : String;
  vgArqConfig : Boolean;

  vgBancoDriverID,
  vgBancoServer,
  vgBancoPorta,
  vgBancoUserName,
  vgBancoPassword,
  vgBancoDatabase : String;

implementation

end.

