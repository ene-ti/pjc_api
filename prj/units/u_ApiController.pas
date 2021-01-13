unit u_ApiController;

interface

uses
  dialogs,
  System.SysUtils,
  System.StrUtils,
  MVCFramework,
  MVCFramework.Commons,
  MVCFramework.Serializer.Commons;

type
  [MVCDoc('Recurso para acesso ao sistema')]
  [MVCPath('/api')]
  TApiController = class(TMVCController)
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;

  public
    [MVCDoc('Retorna p�gina padr�o com configura��es de conex�o')]
    [MVCPath('/')]
    [MVCPath('')]
    [MVCHTTPMethod([httpGET])]
    procedure GetMyRootPage;

    [MVCPath('/artistas')]
    [MVCHTTPMethod([httpGET])]
    procedure GetArtistas;

    [MVCPath('/artistascategoria')]
    [MVCHTTPMethod([httpGET])]
    procedure GetArtistasCategoria;

    [MVCPath('/artista/($art_id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetArtista(art_id: Integer);

    [MVCPath('/artista')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateArtista;

    [MVCPath('/artista/($art_id)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateArtista(art_id: Integer);

    [MVCPath('/artista/($art_id)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteArtista(art_id: Integer);
  end;

implementation

uses
  u_ArtistaService,
  u_ArtistaClass,
  u00_Global;

procedure TApiController.GetMyRootPage;
begin
  ContentType := TMVCMediaType.TEXT_HTML;
  Render(
    '<h1>'+ C_nome_aplicacao+ ' - '+C_versao_aplicacao+ ' - '+C_data_compilacao+'</h1>' + sLineBreak +
    '<p>'+C_desc_aplicacao+'</p>' + sLineBreak +
    '</br>' + sLineBreak +

    '<dl>' + sLineBreak +
//    '<dt>Servidor: </dt><dd>' + ConfiguracaoApp.Servidor       + '</dd>' + sLineBreak +
//    '<dt>Porta: </dt><dd>'    + ConfiguracaoApp.Porta.ToString + '</dd>' + sLineBreak +
//    '<dt>Caminho: </dt><dd>'  + ConfiguracaoApp.Caminho        + '</dd>' + sLineBreak +
    '</dl>'
  );
end;

procedure TApiController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TApiController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;


procedure TApiController.GetArtistas;
var
  StrWhereLike, StrOrderBy, StrRegAtual, StrQtdReg: String;
begin
  // metodo GET: /artistas / QUERY PARAMS (por ART_NOME)
  StrWhereLike := Context.Request.QueryStringParam('wherelike'); // like na clausula where
  StrOrderBy   := Context.Request.QueryStringParam('orderby');   // ordena��o ASC/DSC
  StrRegAtual  := Context.Request.QueryStringParam('regatual');  // Nr Reg Atual
  StrQtdReg    := Context.Request.QueryStringParam('qtdereg');   // Qtde Reg Pagina��o

  Render<TArtista>(TArtistaService.GetArtistas('ART_NOME', StrWhereLike, StrOrderBy, StrRegAtual, StrQtdReg));
end;

procedure TApiController.GetArtistasCategoria;
var
  StrWhereLike, StrOrderBy, StrRegAtual, StrQtdReg: String;
begin
  // metodo GET: /artistas / QUERY PARAMS (por ART_CATEGORIA)
  StrWhereLike := Context.Request.QueryStringParam('wherelike'); // like na clausula where
  StrOrderBy   := Context.Request.QueryStringParam('orderby');   // ordena��o ASC/DSC
  StrRegAtual  := Context.Request.QueryStringParam('regatual');  // Nr Reg Atual
  StrQtdReg    := Context.Request.QueryStringParam('qtdereg');   // Qtde Reg Pagina��o

  Render<TArtista>(TArtistaService.GetArtistas('ART_CATEGORIA', StrWhereLike, StrOrderBy, StrRegAtual, StrQtdReg));
end;

procedure TApiController.GetArtista(art_id: Integer);
begin
  // metodo GET: /artista/($art_id)
  Render(TArtistaService.GetArtista(art_id));
end;

procedure TApiController.CreateArtista;
var
  AArtista: TArtista;
begin
  // metodo POST: /artista
  AArtista := Context.Request.BodyAs<TArtista>;
  try
    TArtistaService.CreateArtista(AArtista);
    Render(200, 'Artista criado com sucesso');
  finally
    AArtista.Free;
  end;
end;

procedure TApiController.UpdateArtista(art_id: Integer);
var
  AArtista: TArtista;
begin
  // metodo PUT: /artista/($art_id)
  AArtista := Context.Request.BodyAs<TArtista>;
  try
    TArtistaService.UpdateArtista(art_id, AArtista);
    Render(200, Format('Artista %d atualizado com sucesso', [art_id]));
  finally
    AArtista.Free;
  end;
end;

procedure TApiController.DeleteArtista(art_id: Integer);
begin
  // metodo DELETE: /artista/($art_id)
  TArtistaService.DeleteArtista(art_id);
  Render(200, Format('Artista %d apagado com sucesso', [art_id]));
end;



end.
