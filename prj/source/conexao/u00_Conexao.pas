unit u00_Conexao;

interface

uses
  forms,
  System.SysUtils,
  System.Classes,

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

  function CreatePoolConnection:Boolean;

implementation

Uses u00_Global, u00_SetupINI, u00_FunPro;


function CreatePoolConnection:Boolean;
var
  FDConnection1 : TFDConnection;
  oParametros: TStringList;
begin

  FDManager.Close;  // Responsavel pelo POOL de conex�o

  oParametros := TStringList.Create;
  try
    oParametros.Clear;
    oParametros.Add('DriverID='+vgBancoDriverID);
    oParametros.Add('Server='+vgBancoServer);
    oParametros.Add('Port='+vgBancoPorta);
    oParametros.Add('User_Name='+vgBancoUserName);
    oParametros.Add('Password='+vgBancoPassword);
    oParametros.Add('Database='+vgBancoDatabase);
      WriteLn(vgBancoDriverID);
      WriteLn(vgBancoServer);
      WriteLn(vgBancoPorta);
      WriteLn(vgBancoUserName);
      WriteLn(vgBancoPassword);
      WriteLn(vgBancoDatabase);

    // parametros para o controle do pool se necess�rio e quiser alterar
    //oParametros.Add('POOL_MaximumItems=50');
    //oParametros.Add('POOL_ExpireTimeout=9000');
    //oParametros.Add('POOL_CleanupTimeout=900000');

    FDManager.AddConnectionDef(NOME_CONEXAO_BD, vgBancoDriverID, oParametros);
    WriteLn('FDManager.Open');
    FDManager.Open;

    FDConnection1 := TFDConnection.Create(nil);
    FDConnection1.ConnectionDefName := NOME_CONEXAO_BD;
    WriteLn('FDConnection1.Connected-01');
    FDConnection1.Connected := true;
    WriteLn('FDConnection1.Connected-02');
    if (FDConnection1.Connected = false) then
    begin
      WriteLn('EDatabaseError');
      raise EDatabaseError.Create('Erro de conex�o com o banco');
    end
    else
    begin
      WriteLn('CONECTADO');
    end;
  finally
    result := FDConnection1.Connected;
    FDConnection1.Free;
    oParametros.Free;
  end;
end;

end.

