unit u_ApiController;

interface

uses
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

    //Sample CRUD Actions for a "Customer" entity
    [MVCPath('/artistas')]
    [MVCHTTPMethod([httpGET])]
    procedure GetArtistas;

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
    '<h1>'+ C_nome_aplicacao+C_versao_aplicacao+C_data_compilacao+'</h1>' + sLineBreak +
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

//Sample CRUD Actions for a "Customer" entity
procedure TApiController.GetArtistas;
var
  StrQuery: string;
begin

  StrQuery := Context.Request.QueryStringParam('like');
  Render<TArtista>(TArtistaService.GetArtistas(StrQuery));

end;

procedure TApiController.GetArtista(art_id: Integer);
begin

  Render(TArtistaService.GetArtista(art_id));

end;

procedure TApiController.CreateArtista;
var
  AArtista: TArtista;
begin
  AArtista := Context.Request.BodyAs<TArtista>;
  try
    TArtistaService.Post(AArtista);
    Render(200, 'Artista criado com sucesso');
  finally
    AArtista.Free;
  end;
end;

procedure TApiController.UpdateArtista(art_id: Integer);
var
  AArtista: TArtista;
begin
  AArtista := Context.Request.BodyAs<TArtista>;
  try
    TArtistaService.Update(art_id, AArtista);
    Render(200, Format('Artista "%d" atualizado com sucesso', [art_id]));
  finally
    AArtista.Free;
  end;
end;

procedure TApiController.DeleteArtista(art_id: Integer);
begin

  TArtistaService.Delete(art_id);
  Render(200, Format('Artista "%d" apagado com sucesso', [art_id]));
end;



end.
