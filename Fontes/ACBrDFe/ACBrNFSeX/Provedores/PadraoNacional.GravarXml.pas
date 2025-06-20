{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2022 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Italo Giurizzato Junior                         }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit PadraoNacional.GravarXml;

interface

uses
  SysUtils, Classes, StrUtils,
  IniFiles,
  ACBrXmlBase,
  ACBrXmlDocument,
  ACBrNFSeXClass,
  ACBrNFSeXGravarXml;

type
  { TNFSeW_PadraoNacional }

  TNFSeW_PadraoNacional = class(TNFSeWClass)
  private
    FpVersao: string;

    function GerarChaveDPS(const AcMun, ACNPJCPF, ASerie, ANumero: string): string;

  protected
    LSecao: string;

    function GerarInfDps: TACBrXmlNode;

    function GerarSubstituicao: TACBrXmlNode;

    function GerarPrestador: TACBrXmlNode;
    function GerarEnderecoPrestador: TACBrXmlNode;
    function GerarEnderecoNacionalPrestador: TACBrXmlNode;
    function GerarEnderecoExteriorPrestador: TACBrXmlNode;
    function GerarRegimeTributacaoPrestador: TACBrXmlNode;

    function GerarTomador: TACBrXmlNode;
    function GerarEnderecoTomador: TACBrXmlNode;
    function GerarEnderecoNacionalTomador: TACBrXmlNode;
    function GerarEnderecoExteriorTomador: TACBrXmlNode;

    function GerarIntermediario: TACBrXmlNode;
    function GerarEnderecoIntermediario: TACBrXmlNode;
    function GerarEnderecoNacionalIntermediario: TACBrXmlNode;
    function GerarEnderecoExteriorIntermediario: TACBrXmlNode;

    function GerarServico: TACBrXmlNode;
    function GerarLocalPrestacao: TACBrXmlNode;
    function GerarCodigoServico: TACBrXmlNode;
    function GerarComercioExterior: TACBrXmlNode;
    function GerarLocacaoSubLocacao: TACBrXmlNode;
    function GerarObra: TACBrXmlNode;
    function GerarEnderecoObra: TACBrXmlNode;
    function GerarEnderecoExteriorObra: TACBrXmlNode;
    function GerarAtividadeEvento: TACBrXmlNode;
    function GerarEnderecoEvento: TACBrXmlNode;
    function GerarEnderecoExteriorEvento: TACBrXmlNode;
    function GerarExploracaoRodoviaria: TACBrXmlNode;
    function GerarInformacoesComplementares: TACBrXmlNode;

    function GerarValores: TACBrXmlNode;

    function GerarServicoPrestado: TACBrXmlNode;
    function GerarDescontos: TACBrXmlNode;
    function GerarDeducoes: TACBrXmlNode;
    function GerarDocDeducoes: TACBrXmlNode;
    function GerarListaDocDeducoes: TACBrXmlNodeArray;
    function GerarNFSeMunicipio(Item: Integer): TACBrXmlNode;
    function GerarNFNFS(Item: Integer): TACBrXmlNode;

    function GerarFornecedor(Item: Integer): TACBrXmlNode;
    function GerarEnderecoFornecedor(Item: Integer): TACBrXmlNode;
    function GerarEnderecoNacionalFornecedor(Item: Integer): TACBrXmlNode;
    function GerarEnderecoExteriorFornecedor(Item: Integer): TACBrXmlNode;

    function GerarTributacao: TACBrXmlNode;
    function GerarTributacaoMunicipal: TACBrXmlNode;
    function GerarBeneficioMunicipal: TACBrXmlNode;
    function GerarExigibilidadeSuspensa: TACBrXmlNode;
    function GerarTributacaoFederal: TACBrXmlNode;
    function GerarTributacaoOutrosPisCofins: TACBrXmlNode;
    function GerarTotalTributos: TACBrXmlNode;
    function GerarValorTotalTributos: TACBrXmlNode;
    function GerarPercentualTotalTributos: TACBrXmlNode;

    // Reforma Tribut�ria
    function GerarIBSCBS(IBSCBS: TIBSCBSDPS): TACBrXmlNode;
    function GerarDestinatario(Dest: TDadosdaPessoa): TACBrXmlNode;
    function GerarEnderecoDestinatario(ender: Tender): TACBrXmlNode;
    function GerarEnderecoNacionalDestinatario(endNac: TendNac): TACBrXmlNode;
    function GerarEnderecoExteriorDestinatario(endExt: TendExt): TACBrXmlNode;

    function GerarAdquirente(Adq: TDadosdaPessoa): TACBrXmlNode;
    function GerarEnderecoAdquirente(ender: Tender): TACBrXmlNode;
    function GerarEnderecoNacionalAdquirente(endNac: TendNac): TACBrXmlNode;
    function GerarEnderecoExteriorAdquirente(endExt: TendExt): TACBrXmlNode;

    function GerarIBSCBSServico(serv: Tserv): TACBrXmlNode;
    function GerargCompraGov(gCompraGov: TgCompraGov): TACBrXmlNode;

    function GerarIBSCBSValores(valores: Tvalorestrib): TACBrXmlNode;
    function GerarTributos(trib: Ttrib): TACBrXmlNode;

    function GerargIBSCBS(gIBSCBS: TgIBSCBS): TACBrXmlNode;
    function GerargIBSCredPres(gIBSCredPres: TgIBSCredPres): TACBrXmlNode;

    function GerargIBSUF(gIBSUF: TgIBSUFValores): TACBrXmlNode;
    function GerargDifUF(gIBSUF: TgIBSUFValores): TACBrXmlNode;
    function GerargDevTribUF(gIBSUF: TgIBSUFValores): TACBrXmlNode;
    function GerargDesonUF(gIBSUF: TgIBSUFValores): TACBrXmlNode;

    function GerargIBSMun(gIBSMun: TgIBSMunValores): TACBrXmlNode;
    function GerargDifMun(gIBSMun: TgIBSMunValores): TACBrXmlNode;
    function GerargDevTribMun(gIBSMun: TgIBSMunValores): TACBrXmlNode;
    function GerargDesonMun(gIBSMun: TgIBSMunValores): TACBrXmlNode;

    function GerargCBS(gCBS: TgCBSValores): TACBrXmlNode;
    function GerargCBSCredPres(gCBS: TgCBSValores): TACBrXmlNode;
    function GerargDifCBS(gCBS: TgCBSValores): TACBrXmlNode;
    function GerargDevTribCBS(gCBS: TgCBSValores): TACBrXmlNode;
    function GerargDesonCBS(gCBS: TgCBSValores): TACBrXmlNode;

    //====== Gerar o Arquivo INI=========================================
    procedure GerarINISecaoIdentificacaoNFSe(const AINIRec: TMemIniFile);
    {
    procedure GerarINIIdentificacaoNFSe(AINIRec: TMemIniFile);
    procedure GerarINIIdentificacaoPrestador(AINIRec: TMemIniFile);
    procedure GerarINIIdentificacaoRps(AINIRec: TMemIniFile);
    procedure GerarINIDadosTomador(AINIRec: TMemIniFile);
    procedure GerarINIDadosIntermediario(AINIRec: TMemIniFile);
    procedure GerarINIConstrucaoCivil(AINIRec: TMemIniFile);
    procedure GerarINIDadosServico(AINIRec: TMemIniFile);
    procedure GerarINIDadosValores(AINIRec: TMemIniFile);
    procedure GerarINIListaServico(AINIRec: TMemIniFile);
    }
    procedure GerarIniRps(AINIRec: TMemIniFile);
    procedure GerarIniNfse(AINIRec: TMemIniFile);
  public
    function GerarXml: Boolean; override;
    function GerarIni: string; override;
  end;

implementation

uses
  ACBrUtil.DateTime,
  ACBrUtil.Strings,
  ACBrNFSeXConsts,
  ACBrDFe.Conversao,
  ACBrNFSeXConversao;

//==============================================================================
// Essa unit tem por finalidade exclusiva gerar o XML do RPS do provedor:
//     PadraoNacional
//==============================================================================

{ TNFSeW_PadraoNacional }

function TNFSeW_PadraoNacional.GerarChaveDPS(const AcMun, ACNPJCPF, ASerie,
  ANumero: string): string;
var
  cMun, vSerie, vNumero, vCNPJ, tpInsc: string;
begin
  {
  A regra de forma��o do identificador de 45 posi��es da DPS �:
  "DPS" + C�d.Mun (7) + Tipo de Inscri��o Federal (1) +
  Inscri��o Federal (14 - CPF completar com 000 � esquerda) + S�rie DPS (5)+
  N�m. DPS (15)
  }
  cMun  := Poem_Zeros(AcMun, 7);
  vCNPJ := OnlyNumber(ACNPJCPF);

  if Length(vCNPJ) = 11 then
    tpInsc := '1'
  else
    tpInsc := '2';

  vCNPJ   := PadLeft(vCNPJ, 14, '0');
  vSerie  := Poem_Zeros(ASerie, 5);
  vNumero := Poem_Zeros(ANumero, 15);

  Result := cMun + tpInsc + vCNPJ + vSerie + vNumero;
end;

function TNFSeW_PadraoNacional.GerarInfDps: TACBrXmlNode;
begin
  Result := CreateElement('infDPS');

  if (FpAOwner.ConfigGeral.Identificador <> '') then
    Result.SetAttribute(FpAOwner.ConfigGeral.Identificador, NFSe.infID.ID);

  Result.AppendChild(AddNode(tcStr, '#1', 'tpAmb', 1, 1, 1,
                                              TipoAmbienteToStr(Ambiente), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'dhEmi', 25, 25, 1,
               DateTimeTodh(NFSe.DataEmissao) +
               GetUTC(NFSe.Prestador.Endereco.UF, NFSe.DataEmissao), DSC_DEMI));

  Result.AppendChild(AddNode(tcStr, '#1', 'verAplic', 1, 20, 1,
                                                            NFSe.verAplic, ''));

  Result.AppendChild(AddNode(tcInt, '#1', 'serie', 1, 5, 1,
                              StrToIntDef(NFSe.IdentificacaoRps.Serie, 0), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'nDPS', 15, 15, 1,
                                             NFSe.IdentificacaoRps.Numero, ''));

  Result.AppendChild(AddNode(tcDat, '#1', 'dCompet', 10, 10, 1,
                                                         NFSe.Competencia, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'tpEmit', 1, 1, 1,
                                                 tpEmitToStr(NFSe.tpEmit), ''));

  case NFSe.tpEmit of
    teTomador:
      Result.AppendChild(AddNode(tcStr, '#1', 'cLocEmi', 7, 7, 1,
                                    NFSe.Tomador.Endereco.CodigoMunicipio, ''));
    teIntermediario:
      Result.AppendChild(AddNode(tcStr, '#1', 'cLocEmi', 7, 7, 1,
                              NFSe.Intermediario.Endereco.CodigoMunicipio, ''));
  else
    Result.AppendChild(AddNode(tcStr, '#1', 'cLocEmi', 7, 7, 1,
                                  NFSe.Prestador.Endereco.CodigoMunicipio, ''));
  end;

  Result.AppendChild(GerarSubstituicao);
  Result.AppendChild(GerarPrestador);
  Result.AppendChild(GerarTomador);
  Result.AppendChild(GerarIntermediario);
  Result.AppendChild(GerarServico);
  Result.AppendChild(GerarValores);

  // Reforma Tribut�ria
  if (NFSe.IBSCBS.dest.xNome <> '') or (NFSe.IBSCBS.adq.xNome <> '') or
     (NFSe.IBSCBS.valores.trib.gIBSCBS.gIBSCredPres.pCredPresIBS > 0) then
    Result.AppendChild(GerarIBSCBS(NFSe.IBSCBS));
end;

function TNFSeW_PadraoNacional.GerarSubstituicao: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.subst.chSubstda <> '' then
  begin
    Result := CreateElement('subst');

    Result.AppendChild(AddNode(tcStr, '#1', 'chSubstda', 1, 50, 1,
                                                     NFSe.subst.chSubstda, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'cMotivo', 2, 2, 1,
                                         cMotivoToStr(NFSe.subst.cMotivo), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xMotivo', 15, 255, 0,
                                                       NFSe.subst.xMotivo, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarPrestador: TACBrXmlNode;
begin
  Result := CreateElement('prest');

  if NFSe.Prestador.IdentificacaoPrestador.CpfCnpj <> '' then
    Result.AppendChild(AddNodeCNPJCPF('#1', '#1',
                                 NFSe.Prestador.IdentificacaoPrestador.CpfCnpj))
  else
  begin
    if NFSe.Prestador.IdentificacaoPrestador.Nif <> '' then
      Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1,
                                 NFSe.Prestador.IdentificacaoPrestador.Nif, ''))
    else
      Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
               NaoNIFToStr(NFSe.Prestador.IdentificacaoPrestador.cNaoNIF), ''));
  end;

  Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0,
                              NFSe.Prestador.IdentificacaoPrestador.CAEPF, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'IM', 1, 15, 0,
                 NFSe.Prestador.IdentificacaoPrestador.InscricaoMunicipal, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 0,
                                               NFSe.Prestador.RazaoSocial, ''));

  if NFSe.tpEmit <> tePrestador then
    Result.AppendChild(GerarEnderecoPrestador);

  Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0,
                                          NFSe.Prestador.Contato.Telefone, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0,
                                             NFSe.Prestador.Contato.Email, ''));

  Result.AppendChild(GerarRegimeTributacaoPrestador);
end;

function TNFSeW_PadraoNacional.GerarEnderecoPrestador: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Prestador.Endereco.Endereco <> '' then
  begin
    Result := CreateElement('end');

    if (NFSe.Prestador.Endereco.CodigoMunicipio <> '') then
      Result.AppendChild(GerarEnderecoNacionalPrestador)
    else
      Result.AppendChild(GerarEnderecoExteriorPrestador);

    Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1,
                                         NFSe.Prestador.Endereco.Endereco, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1,
                                           NFSe.Prestador.Endereco.Numero, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0,
                                      NFSe.Prestador.Endereco.Complemento, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                           NFSe.Prestador.Endereco.Bairro, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalPrestador: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Prestador.Endereco.CEP <> '' then
  begin
    Result := CreateElement('endNac');

    Result.AppendChild(AddNode(tcStr, '#1', 'cMun', 7, 7, 1,
                                  NFSe.Prestador.Endereco.CodigoMunicipio, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1,
                                              NFSe.Prestador.Endereco.CEP, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorPrestador: TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
               CodIBGEPaisToSiglaISO2(NFSe.Prestador.Endereco.CodigoPais), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                              NFSe.Prestador.Endereco.CEP, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                       NFSe.Prestador.Endereco.xMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                               NFSe.Prestador.Endereco.UF, ''));
end;

function TNFSeW_PadraoNacional.GerarRegimeTributacaoPrestador: TACBrXmlNode;
begin
  Result := CreateElement('regTrib');

  Result.AppendChild(AddNode(tcStr, '#1', 'opSimpNac', 1, 1, 1,
                                  OptanteSNToStr(NFSe.OptanteSN), DSC_INDOPSN));

  if NFSe.OptanteSN = osnOptanteMEEPP then
    Result.AppendChild(AddNode(tcStr, '#1', 'regApTribSN', 1, 1, 1,
                             RegimeApuracaoSNToStr(NFSe.RegimeApuracaoSN), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'regEspTrib', 1, 1, 1,
   FpAOwner.RegimeEspecialTributacaoToStr(NFSe.RegimeEspecialTributacao), DSC_REGISSQN));
end;

function TNFSeW_PadraoNacional.GerarTomador: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Tomador.RazaoSocial <> '' then
  begin
    Result := CreateElement('toma');

    if NFSe.Tomador.IdentificacaoTomador.CpfCnpj <> '' then
      Result.AppendChild(AddNodeCNPJCPF('#1', '#1',
                                     NFSe.Tomador.IdentificacaoTomador.CpfCnpj))
    else
    if NFSe.Tomador.IdentificacaoTomador.Nif <> '' then
      Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1,
                                     NFSe.Tomador.IdentificacaoTomador.Nif, ''))
    else
      Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
                   NaoNIFToStr(NFSe.Tomador.IdentificacaoTomador.cNaoNIF), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0,
                                  NFSe.Tomador.IdentificacaoTomador.CAEPF, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'IM', 1, 15, 0,
                     NFSe.Tomador.IdentificacaoTomador.InscricaoMunicipal, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 1,
                                                 NFSe.Tomador.RazaoSocial, ''));

    Result.AppendChild(GerarEnderecoTomador);

    Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0,
                                            NFSe.Tomador.Contato.Telefone, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0,
                                               NFSe.Tomador.Contato.Email, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoTomador: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Tomador.Endereco.CodigoMunicipio <> '') or
     (NFSe.Tomador.Endereco.CodigoPais <> 0) then
  begin
    Result := CreateElement('end');

    if (NFSe.Tomador.Endereco.CodigoMunicipio <> '') then
      Result.AppendChild(GerarEnderecoNacionalTomador)
    else
      Result.AppendChild(GerarEnderecoExteriorTomador);

    Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1,
                                           NFSe.Tomador.Endereco.Endereco, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1,
                                             NFSe.Tomador.Endereco.Numero, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0,
                                        NFSe.Tomador.Endereco.Complemento, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                             NFSe.Tomador.Endereco.Bairro, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalTomador: TACBrXmlNode;
begin
  Result := CreateElement('endNac');

  Result.AppendChild(AddNode(tcStr, '#1', 'cMun', 7, 7, 1,
                                    NFSe.Tomador.Endereco.CodigoMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1,
                                                NFSe.Tomador.Endereco.CEP, ''));
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorTomador: TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
                 CodIBGEPaisToSiglaISO2(NFSe.Tomador.Endereco.CodigoPais), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                                NFSe.Tomador.Endereco.CEP, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                         NFSe.Tomador.Endereco.xMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                                 NFSe.Tomador.Endereco.UF, ''));
end;

function TNFSeW_PadraoNacional.GerarIntermediario: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Intermediario.RazaoSocial <> '' then
  begin
    Result := CreateElement('interm');

    if NFSe.Intermediario.Identificacao.CpfCnpj <> '' then
      Result.AppendChild(AddNodeCNPJCPF('#1', '#1',
                                      NFSe.Intermediario.Identificacao.CpfCnpj))
    else
    if NFSe.Intermediario.Identificacao.Nif <> '' then
      Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1,
                                      NFSe.Intermediario.Identificacao.Nif, ''))
    else
      Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
                    NaoNIFToStr(NFSe.Intermediario.Identificacao.cNaoNIF), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0,
                                   NFSe.Intermediario.Identificacao.CAEPF, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'IM', 1, 15, 0,
                      NFSe.Intermediario.Identificacao.InscricaoMunicipal, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 1,
                                           NFSe.Intermediario.RazaoSocial, ''));

    Result.AppendChild(GerarEnderecoIntermediario);

    Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0,
                                      NFSe.Intermediario.Contato.Telefone, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0,
                                         NFSe.Intermediario.Contato.Email, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoIntermediario: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Intermediario.Endereco.CodigoMunicipio <> '') or
     (NFSe.Intermediario.Endereco.CodigoPais <> 0) then
  begin
    Result := CreateElement('end');

    if (NFSe.Intermediario.Endereco.CodigoMunicipio <> '') then
      Result.AppendChild(GerarEnderecoNacionalIntermediario)
    else
      Result.AppendChild(GerarEnderecoExteriorIntermediario);

    Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1,
                                     NFSe.Intermediario.Endereco.Endereco, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1,
                                       NFSe.Intermediario.Endereco.Numero, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0,
                                  NFSe.Intermediario.Endereco.Complemento, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                       NFSe.Intermediario.Endereco.Bairro, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalIntermediario: TACBrXmlNode;
begin
  Result := CreateElement('endNac');

  Result.AppendChild(AddNode(tcStr, '#1', 'cMun', 7, 7, 1,
                              NFSe.Intermediario.Endereco.CodigoMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1,
                                          NFSe.Intermediario.Endereco.CEP, ''));
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorIntermediario: TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
           CodIBGEPaisToSiglaISO2(NFSe.Intermediario.Endereco.CodigoPais), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                          NFSe.Intermediario.Endereco.CEP, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                   NFSe.Intermediario.Endereco.xMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                           NFSe.Intermediario.Endereco.UF, ''));
end;

function TNFSeW_PadraoNacional.GerarServico: TACBrXmlNode;
begin
  Result := CreateElement('serv');

  Result.AppendChild(GerarLocalPrestacao);
  Result.AppendChild(GerarCodigoServico);
  Result.AppendChild(GerarComercioExterior);
  Result.AppendChild(GerarLocacaoSubLocacao);
  Result.AppendChild(GerarObra);
  Result.AppendChild(GerarAtividadeEvento);
  Result.AppendChild(GerarExploracaoRodoviaria);
  Result.AppendChild(GerarInformacoesComplementares);
end;

function TNFSeW_PadraoNacional.GerarLocalPrestacao: TACBrXmlNode;
begin
  Result := CreateElement('locPrest');

  Result.AppendChild(AddNode(tcStr, '#1', 'cLocPrestacao', 7, 7, 0,
                                             NFSe.Servico.CodigoMunicipio, ''));

  if (NFSe.Servico.CodigoPais <> 0) and (NFSe.Servico.CodigoPais <> 1058) then
    Result.AppendChild(AddNode(tcStr, '#1', 'cPaisPrestacao', 2, 2, 0,
                          CodIBGEPaisToSiglaISO2(NFSe.Servico.CodigoPais), ''));
end;

function TNFSeW_PadraoNacional.GerarCodigoServico: TACBrXmlNode;
begin
  Result := CreateElement('cServ');

  Result.AppendChild(AddNode(tcStr, '#1', 'cTribNac', 6, 6, 1,
                                            NFSe.Servico.ItemListaServico, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cTribMun', 3, 3, 0,
                                   NFSe.Servico.CodigoTributacaoMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xDescServ', 1, 2000, 1,
                                               NFSe.Servico.Discriminacao, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cNBS', 9, 9, 0,
                                                   NFSe.Servico.CodigoNBS, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cIntContrib', 1, 20, 0,
                                            NFSe.Servico.CodigoInterContr, ''));
end;

function TNFSeW_PadraoNacional.GerarComercioExterior: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.comExt.vServMoeda > 0 then
  begin
    Result := CreateElement('comExt');

    Result.AppendChild(AddNode(tcStr, '#1', 'mdPrestacao', 1, 1, 1,
                        mdPrestacaoToStr(NFSe.Servico.comExt.mdPrestacao), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'vincPrest', 1, 1, 1,
                            vincPrestToStr(NFSe.Servico.comExt.vincPrest), ''));

    Result.AppendChild(AddNode(tcInt, '#1', 'tpMoeda', 3, 3, 1,
                                              NFSe.Servico.comExt.tpMoeda, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vServMoeda', 1, 15, 1,
                                           NFSe.Servico.comExt.vServMoeda, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'mecAFComexP', 2, 2, 1,
                        mecAFComexPToStr(NFSe.Servico.comExt.mecAFComexP), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'mecAFComexT', 2, 2, 1,
                        mecAFComexTToStr(NFSe.Servico.comExt.mecAFComexT), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'movTempBens', 1, 1, 1,
                        movTempBensToStr(NFSe.Servico.comExt.movTempBens), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nDI', 1, 12, 0,
                                                  NFSe.Servico.comExt.nDI, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nRE', 1, 12, 0,
                                                  NFSe.Servico.comExt.nRE, ''));

    Result.AppendChild(AddNode(tcInt, '#1', 'mdic', 1, 1, 1,
                                                 NFSe.Servico.comExt.mdic, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarLocacaoSubLocacao: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.Locacao.extensao <> '' then
  begin
    Result := CreateElement('lsadppu');

    Result.AppendChild(AddNode(tcStr, '#1', 'categ', 1, 1, 1,
                                   categToStr(NFSe.Servico.Locacao.categ), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'objeto', 1, 1, 1,
                                 objetoToStr(NFSe.Servico.Locacao.objeto), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'extensao', 1, 5, 1,
                                            NFSe.Servico.Locacao.extensao, ''));

    Result.AppendChild(AddNode(tcInt, '#1', 'nPostes', 1, 6, 1,
                                             NFSe.Servico.Locacao.nPostes, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarObra: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.ConstrucaoCivil.CodigoObra <> '' then
  begin
    Result := CreateElement('obra');
    Result.AppendChild(AddNode(tcStr, '#1', 'cObra', 1, 30, 1,
                                          NFSe.ConstrucaoCivil.CodigoObra, ''));
    exit;
  end;

  if NFSe.ConstrucaoCivil.inscImobFisc <> '' then
  begin
    Result := CreateElement('obra');
    Result.AppendChild(AddNode(tcStr, '#1', 'inscImobFisc', 1, 30, 1,
                                        NFSe.ConstrucaoCivil.inscImobFisc, ''));
    exit;
  end;

  if (NFSe.ConstrucaoCivil.Endereco.CEP <> '') or
     (NFSe.ConstrucaoCivil.Endereco.Endereco <> '') then
  begin
    Result := CreateElement('obra');
    Result.AppendChild(GerarEnderecoObra);
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoObra: TACBrXmlNode;
begin
  Result := CreateElement('end');

  if (NFSe.ConstrucaoCivil.Endereco.UF = '') then
    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1,
                                         NFSe.ConstrucaoCivil.Endereco.CEP, ''))
  else
    Result.AppendChild(GerarEnderecoExteriorObra);

  Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1,
                                   NFSe.ConstrucaoCivil.Endereco.Endereco, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1,
                                     NFSe.ConstrucaoCivil.Endereco.Numero, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0,
                                NFSe.ConstrucaoCivil.Endereco.Complemento, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                     NFSe.ConstrucaoCivil.Endereco.Bairro, ''));
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorObra: TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                        NFSe.ConstrucaoCivil.Endereco.CEP, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                 NFSe.ConstrucaoCivil.Endereco.xMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                         NFSe.ConstrucaoCivil.Endereco.UF, ''));
end;

function TNFSeW_PadraoNacional.GerarAtividadeEvento: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.Evento.xNome <> '' then
  begin
    Result := CreateElement('atvEvento');

    Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 255, 1,
                                                NFSe.Servico.Evento.xNome, ''));

    Result.AppendChild(AddNode(tcDat, '#1', 'dtIni', 10, 10, 1,
                                                NFSe.Servico.Evento.dtIni, ''));

    Result.AppendChild(AddNode(tcDat, '#1', 'dtFim', 10, 10, 1,
                                                NFSe.Servico.Evento.dtFim, ''));

    if NFSe.Servico.Evento.idAtvEvt <> '' then
      Result.AppendChild(AddNode(tcStr, '#1', 'idAtvEvt', 1, 30, 1,
                                              NFSe.Servico.Evento.idAtvEvt, ''))
    else
      Result.AppendChild(GerarEnderecoEvento);
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoEvento: TACBrXmlNode;
begin
  Result := CreateElement('end');

  if (NFSe.Servico.Evento.Endereco.UF = '') then
    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1,
                                          NFSe.Servico.Evento.Endereco.CEP, ''))
  else
    Result.AppendChild(GerarEnderecoExteriorEvento);

  Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1,
                                    NFSe.Servico.Evento.Endereco.Endereco, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1,
                                      NFSe.Servico.Evento.Endereco.Numero, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0,
                                 NFSe.Servico.Evento.Endereco.Complemento, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                      NFSe.Servico.Evento.Endereco.Bairro, ''));
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorEvento: TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                         NFSe.Servico.Evento.Endereco.CEP, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                  NFSe.Servico.Evento.Endereco.xMunicipio, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                          NFSe.Servico.Evento.Endereco.UF, ''));
end;

function TNFSeW_PadraoNacional.GerarExploracaoRodoviaria: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.explRod.nEixos > 0 then
  begin
    Result := CreateElement('explRod');

    Result.AppendChild(AddNode(tcStr, '#1', 'categVeic', 2, 2, 1,
                           categVeicToStr(NFSe.Servico.explRod.categVeic), ''));

    Result.AppendChild(AddNode(tcInt, '#1', 'nEixos', 1, 2, 1,
                                              NFSe.Servico.explRod.nEixos, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'rodagem', 1, 1, 1,
                               rodagemToStr(NFSe.Servico.explRod.rodagem), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'sentido', 1, 3, 1,
                                             NFSe.Servico.explRod.sentido, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'placa', 7, 7, 1,
                                               NFSe.Servico.explRod.placa, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'codAcessoPed', 10, 10, 1,
                                        NFSe.Servico.explRod.codAcessoPed, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'codContrato', 4, 4, 1,
                                         NFSe.Servico.explRod.codContrato, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarInformacoesComplementares: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Servico.infoCompl.idDocTec <> '') or
     (NFSe.Servico.infoCompl.docRef <> '') or
     (NFSe.Servico.infoCompl.xInfComp <> '') then
  begin
    Result := CreateElement('infoCompl');

    Result.AppendChild(AddNode(tcStr, '#1', 'idDocTec', 1, 40, 0,
                                          NFSe.Servico.infoCompl.idDocTec, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'docRef', 1, 255, 0,
                                            NFSe.Servico.infoCompl.docRef, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xInfComp', 1, 2000, 0,
                                          NFSe.Servico.infoCompl.xInfComp, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarValores: TACBrXmlNode;
begin
  Result := CreateElement('valores');

  Result.AppendChild(GerarServicoPrestado);
  Result.AppendChild(GerarDescontos);
  Result.AppendChild(GerarDeducoes);
  Result.AppendChild(GerarTributacao);
end;

function TNFSeW_PadraoNacional.GerarServicoPrestado: TACBrXmlNode;
begin
  Result := CreateElement('vServPrest');

  Result.AppendChild(AddNode(tcDe2, '#1', 'vReceb', 1, 15, 0,
                                       NFSe.Servico.Valores.ValorRecebido, ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'vServ', 1, 15, 0,
                                       NFSe.Servico.Valores.ValorServicos, ''));
end;

function TNFSeW_PadraoNacional.GerarDescontos: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Servico.Valores.DescontoIncondicionado > 0) or
     (NFSe.Servico.Valores.DescontoCondicionado > 0) then
  begin
    Result := CreateElement('vDescCondIncond');

    Result.AppendChild(AddNode(tcDe2, '#1', 'vDescIncond', 1, 15, 0,
                              NFSe.Servico.Valores.DescontoIncondicionado, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vDescCond', 1, 15, 0,
                                NFSe.Servico.Valores.DescontoCondicionado, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarDeducoes: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Servico.Valores.AliquotaDeducoes > 0) then
  begin
    Result := CreateElement('vDedRed');
    Result.AppendChild(AddNode(tcDe2, '#1', 'pDR', 1, 5, 1,
                                    NFSe.Servico.Valores.AliquotaDeducoes, ''));
    exit;
  end;

  if (NFSe.Servico.Valores.ValorDeducoes > 0) then
  begin
    Result := CreateElement('vDedRed');
    Result.AppendChild(AddNode(tcDe2, '#1', 'vDR', 1, 15, 1,
                                       NFSe.Servico.Valores.ValorDeducoes, ''));
    exit;
  end;

  if (NFSe.Servico.Valores.DocDeducao.Count > 0) then
  begin
    Result := CreateElement('vDedRed');
    Result.AppendChild(GerarDocDeducoes);
  end;
end;

function TNFSeW_PadraoNacional.GerarDocDeducoes: TACBrXmlNode;
var
  nodeArray: TACBrXmlNodeArray;
  i: Integer;
begin
  Result := CreateElement('documentos');

  nodeArray := GerarListaDocDeducoes;

  if nodeArray <> nil then
  begin
    for i := 0 to Length(nodeArray) - 1 do
    begin
      Result.AppendChild(nodeArray[i]);
    end;
  end;
end;

function TNFSeW_PadraoNacional.GerarListaDocDeducoes: TACBrXmlNodeArray;
var
  i: integer;
begin
  Result := nil;
  SetLength(Result, NFSe.Servico.Valores.DocDeducao.Count);

  for i := 0 to NFSe.Servico.Valores.DocDeducao.Count - 1 do
  begin
    Result[i] := CreateElement('docDedRed');

    if NFSe.Servico.Valores.DocDeducao.Items[i].chNFSe <> '' then
      Result[i].AppendChild(AddNode(tcStr, '#1', 'chNFSe', 50, 50, 1,
                           NFSe.Servico.Valores.DocDeducao.Items[i].chNFSe, ''))
    else
    begin
      if NFSe.Servico.Valores.DocDeducao.Items[i].chNFe <> '' then
        Result[i].AppendChild(AddNode(tcStr, '#1', 'chNFe', 44, 44, 1,
                            NFSe.Servico.Valores.DocDeducao.Items[i].chNFe, ''))
      else
      begin
        if NFSe.Servico.Valores.DocDeducao.Items[i].NFSeMun.cMunNFSeMun <> '' then
          Result[i].AppendChild(GerarNFSeMunicipio(i))
        else
        begin
          if NFSe.Servico.Valores.DocDeducao.Items[i].NFNFS.nNFS <> '' then
            Result[i].AppendChild(GerarNFNFS(i))
          else
          begin
            if NFSe.Servico.Valores.DocDeducao.Items[i].nDocFisc <> '' then
              Result[i].AppendChild(AddNode(tcStr, '#1', 'nDocFisc', 1, 255, 1,
                         NFSe.Servico.Valores.DocDeducao.Items[i].nDocFisc, ''))
            else
              Result[i].AppendChild(AddNode(tcStr, '#1', 'nDoc', 1, 255, 0,
                            NFSe.Servico.Valores.DocDeducao.Items[i].nDoc, ''));
          end;
        end;
      end;
    end;

    Result[i].AppendChild(AddNode(tcStr, '#1', 'tpDedRed', 1, 2, 1,
         tpDedRedToStr(NFSe.Servico.Valores.DocDeducao.Items[i].tpDedRed), ''));

    Result[i].AppendChild(AddNode(tcStr, '#1', 'xDescOutDed', 1, 150, 0,
                     NFSe.Servico.Valores.DocDeducao.Items[i].xDescOutDed, ''));

    Result[i].AppendChild(AddNode(tcDat, '#1', 'dtEmiDoc', 10, 10, 1,
                        NFSe.Servico.Valores.DocDeducao.Items[i].dtEmiDoc, ''));

    Result[i].AppendChild(AddNode(tcDe2, '#1', 'vDedutivelRedutivel', 1, 15, 1,
             NFSe.Servico.Valores.DocDeducao.Items[i].vDedutivelRedutivel, ''));

    Result[i].AppendChild(AddNode(tcDe2, '#1', 'vDeducaoReducao', 1, 15, 1,
                 NFSe.Servico.Valores.DocDeducao.Items[i].vDeducaoReducao, ''));

    Result[i].AppendChild(GerarFornecedor(i))
  end;

  if NFSe.Servico.Valores.DocDeducao.Count > 1000 then
    wAlerta('#1', 'docDedRed', '', ERR_MSG_MAIOR_MAXIMO + '1000');
end;

function TNFSeW_PadraoNacional.GerarNFSeMunicipio(Item: Integer): TACBrXmlNode;
begin
  Result := CreateElement('NFSeMun');

  Result.AppendChild(AddNode(tcStr, '#1', 'cMunNFSeMun', 7, 7, 1,
          NFSe.Servico.Valores.DocDeducao.Items[item].NFSeMun.cMunNFSeMun, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'nNFSeMun', 15, 15, 1,
             NFSe.Servico.Valores.DocDeducao.Items[item].NFSeMun.nNFSeMun, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cVerifNFSeMun', 1, 9, 1,
        NFSe.Servico.Valores.DocDeducao.Items[item].NFSeMun.cVerifNFSeMun, ''));
end;

function TNFSeW_PadraoNacional.GerarNFNFS(Item: Integer): TACBrXmlNode;
begin
  Result := CreateElement('NFNFS');

  Result.AppendChild(AddNode(tcStr, '#1', 'nNFS', 7, 7, 1,
                   NFSe.Servico.Valores.DocDeducao.Items[item].NFNFS.nNFS, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'modNFS', 15, 15, 1,
                 NFSe.Servico.Valores.DocDeducao.Items[item].NFNFS.modNFS, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'serieNFS', 1, 15, 1,
               NFSe.Servico.Valores.DocDeducao.Items[item].NFNFS.serieNFS, ''));
end;

function TNFSeW_PadraoNacional.GerarFornecedor(Item: Integer): TACBrXmlNode;
begin
  Result := nil;

  with NFSe.Servico.Valores.DocDeducao.Items[Item].fornec do
  begin
    if RazaoSocial <> '' then
    begin
      Result := CreateElement('fornec');

      if Identificacao.CpfCnpj <> '' then
        Result.AppendChild(AddNodeCNPJCPF('#1', '#1', Identificacao.CpfCnpj))
      else
      if Identificacao.Nif <> '' then
        Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1,
                                                         Identificacao.Nif, ''))
      else
        Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
                                       NaoNIFToStr(Identificacao.cNaoNIF), ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0,
                                                      Identificacao.CAEPF, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'IM', 1, 15, 0,
                                         Identificacao.InscricaoMunicipal, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 1,
                                                              RazaoSocial, ''));

      Result.AppendChild(GerarEnderecoFornecedor(Item));

      Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0,
                                                         Contato.Telefone, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0,
                                                            Contato.Email, ''));
    end;
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoFornecedor(
  Item: Integer): TACBrXmlNode;
begin
  Result := nil;

  with NFSe.Servico.Valores.DocDeducao.Items[Item].fornec.Endereco do
  begin
    if (CodigoMunicipio <> '') or (CodigoPais <> 0) then
    begin
      Result := CreateElement('end');

      if (CodigoMunicipio <> '') then
        Result.AppendChild(GerarEnderecoNacionalFornecedor(Item))
      else
        Result.AppendChild(GerarEnderecoExteriorFornecedor(Item));

      Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1, Endereco, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1, Numero, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0, Complemento, ''));

      Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1, Bairro, ''));
    end;
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalFornecedor(
  Item: Integer): TACBrXmlNode;
begin
  Result := CreateElement('endNac');

  with NFSe.Servico.Valores.DocDeducao.Items[Item].fornec.Endereco do
  begin
    Result.AppendChild(AddNode(tcStr, '#1', 'cMun', 7, 7, 1, CodigoMunicipio, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1, CEP, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorFornecedor(
  Item: Integer): TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  with NFSe.Servico.Valores.DocDeducao.Items[Item].fornec.Endereco do
  begin
    Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
                                       CodIBGEPaisToSiglaISO2(CodigoPais), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1, CEP, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1, xMunicipio, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1, UF, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarTributacao: TACBrXmlNode;
begin
  Result := CreateElement('trib');

  Result.AppendChild(GerarTributacaoMunicipal);
  Result.AppendChild(GerarTributacaoFederal);
  Result.AppendChild(GerarTotalTributos);
end;

function TNFSeW_PadraoNacional.GerarTributacaoMunicipal: TACBrXmlNode;
begin
  Result := CreateElement('tribMun');

  Result.AppendChild(AddNode(tcStr, '#1', 'tribISSQN', 1, 1, 1,
                   tribISSQNToStr(NFSe.Servico.Valores.tribMun.tribISSQN), ''));

  if NFSe.Servico.Valores.tribMun.cPaisResult > 0 then
    Result.AppendChild(AddNode(tcStr, '#1', 'cPaisResult', 2, 2, 0,
         CodIBGEPaisToSiglaISO2(NFSe.Servico.Valores.tribMun.cPaisResult), ''));

  Result.AppendChild(GerarBeneficioMunicipal);
  Result.AppendChild(GerarExigibilidadeSuspensa);

  if NFSe.Servico.Valores.tribMun.tribISSQN = tiImunidade then
    Result.AppendChild(AddNode(tcStr, '#1', 'tpImunidade', 1, 1, 0,
               tpImunidadeToStr(NFSe.Servico.Valores.tribMun.tpImunidade), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pAliq', 1, 3, 0,
                                       NFSe.Servico.Valores.tribMun.pAliq, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'tpRetISSQN', 2, 2, 1,
                 tpRetISSQNToStr(NFSe.Servico.Valores.tribMun.tpRetISSQN), ''));
end;

function TNFSeW_PadraoNacional.GerarBeneficioMunicipal: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.Valores.tribMun.nBM <> '' then
  begin
    Result := CreateElement('BM');

    Result.AppendChild(AddNode(tcStr, '#1', 'tpBM', 1, 1, 1,
                             tpBMToStr(NFSe.Servico.Valores.tribMun.tpBM), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nBM', 14, 14, 1,
                                         NFSe.Servico.Valores.tribMun.nBM, ''));

    if NFSe.Servico.Valores.tribMun.vRedBCBM > 0 then
      Result.AppendChild(AddNode(tcDe2, '#1', 'vRedBCBM', 1, 15, 1,
                                     NFSe.Servico.Valores.tribMun.vRedBCBM, ''))
    else
      Result.AppendChild(AddNode(tcDe2, '#1', 'pRedBCBM', 1, 5, 1,
                                    NFSe.Servico.Valores.tribMun.pRedBCBM, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarExigibilidadeSuspensa: TACBrXmlNode;
begin
  Result := nil;

  if NFSe.Servico.Valores.tribMun.nProcesso <> '' then
  begin
    Result := CreateElement('exigSusp');

    Result.AppendChild(AddNode(tcStr, '#1', 'tpSusp', 1, 1, 1,
                         tpSuspToStr(NFSe.Servico.Valores.tribMun.tpSusp), ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nProcesso', 30, 30, 1,
                                   NFSe.Servico.Valores.tribMun.nProcesso, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarTributacaoFederal: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Servico.Valores.tribFed.vRetCP > 0) or
     (NFSe.Servico.Valores.tribFed.vRetIRRF > 0) or
     (NFSe.Servico.Valores.tribFed.vRetCSLL > 0) or
     (NFSe.Servico.Valores.tribFed.vBCPisCofins > 0) or
     (NFSe.Servico.Valores.tribFed.pAliqPis > 0) or
     (NFSe.Servico.Valores.tribFed.pAliqCofins > 0) or
     (NFSe.Servico.Valores.tribFed.vPis > 0) or
     (NFSe.Servico.Valores.tribFed.vCofins > 0) then
  begin
    Result := CreateElement('tribFed');

    Result.AppendChild(GerarTributacaoOutrosPisCofins);

    Result.AppendChild(AddNode(tcDe2, '#1', 'vRetCP', 1, 15, 0,
                                      NFSe.Servico.Valores.tribFed.vRetCP, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vRetIRRF', 1, 15, 0,
                                    NFSe.Servico.Valores.tribFed.vRetIRRF, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vRetCSLL', 1, 15, 0,
                                    NFSe.Servico.Valores.tribFed.vRetCSLL, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarTributacaoOutrosPisCofins: TACBrXmlNode;
begin
  Result := nil;

  if (NFSe.Servico.Valores.tribFed.vBCPisCofins > 0) or
     (NFSe.Servico.Valores.tribFed.pAliqPis > 0) or
     (NFSe.Servico.Valores.tribFed.pAliqCofins > 0) or
     (NFSe.Servico.Valores.tribFed.vPis > 0) or
     (NFSe.Servico.Valores.tribFed.vCofins > 0) then
  begin
    Result := CreateElement('piscofins');

    Result.AppendChild(AddNode(tcStr, '#1', 'CST', 2, 2, 1,
                               CSTToStr(NFSe.Servico.Valores.tribFed.CST), ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vBCPisCofins', 1, 15, 0,
                                NFSe.Servico.Valores.tribFed.vBCPisCofins, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'pAliqPis', 1, 5, 0,
                                    NFSe.Servico.Valores.tribFed.pAliqPis, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'pAliqCofins', 1, 5, 0,
                                 NFSe.Servico.Valores.tribFed.pAliqCofins, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vPis', 1, 15, 0,
                                        NFSe.Servico.Valores.tribFed.vPis, ''));

    Result.AppendChild(AddNode(tcDe2, '#1', 'vCofins', 1, 15, 0,
                                     NFSe.Servico.Valores.tribFed.vCofins, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'tpRetPisCofins', 1, 1, 0,
         tpRetPisCofinsToStr(NFSe.Servico.Valores.tribFed.tpRetPisCofins), ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarTotalTributos: TACBrXmlNode;
begin
  Result := CreateElement('totTrib');

  if (NFSe.Servico.Valores.totTrib.vTotTribFed > 0) or
     (NFSe.Servico.Valores.totTrib.vTotTribEst > 0) or
     (NFSe.Servico.Valores.totTrib.vTotTribMun > 0) then
    Result.AppendChild(GerarValorTotalTributos)
  else
  begin
    if (NFSe.Servico.Valores.totTrib.pTotTribFed > 0) or
       (NFSe.Servico.Valores.totTrib.pTotTribEst > 0) or
       (NFSe.Servico.Valores.totTrib.pTotTribMun > 0) then
      Result.AppendChild(GerarPercentualTotalTributos)
    else
    begin
      if NFSe.Servico.Valores.totTrib.indTotTrib <> indSim then
        Result.AppendChild(AddNode(tcStr, '#1', 'indTotTrib', 1, 1, 1,
                  indTotTribToStr(NFSe.Servico.Valores.totTrib.indTotTrib), ''))
      else
        Result.AppendChild(AddNode(tcDe2, '#1', 'pTotTribSN', 1, 5, 1,
                                  NFSe.Servico.Valores.totTrib.pTotTribSN, ''));
    end;
  end;
end;

function TNFSeW_PadraoNacional.GerarValorTotalTributos: TACBrXmlNode;
begin
  Result := CreateElement('vTotTrib');

  Result.AppendChild(AddNode(tcDe2, '#1', 'vTotTribFed', 1, 15, 1,
                                 NFSe.Servico.Valores.totTrib.vTotTribFed, ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'vTotTribEst', 1, 15, 1,
                                 NFSe.Servico.Valores.totTrib.vTotTribEst, ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'vTotTribMun', 1, 15, 1,
                                 NFSe.Servico.Valores.totTrib.vTotTribMun, ''));
end;

function TNFSeW_PadraoNacional.GerarPercentualTotalTributos: TACBrXmlNode;
begin
  Result := CreateElement('pTotTrib');

  Result.AppendChild(AddNode(tcDe2, '#1', 'pTotTribFed', 1, 5, 1,
                                 NFSe.Servico.Valores.totTrib.pTotTribFed, ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pTotTribEst', 1, 5, 1,
                                 NFSe.Servico.Valores.totTrib.pTotTribEst, ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pTotTribMun', 1, 5, 1,
                                 NFSe.Servico.Valores.totTrib.pTotTribMun, ''));
end;

function TNFSeW_PadraoNacional.GerarXml: Boolean;
var
  NFSeNode, xmlNode: TACBrXmlNode;
  chave: string;
begin
  Configuracao;

  ListaDeAlertas.Clear;

  FDocument.Clear();

  FpVersao := VersaoNFSeToStr(VersaoNFSe);

  chave := GerarChaveDPS(NFSe.Prestador.Endereco.CodigoMunicipio,
                         NFSe.Prestador.IdentificacaoPrestador.CpfCnpj,
                         NFSe.IdentificacaoRps.Serie,
                         NFSe.IdentificacaoRps.Numero);

  NFSe.InfID.ID := 'DPS' + chave;

  NFSeNode := CreateElement('DPS');
  NFSeNode.SetAttribute('versao', FpVersao);
  NFSeNode.SetNamespace(FpAOwner.ConfigMsgDados.LoteRps.xmlns, Self.PrefixoPadrao);

  FDocument.Root := NFSeNode;

  xmlNode := GerarInfDps;
  NFSeNode.AppendChild(xmlNode);

  Result := True;
end;

// Reforma Tribut�ria
function TNFSeW_PadraoNacional.GerarIBSCBS(IBSCBS: TIBSCBSDPS): TACBrXmlNode;
begin
  Result := CreateElement('IBSCBS');

  if IBSCBS.dest.xNome <> '' then
    Result.AppendChild(GerarDestinatario(IBSCBS.dest));

  if IBSCBS.adq.xNome <> '' then
    Result.AppendChild(GerarAdquirente(IBSCBS.adq));

  Result.AppendChild(GerarIBSCBSServico(IBSCBS.serv));

  Result.AppendChild(GerarIBSCBSValores(IBSCBS.valores));
end;

function TNFSeW_PadraoNacional.GerarDestinatario(Dest: TDadosdaPessoa): TACBrXmlNode;
begin
  Result := CreateElement('dest');

  if Dest.CNPJCPF <> '' then
    Result.AppendChild(AddNodeCNPJCPF('#1', '#1', Dest.CNPJCPF))
  else
  if Dest.Nif <> '' then
    Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1, Dest.Nif, ''))
  else
    Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
                                                NaoNIFToStr(Dest.cNaoNIF), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0, Dest.CAEPF, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 1, Dest.xNome, ''));

  Result.AppendChild(GerarEnderecoDestinatario(Dest.ender));

  Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0, Dest.fone, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0, Dest.email, ''));
end;

function TNFSeW_PadraoNacional.GerarEnderecoDestinatario(
  ender: Tender): TACBrXmlNode;
begin
  Result := nil;

  if (ender.endNac.cMun <> 0) or (ender.endExt.cPais <> 0) then
  begin
    Result := CreateElement('end');

    if (ender.endNac.cMun <> 0) then
      Result.AppendChild(GerarEnderecoNacionalDestinatario(ender.endNac))
    else
      Result.AppendChild(GerarEnderecoExteriorDestinatario(ender.endExt));

    Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1, ender.xLgr, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1, ender.nro, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0, ender.xCpl, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                                            ender.xBairro, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalDestinatario(
  endNac: TendNac): TACBrXmlNode;
begin
  Result := nil;

  if endNac.CEP <> '' then
  begin
    Result := CreateElement('endNac');

    Result.AppendChild(AddNode(tcInt, '#1', 'cMun', 7, 7, 1, endNac.cMun, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1, endNac.CEP, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorDestinatario(
  endExt: TendExt): TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
                                     CodIBGEPaisToSiglaISO2(endExt.cPais), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                                          endExt.cEndPost, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                                           endExt.xCidade, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                                       endExt.xEstProvReg, ''));
end;

function TNFSeW_PadraoNacional.GerarAdquirente(
  Adq: TDadosdaPessoa): TACBrXmlNode;
begin
  Result := CreateElement('adq');

  if Adq.CNPJCPF <> '' then
    Result.AppendChild(AddNodeCNPJCPF('#1', '#1', Adq.CNPJCPF))
  else
  if Adq.Nif <> '' then
    Result.AppendChild(AddNode(tcStr, '#1', 'NIF', 1, 40, 1, Adq.Nif, ''))
  else
    Result.AppendChild(AddNode(tcStr, '#1', 'cNaoNIF', 1, 1, 1,
                                                NaoNIFToStr(Adq.cNaoNIF), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'CAEPF', 1, 14, 0, Adq.CAEPF, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xNome', 1, 300, 1, Adq.xNome, ''));

  Result.AppendChild(GerarEnderecoAdquirente(Adq.ender));

  Result.AppendChild(AddNode(tcStr, '#1', 'fone', 6, 20, 0, Adq.fone, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'email', 1, 80, 0, Adq.email, ''));

end;

function TNFSeW_PadraoNacional.GerarEnderecoAdquirente(
  ender: Tender): TACBrXmlNode;
begin
  Result := nil;

  if (ender.endNac.cMun <> 0) or (ender.endExt.cPais <> 0) then
  begin
    Result := CreateElement('end');

    if (ender.endNac.cMun <> 0) then
      Result.AppendChild(GerarEnderecoNacionalDestinatario(ender.endNac))
    else
      Result.AppendChild(GerarEnderecoExteriorDestinatario(ender.endExt));

    Result.AppendChild(AddNode(tcStr, '#1', 'xLgr', 1, 255, 1, ender.xLgr, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'nro', 1, 60, 1, ender.nro, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xCpl', 1, 156, 0, ender.xCpl, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'xBairro', 1, 60, 1,
                                                            ender.xBairro, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoNacionalAdquirente(
  endNac: TendNac): TACBrXmlNode;
begin
  Result := nil;

  if endNac.CEP <> '' then
  begin
    Result := CreateElement('endNac');

    Result.AppendChild(AddNode(tcInt, '#1', 'cMun', 7, 7, 1, endNac.cMun, ''));

    Result.AppendChild(AddNode(tcStr, '#1', 'CEP', 8, 8, 1, endNac.CEP, ''));
  end;
end;

function TNFSeW_PadraoNacional.GerarEnderecoExteriorAdquirente(
  endExt: TendExt): TACBrXmlNode;
begin
  Result := CreateElement('endExt');

  Result.AppendChild(AddNode(tcStr, '#1', 'cPais', 2, 2, 1,
                                     CodIBGEPaisToSiglaISO2(endExt.cPais), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cEndPost', 1, 11, 1,
                                                          endExt.cEndPost, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xCidade', 1, 60, 1,
                                                           endExt.xCidade, ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'xEstProvReg', 1, 60, 1,
                                                       endExt.xEstProvReg, ''));
end;

function TNFSeW_PadraoNacional.GerarIBSCBSServico(serv: Tserv): TACBrXmlNode;
begin
  Result := CreateElement('serv');

  Result.AppendChild(AddNode(tcStr, '#1', 'modoPrestServ', 1, 1, 1,
                                   modoPrestServToStr(serv.modoPrestServ), ''));

  if serv.clocalPrestServ > 0 then
    Result.AppendChild(AddNode(tcInt, '#1', 'clocalPrestServ', 7, 7, 1,
                                                      serv.clocalPrestServ, ''))
  else
    Result.AppendChild(AddNode(tcStr, '#1', 'cPaisPrestServ', 2, 2, 1,
                              CodIBGEPaisToSiglaISO2(serv.cPaisPrestServ), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cCIB', 8, 8, 0, serv.cCIB, ''));

  if serv.gCompraGov.indCompGov <> icgNenhum then
    Result.AppendChild(GerargCompraGov(serv.gCompraGov));
end;

function TNFSeW_PadraoNacional.GerargCompraGov(
  gCompraGov: TgCompraGov): TACBrXmlNode;
begin
  Result := CreateElement('gCompraGov');

  Result.AppendChild(AddNode(tcStr, '#1', 'indCompGov', 2, 2, 1,
                                   indCompGovToStr(gCompraGov.indCompGov), ''));
end;

function TNFSeW_PadraoNacional.GerarIBSCBSValores(
  valores: Tvalorestrib): TACBrXmlNode;
begin
  Result := CreateElement('valores');

  Result.AppendChild(GerarTributos(valores.trib));
end;

function TNFSeW_PadraoNacional.GerarTributos(
  trib: Ttrib): TACBrXmlNode;
begin
  Result := CreateElement('trib');

  Result.AppendChild(GerargIBSCBS(trib.gIBSCBS));
end;

function TNFSeW_PadraoNacional.GerargIBSCBS(
  gIBSCBS: TgIBSCBS): TACBrXmlNode;
begin
  Result := CreateElement('gIBSCBS');

  Result.AppendChild(AddNode(tcStr, '#1', 'cstIBSCBS', 3, 3, 1,
                                        CSTIBSCBSToStr(gIBSCBS.cstIBSCBS), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cClassTribIBSCBS', 6, 6, 1,
                                cClassTribToStr(gIBSCBS.cClassTribIBSCBS), ''));

  Result.AppendChild(GerargIBSCredPres(gIBSCBS.gIBSCredPres));
  Result.AppendChild(GerargIBSUF(gIBSCBS.gIBSUF));
  Result.AppendChild(GerargIBSMun(gIBSCBS.gIBSMun));
  Result.AppendChild(GerargCBS(gIBSCBS.gCBS));
end;

function TNFSeW_PadraoNacional.GerargIBSCredPres(
  gIBSCredPres: TgIBSCredPres): TACBrXmlNode;
begin
  Result := CreateElement('gIBSCredPres');

  Result.AppendChild(AddNode(tcStr, '#1', 'cCredPresIBS', 3, 3, 1,
                                cCredPresToStr(gIBSCredPres.cCredPresIBS), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pCredPresIBS', 1, 5, 1,
                                                gIBSCredPres.pCredPresIBS, ''));
end;

function TNFSeW_PadraoNacional.GerargIBSUF(
  gIBSUF: TgIBSUFValores): TACBrXmlNode;
begin
  Result := CreateElement('gIBSUF');

  if gIBSUF.pDifUF > 0 then
    Result.AppendChild(GerargDifUF(gIBSUF));

  if gIBSUF.vDevTribUF > 0 then
    Result.AppendChild(GerargDevTribUF(gIBSUF));

  if gIBSUF.pAliqUFDeson > 0 then
    Result.AppendChild(GerargDesonUF(gIBSUF));
end;

function TNFSeW_PadraoNacional.GerargDifUF(
  gIBSUF: TgIBSUFValores): TACBrXmlNode;
begin
  Result := CreateElement('gDif');

  Result.AppendChild(AddNode(tcDe2, '#1', 'pDifUF', 1, 5, 1,
                                                            gIBSUF.pDifUF, ''));
end;

function TNFSeW_PadraoNacional.GerargDevTribUF(
  gIBSUF: TgIBSUFValores): TACBrXmlNode;
begin
  Result := CreateElement('gDevTrib');

  Result.AppendChild(AddNode(tcDe2, '#1', 'vDevTribUF', 1, 15, 1,
                                                        gIBSUF.vDevTribUF, ''));
end;

function TNFSeW_PadraoNacional.GerargDesonUF(
  gIBSUF: TgIBSUFValores): TACBrXmlNode;
begin
  Result := CreateElement('gDeson');

  Result.AppendChild(AddNode(tcStr, '#1', 'cstUFDeson', 3, 3, 1,
                                        CSTIBSCBSToStr(gIBSUF.cstUFDeson), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cClassTribUFDeson', 6, 6, 1,
                                cClassTribToStr(gIBSUF.cClassTribUFDeson), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pAliqUFDeson', 1, 5, 1,
                                                      gIBSUF.pAliqUFDeson, ''));
end;

function TNFSeW_PadraoNacional.GerargIBSMun(
  gIBSMun: TgIBSMunValores): TACBrXmlNode;
begin
  Result := CreateElement('gIBSMun');

  if gIBSMun.pDifMun > 0 then
    Result.AppendChild(GerargDifMun(gIBSMun));

  if gIBSMun.vDevTribMun > 0 then
    Result.AppendChild(GerargDevTribMun(gIBSMun));

  if gIBSMun.pAliqMunDeson > 0 then
    Result.AppendChild(GerargDesonMun(gIBSMun));
end;

function TNFSeW_PadraoNacional.GerargDifMun(
  gIBSMun: TgIBSMunValores): TACBrXmlNode;
begin
  Result := CreateElement('gDif');

  Result.AppendChild(AddNode(tcDe2, '#1', 'pDifMun', 1, 5, 1,
                                                          gIBSMun.pDifMun, ''));
end;

function TNFSeW_PadraoNacional.GerargDevTribMun(
  gIBSMun: TgIBSMunValores): TACBrXmlNode;
begin
  Result := CreateElement('gDevTrib');

  Result.AppendChild(AddNode(tcDe2, '#1', 'vDevTribMun', 1, 15, 1,
                                                      gIBSMun.vDevTribMun, ''));
end;

function TNFSeW_PadraoNacional.GerargDesonMun(
  gIBSMun: TgIBSMunValores): TACBrXmlNode;
begin
  Result := CreateElement('gDeson');

  Result.AppendChild(AddNode(tcStr, '#1', 'cstMunDeson', 3, 3, 1,
                                      CSTIBSCBSToStr(gIBSMun.cstMunDeson), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cClassTribMunDeson', 6, 6, 1,
                              cClassTribToStr(gIBSMun.cClassTribMunDeson), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pAliqMunDeson', 1, 5, 1,
                                                    gIBSMun.pAliqMunDeson, ''));
end;

function TNFSeW_PadraoNacional.GerargCBS(
  gCBS: TgCBSValores): TACBrXmlNode;
begin
  Result := CreateElement('gCBS');

  if gCBS.pCredPresCBS > 0 then
    Result.AppendChild(GerargCBSCredPres(gCBS));

  if gCBS.pDifCBS > 0 then
    Result.AppendChild(GerargDifCBS(gCBS));

  if gCBS.vDevTribCBS > 0 then
    Result.AppendChild(GerargDevTribCBS(gCBS));

  if gCBS.pAliqCBSDeson > 0 then
    Result.AppendChild(GerargDesonCBS(gCBS));
end;

function TNFSeW_PadraoNacional.GerargCBSCredPres(
  gCBS: TgCBSValores): TACBrXmlNode;
begin
  Result := CreateElement('gCredPres');

  Result.AppendChild(AddNode(tcStr, '#1', 'cCredPresCBS', 2, 2, 1,
                                        cCredPresToStr(gCBS.cCredPresCBS), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pCredPresCBS', 1, 5, 1,
                                                        gCBS.pCredPresCBS, ''));
end;

function TNFSeW_PadraoNacional.GerargDifCBS(
  gCBS: TgCBSValores): TACBrXmlNode;
begin
  Result := CreateElement('gDif');

  Result.AppendChild(AddNode(tcDe2, '#1', 'pDifCBS', 1, 5, 1,
                                                             gCBS.pDifCBS, ''));
end;

function TNFSeW_PadraoNacional.GerargDevTribCBS(
  gCBS: TgCBSValores): TACBrXmlNode;
begin
  Result := CreateElement('gDevTrib');

  Result.AppendChild(AddNode(tcDe2, '#1', 'vDevTribCBS', 1, 15, 1,
                                                         gCBS.vDevTribCBS, ''));
end;

function TNFSeW_PadraoNacional.GerargDesonCBS(
  gCBS: TgCBSValores): TACBrXmlNode;
begin
  Result := CreateElement('gDeson');

  Result.AppendChild(AddNode(tcStr, '#1', 'cstCBSDeson', 3, 3, 1,
                                         CSTIBSCBSToStr(gCBS.cstCBSDeson), ''));

  Result.AppendChild(AddNode(tcStr, '#1', 'cClassTribCBSDeson', 6, 6, 1,
                                 cClassTribToStr(gCBS.cClassTribCBSDeson), ''));

  Result.AppendChild(AddNode(tcDe2, '#1', 'pAliqCBSDeson', 1, 5, 1,
                                                       gCBS.pAliqCBSDeson, ''));
end;

//====== Gerar o Arquivo INI=========================================
function TNFSeW_PadraoNacional.GerarIni: string;
var
  INIRec: TMemIniFile;
  IniNFSe: TStringList;
begin
  Result:= '';
// Usar FpAOwner no lugar de FProvider

  INIRec := TMemIniFile.Create('');
  try
    if NFSe.tpXML = txmlRPS then
      GerarIniRps(INIRec)
    else
      GerarIniNfse(INIRec);
  finally
    IniNFSe := TStringList.Create;
    try
      INIRec.GetStrings(IniNFSe);
      INIRec.Free;

      Result := StringReplace(IniNFSe.Text, sLineBreak + sLineBreak, sLineBreak, [rfReplaceAll]);
    finally
      IniNFSe.Free;
    end;
  end;
end;

procedure TNFSeW_PadraoNacional.GerarINISecaoIdentificacaoNFSe(
  const AINIRec: TMemIniFile);
begin
  LSecao:= 'IdentificacaoNFSe';

  if NFSe.tpXML = txmlRPS then
    AINIRec.WriteString(LSecao, 'TipoXML', 'RPS')
  else
    AINIRec.WriteString(LSecao, 'TipoXML', 'NFSE');

  AINIRec.WriteString(LSecao, 'Numero', NFSe.Numero);
  AINIRec.WriteString(LSecao, 'StatusNFSe', StatusNFSeToStr(NFSe.SituacaoNfse));

  if NFSe.CodigoVerificacao <> '' then
    AINIRec.WriteString(LSecao, 'CodigoVerificacao', NFSe.CodigoVerificacao);

  if NFSe.InfNFSe.Id <> '' then
    AINIRec.WriteString(LSecao, 'ID', NFSe.InfNFse.ID);

  if NFSe.NfseSubstituida <> '' then
    AINIRec.WriteString(LSecao, 'NfseSubstituida', NFSe.NfseSubstituida);

  if NFSe.NfseSubstituidora <> '' then
    AINIRec.WriteString(LSecao, 'NfseSubstituidora', NFSe.NfseSubstituidora);

  AINIRec.WriteFloat(LSecao, 'ValorCredito', NFSe.ValorCredito);
  AINIRec.WriteString(LSecao, 'Link', NFSe.Link);
end;

procedure TNFSeW_PadraoNacional.GerarIniNfse(AINIRec: TMemIniFile);
begin
  {
  GerarINIIdentificacaoNFSe(AINIRec);
  }
end;

procedure TNFSeW_PadraoNacional.GerarIniRps(AINIRec: TMemIniFile);
begin
  {
  GerarINIIdentificacaoNFSe(AINIRec);
  GerarINIIdentificacaoPrestador(AINIRec);
  GerarINIIdentificacaoRps(AINIRec);
  GerarINIDadosTomador(AINIRec);
  GerarINIDadosIntermediario(AINIRec);
  GerarINIConstrucaoCivil(AINIRec);
  GerarINIDadosServico(AINIRec);
  GerarINIDadosValores(AINIRec);
  GerarINIListaServico(AINIRec);
  }
end;

end.
