unit u_AlbumClass;

interface

uses
  MVCFramework.Serializer.Commons;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TAlbum = class
  private
    Falb_id: Integer;
    Falb_nome: string;
    Fart_id: Integer;
  public
    property alb_id: Integer read Falb_id write Falb_id;
    property alb_nome: string read Falb_nome write Falb_nome;
    property art_id: string read Fart_id write Fart_id;
  end;

implementation

end.
