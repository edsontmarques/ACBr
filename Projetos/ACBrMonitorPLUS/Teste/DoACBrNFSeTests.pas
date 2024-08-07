unit DoACBrNFSeTests;

{$I ACBr.inc}

interface

uses
  Classes, SysUtils, IniFiles, ACBrTests.Util, ACBrMonitorTestConsts, ACBrNFSeX,
  ACBrNFSeXConversao, ACBrMonitorConfig, DoACBrNFSeUnit, CmdUnit;

type

{ TDoACBrNFSeTest }

TDoACBrNFSeTest = class(TTestCase)
private
  FMonitorConfig: TMonitorConfig;
  FObjetoDono: TACBrObjetoNFSe;
  FACBrNFSeX: TACBrNFSeX;
  FCmd: TACBrCmd;
public
  procedure SetUp; override;
  procedure TearDown; override;
  procedure ConfigurarNFSeX;
published
  procedure AdicionarRPSCaminhoIni;
  procedure AdicionarRPSConteudoIni;
  procedure LerIniNFSeCaminhoIni;
  procedure LerIniNFSeConteudoIni;
  procedure AdicionarRPSCom5RPS;
  procedure AdicionarRPSCom50RPS;
  procedure AdicionarRPSCom51RPS;
  procedure LimparLoteRPSCom50RPS;
  procedure TotalRPSLoteCom25RPS;
  procedure SetCodigoMunicipioValorValido;
  procedure SetCodigoMunicipioValorInvalido;
  procedure SetCodigoMunicipioCidadeSemProvedor;
  procedure SetLayoutNFSeValoresValidos;
  procedure SetLayoutNFSeValoresInvalidos;
  procedure SetEmitenteValoresPreenchidos;
  procedure SetEmitenteValoresEmBranco;
  procedure SetAutenticacaoNFSeValoresPreenchidos;
  procedure SetAutenticacaoNFSeValoresEmBranco;
end;

implementation

{ TDoACBrNFSeTest }

procedure TDoACBrNFSeTest.SetUp;
begin
  inherited SetUp;
  FMonitorConfig := TMonitorConfig.Create(MONITORINICONFIG);
  FACBrNFSeX := TACBrNFSeX.Create(nil);
  ConfigurarNFSeX;
  FObjetoDono := TACBrObjetoNFSe.Create(FMonitorConfig, FACBrNFSeX);
  FCmd := TACBrCmd.Create;
end;

procedure TDoACBrNFSeTest.TearDown;
begin
  FreeAndNil(FObjetoDono);
  FreeAndNil(FMonitorConfig);
  FreeAndNil(FACBrNFSeX);
  FreeAndNil(FCmd);

  inherited TearDown;
end;

procedure TDoACBrNFSeTest.ConfigurarNFSeX;
var
  IniConfig: TMemIniFile;
begin
  IniConfig := TMemIniFile.Create(MONITORINICONFIG);
  try
    if not IniConfig.SectionExists('NFSE') then
       raise Exception.Create('Arquivo MonitorConfig.ini em branco, preencha o arquivo!');
    FACBrNFSeX.Configuracoes.Geral.Emitente.WSUser := IniConfig.ReadString('NFSe', 'Usuario', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.WSSenha := IniConfig.ReadString('NFSe', 'Senha', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.WSChaveAcesso := IniConfig.ReadString('NFSe', 'ChaveAutenticacao', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.WSFraseSecr := IniConfig.ReadString('NFSe', 'FraseSecreta', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.CNPJ := IniConfig.ReadString('NFSe', 'CNPJEmitente', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.InscMun := IniConfig.ReadString('NFSe', 'IMEmitente', '');
    FACBrNFSeX.Configuracoes.Geral.Emitente.RazSocial := IniConfig.ReadString('NFSe', 'NomeEmitente', '');
    FACBrNFSeX.Configuracoes.Geral.MontarPathSchema := IniConfig.ReadBool('NFSe', 'MontarAutoPathSchema', True);
    FACBrNFSeX.Configuracoes.Geral.ConsultaAposCancelar := IniConfig.ReadBool('NFSe', 'ConsultarLoteAposEnvio', True);
    FACBrNFSeX.Configuracoes.Geral.ConsultaLoteAposEnvio := IniConfig.ReadBool('NFSe', 'ConsultarAposCancelar', True);
    FACBrNFSeX.Configuracoes.Geral.CNPJPrefeitura := IniConfig.ReadString('NFSe', 'CNPJPrefeitura', '');
    FACBrNFSeX.Configuracoes.Geral.LayoutNFSe := IfThen<TLayoutNFSe>(IniConfig.ReadInteger('NFSe', 'LayoutProvedor', 0)=0, lnfsProvedor, lnfsPadraoNacionalv1) ;
    FACBrNFSeX.Configuracoes.Geral.CodigoMunicipio := IniConfig.ReadInteger('NFSe', 'CodigoMunicipio', 0);
  finally
    FreeAndNil(IniConfig);
  end;
end;

procedure TDoACBrNFSeTest.AdicionarRPSCaminhoIni;
var
  FParameters: TStringList;
begin
  FParameters := TStringList.Create;
  try
    FParameters.Clear;
    FParameters.Add(NFSEINI);
    FParameters.Add('1');

    FACBrNFSeX.NotasFiscais.Clear;

    FCmd.Comando := 'NFSe.AdicionarRPS("'+FParameters.Strings[0]+'",' + FParameters.Strings[1]+')';

    FObjetoDono.Executar(FCmd);
    Check(FCmd.Params(0) = FParameters.Strings[0], 'Params(0) diferente do esperado!'+
                                                   sLineBreak + 'Esperado:'+
                                                   sLineBreak + FParameters.Strings[0] +
                                                   SLineBreak + 'Recebido:'+
                                                   SLineBreak + FCmd.Params(0));

    Check(FCmd.Params(1) = FParameters.Strings[1], 'Params(1) diferente do esperado!'+
                                                   sLineBreak + 'Esperado:'+
                                                   sLineBreak + FParameters.Strings[1] +
                                                   SLineBreak + 'Recebido:'+
                                                   SLineBreak + FCmd.Params(1));
    Check(FCmd.Resposta = 'Total RPS Adicionados= 1', 'Esperado:Total RPS Adicionados= 1|Recebido:'+FCmd.Resposta);

  finally
    FreeAndNil(FParameters);
  end;
end;

procedure TDoACBrNFSeTest.AdicionarRPSConteudoIni;
var
  IniNFSe: TStringList;
  FParameters: TStringList;
begin
  FACBrNFSeX.NotasFiscais.Clear;

  IniNFSe := TStringList.Create;
  FParameters := TStringList.Create;
  try
    IniNFSe.LoadFromFile(NFSEINI);

    FParameters.Add(IniNFSe.Text);
    FParameters.Add('1');

    FCmd.Comando := 'NFSe.AdicionarRPS("'+FParameters.Strings[0]+'",'+FParameters.Strings[1]+')';

    FObjetoDono.Executar(FCmd);
    Check(FCmd.Params(0) = FParameters.Strings[0], 'Params(0) diferente do esperado!'+
                                                   sLineBreak + 'Esperado:'+
                                                   sLineBreak + FParameters.Strings[0] +
                                                   SLineBreak + 'Recebido:'+
                                                   SLineBreak + FCmd.Params(0));

    Check(FCmd.Params(1) = FParameters.Strings[1], 'Params(1) diferente do esperado!'+
                                                   sLineBreak + 'Esperado:'+
                                                   sLineBreak + FParameters.Strings[1] +
                                                   SLineBreak + 'Recebido:'+
                                                   SLineBreak + FCmd.Params(1));
    Check(FCmd.Resposta = 'Total RPS Adicionados= 1', 'Esperado:Total RPS Adicionados= 1|Recebido:'+FCmd.Resposta);
  finally
    FreeAndNil(IniNFSe);
    FreeAndNil(FParameters);
  end;
end;

procedure TDoACBrNFSeTest.LerIniNFSeCaminhoIni;
begin
  FCmd.Comando := 'NFSe.AdicionarRPS("'+NFSEINI+'", 1)';

  FACBrNFSeX.NotasFiscais.Clear;
  FACBrNFSeX.NotasFiscais.LoadFromIni(FCmd.Params(0));

  CheckTrue(FACBrNFSeX.NotasFiscais.Count = 1, 'LerIniNFSe não carregou NFSe');
end;

procedure TDoACBrNFSeTest.LerIniNFSeConteudoIni;
var
  IniNFSe: TStringList;
begin
  IniNFSe := TStringList.Create;
  try
    IniNFSe.LoadFromFile(NFSEINI);

    FCmd.Comando := 'NFSe.AdicionarRPS("'+IniNFSe.Text+'", 1)';
    FACBrNFSeX.NotasFiscais.LoadFromIni(FCmd.Params(0));

    CheckTrue(FACBrNFSeX.NotasFiscais.Count = 1, 'LerIniNFSe não carregou NFSe');
  finally
    FreeAndNil(IniNFSe);
  end;
end;

procedure TDoACBrNFSeTest.AdicionarRPSCom5RPS;
var
  Parametros: TStringList;
  i: Integer;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add(NFSEINI);
    Parametros.Add('1');

    for i:=1 to 5 do
    begin
      FCmd.Comando := 'NFSe.AdicionarRPS("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'")';
      FObjetoDono.Executar(FCmd);
    end;
    CheckEquals(5, FObjetoDono.ACBrNFSeX.NotasFiscais.Count, 'Quantidade de RPS diferente|Esperado:5|Obtibo:'
                                                             +IntToStr(FObjetoDono.ACBrNFSeX.NotasFiscais.Count));
    CheckEquals('Total RPS Adicionados= 5', FCmd.Resposta,
                'Esperado: Total RPS Adicionados= 5' + sLineBreak +
                'Recebido: ' + FCmd.Resposta);
  finally
    FreeAndNil(Parametros);
  end;
end;

procedure TDoACBrNFSeTest.AdicionarRPSCom50RPS;
var
  Parametros: TStringList;
  i: Integer;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add(NFSEINI);
    Parametros.Add('1');

    for i:=1 to 50 do
    begin
      FCmd.Comando := 'NFSe.AdicionarRPS("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'")';
      FObjetoDono.Executar(FCmd);
    end;
    CheckEquals(50, FObjetoDono.ACBrNFSeX.NotasFiscais.Count, 'Quantidade de RPS diferente|Esperado:50|Obtibo:'
                                                             +IntToStr(FObjetoDono.ACBrNFSeX.NotasFiscais.Count));
    CheckEquals('Total RPS Adicionados= 50', FCmd.Resposta,
                'Esperado: Total RPS Adicionados= 50' + sLineBreak +
                'Recebido: ' + FCmd.Resposta);
  finally
    FreeAndNil(Parametros);
  end;
end;

procedure TDoACBrNFSeTest.AdicionarRPSCom51RPS;
var
  Parametros: TStringList;
  i: Integer;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add(NFSEINI);
    Parametros.Add('1');

    for i:=1 to 51 do
    begin
      FCmd.Comando := 'NFSe.AdicionarRPS("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'")';
      FObjetoDono.Executar(FCmd);
    end;
    CheckEquals('Limite de RPS por Lote(50) atingido, envie o lote ou limpe a lista', FCmd.Resposta,
                'Esperado: Limite de RPS por Lote(50) atingido, envie o lote ou limpe a lista' + sLineBreak +
                'Recebido: ' + FCmd.Resposta);
    Check(FObjetoDono.ACBrNFSeX.NotasFiscais.Count = 50, 'Total de RPS carregados:'+IntToStr(FObjetoDono.ACBrNFSeX.NotasFiscais.Count)+'|Esperado:50');
  finally
    FreeAndNil(Parametros);
  end;
end;

procedure TDoACBrNFSeTest.LimparLoteRPSCom50RPS;
var
  Parametros: TStringList;
  i: Integer;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add(NFSEINI);
    Parametros.Add('1');

    for i:=1 to 51 do
    begin
      FCmd.Comando := 'NFSe.AdicionarRPS("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'")';
      FObjetoDono.Executar(FCmd);
    end;

    FCmd.Comando := 'NFSe.LimparLoteRPS';
    FObjetoDono.Executar(FCmd);

    Check(FObjetoDono.ACBrNFSeX.NotasFiscais.Count = 0, 'Total RPS esperado:0|Recebido:'+IntToStr(FObjetoDono.ACBrNFSeX.NotasFiscais.Count));

  finally
    FreeAndNil(Parametros);
  end;
end;

procedure TDoACBrNFSeTest.TotalRPSLoteCom25RPS;
var
  Parametros: TStringList;
  i: Integer;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add(NFSEINI);
    Parametros.Add('1');

    for i:=1 to 25 do
    begin
      FCmd.Comando := 'NFSe.AdicionarRPS("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'")';
      FObjetoDono.Executar(FCmd);
    end;

    FCmd.Comando := 'NFSe.TotalRPSLote';
    FObjetoDono.Executar(FCmd);

    CheckEquals('25', FCmd.Resposta);

  finally
    FreeAndNil(Parametros);
  end;
end;

procedure TDoACBrNFSeTest.SetLayoutNFSeValoresValidos;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('0');
    Parametros.Add('1');
    FCmd.Comando := 'NFSe.SetLayoutNFSe("'+Parametros.Strings[0]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.LayoutNFSe = lnfsProvedor, 'Valor do Layout diferente do esperado');

    FCmd.Comando := 'NFSe.SetLayoutNFSe("'+Parametros.Strings[1]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.LayoutNFSe = lnfsPadraoNacionalv1, 'Valor do Layout diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetLayoutNFSeValoresInvalidos;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('-1');
    Parametros.Add('3');
    FCmd.Comando := 'NFSe.SetLayoutNFSe("'+Parametros.Strings[0]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.LayoutNFSe in [lnfsProvedor, lnfsPadraoNacionalv1], 'Valor do Layout diferente do esperado');

    FCmd.Comando := 'NFSe.SetLayoutNFSe("'+Parametros.Strings[1]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.LayoutNFSe in [lnfsProvedor, lnfsPadraoNacionalv1], 'Valor do Layout diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetEmitenteValoresPreenchidos;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('99999999999999');
    Parametros.Add('987654321');
    Parametros.Add('Razao Emitente');

    FCmd.Comando := 'NFSe.SetEmitente("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'","'+Parametros.Strings[2]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.CNPJ = Parametros.Strings[0], 'CNPJ diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.InscMun = Parametros.Strings[1], 'Insc. Municipal diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.RazSocial = Parametros.Strings[2], 'Razão Social diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetEmitenteValoresEmBranco;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('');
    Parametros.Add('');
    Parametros.Add('');

    FCmd.Comando := 'NFSe.SetEmitente("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'","'+Parametros.Strings[2]+'")';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.CNPJ = '', 'CNPJ diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.InscMun = '', 'Insc. Municipal diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.RazSocial = '', 'Razão Social diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetAutenticacaoNFSeValoresPreenchidos;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('Admin');
    Parametros.Add('1234');
    Parametros.Add('ChaveDeAcesso');
    Parametros.Add('ChaveAutenticacao');
    Parametros.Add('FraseSecreta');

    FCmd.Comando := 'NFSe.SetAutenticacaoNFSe("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'","'+Parametros.Strings[2]+'","'
                                            +Parametros.Strings[3]+'","'+Parametros.Strings[4]+'")';


    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSUser = Parametros.Strings[0], 'WSUser diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSSenha = Parametros.Strings[1], 'WSSenha diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSChaveAcesso = Parametros.Strings[2], 'WSChaveAcesso diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSChaveAutoriz = Parametros.Strings[3], 'WSChaveAutenticacao diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSFraseSecr = Parametros.Strings[4], 'WSFraseSecreta diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetAutenticacaoNFSeValoresEmBranco;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('');
    Parametros.Add('');
    Parametros.Add('');
    Parametros.Add('');
    Parametros.Add('');

    FCmd.Comando := 'NFSe.SetAutenticacaoNFSe("'+Parametros.Strings[0]+'","'+Parametros.Strings[1]+'","'+Parametros.Strings[2]+'","'
                                            +Parametros.Strings[3]+'","'+Parametros.Strings[4]+'")';


    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSUser = Parametros.Strings[0], 'WSUser diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSSenha = Parametros.Strings[1], 'WSSenha diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSChaveAcesso = Parametros.Strings[2], 'WSChaveAcesso diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSChaveAutoriz = Parametros.Strings[3], 'WSChaveAutenticacao diferente do esperado');
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.Emitente.WSFraseSecr = Parametros.Strings[4], 'WSFraseSecreta diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetCodigoMunicipioValorValido;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('3554003');

    FCmd.Comando := 'NFSe.SetCodigoMunicipio('+Parametros.Strings[0]+')';
    FObjetoDono.Executar(FCmd);
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.CodigoMunicipio = StrToIntDef(Parametros.Strings[0], 0), 'Código do Municipio diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetCodigoMunicipioValorInvalido;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('3554003');
    Parametros.Add('-1');

    FCmd.Comando := 'NFSe.SetCodigoMunicipio('+Parametros.Strings[0]+')';
    FObjetoDono.Executar(FCmd);

    FCmd.Comando := 'NFSe.SetCodigoMunicipio('+Parametros.Strings[1]+')';
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.CodigoMunicipio = StrToIntDef(Parametros.Strings[0], 0), 'Código do Municipio diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

procedure TDoACBrNFSeTest.SetCodigoMunicipioCidadeSemProvedor;
var
  Parametros: TStringList;
begin
  Parametros := TStringList.Create;
  try
    Parametros.Add('3554003');
    Parametros.Add('3553955');

    FCmd.Comando := 'NFSe.SetCodigoMunicipio('+Parametros.Strings[0]+')';
    FObjetoDono.Executar(FCmd);

    FCmd.Comando := 'NFSe.SetCodigoMunicipio('+Parametros.Strings[1]+')';
    Check(FObjetoDono.ACBrNFSeX.Configuracoes.Geral.CodigoMunicipio = StrToIntDef(Parametros.Strings[0], 0), 'Código do Municipio diferente do esperado');
  finally
    Parametros.Free;
  end;
end;

initialization
  _RegisterTest('ACBrMonitor.DoACBrNFSeUnit', TDoACBrNFSeTest);

end.

