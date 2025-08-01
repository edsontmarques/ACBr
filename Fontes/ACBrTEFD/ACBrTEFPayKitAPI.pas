{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2024 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
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

unit ACBrTEFPayKitAPI;

interface

uses
  Classes, SysUtils,
  ACBrBase;

const
  {$IFDEF MSWINDOWS}
   CPayKitLib = 'DPOSDRV.dll';
  {$ELSE}
   CPayKitLib = 'libDPOSDRV.so';
  {$ENDIF}

  CPayKitDirBin = 'Bin';
  CPayKitDirCupons = 'Cupons';
  CPayKitDirInterno = 'Interno';
  CPayKitNumControleReimpressao = 999999;

  CPayKitConf = 'dposlocal.ini';
  CSecMovimentoACBr = 'Movimento_ACBr';

  CPayKitURLCertificado = 'https://tef.linxsaas.com.br/certificados/Gerenciador_Certificado.cgi';

  RET_OK = 0;

resourcestring
  sErrCNPJNaoInformado = 'CNPJ do Estabelecimento, n�o informado';
  sErrEmpresaNaoInformada = 'N�mero de Empresa n�o informado';
  sErrLojaNaoInformada = 'N�mero de Loja n�o informado';

  sErrArqPayKitNaoEncontrado = 'Arquivo do PayKit: "%s", n�o encontrado em: %s';
  sErrLibJaInicializada = 'Biblioteca DPOSDRV j� foi inicializada';
  sErrLibNaoInicializada = 'Biblioteca DPOSDRV ainda N�O foi carregada';
  sErrDirPayKitInvalido = 'Subdiret�rio "%s" do PayKit, n�o encontrado na Pasta: %s';
  sErrEventoNaoAtribuido = 'Evento %s n�o atribuido';
  sErrImagemNaoEncontrada = 'Imagem %s n�o encontrada';

type
  EACBrTEFPayKitAPI = class(Exception);

  TACBrTEFPayKitGravarLog = procedure(const ALogLine: String; var Tratado: Boolean) of object ;

  TACBrTEFPayKitTipoMensagem = (msgInfo, msgAlerta, msgErro, msgAdicional, msgTerminal, msgPreview);

  TACBrTEFPayKitQuandoExibirMensagem = procedure(
    const Mensagem: String;
    TipoMensagem: TACBrTEFPayKitTipoMensagem;
    MilissegundosExibicao: Integer  // 0 - Para com OK;
    ) of object;                    // Positivo - Aguarda N milissegundos, e apaga a msg;
                                    // Negativo - Apenas exibe a Msg (n�o aguarda e n�o apaga msg)

  TACBrTEFPayKitQuandoPerguntarMenu = procedure(
    const Titulo: String;
    Opcoes: TStringList;
    var ItemSelecionado: LongInt) of object;  // Retorna o Item Selecionado, iniciando com 0
                                              // -2 - Volta no Fluxo
                                              // -1 - Cancela o Fluxo

  TACBrTEFPayKitTiposEntrada = ( teString,
                                 teNumero,
                                 teValor,
                                 teCartao,
                                 teBarrasDigitado,
                                 teBarrasLido,
                                 teValidade,
                                 teData,
                                 teCodSeguranca,
                                 teValorEspecial);

  TACBrTEFPayKitDefinicaoCampo = record
    TituloPergunta: String;
    MascaraDeCaptura: String;
    TipoDeEntrada: TACBrTEFPayKitTiposEntrada;
    TamanhoMinimo: Integer;
    TamanhoMaximo: Integer;
    ValorMinimo : Double;
    ValorMaximo : Double;
    ValorInicial: String;
  end;

  TACBrTEFAPIQuandoPerguntarCampo = procedure(
    DefinicaoCampo: TACBrTEFPayKitDefinicaoCampo;
    var Resposta: String;
    var Acao: Integer) of object ;     // 0 - O operador digitou o valor, -1 - A opera��o foi cancelada

  TACBrTEFPayKitQuandoExibirQRCode = procedure(const DadosQRCode: String) of object ;

  TACBrTEFPayKitEstadoOperacao = ( pkeOperacaoCancelada );

  TACBrTEFPayKitTransacaoEmAndamento = procedure(
    EstadoOperacao: TACBrTEFPayKitEstadoOperacao; out Cancelar: Boolean) of object;

  TACBrTEFPayKitAvaliarTransacaoPendente = procedure(const NumeroControle, MsgErro: String) of object;

  TACBrTEFPayKitCallBackDisplayTerminal = procedure(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackDisplayErro = procedure(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackMensagem = procedure(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackBeep = procedure;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackSolicitaConfirmacao = function(pMensagem: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraCartao = function(pLabel, pCartao: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraDataValidade = function(pLabel, pDataValidade: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraData = function(pLabel, pDataValidade: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraCodigoSeguranca = function(pLabel, pEntraCodigoSeguranca: PAnsiChar; iTamanhoMax: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackSelecionaOpcao = function(pLabel, pOpcoes: PAnsiChar; var iOpcaoSelecionada: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraValor = function(pLabel, pValor, pValorMinimo, pValorMaximo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraNumero = function(pLabel, pNumero, pNumeroMinimo, pNumeroMaximo: PAnsiChar; iMinimoDigitos, iMaximoDigitos, iDigitosExatos: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackOperacaoCancelada = function: LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackSetaOperacaoCancelada = function(iCancelada: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackProcessaMensagens = procedure;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraString = function(pLabel, pString, pTamanhoMaximo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackConsultaAVS = function(cEndereco, cNumero, cApto, cBloco, cCEP, cBairro, cCPF: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackMensagemAdicional = function(pMensagemAdicional: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackImagemAdicional = function(iIndiceImagem: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraCodigoBarras = function(pLabel, pCampo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraCodigoBarrasLido = function(pLabel, pCampo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackMensagemAlerta = procedure(pMensagemAlerta: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackPreviewComprovante = procedure(cComprovante: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackSelecionaPlanos = function(iCodigoRede, iCodigoTransacao, iTipoFinanciamento, iMaximoParcelas: Longint; pValorMinimoParcela: PAnsiChar; iMaxDiasPreDatado: LongInt; pNumeroParcelas, pValorTransacao, pValorParcela, pValorEntrada, pData: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackSelecionaPlanosEx = function(pSolicitacao, pRetorno: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackEntraValorEspecial = function(pLabel, pValor, pParametros: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  TACBrTEFPayKitCallBackComandos = function(pParametrosEntrada, pDadosRetorno: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

  { TACBrTEFPayKitAPI }

  TACBrTEFPayKitAPI = Class
  private
    fCarregada: Boolean;
    fCNPJEstabelecimento: String;
    fConfiguracaoIpPortaSsl: String;
    fOnExibeMensagem: TACBrTEFPayKitQuandoExibirMensagem;
    fOnTransacaoEmAndamento: TACBrTEFPayKitTransacaoEmAndamento;
    fQuandoAvaliarTransacaoPendente: TACBrTEFPayKitAvaliarTransacaoPendente;
    fQuandoExibirQRCode: TACBrTEFPayKitQuandoExibirQRCode;
    fQuandoPerguntarCampo: TACBrTEFAPIQuandoPerguntarCampo;
    fQuandoPerguntarMenu: TACBrTEFPayKitQuandoPerguntarMenu;
    fPathPayKit: String;
    fEmTransacao: Boolean;
    fInicializada: Boolean;
    fModoDesfazimento: Byte;
    fNomeAutomacao: String;
    fNumeroEmpresa: Integer;
    fNumeroLoja: Integer;
    fNumeroPDV: Integer;
    fOnGravarLog: TACBrTEFPayKitGravarLog;
    fPortaPinPad: String;
    fUltimoNumeroControle: Integer;
    fUltimaMsgEnviada: String;
    fURLCertificado: String;
    fVersaoAutomacao: String;

    xTransacaoCheque: function(pValorTransacao, pNumeroCupomVenda, pNumeroControle,
      pQuantidadeCheques, pPeriodicidadeCheques, pDataPrimeiroCheque,
      pCarenciaPrimeiroCheque: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoCredito: function(pValorTransacao, pNumeroCupomVenda,
      pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoDebito: function(pValorTransacao, pNumeroCupomVenda,
      pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoVoucher: function (pValorTransacao, pNumeroCupomVenda,
      pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoFrota: function (pValorTransacao, pNumeroCupomVenda,
      pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoQRCode: function(pValorTransacao, pNumeroCupom, pNumeroControle,
      pTransactionParamsData: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCancelamentoPagamento: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoPreAutorizacaoCartaoCredito: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoConsultaParcelas: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoResumoVendas: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoReimpressaoCupom: function: LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xConfirmaCartao: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xDesfazCartao: function(pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xFinalizaTransacao: function: LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xConsultaTransacao: function(pNumeroEmpresa, pNumeroLoja, pNumeroPDV,
      pSolicitacao, pResposta, pMensagemErro: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xVersaoDPOS: procedure(pVersao: PAnsiChar);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xInicializaDPOS: function: LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xFinalizaDPOS: function: LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xIdentificacaoAutomacaoComercial: function(pNomeAutomacao, pVersaoAutomacao,
      pReservado: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xConfiguraModoDesfazimento: function(iModoDesfazimento: LongInt): LongInt
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xDefineParametroTransacao: function(iCodigoParametro: LongInt;
      pValorParametro: PAnsiChar; iTamanhoParametro: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xConfiguraCNPJEstabelecimento: function(pCNPJEstabelecimento: PAnsiChar): LongInt
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xConfiguraEmpresaLojaPDV: function(pNumeroEmpresa, pNumeroLoja, pNumeroPDV: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xConfiguraComunicacaoDTEF: function(pConfiguracaoIpPortaSsl: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xBuscaCertificado: function(pURL, pPathCertificado: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xTransacaoEspecial: function(iCodigoTransacao: LongInt; pDados: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xLeIdentificacaoPinPad: function(pDados: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoFuncoesAdministrativas: function(pValorTransacao, pNumeroCupom, pNumeroControle,
      pReservado: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xTransacaoCartaoCreditoCompleta: function( pValorTransacao, pNumeroCupomVenda,
      pNumeroControle, pTipoOperacao, pNumeroParcelas, pValorParcela,
      pValorTaxaServico, pPermiteAlteracao, pReservado: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoDebitoCompleta: function ( pValorTransacao, pNumeroCupomVenda,
      pNumeroControle, pTipoOperacao, pNumeroParcelas, pSequenciaParcela, pDataDebito,
      pValorParcela, pValorTaxaServico, pPermiteAlteracao, pReservado: PAnsiChar): LongInt;
     {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoCartaoVoucherCompleta: function (pValorTransacao, pNumeroCupomVenda,
      pNumeroControle, pReservado: PAnsiChar): LongInt;
     {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xTransacaoManualPOSCompleta: function(pValorTransacao, pCodigoEstabelecimento,
      pData, pHora, pNumeroAutorizadora, pNumeroCartao, pTipoOperacao,
      pNumeroParcelas, pDataPreDatado, pNumeroControle: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xObtemLogTransacaoJson: function(pNumeroControle: PAnsiChar): PAnsiChar;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xForcaAtualizacaoTabelasPinpad: function: LongInt
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xExibeImagemPinPadPayKit: function(pcNomeArquivo: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xApagaImagemPinPadPayKit: function(pNomeImagem: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xObtemDadosEmpresaLojaTEF: function(pCNPJ, pCodigoEmpresa, pCodigoLoja: PAnsiChar): LongInt;
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    xRegPDVDisplayTerminal: procedure(pCallBackDisplayTerminal: TACBrTEFPayKitCallBackDisplayTerminal);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVDisplayErro: procedure(pCallBackDisplayErro: TACBrTEFPayKitCallBackDisplayErro);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVMensagem: procedure(pCallBackMensagem: TACBrTEFPayKitCallBackMensagem);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVBeep: procedure(pCallBackBeep: TACBrTEFPayKitCallBackBeep);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVSolicitaConfirmacao: procedure(pCallBackSolicitaConfirmacao: TACBrTEFPayKitCallBackSolicitaConfirmacao);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraCartao: procedure(pCallBackEntraCartao: TACBrTEFPayKitCallBackEntraCartao);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraDataValidade: procedure(pCallBackEntraDataValidade: TACBrTEFPayKitCallBackEntraDataValidade);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraData: procedure(pCallBackEntraData: TACBrTEFPayKitCallBackEntraData);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraCodigoSeguranca: procedure(pCallBackEntraCodigoSeguranca: TACBrTEFPayKitCallBackEntraCodigoSeguranca);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVSelecionaOpcao: procedure(pCallBackSelecionaOpcao: TACBrTEFPayKitCallBackSelecionaOpcao);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraValor: procedure(pCallBackEntraValor: TACBrTEFPayKitCallBackEntraValor);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraNumero: procedure(pCallBackEntraNumero: TACBrTEFPayKitCallBackEntraNumero);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVOperacaoCancelada: procedure(pCallBackOperacaoCancelada: TACBrTEFPayKitCallBackOperacaoCancelada);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVSetaOperacaoCancelada: procedure(pCallBackSetaOperacaoCancelada: TACBrTEFPayKitCallBackSetaOperacaoCancelada);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVProcessaMensagens: procedure(pCallBackProcessaMensagens: TACBrTEFPayKitCallBackProcessaMensagens);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraString: procedure(pCallBackEntraString: TACBrTEFPayKitCallBackEntraString);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVConsultaAVS: procedure(pCallBackConsultaAVS: TACBrTEFPayKitCallBackConsultaAVS);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVMensagemAdicional: procedure(pCallBackMensagemAdicional: TACBrTEFPayKitCallBackMensagemAdicional);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVImagemAdicional: procedure(pCallBackImagemAdicional: TACBrTEFPayKitCallBackImagemAdicional);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraCodigoBarras: procedure(pCallBackEntraCodigoBarras: TACBrTEFPayKitCallBackEntraCodigoBarras);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraCodigoBarrasLido: procedure(pCallBackEntraCodigoBarrasLido: TACBrTEFPayKitCallBackEntraCodigoBarrasLido);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVMensagemAlerta: procedure(pCallBackMensagemAlerta: TACBrTEFPayKitCallBackMensagemAlerta);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVPreviewComprovante: procedure(pCallBackPreviewComprovante: TACBrTEFPayKitCallBackPreviewComprovante);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVSelecionaPlanos: procedure(pCallBackSelecionaPlanos: TACBrTEFPayKitCallBackSelecionaPlanos);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVSelecionaPlanosEx: procedure(pCallBackSelecionaPlanosEx: TACBrTEFPayKitCallBackSelecionaPlanosEx);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVEntraValorEspecial: procedure(pCallBackEntraValorEspecial: TACBrTEFPayKitCallBackEntraValorEspecial);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
    xRegPDVComandos: procedure(pCallBackComandos: TACBrTEFPayKitCallBackComandos);
      {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

    procedure SetCNPJEstabelecimento(AValue: String);
    procedure SetConfiguracaoIpPortaSsl(AValue: String);
    procedure SetEmTransacao(AValue: Boolean);
    procedure SetURLCertificado(AValue: String);
    procedure SetInicializada(AValue: Boolean);
    procedure SetModoDesfazimento(AValue: Byte);
    procedure SetNomeAutomacao(AValue: String);
    procedure SetNumeroEmpresa(AValue: Integer);
    procedure SetNumeroLoja(AValue: Integer);
    procedure SetNumeroPDV(AValue: Integer);
    procedure SetVersaoAutomacao(AValue: String);
    procedure SetPathPayKit(AValue: String);

  protected
    procedure LoadLibFunctions;
    procedure UnLoadLibFunctions;
    procedure ClearMethodPointers;
    procedure RegisterCallBackFunctions;

    procedure TratarErroPayKit(AErrorCode: LongInt);

    procedure DoException(const AErrorMsg: String );

    procedure VerificarCarregada;
    procedure VerificarEAjustarConf;
    procedure CriarArquivoConfSeNaoExistir;
    function VerificarSeEstaEmTransacao: Boolean;

    procedure IdentificacaoAutomacaoComercial;
    procedure ConfiguraModoDesfazimento;
    procedure ConfiguraCNPJEstabelecimento;
    procedure ConfiguraEmpresaLojaPDV;
    procedure ConfiguraComunicacaoDTEF;
    procedure BuscaCertificado;
    procedure DefineTagACBr;

    procedure ExibirMensagem(const AMsg: String; TipoMensagem: TACBrTEFPayKitTipoMensagem = msgInfo;
      MilissegundosExibicao: Integer = -1);
    procedure PerguntarMenu(const Titulo: String; Opcoes: TStringList; var ItemSelecionado: LongInt);
    procedure PerguntarCampo(DefinicaoCampo: TACBrTEFPayKitDefinicaoCampo;
      var Resposta: String; var Acao: Integer);
    function VerificarTransacaoEmAndamento(EstadoOperacao: TACBrTEFPayKitEstadoOperacao): Boolean;

    procedure ExibirQRCode(const DadosQRCode: String);
  public
    constructor Create;
    destructor Destroy; override;

    property PathPayKit: String read fPathPayKit write SetPathPayKit;

    property Carregada: Boolean read fCarregada;
    property Inicializada: Boolean read fInicializada write SetInicializada;
    property EmTransacao: Boolean read fEmTransacao write SetEmTransacao;

    property OnGravarLog: TACBrTEFPayKitGravarLog read fOnGravarLog write fOnGravarLog;
    property OnExibeMensagem: TACBrTEFPayKitQuandoExibirMensagem read fOnExibeMensagem
      write fOnExibeMensagem;
    property OnTransacaoEmAndamento: TACBrTEFPayKitTransacaoEmAndamento read fOnTransacaoEmAndamento
      write fOnTransacaoEmAndamento;
    property QuandoPerguntarMenu: TACBrTEFPayKitQuandoPerguntarMenu read fQuandoPerguntarMenu
      write fQuandoPerguntarMenu;
    property QuandoPerguntarCampo: TACBrTEFAPIQuandoPerguntarCampo read fQuandoPerguntarCampo
      write fQuandoPerguntarCampo;
    property QuandoExibirQRCode: TACBrTEFPayKitQuandoExibirQRCode read fQuandoExibirQRCode
      write fQuandoExibirQRCode;
    property QuandoAvaliarTransacaoPendente: TACBrTEFPayKitAvaliarTransacaoPendente
      read fQuandoAvaliarTransacaoPendente write fQuandoAvaliarTransacaoPendente;

    procedure Inicializar;
    procedure DesInicializar;

    procedure GravarLog(const AString: AnsiString; Traduz: Boolean = False);

    function VersaoDPOS: String;
    procedure InicializaDPOS(Forcar: Boolean = False);
    procedure FinalizaDPOS(Forcar: Boolean = False);
    function CalcPayKitPath(ASubFolder: String; VerificarSeExiste: Boolean = True): String;

    procedure TransacaoEspecial(iCodigoTransacao: LongInt; var Dados: AnsiString);
    procedure DefineParametroTransacao(iCodigoParametro: LongInt; const ValorParametro: AnsiString);
    procedure ExibirMensagemPinPad(const MsgPinPad: String; Tempo: Integer);
    function LeIdentificacaoPinPad: String;
    function ObterPortaPinPadINI: String;
    function TransacaoFuncoesAdministrativas(ValorTransacao: Double = 0;
      const NumeroCupom: Integer = 0; const Reservado: String = ''): String;

    function TransacaoCartaoCredito(ValorTransacao: Double; const NumeroCupomVenda: Integer): String;
    function TransacaoCartaoCreditoCompleta(ValorTransacao: Double;
      const NumeroCupomVenda: Integer; TipoOperacao: String;
      NumeroParcelas: Integer; ValorParcela, ValorTaxaServico: Double;
      PermiteAlteracao: Boolean; const Reservado: String): String;
    function TransacaoCartaoDebito(ValorTransacao: Double; const NumeroCupomVenda: Integer): String;
    function TransacaoCartaoDebitoCompleta(ValorTransacao: Double;
      const NumeroCupomVenda: Integer; TipoOperacao: String;
      NumeroParcelas, SequenciaParcela: Integer; DataDebito: TDateTime;
      ValorParcela, ValorTaxaServico: Double;
      PermiteAlteracao: Boolean; const Reservado: String): String;
    function TransacaoCartaoVoucher(ValorTransacao: Double; const NumeroCupomVenda: Integer): String;
    function TransacaoCartaoFrota(ValorTransacao: Double; const NumeroCupomVenda: Integer): String;
    function TransacaoQRCode(ValorTransacao: Double; const NumeroCupomVenda: Integer;
      const TransactionParamsData: String = ''): String;

    function ObtemLogTransacaoJson(const NumeroControle: String): String;
    function ObtemComprovanteTransacao(const NumeroControle: String; Resumida: Boolean = False): String;
    procedure TransacaoReimpressaoCupom;
    function TransacaoResumoVendas: String;

    function ConfirmarTransacao(const NumeroControle: String): LongInt;
    function DesfazerTransacao(const NumeroControle: String): LongInt;
    procedure CancelarTransacao(const NumeroControle: String);
    procedure FinalizarTransacao;
    procedure ConsultaTransacao(Data: TDateTime; NSU: Integer; out Resposta,
      MensagemErro: String; NumEmpresa: Integer = 0; NumLoja: Integer = 0;
      NumPDV: Integer = 0);
    procedure AbortarTransacao;
    procedure ForcaAtualizacaoTabelasPinpad;
    procedure ExibeImagemPinPadPayKit(const NomeArq: String);
    procedure ApagaImagemPinPadPayKit(const NomeImagem: String);
    function ObtemDadosEmpresaLojaTEF(const CNPJ: String; out CodigoEmpresa: String;
      out CodigoLoja: String): LongInt;

    property NomeAutomacao: String read fNomeAutomacao write SetNomeAutomacao;
    property VersaoAutomacao: String read fVersaoAutomacao write SetVersaoAutomacao;
    property ModoDesfazimento: Byte read fModoDesfazimento write SetModoDesfazimento default 1;  // 0 - Autom�tico, 1 - Expl�cito

    property CNPJEstabelecimento: String read fCNPJEstabelecimento write SetCNPJEstabelecimento;
    property NumeroEmpresa: Integer read fNumeroEmpresa write SetNumeroEmpresa;
    property NumeroLoja: Integer read fNumeroLoja write SetNumeroLoja;
    property NumeroPDV: Integer read fNumeroPDV write SetNumeroPDV;

    property ConfiguracaoIpPortaSsl: String read fConfiguracaoIpPortaSsl write SetConfiguracaoIpPortaSsl;
    property URLCertificado: String read fURLCertificado write SetURLCertificado;

    property PortaPinPad: String read fPortaPinPad write fPortaPinPad;
    property UltimoNumeroControle: Integer read fUltimoNumeroControle;
  end;

  function GetTEFPayKitAPI: TACBrTEFPayKitAPI;
  procedure LimparDefinicaoCampo(out Adef: TACBrTEFPayKitDefinicaoCampo);

  procedure CallBackDisplayTerminal(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackDisplayErro(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackMensagem(pMensagem: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackBeep;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackSolicitaConfirmacao(pMensagem: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraCartao(pLabel, pCartao: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraDataValidade(pLabel, pDataValidade: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraData(pLabel, pData: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraCodigoSeguranca(pLabel, pEntraCodigoSeguranca: PAnsiChar; iTamanhoMax: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackSelecionaOpcao(pLabel, pOpcoes: PAnsiChar; var iOpcaoSelecionada: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraValor(pLabel, pValor, pValorMinimo, pValorMaximo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraNumero(pLabel, pNumero, pNumeroMinimo, pNumeroMaximo: PAnsiChar; iMinimoDigitos, iMaximoDigitos, iDigitosExatos: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackOperacaoCancelada: LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackSetaOperacaoCancelada(iCancelada: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackProcessaMensagens;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraString(pLabel, pString, pTamanhoMaximo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackConsultaAVS(cEndereco, cNumero, cApto, cBloco, cCEP, cBairro, cCPF: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackMensagemAdicional(pMensagemAdicional: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackImagemAdicional(iIndiceImagem: LongInt): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraCodigoBarras(pLabel, pCampo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraCodigoBarrasLido(pLabel, pCampo: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackMensagemAlerta(pMensagemAlerta: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  procedure CallBackPreviewComprovante(cComprovante: PAnsiChar);
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackSelecionaPlanos(iCodigoRede, iCodigoTransacao, iTipoFinanciamento, iMaximoParcelas: Longint; pValorMinimoParcela: PAnsiChar; iMaxDiasPreDatado: LongInt; pNumeroParcelas, pValorTransacao, pValorParcela, pValorEntrada, pData: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackSelecionaPlanosEx(pSolicitacao, pRetorno: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackEntraValorEspecial(pLabel, pValor, pParametros: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
  function CallBackComandos(pParametrosEntrada, pDadosRetorno: PAnsiChar): LongInt;
    {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};

var
  vTEFPayKit: TACBrTEFPayKitAPI;

implementation

uses
  IniFiles, Math, StrUtils, DateUtils,
  ACBrUtil.Strings,
  ACBrUtil.FilesIO;

function GetTEFPayKitAPI: TACBrTEFPayKitAPI;
begin
  if not Assigned(vTEFPayKit) then
    vTEFPayKit := TACBrTEFPayKitAPI.Create;

  Result := vTEFPayKit;
end;

procedure LimparDefinicaoCampo(out Adef: TACBrTEFPayKitDefinicaoCampo);
begin
  Adef.TituloPergunta := '';
  Adef.MascaraDeCaptura := '';
  Adef.TipoDeEntrada := teString;
  Adef.TamanhoMinimo := 0;
  Adef.TamanhoMaximo := 0;
  Adef.ValorMinimo := 0;
  Adef.ValorMaximo := 0;
  Adef.ValorInicial := '';
end;

procedure CallBackDisplayTerminal(pMensagem: PAnsiChar); {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
begin
  with GetTEFPayKitAPI do
  begin
    s := String(pMensagem);
    GravarLog('  CallBackDisplayTerminal( '+s+' )');
    ExibirMensagem(ACBrStr(s), msgTerminal);
  end;
end;

procedure CallBackDisplayErro(pMensagem: PAnsiChar); {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
begin
  with GetTEFPayKitAPI do
  begin
    s := String(pMensagem);
    GravarLog('  CallBackDisplayErro( '+s+' )');
    ExibirMensagem(ACBrStr(s), msgErro, 0);
  end;
end;

procedure CallBackMensagem(pMensagem: PAnsiChar); {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
begin
  with GetTEFPayKitAPI do
  begin
    s := String(pMensagem);
    GravarLog('  CallBackMensagem( '+s+' )');
    ExibirMensagem(ACBrStr(s), msgInfo);
  end;
end;

procedure CallBackBeep; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackBeep');
    Beep;
  end;
end;

function CallBackSolicitaConfirmacao(pMensagem: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
  sl: TStringList;
  ItemSelecionado: LongInt;
begin
  Result := 1;   // NAO
  with GetTEFPayKitAPI do
  begin
    s := Trim(String(pMensagem));
    GravarLog('  CallBackSolicitaConfirmacao( '+s+' )');
    if (s = '') then
    begin
      if (fUltimaMsgEnviada <> '') then
        ExibirMensagem(fUltimaMsgEnviada, msgAlerta, 0);

      Result := 0;  // SIM
    end
    else
    begin
      sl := TStringList.Create;
      try
        ItemSelecionado := 0;
        sl.Add('1-SIM');
        sl.Add('2-NAO');
        PerguntarMenu(ACBrStr(s), sl, ItemSelecionado);
        if (ItemSelecionado = 0) then     //-2 - Volta no Fluxo, -1 - Cancela o Fluxo
          Result := 0;  // SIM
      finally
        sl.Free;
      end;
    end;

    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackEntraCartao(pLabel, pCartao: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    GravarLog('  CallBackEntraCartao( '+s+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.TipoDeEntrada := teCartao;
    def.TamanhoMaximo := 19;

    resp := String(pCartao);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pCartao^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Cartao:'+String(pCartao))
  end;
end;

function CallBackEntraDataValidade(pLabel, pDataValidade: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    GravarLog('  CallBackEntraDataValidade( '+s+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.TipoDeEntrada := teValidade;

    resp := String(pDataValidade);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    resp := OnlyNumber(resp);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pDataValidade^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', DataValidade:'+String(pDataValidade));
  end;
end;

function CallBackEntraData(pLabel, pData: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    GravarLog('  CallBackEntraData( '+s+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.TipoDeEntrada := teData;

    resp := String(pData);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pData^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Data:'+String(pData))
  end;
end;

function CallBackEntraCodigoSeguranca(pLabel, pEntraCodigoSeguranca: PAnsiChar; iTamanhoMax: LongInt): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    GravarLog('  CallBackEntraCodigoSeguranca( '+s+', '+IntToStr(iTamanhoMax)+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.TipoDeEntrada := teCodSeguranca;
    def.TamanhoMaximo := iTamanhoMax;

    resp := String(pEntraCodigoSeguranca);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pEntraCodigoSeguranca^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Cod:'+String(pEntraCodigoSeguranca));
  end;
end;

function CallBackSelecionaOpcao(pLabel, pOpcoes: PAnsiChar; var iOpcaoSelecionada: LongInt): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  titulo, opcoes, s, atalho: String;
  sl: TStringList;
  i, p1, p2: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    titulo := String(pLabel);
    opcoes := String(pOpcoes);
    GravarLog('  CallBackSelecionaOpcao( '+titulo+', '+opcoes+' )');
    sl := TStringList.Create;
    try
      sl.Text := StringReplace(opcoes, '#', sLineBreak, [rfReplaceAll]);
      for i := 0 to sl.Count-1 do
      begin
        s := sl[i];
        p1 := pos(',',s);
        if (p1 > 0) then
          atalho := copy(s,2,p1-2);
        p1 := max(Pos('"' ,s),1);
        p2 := min(PosEx('"' ,s, p1+1), Length(s));
        s := ACBrStr(copy(s, p1+1, p2-p1-1));
        if copy(s, 1, Length(atalho)) <> atalho then
          s := atalho +'-'+ s;
        sl[i] := s;
      end;
      iOpcaoSelecionada := min(max(iOpcaoSelecionada, 1), sl.Count)-1;

      PerguntarMenu(ACBrStr(titulo), sl, iOpcaoSelecionada);
      if (iOpcaoSelecionada < 0) then     // -2 - Volta no Fluxo, -1 - Cancela o Fluxo
        Result := -1
      else
        Inc(iOpcaoSelecionada);  // Converte de Indice 0 para indice 1
    finally
      sl.Free;
    end;
    GravarLog('    ret:'+IntToStr(Result)+', OpcaoSelecionada:'+IntToStr(iOpcaoSelecionada));
  end;
end;

function CallBackEntraValor(pLabel, pValor, pValorMinimo, pValorMaximo: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp, vmin, vmax: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    vmin := String(pValorMinimo);
    vmax := String(pValorMaximo);
    GravarLog('  CallBackEntraValor( '+s+', '+vmin+', '+vmax+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.ValorMinimo := StrToIntDef(vmin, 0)/100;
    def.ValorMaximo := StrToIntDef(vmax, 0)/100;
    def.TamanhoMinimo := 1;
    def.TamanhoMaximo := 12;
    def.MascaraDeCaptura := '@@@.@@@.@@@.@@@,@@';
    def.TipoDeEntrada := teValor;

    resp := String(pValor);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    resp := Format('%.12d',[StrToIntDef(OnlyNumber(resp), 0)]) ;
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pValor^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Valor:'+String(pValor));
  end;
end;

function CallBackEntraNumero(pLabel, pNumero, pNumeroMinimo,
  pNumeroMaximo: PAnsiChar; iMinimoDigitos, iMaximoDigitos,
  iDigitosExatos: LongInt): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp, vmin, vmax: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    vmin := String(pNumeroMinimo);
    vmax := String(pNumeroMaximo);
    GravarLog( '  CallBackEntraNumero( '+s+', '+vmin+', '+vmax+', '+
               IntToStr(iMinimoDigitos)+', '+IntToStr(iMaximoDigitos)+', '+IntToStr(iDigitosExatos)+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.ValorMinimo := StrToIntDef(vmin, 0);
    def.ValorMaximo := StrToIntDef(vmax, 0);
    def.TamanhoMinimo := iMinimoDigitos;
    def.TamanhoMaximo := iMaximoDigitos;
    if (iDigitosExatos <> 0) then
    begin
      def.TamanhoMinimo := iDigitosExatos;
      def.TamanhoMaximo := iDigitosExatos;
    end;

    def.TipoDeEntrada := teNumero;

    resp := String(pNumero);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pNumero^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Valor:'+String(pNumero));
  end;
end;

function CallBackOperacaoCancelada: LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := 0;   // Continua o Fluxo
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackOperacaoCancelada');
    if (not EmTransacao) or
       (not VerificarTransacaoEmAndamento(pkeOperacaoCancelada)) then
      Result := 1;    // Interrompe o Fluxo
    GravarLog('    ret:'+IntToStr(Result));
  end;
end;

function CallBackSetaOperacaoCancelada(iCancelada: LongInt): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackSetaOperacaoCancelada( '+IntToStr(iCancelada)+' )');
    { O que fazer aqui ? }
    GravarLog('    ret:'+IntToStr(Result));
  end;
end;

procedure CallBackProcessaMensagens; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackProcessaMensagens');
  end;
end;

function CallBackEntraString(pLabel, pString, pTamanhoMaximo: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    GravarLog('  CallBackEntraString( '+s+', '+String(pTamanhoMaximo)+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.TamanhoMaximo := StrToIntDef(String(pTamanhoMaximo), 0);
    def.TipoDeEntrada := teString;

    resp := String(pString);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pString^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', String:'+String(pString));
  end;
end;

function CallBackConsultaAVS(cEndereco, cNumero, cApto, cBloco, cCEP, cBairro,
  cCPF: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := -1;  // A opera��o foi cancelada;  (n�o implementado)
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackConsultaAVS');
    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackMensagemAdicional(pMensagemAdicional: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pMensagemAdicional);
    GravarLog('  CallBackMensagemAdicional( '+s+' )');
    ExibirMensagem(ACBrStr(s), msgAdicional);
    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackImagemAdicional(iIndiceImagem: LongInt): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := 0;   // Sempre deve retornar 0
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackImagemAdicional( '+IntToStr(iIndiceImagem)+' )');
    { ainda n�o implementado }
    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackEntraCodigoBarras(pLabel, pCampo: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    with GetTEFPayKitAPI do
    begin
      GravarLog('  CallBackEntraCodigoBarras( '+s+' )');
      LimparDefinicaoCampo(def);
      def.TituloPergunta := ACBrStr(s);
      def.TipoDeEntrada := teBarrasDigitado;
      resp := '';
      acao := 0;
      PerguntarCampo(def, resp, acao);
      Result := acao;
      if (acao >= 0) then
        move(resp[1], pCampo^, Length(resp)+1);

      GravarLog('    ret:'+IntToStr(Result)+', Campo:'+String(pCampo));
    end;
  end;
end;

function CallBackEntraCodigoBarrasLido(pLabel, pCampo: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    with GetTEFPayKitAPI do
    begin
      GravarLog('  CallBackEntraCodigoBarrasLido( '+s+' )');
      LimparDefinicaoCampo(def);
      def.TituloPergunta := ACBrStr(s);
      def.TipoDeEntrada := teBarrasLido;
      resp := '';
      acao := 0;
      PerguntarCampo(def, resp, acao);
      Result := acao;
      if (acao >= 0) then
        move(resp[1], pCampo^, Length(resp)+1);

      GravarLog('    ret:'+IntToStr(Result)+', Campo:'+String(pCampo));
    end;
  end;
end;

procedure CallBackMensagemAlerta(pMensagemAlerta: PAnsiChar); {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, NumeroControle: String;
  p: Integer;
begin
  with GetTEFPayKitAPI do
  begin
    s := String(pMensagemAlerta);
    GravarLog('  CallBackMensagemAlerta( '+s+' )');

    // Verificando se � Erro de Transa��o pendente //
    if (pos('pendente!!!', s) > 0) then
    begin
      if Assigned(QuandoAvaliarTransacaoPendente) then
      begin
        NumeroControle := '';
        p := Pos(':', s);
        if (p > 0) then
          NumeroControle := Trim(copy(s, p+1, 7));

        if (NumeroControle <> '') then
          QuandoAvaliarTransacaoPendente(NumeroControle, s);
      end;
    end;

    ExibirMensagem(ACBrStr(s), msgAlerta, 0);
  end;
end;

procedure CallBackPreviewComprovante(cComprovante: PAnsiChar); {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s: String;
begin
  with GetTEFPayKitAPI do
  begin
    s := String(cComprovante);
    GravarLog('  CallBackPreviewComprovante( '+s+' )');
    ExibirMensagem(ACBrStr(s), msgPreview, 0);
  end;
end;

function CallBackSelecionaPlanos(iCodigoRede, iCodigoTransacao,
  iTipoFinanciamento, iMaximoParcelas: Longint; pValorMinimoParcela: PAnsiChar;
  iMaxDiasPreDatado: LongInt; pNumeroParcelas, pValorTransacao, pValorParcela,
  pValorEntrada, pData: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := -1;  // Os planos n�o ser�o tratados (n�o implementado)
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackSelecionaPlanos');
    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackSelecionaPlanosEx(pSolicitacao, pRetorno: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
begin
  Result := -1;  // Os planos n�o ser�o tratados (n�o implementado)
  with GetTEFPayKitAPI do
  begin
    GravarLog('  CallBackSelecionaPlanosEx');
    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

function CallBackEntraValorEspecial(pLabel, pValor, pParametros: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  s, resp, p: String;
  def: TACBrTEFPayKitDefinicaoCampo;
  acao, decimais: Integer;
begin
  Result := 0;
  with GetTEFPayKitAPI do
  begin
    s := String(pLabel);
    p := String(pParametros);
    GravarLog('  CallBackEntraValorEspecial( '+s+', '+p+' )');
    LimparDefinicaoCampo(def);
    def.TituloPergunta := ACBrStr(s);
    def.ValorMinimo := StrToIntDef(copy(p,  1, 12), 0);
    def.ValorMaximo := StrToIntDef(copy(p, 13, 12), 0);
    decimais := StrToIntDef(copy(p, 25, 1), 2);
    def.TipoDeEntrada := teValorEspecial;
    def.MascaraDeCaptura := '@@@.@@@.@@@.@@@,'+StringOfChar('@', decimais);

    resp := String(pValor);
    acao := 0;
    PerguntarCampo(def, resp, acao);
    resp := Format('%.12d',[StrToIntDef(OnlyNumber(resp), 0)]) ;
    Result := acao;
    if (acao >= 0) then
      move(resp[1], pValor^, Length(resp)+1);

    GravarLog('    ret:'+IntToStr(Result)+', Valor:'+String(pValor));
  end;
end;

function CallBackComandos(pParametrosEntrada, pDadosRetorno: PAnsiChar): LongInt; {$IfDef MSWINDOWS}stdcall{$Else}cdecl{$EndIf};
var
  dados, comando: String;
  tamanho: integer;
begin
  Result := 0;
  //0 	O comando foi executado corretamente.
  //-1 	O comando n�o foi implementado
  //-2 	Ocorreu um erro ao executar o comando

  // QRCODE
  // Os comandos s�o enviados no formato TLV, com c�digo de comando com 3 bytes e tamanho com 6 bytes.
  // O tamanho se refere ao tamanho dos dados e n�o ao tamanho total.
  // Por exemplo, o comando para apresenta��o de um c�digo QR Code fica assim:
  // 001000030LINXeFuiMzDmu85TcYCimGcOeMvUwM
  // C�digo de comando: 001
  // Tamanho: 000030
  // QRCode: LINXeFuiMzDmu85TcYCimGcOeMvUwM

  with GetTEFPayKitAPI do
  begin
    dados := String(pParametrosEntrada);
    GravarLog('  CallBackComandos( '+dados+' )');

    comando := copy(dados,1,3);
    tamanho := StrToIntDef(copy(dados, 4, 6), 0);
    dados := copy(dados, 10, tamanho);

    if (comando = '001') then
      ExibirQRCode(dados)
    else
      Result := -1;

    GravarLog('    ret:'+IntToStr(Result))
  end;
end;

{ TACBrTEFPayKitAPI }

constructor TACBrTEFPayKitAPI.Create;
begin
  inherited;
  fCarregada := False;
  fPathPayKit := '';
  fEmTransacao := False;
  fInicializada := False;

  fNomeAutomacao := '';
  fPortaPinPad := '';
  fVersaoAutomacao := '';
  fUltimoNumeroControle := -1;
  fModoDesfazimento := 1;
  fUltimaMsgEnviada := '';

  fOnGravarLog := Nil;
  fOnExibeMensagem := Nil;
  fOnTransacaoEmAndamento := Nil;
  fQuandoPerguntarMenu := Nil;
  fQuandoExibirQRCode := Nil;
  fQuandoPerguntarCampo := Nil;
  fQuandoAvaliarTransacaoPendente := Nil;
end;

destructor TACBrTEFPayKitAPI.Destroy;
begin
  fOnGravarLog := Nil;
  fOnExibeMensagem := Nil;
  fOnTransacaoEmAndamento := Nil;
  fQuandoPerguntarMenu := Nil;
  fQuandoExibirQRCode := Nil;
  fQuandoPerguntarCampo := Nil;
  fQuandoAvaliarTransacaoPendente := Nil;

  inherited Destroy;
end;

procedure TACBrTEFPayKitAPI.Inicializar;
begin
  if fInicializada then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.Inicializar');

  if not Assigned(fOnExibeMensagem) then
    DoException(Format(sErrEventoNaoAtribuido, ['OnExibeMensagem']));
  if not Assigned(fOnTransacaoEmAndamento) then
    DoException(Format(sErrEventoNaoAtribuido, ['OnTransacaoEmAndamento']));
  if not Assigned(fQuandoPerguntarMenu) then
    DoException(Format(sErrEventoNaoAtribuido, ['QuandoPerguntarMenu']));
  if not Assigned(fQuandoPerguntarCampo) then
    DoException(Format(sErrEventoNaoAtribuido, ['QuandoPerguntarCampo']));

  VerificarEAjustarConf;
  LoadLibFunctions;
  RegisterCallBackFunctions;

  IdentificacaoAutomacaoComercial;
  ConfiguraModoDesfazimento;
  ConfiguraCNPJEstabelecimento;
  ConfiguraEmpresaLojaPDV;
  ConfiguraComunicacaoDTEF;
  BuscaCertificado;
  //InicializaDPOS;

  fInicializada := True;
  fUltimoNumeroControle := -1;
  fUltimaMsgEnviada := '';
end;

procedure TACBrTEFPayKitAPI.DesInicializar;
begin
  if not fInicializada then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.DesInicializar');
  UnLoadLibFunctions;
  fInicializada := False;
end;

procedure TACBrTEFPayKitAPI.GravarLog(const AString: AnsiString; Traduz: Boolean);
Var
  Tratado: Boolean;
  AStringLog: AnsiString;
begin
  if not Assigned(fOnGravarLog) then
    Exit;

  if Traduz then
    AStringLog := TranslateUnprintable(AString)
  else
    AStringLog := AString;

  Tratado := False;
  fOnGravarLog(AStringLog, Tratado);
end;

function TACBrTEFPayKitAPI.VersaoDPOS: String;
var
  pVersao: AnsiString;
begin
  Result := '';
  pVersao := StringOfChar(' ', 100);
  GravarLog('Lib.VersaoDPOS');
  xVersaoDPOS(PAnsiChar(pVersao));
  Result := String(pVersao);
  GravarLog('  Result: '+Result);
end;

procedure TACBrTEFPayKitAPI.InicializaDPOS(Forcar: Boolean);
var
  iRet: LongInt;
  ini: TMemIniFile;
  datamov: TDateTime;
  fechado: Boolean;
  p, f: String;
begin
  GravarLog('TACBrTEFPayKitAPI.InicializaDPOS');
  p := CalcPayKitPath(CPayKitDirBin);
  f := p + CPayKitConf;
  if not FileExists(f) then
    DoException(Format(sErrArqPayKitNaoEncontrado, [CPayKitConf, p]));

  datamov := 0;
  fechado := False;
  ini := TMemIniFile.Create(f);
  try
    if not Forcar then
    begin
      datamov := ini.ReadDateTime(CSecMovimentoACBr, 'Data', 0);
      fechado := ini.ReadBool(CSecMovimentoACBr, 'Fechado', False);
    end;

    if (datamov = Date) then
    begin
      if fechado then
        GravarLog('  Movimento estava fechado')
      else
        GravarLog('  Movimento estava aberto');

      Exit;
    end;

    EmTransacao := True;
    try
      GravarLog('Lib.InicializaDPOS');
      iRet := xInicializaDPOS;
      GravarLog('  ret: '+IntToStr(iRet));
      TratarErroPayKit(iRet);
    finally
      EmTransacao := False;
    end;

    ini.WriteDateTime(CSecMovimentoACBr, 'Data', Date);
    ini.WriteBool(CSecMovimentoACBr, 'Fechado', False);
  finally
    ini.Free;
  end;
end;

procedure TACBrTEFPayKitAPI.FinalizaDPOS(Forcar: Boolean);
var
  iRet: LongInt;
  ini: TMemIniFile;
  fechado: Boolean;
  datamov: TDateTime;
  p, f: String;
begin
  GravarLog('TACBrTEFPayKitAPI.InicializaDPOS');
  p := CalcPayKitPath(CPayKitDirBin);
  f := p + CPayKitConf;
  if not FileExists(f) then
    DoException(Format(sErrArqPayKitNaoEncontrado, [CPayKitConf, p]));

  fechado := False;
  datamov := 0;
  ini := TMemIniFile.Create(f);
  try
    if not Forcar then
    begin
      datamov := ini.ReadDateTime(CSecMovimentoACBr, 'Data', 0);
      fechado := ini.ReadBool(CSecMovimentoACBr, 'Fechado', False);
    end;

    if fechado and (datamov = Date) then
    begin
      GravarLog('  Movimento estava fechado');
      Exit;
    end;

    EmTransacao := True;
    try
      GravarLog('Lib.FinalizaDPOS');
      iRet := xFinalizaDPOS;
      GravarLog('  ret: '+IntToStr(iRet));
      TratarErroPayKit(iRet);
    finally
      EmTransacao := False;
    end;

    ini.WriteDateTime(CSecMovimentoACBr, 'Data', Date);
    ini.WriteBool(CSecMovimentoACBr, 'Fechado', True);
  finally
    ini.Free;
  end;
end;

procedure TACBrTEFPayKitAPI.TransacaoEspecial(iCodigoTransacao: LongInt;
  var Dados: AnsiString);
var
  iRet: LongInt;
begin
  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoEspecial( '+IntToStr(iCodigoTransacao)+', '+Dados+' )');
    iRet := xTransacaoEspecial(iCodigoTransacao, PAnsiChar(Dados));
    if (iRet = RET_OK) then
      Dados := Trim(Dados)
    else
      Dados := '';

    GravarLog('  ret: '+IntToStr(iRet)+', Dados: '+Dados);
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.DefineParametroTransacao(iCodigoParametro: LongInt;
  const ValorParametro: AnsiString);
var
  iRet, iTamanho: LongInt;
  pValorParametro: AnsiString;
begin
  EmTransacao := True;
  try
    pValorParametro := LeftStr(ValorParametro, 4096);
    iTamanho := Length(pValorParametro);
    GravarLog('Lib.DefineParametroTransacao( '+IntToStr(iCodigoParametro)+', '+pValorParametro+', '+IntToStr(iTamanho)+' )');
    iRet := xDefineParametroTransacao(iCodigoParametro, PAnsiChar(pValorParametro), iTamanho);
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.ExibirMensagemPinPad(const MsgPinPad: String;
  Tempo: Integer);
var
  Dados: AnsiString;
begin
  Dados := PadRight(MsgPinPad, 32) + Format('%.6d',[Tempo]);
  TransacaoEspecial(106, Dados);
end;

function TACBrTEFPayKitAPI.LeIdentificacaoPinPad: String;
var
  iRet: LongInt;
  pDados: AnsiString;
begin
  pDados := StringOfChar(' ', 110);
  EmTransacao := True;
  try
    GravarLog('Lib.LeIdentificacaoPinPad');
    iRet := xLeIdentificacaoPinPad(PAnsiChar(pDados));
    if (iRet = RET_OK) then
      Result := String(pDados)
    else
      Result := '';

    GravarLog('  ret: '+IntToStr(iRet)+', Dados: '+Result);
  finally
    EmTransacao := False;
  end;
  TratarErroPayKit(iRet);
end;

function TACBrTEFPayKitAPI.ObterPortaPinPadINI: String;
var
  Ini: TMemIniFile;
  p, f: String;
begin
  p := CalcPayKitPath(CPayKitDirBin);
  f := p + CPayKitConf;
  Result := '';
  if not FileExists(f) then
    Exit;

  Ini := TMemIniFile.Create(f);
  try
    Result := Ini.ReadString('PIN', 'PORTA', '');
  finally
    Ini.Free;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoFuncoesAdministrativas(
  ValorTransacao: Double; const NumeroCupom: Integer; const Reservado: String
  ): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupom, pReservado, pNumeroControle: AnsiString;
begin
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupom := Format('%.6d',[NumeroCupom]);
  pReservado := PadRight(Reservado, 128);
  pNumeroControle := StringOfChar('0',6);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoFuncoesAdministrativas( '+pValorTransacao+', '+pNumeroCupom+', '+pReservado+' )');
    iRet := xTransacaoFuncoesAdministrativas( PAnsiChar(pValorTransacao),
                                              PAnsiChar(pNumeroCupom),
                                              PAnsiChar(pNumeroControle),
                                              PAnsiChar(pReservado) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
    TratarErroPayKit(iRet);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoCredito(ValorTransacao: Double;
  const NumeroCupomVenda: Integer): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoCredito( '+pValorTransacao+', '+pNumeroCupomVenda+' )');
    iRet := xTransacaoCartaoCredito( PAnsiChar(pValorTransacao),
                                     PAnsiChar(pNumeroCupomVenda),
                                     PAnsiChar(pNumeroControle) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoCreditoCompleta(
  ValorTransacao: Double; const NumeroCupomVenda: Integer;
  TipoOperacao: String; NumeroParcelas: Integer; ValorParcela,
  ValorTaxaServico: Double; PermiteAlteracao: Boolean; const Reservado: String
  ): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pTipoOperacao, pNumeroParcelas,
    pValorParcela, pValorTaxaServico, pPermiteAlteracao, pReservado,
    pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  pTipoOperacao := PadRight(TipoOperacao, 3);
  pNumeroParcelas := Format('%.2d',[max(NumeroParcelas, 1)]);
  pValorParcela := Format('%.12d',[Round(ValorParcela*100)]);
  pValorTaxaServico := Format('%.12d',[Round(ValorTaxaServico*100)]);
  pPermiteAlteracao := IfThen(PermiteAlteracao, 'S', 'N');
  pReservado := PadRight( IfEmptyThen(Reservado, '0000'), 148, ' ');
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoCreditoCompleta( '+pValorTransacao+', '+pNumeroCupomVenda+', '+
      pNumeroControle+', '+pTipoOperacao+', '+pNumeroParcelas+', '+pValorParcela+', '+
      pValorTaxaServico+', '+pPermiteAlteracao+', '+ pReservado+' )');
    iRet := xTransacaoCartaoCreditoCompleta( PAnsiChar(pValorTransacao),
                                             PAnsiChar(pNumeroCupomVenda),
                                             PAnsiChar(pNumeroControle),
                                             PAnsiChar(pTipoOperacao),
                                             PAnsiChar(pNumeroParcelas),
                                             PAnsiChar(pValorParcela),
                                             PAnsiChar(pValorTaxaServico),
                                             PAnsiChar(pPermiteAlteracao),
                                             PAnsiChar(pReservado));
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoDebito(ValorTransacao: Double;
  const NumeroCupomVenda: Integer): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoDebito( '+pValorTransacao+', '+pNumeroCupomVenda+' )');
    iRet := xTransacaoCartaoDebito( PAnsiChar(pValorTransacao),
                                    PAnsiChar(pNumeroCupomVenda),
                                    PAnsiChar(pNumeroControle) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoDebitoCompleta(
  ValorTransacao: Double; const NumeroCupomVenda: Integer;
  TipoOperacao: String; NumeroParcelas, SequenciaParcela: Integer;
  DataDebito: TDateTime; ValorParcela, ValorTaxaServico: Double;
  PermiteAlteracao: Boolean; const Reservado: String): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pTipoOperacao, pNumeroParcelas,
    pSequenciaParcela, pDataDebito,
    pValorParcela, pValorTaxaServico, pPermiteAlteracao, pReservado,
    pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  pTipoOperacao := PadRight(TipoOperacao, 3);
  pNumeroParcelas := Format('%.2d',[max(NumeroParcelas, 1)]);
  pDataDebito := IfThen(DataDebito = 0, StringOfChar('0',8), FormatDateTime('DDMMYYYY', DataDebito));
  pSequenciaParcela := Format('%.2d',[max(SequenciaParcela, 1)]);
  pValorParcela := Format('%.12d',[Round(ValorParcela*100)]);
  pValorTaxaServico := Format('%.12d',[Round(ValorTaxaServico*100)]);
  pPermiteAlteracao := IfThen(PermiteAlteracao, 'S', 'N');
  pReservado := PadRight('0000', 148, ' ');
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoDebitoCompleta( '+pValorTransacao+', '+pNumeroCupomVenda+', '+
      pNumeroControle+', '+pTipoOperacao+', '+pNumeroParcelas+', '+pSequenciaParcela+', '+
      pDataDebito+', '+pValorParcela+', '+pValorTaxaServico+', '+pPermiteAlteracao+', '+
      pReservado+' )');
    iRet := xTransacaoCartaoDebitoCompleta( PAnsiChar(pValorTransacao),
                                            PAnsiChar(pNumeroCupomVenda),
                                            PAnsiChar(pNumeroControle),
                                            PAnsiChar(pTipoOperacao),
                                            PAnsiChar(pNumeroParcelas),
                                            PAnsiChar(pSequenciaParcela),
                                            PAnsiChar(pDataDebito),
                                            PAnsiChar(pValorParcela),
                                            PAnsiChar(pValorTaxaServico),
                                            PAnsiChar(pPermiteAlteracao),
                                            PAnsiChar(pReservado) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoVoucher(ValorTransacao: Double;
  const NumeroCupomVenda: Integer): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoVoucher( '+pValorTransacao+', '+pNumeroCupomVenda+' )');
    iRet := xTransacaoCartaoVoucher( PAnsiChar(pValorTransacao),
                                     PAnsiChar(pNumeroCupomVenda),
                                     PAnsiChar(pNumeroControle) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoCartaoFrota(ValorTransacao: Double;
  const NumeroCupomVenda: Integer): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pNumeroControle: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCartaoFrota( '+pValorTransacao+', '+pNumeroCupomVenda+' )');
    iRet := xTransacaoCartaoFrota( PAnsiChar(pValorTransacao),
                                   PAnsiChar(pNumeroCupomVenda),
                                   PAnsiChar(pNumeroControle) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoQRCode(ValorTransacao: Double;
  const NumeroCupomVenda: Integer; const TransactionParamsData: String): String;
var
  iRet: LongInt;
  pValorTransacao, pNumeroCupomVenda, pNumeroControle, pTransactionParamsData: AnsiString;
begin
  DefineTagACBr;
  pValorTransacao := Format('%.12d',[Round(ValorTransacao*100)]);
  pNumeroCupomVenda := Format('%.6d',[NumeroCupomVenda]);
  pNumeroControle := StringOfChar('0',6);
  pTransactionParamsData := Trim(TransactionParamsData);
  Result := '';

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoQRCode( '+pValorTransacao+', '+pNumeroCupomVenda+', '+pTransactionParamsData+' )');
    iRet := xTransacaoQRCode( PAnsiChar(pValorTransacao),
                              PAnsiChar(pNumeroCupomVenda),
                              PAnsiChar(pNumeroControle),
                              PAnsiChar(pTransactionParamsData) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle);

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    ExibirQRCode('');  // Remove o QRCode
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.ObtemLogTransacaoJson(const NumeroControle: String): String;
var
  p: PAnsiChar;
  pNumeroControle: AnsiString;
begin
  pNumeroControle := Trim(NumeroControle);
  EmTransacao := True;
  try
    GravarLog('Lib.ObtemLogTransacaoJson( '+pNumeroControle+' )');
    p := xObtemLogTransacaoJson( PAnsiChar(pNumeroControle) );
    Result := String(p);
    GravarLog('  json: '+Result);
  finally
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.ObtemComprovanteTransacao(
  const NumeroControle: String; Resumida: Boolean): String;
var
  p, f, fn, fr: String;
  sl: TStringList;
  nc: Integer;
begin
  GravarLog('TACBrTEFPayKitAPI.ObtemComprovanteTransacao( '+NumeroControle+' )');
  Result := '';
  nc := StrToIntDef(NumeroControle, -1);
  if (nc < 1) then
    Exit;

  p := CalcPayKitPath(CPayKitDirCupons);
  if (nc = CPayKitNumControleReimpressao) then
  begin
    fn := 'ULTIMO.PRN';
    fr := fn;
  end
  else
  begin
    fn := Format('%.6d', [nc]) + '.' + Format('%.3d', [NumeroPDV]);
    fr := 'R'+fn;
  end;

  f := p + fn;
  if Resumida then
  begin
    if FileExists(p + fr) then
      f := p + fr;
  end
  else
  begin
    if (not FileExists(f)) and FileExists(p + fr) then
      f := p + fr;
  end;

  if not FileExists(f) then
    Exit;

  sl := TStringList.Create;
  try
    sl.LoadFromFile(f);
    Result := sl.Text;
  finally
    sl.Free;
  end;

  GravarLog( Result );
end;

procedure TACBrTEFPayKitAPI.TransacaoReimpressaoCupom;
var
  iRet: LongInt;
begin
  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoReimpressaoCupom()');
    iRet := xTransacaoReimpressaoCupom;
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
    fUltimoNumeroControle := CPayKitNumControleReimpressao;
  finally
    ExibirMensagem('', msgTerminal);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.TransacaoResumoVendas: String;
var
  iRet: LongInt;
  pNumeroControle: AnsiString;
begin
  pNumeroControle := StringOfChar('0',6);
  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoResumoVendas()');
    iRet := xTransacaoResumoVendas( PAnsiChar(pNumeroControle) );
    if (iRet = RET_OK) then
      Result := String(pNumeroControle)
    else
      Result := '';

    GravarLog('  ret: '+IntToStr(iRet)+', NumeroControle: '+Result);
    TratarErroPayKit(iRet);
  finally
    fUltimoNumeroControle := StrToIntDef(Result, -1);
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.ConfirmarTransacao(const NumeroControle: String
  ): LongInt;
var
  pNumeroControle: AnsiString;
begin
  pNumeroControle := PadRight(NumeroControle, 6);

  EmTransacao := True;
  try
    GravarLog('Lib.ConfirmaCartao( '+pNumeroControle+' )');
    Result := xConfirmaCartao( PAnsiChar(pNumeroControle) );
    GravarLog('  ret: '+IntToStr(Result));
  finally
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.DesfazerTransacao(const NumeroControle: String
  ): LongInt;
var
  pNumeroControle: AnsiString;
begin
  pNumeroControle := PadRight(NumeroControle, 6);

  EmTransacao := True;
  try
    GravarLog('Lib.DesfazCartao( '+pNumeroControle+' )');
    Result := xDesfazCartao( PAnsiChar(pNumeroControle) );
    GravarLog('  ret: '+IntToStr(Result));
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.CancelarTransacao(const NumeroControle: String);
var
  iRet: LongInt;
  pNumeroControle: AnsiString;
begin
  pNumeroControle := PadRight(NumeroControle, 6);

  EmTransacao := True;
  try
    GravarLog('Lib.TransacaoCancelamentoPagamento( '+pNumeroControle+' )');
    iRet := xTransacaoCancelamentoPagamento( PAnsiChar(pNumeroControle) );
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.FinalizarTransacao;
var
  iRet: LongInt;
begin
  EmTransacao := True;
  try
    GravarLog('Lib.FinalizaTransacao');
    iRet := xFinalizaTransacao;
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.ConsultaTransacao(Data: TDateTime; NSU: Integer;
  out Resposta, MensagemErro: String; NumEmpresa: Integer;
  NumLoja: Integer; NumPDV: Integer);
var
  iRet: LongInt;
  pNumeroEmpresa, pNumeroLoja, pNumeroPDV, pSolicitacao, pResposta, pMensagem: AnsiString;
begin
  pNumeroEmpresa := Format('%.4d',[IfThen(NumEmpresa=0, fNumeroEmpresa, NumEmpresa)]);
  pNumeroLoja := Format('%.4d',[IfThen(NumLoja=0, fNumeroLoja, NumLoja)]);
  pNumeroPDV := Format('%.4d',[IfThen(NumPDV=0, fNumeroPDV, NumPDV)]);
  pSolicitacao := FormatDateTime('YYYYMMDD', Data) + Format('%.6d',[NSU]) + StringOfChar(' ', 88);
  pResposta := StringOfChar(' ', 102);
  pMensagem := StringOfChar(' ', 64);
  Resposta := '';
  MensagemErro := '';

  EmTransacao := True;
  try
    GravarLog('Lib.ConsultaTransacao( '+pNumeroEmpresa+', '+pNumeroLoja+', '+pNumeroPDV+', '+pSolicitacao+' )');
    iRet := xConsultaTransacao( PAnsiChar(pNumeroEmpresa),
                                PAnsiChar(pNumeroLoja),
                                PAnsiChar(pNumeroPDV),
                                PAnsiChar(pSolicitacao),
                                PAnsiChar(pResposta),
                                PAnsiChar(pMensagem));

    if (iRet = RET_OK) then
    begin
      Resposta := Trim(String(pResposta));
      MensagemErro := Trim(String(pMensagem));
    end;

    GravarLog('  ret: '+IntToStr(iRet)+', Resp: '+Resposta+', Msg: '+MensagemErro);
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.AbortarTransacao;
begin
  EmTransacao := False;
end;

procedure TACBrTEFPayKitAPI.ForcaAtualizacaoTabelasPinpad;
var
  iRet: LongInt;
begin
  EmTransacao := True;
  try
    GravarLog('Lib.ForcaAtualizacaoTabelasPinpad');
    iRet := xForcaAtualizacaoTabelasPinpad;
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.ExibeImagemPinPadPayKit(const NomeArq: String);
var
  iRet: LongInt;
  pcNomeArquivo: AnsiString;
begin
  EmTransacao := True;
  try
    pcNomeArquivo := Trim(NomeArq);
    if not FileExists(pcNomeArquivo) then
      DoException(ACBrStr(Format(sErrImagemNaoEncontrada, [pcNomeArquivo])));

    GravarLog('Lib.ExibeImagemPinPadPayKit( '+pcNomeArquivo+' )');
    iRet := xExibeImagemPinPadPayKit( PAnsiChar(pcNomeArquivo) ) ;
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.ApagaImagemPinPadPayKit(const NomeImagem: String);
var
  iRet: LongInt;
  pNomeImagem: AnsiString;
begin
  EmTransacao := True;
  try
    pNomeImagem := Trim(NomeImagem);
    GravarLog('Lib.ApagaImagemPinPadPayKit( '+pNomeImagem+' )');
    iRet := xApagaImagemPinPadPayKit( PAnsiChar(pNomeImagem) );
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

function TACBrTEFPayKitAPI.ObtemDadosEmpresaLojaTEF(const CNPJ: String; out
  CodigoEmpresa: String; out CodigoLoja: String): LongInt;
var
  pCNPJ, pCodigoEmpresa, pCodigoLoja: AnsiString;
begin
  CodigoEmpresa := '';
  CodigoLoja := '';
  EmTransacao := True;
  try
    pCNPJ := PadLeft(Trim(CNPJ), 14, '0');
    pCodigoEmpresa := space(5);
    pCodigoLoja := space(5);

    GravarLog('Lib.ObtemDadosEmpresaLojaTEF( '+pCNPJ+' )');
    Result := xObtemDadosEmpresaLojaTEF( PAnsiChar(pCNPJ),
                                         PAnsiChar(pCodigoEmpresa),
                                         PAnsiChar(pCodigoLoja) );
    if (Result = RET_OK) then
    begin
      CodigoEmpresa := String(pCodigoEmpresa);
      CodigoLoja := String(pCodigoLoja);
    end;
    GravarLog('  ret: '+IntToStr(Result)+', Empresa:'+CodigoEmpresa+', Loja:'+CodigoLoja);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.ExibirMensagem(const AMsg: String;
  TipoMensagem: TACBrTEFPayKitTipoMensagem; MilissegundosExibicao: Integer);
begin
  if not VerificarSeEstaEmTransacao then
    Exit;

  if Assigned(fOnExibeMensagem) then
    fOnExibeMensagem(AMsg, TipoMensagem, MilissegundosExibicao);

  if MilissegundosExibicao >= 0 then
    fUltimaMsgEnviada := ''
  else
    fUltimaMsgEnviada := AMsg;
end;

procedure TACBrTEFPayKitAPI.PerguntarMenu(const Titulo: String;
  Opcoes: TStringList; var ItemSelecionado: LongInt);
begin
  if not VerificarSeEstaEmTransacao then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.PerguntarMenu( '+Titulo+' )');
  if Assigned(fQuandoPerguntarMenu) then
    fQuandoPerguntarMenu(Titulo, Opcoes, ItemSelecionado);
end;

procedure TACBrTEFPayKitAPI.PerguntarCampo(
  DefinicaoCampo: TACBrTEFPayKitDefinicaoCampo; var Resposta: String;
  var Acao: Integer);
begin
  if not VerificarSeEstaEmTransacao then
    Exit;
  GravarLog('TACBrTEFPayKitAPI.PerguntarCampo( '+DefinicaoCampo.TituloPergunta+' )');
  Acao := 0; // 0 - O operador digitou o valor, -1 - A opera��o foi cancelada
  if Assigned(fQuandoPerguntarCampo) then
    fQuandoPerguntarCampo(DefinicaoCampo, Resposta, Acao);
  Acao := min(max(Acao, -1), 0);
end;

function TACBrTEFPayKitAPI.VerificarTransacaoEmAndamento(
  EstadoOperacao: TACBrTEFPayKitEstadoOperacao): Boolean;
var
  Cancelar: Boolean;
begin
  if not VerificarSeEstaEmTransacao then
  begin
    Cancelar := True;
    Exit;
  end;

  Cancelar := False;
  if Assigned(fOnTransacaoEmAndamento) then
    fOnTransacaoEmAndamento(EstadoOperacao, Cancelar);

  Result := not Cancelar;
end;

procedure TACBrTEFPayKitAPI.ExibirQRCode(const DadosQRCode: String);
begin
  if not VerificarSeEstaEmTransacao then
    Exit;
  GravarLog('TACBrTEFPayKitAPI.ExibirQRCode( '+DadosQRCode+' )');
  if Assigned(fQuandoExibirQRCode) then
    fQuandoExibirQRCode(DadosQRCode);
end;

procedure TACBrTEFPayKitAPI.IdentificacaoAutomacaoComercial;
var
  iRet: LongInt;
  pNomeAutomacao, pVersaoAutomacao, pReservado: AnsiString;
begin
  pNomeAutomacao := PadRight(fNomeAutomacao, 20);
  pVersaoAutomacao := PadRight(fVersaoAutomacao, 20);
  pReservado := PadRight('010', 256);   // O segundo byte informa se a automa��o est� integrada com QR Code ('1' se sim, '0' se n�o)
  GravarLog('Lib.IdentificacaoAutomacaoComercial( '+pNomeAutomacao+', '+pVersaoAutomacao+', '+pReservado+ ')');
  iRet := xIdentificacaoAutomacaoComercial(PAnsiChar(pNomeAutomacao), PAnsiChar(pVersaoAutomacao), PAnsiChar(pReservado));
  GravarLog('  ret: '+IntToStr(iRet));
  TratarErroPayKit(iRet);
end;

procedure TACBrTEFPayKitAPI.ConfiguraModoDesfazimento;
var
  iRet: LongInt;
begin
  GravarLog('Lib.ConfiguraModoDesfazimento( '+IntToStr(fModoDesfazimento)+' )');
  iRet := xConfiguraModoDesfazimento(fModoDesfazimento);
  GravarLog('  ret: '+IntToStr(iRet));
  TratarErroPayKit(iRet);
end;

procedure TACBrTEFPayKitAPI.ConfiguraCNPJEstabelecimento;
var
  iRet: LongInt;
  pCNPJEstabelecimento: AnsiString;
begin
  if (Trim(fCNPJEstabelecimento) = '') then
    DoException(sErrCNPJNaoInformado);

  pCNPJEstabelecimento := PadRight(fCNPJEstabelecimento, 14);
  GravarLog('Lib.ConfiguraCNPJEstabelecimento( '+pCNPJEstabelecimento+' )');
  iRet := xConfiguraCNPJEstabelecimento(PAnsiChar(pCNPJEstabelecimento));
  GravarLog('  ret: '+IntToStr(iRet));
  TratarErroPayKit(iRet);
end;

procedure TACBrTEFPayKitAPI.ConfiguraEmpresaLojaPDV;
var
  iRet: LongInt;
  pNumeroEmpresa, pNumeroLoja, pNumeroPDV: AnsiString;
  emp, loja: String;
begin
  if (fNumeroEmpresa <= 0) or (fNumeroLoja <= 0) then
  begin
    if ObtemDadosEmpresaLojaTEF(fCNPJEstabelecimento, emp, loja) = 0 then
    begin
      NumeroEmpresa := StrToIntDef(emp, 0);
      NumeroLoja := StrToIntDef(loja, 0);
    end;
  end;

  if (fNumeroEmpresa <= 0) then
    DoException(sErrEmpresaNaoInformada);

  if (fNumeroLoja <= 0) then
    DoException(sErrLojaNaoInformada);

  pNumeroEmpresa := Format('%.4d',[fNumeroEmpresa]);
  pNumeroLoja := Format('%.4d',[fNumeroLoja]);
  pNumeroPDV := Format('%.4d',[fNumeroPDV]);
  GravarLog('Lib.ConfiguraEmpresaLojaPDV( '+pNumeroEmpresa+', '+pNumeroLoja+', '+pNumeroPDV+' )');
  iRet := xConfiguraEmpresaLojaPDV(PAnsiChar(pNumeroEmpresa), PAnsiChar(pNumeroLoja), PAnsiChar(pNumeroPDV));
  GravarLog('  ret: '+IntToStr(iRet));
  TratarErroPayKit(iRet);
end;

procedure TACBrTEFPayKitAPI.ConfiguraComunicacaoDTEF;
var
  iRet: LongInt;
  pConfiguracaoIpPortaSsl: AnsiString;
begin
  pConfiguracaoIpPortaSsl := Trim(fConfiguracaoIpPortaSsl);
  if (pConfiguracaoIpPortaSsl = '') then
    Exit;

  GravarLog('Lib.ConfiguraComunicacaoDTEF( '+pConfiguracaoIpPortaSsl+' )');
  iRet := xConfiguraComunicacaoDTEF(PAnsiChar(pConfiguracaoIpPortaSsl));
  GravarLog('  ret: '+IntToStr(iRet));
  TratarErroPayKit(iRet);
end;

procedure TACBrTEFPayKitAPI.BuscaCertificado;
var
  iRet: LongInt;
  pURL, pPathCertificado: AnsiString;
begin
  pURL := Trim(fURLCertificado);
  if (pURL = '') then
    pURL := CPayKitURLCertificado;

  EmTransacao := True;
  try
    pPathCertificado := PathWithoutDelim(CalcPayKitPath(CPayKitDirBin));
    GravarLog('Lib.BuscaCertificado( '+pURL+', '+pPathCertificado+' )');
    iRet := xBuscaCertificado(PAnsiChar(pURL), PAnsiChar(pPathCertificado));
    GravarLog('  ret: '+IntToStr(iRet));
    TratarErroPayKit(iRet);
  finally
    EmTransacao := False;
  end;
end;

procedure TACBrTEFPayKitAPI.DefineTagACBr;
begin
  DefineParametroTransacao(1029, 'ACBr');
end;

procedure TACBrTEFPayKitAPI.SetInicializada(AValue: Boolean);
begin
  if (fInicializada = AValue) then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.SetInicializada( '+BoolToStr(AValue, True)+' )');

  if AValue then
    Inicializar
  else
    DesInicializar;
end;

procedure TACBrTEFPayKitAPI.SetCNPJEstabelecimento(AValue: String);
begin
  if fCNPJEstabelecimento = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fCNPJEstabelecimento := LeftStr(OnlyNumber(AValue), 14);
end;

procedure TACBrTEFPayKitAPI.SetConfiguracaoIpPortaSsl(AValue: String);
begin
  if fConfiguracaoIpPortaSsl = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fConfiguracaoIpPortaSsl := AValue;
end;

procedure TACBrTEFPayKitAPI.SetEmTransacao(AValue: Boolean);
begin
  if (fEmTransacao = AValue) then
    Exit;

  if AValue then
    fUltimoNumeroControle := -1;

  fEmTransacao := AValue;
  fUltimaMsgEnviada := '';
end;

procedure TACBrTEFPayKitAPI.SetURLCertificado(AValue: String);
begin
  if fURLCertificado = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fURLCertificado := AValue;
end;

procedure TACBrTEFPayKitAPI.SetModoDesfazimento(AValue: Byte);
begin
  if fModoDesfazimento = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fModoDesfazimento := max(0, min(1, AValue));
end;

procedure TACBrTEFPayKitAPI.SetNomeAutomacao(AValue: String);
begin
  if fNomeAutomacao = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fNomeAutomacao := LeftStr(AValue, 20);
end;

procedure TACBrTEFPayKitAPI.SetNumeroEmpresa(AValue: Integer);
begin
  if fNumeroEmpresa = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fNumeroEmpresa := max(AValue, 0);
end;

procedure TACBrTEFPayKitAPI.SetNumeroLoja(AValue: Integer);
begin
  if fNumeroLoja = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fNumeroLoja := max(AValue, 0);
end;

procedure TACBrTEFPayKitAPI.SetNumeroPDV(AValue: Integer);
begin
  if fNumeroPDV = AValue then
    Exit;
  if fInicializada then
    DoException(sErrLibJaInicializada);
  fNumeroPDV := max(AValue, 0);
end;

procedure TACBrTEFPayKitAPI.SetVersaoAutomacao(AValue: String);
begin
  if fVersaoAutomacao = AValue then Exit;
  fVersaoAutomacao := LeftStr(AValue, 20);
end;

procedure TACBrTEFPayKitAPI.SetPathPayKit(AValue: String);
var
  p: String;
begin
  if (fPathPayKit = AValue) then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.SetPathPayKit( '+AValue+' )');

  if fInicializada then
    DoException(sErrLibJaInicializada);

  if (AValue = '') then
  begin
    fPathPayKit := '';
    Exit;
  end;

  p := PathWithDelim(ExtractFilePath(AValue));
  if FileExists(p + CPayKitLib) then  // Informou o diret�rio Bin... voltando um Path
    p := copy(p, 1, Length(p)-Length(CPayKitDirBin)-1);

  if not DirectoryExists(p + CPayKitDirBin) then
    DoException(Format(sErrDirPayKitInvalido, [CPayKitDirBin, p]));

  fPathPayKit := p;
end;

function TACBrTEFPayKitAPI.CalcPayKitPath(ASubFolder: String;
  VerificarSeExiste: Boolean): String;
var
  p: String;
begin
  p := PathPayKit;
  if (p = '') then
    p := ApplicationPath;

  if VerificarSeExiste and (not DirectoryExists(p + ASubFolder)) then
    DoException(Format(sErrDirPayKitInvalido, [ASubFolder, p]));

  Result := p + ASubFolder + PathDelim;
end;

procedure TACBrTEFPayKitAPI.VerificarEAjustarConf;
var
  Path, PathInterno, PathCupom, ArqIni: String;
  Ini: TMemIniFile;
begin
  CriarArquivoConfSeNaoExistir;

  Path := CalcPayKitPath(CPayKitDirBin);
  ArqIni := Path + CPayKitConf;
  if not FileExists(ArqIni) then
    DoException(Format(sErrArqPayKitNaoEncontrado, [CPayKitConf, Path]));

  PathCupom := CalcPayKitPath(CPayKitDirCupons, False);
  if not DirectoryExists(PathCupom) then
    ForceDirectories(PathCupom);
  PathInterno := CalcPayKitPath(CPayKitDirInterno, False);
  if not DirectoryExists(PathInterno) then
    ForceDirectories(PathInterno);

  Ini := TMemIniFile.Create(ArqIni);
  try
    Ini.WriteString('CONFIG', 'DIRETORIOBASE', PathWithoutDelim(Path) );
    Ini.WriteString('CONFIG', 'QTDIRETORIOBASE', Path + 'QtApplication' );
    Ini.WriteString('DIRETORIOS', 'CUPONS', PathWithoutDelim(PathCupom) );
    Ini.WriteString('DIRETORIOS', 'INTERNO', PathWithoutDelim(PathInterno) );
    if (fPortaPinPad <> '') then
      Ini.WriteString('PIN', 'PORTA', fPortaPinPad );

    Ini.WriteInteger('DIVERSOS', 'OtimizacaoMensagemTela', 0);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TACBrTEFPayKitAPI.CriarArquivoConfSeNaoExistir;
var
  p, f: String;
  Ini: TMemIniFile;
begin
  p := CalcPayKitPath(CPayKitDirBin);
  f := p + CPayKitConf;
  if FileExists(f) then
    Exit;

  Ini := TMemIniFile.Create(f);
  try
    Ini.WriteString('CONFIG', 'DIRETORIOBASE', PathWithoutDelim(p) );
    Ini.WriteString('CONFIG', 'VERSAODPOS8', '0');
    Ini.WriteInteger('CONFIG', 'NIVELDEBUG', 10);
    Ini.WriteString('CONFIG', 'QTDIRETORIOBASE', p + 'QtApplication' );
    Ini.WriteInteger('CONFIG', 'QTPORTASOCKET', 30000);

    Ini.WriteString('DIRETORIOS', 'CUPONS', PathWithoutDelim(CalcPayKitPath(CPayKitDirCupons)) );
    Ini.WriteString('DIRETORIOS', 'INTERNO', PathWithoutDelim(CalcPayKitPath(CPayKitDirInterno)) );

    Ini.WriteInteger('PIN', 'ProcurarPinpad', 1);
    Ini.WriteInteger('PIN', 'Ativo', 1);
    Ini.WriteInteger('PIN', 'TipoBiblioteca', 0);
    Ini.WriteString('PIN', 'PORTA', fPortaPinPad);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

function TACBrTEFPayKitAPI.VerificarSeEstaEmTransacao: Boolean;
begin
  Result := EmTransacao;
  if not Result then
    GravarLog('  Sem Transacao');
end;

procedure TACBrTEFPayKitAPI.LoadLibFunctions;

  procedure PayKitFunctionDetect(LibName, FuncName: AnsiString; var LibPointer: Pointer;
    FuncIsRequired: Boolean = True) ;
  begin
    if not Assigned( LibPointer )  then
    begin
      GravarLog('   '+FuncName);
      if not FunctionDetect(LibName, FuncName, LibPointer) then
      begin
        LibPointer := NIL ;
        if FuncIsRequired then
          DoException(Format('Erro ao carregar a fun��o: %s de: %s',[FuncName, LibName]))
        else
          GravarLog(Format('     Fun��o n�o requerida: %s n�o encontrada em: %s',[FuncName, LibName]));
        end ;
    end ;
  end;

var
  sLibName, p: string;
begin
  if fCarregada then
    Exit;

  p := CalcPayKitPath(CPayKitDirBin);
  if not FileExists(p + CPayKitLib) then
    DoException(Format(sErrArqPayKitNaoEncontrado, [CPayKitLib, p]));

  sLibName := p + CPayKitLib;
  GravarLog('TACBrTEFPayKitAPI.LoadLibFunctions - '+sLibName);

  PayKitFunctionDetect(sLibName, 'TransacaoCheque', @xTransacaoCheque);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoCredito', @xTransacaoCartaoCredito);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoDebito', @xTransacaoCartaoDebito);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoVoucher', @xTransacaoCartaoVoucher);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoFrota', @xTransacaoCartaoFrota);
  PayKitFunctionDetect(sLibName, 'TransacaoQRCode', @xTransacaoQRCode);
  PayKitFunctionDetect(sLibName, 'TransacaoCancelamentoPagamento', @xTransacaoCancelamentoPagamento);
  PayKitFunctionDetect(sLibName, 'TransacaoPreAutorizacaoCartaoCredito', @xTransacaoPreAutorizacaoCartaoCredito);
  PayKitFunctionDetect(sLibName, 'TransacaoConsultaParcelas', @xTransacaoConsultaParcelas);
  PayKitFunctionDetect(sLibName, 'TransacaoResumoVendas', @xTransacaoResumoVendas);
  PayKitFunctionDetect(sLibName, 'TransacaoReimpressaoCupom', @xTransacaoReimpressaoCupom);
  PayKitFunctionDetect(sLibName, 'ConfirmaCartao', @xConfirmaCartao);
  PayKitFunctionDetect(sLibName, 'DesfazCartao', @xDesfazCartao);
  PayKitFunctionDetect(sLibName, 'FinalizaTransacao', @xFinalizaTransacao);
  PayKitFunctionDetect(sLibName, 'ConsultaTransacao', @xConsultaTransacao);
  PayKitFunctionDetect(sLibName, 'VersaoDPOS', @xVersaoDPOS);
  PayKitFunctionDetect(sLibName, 'InicializaDPOS', @xInicializaDPOS);
  PayKitFunctionDetect(sLibName, 'FinalizaDPOS', @xFinalizaDPOS);
  PayKitFunctionDetect(sLibName, 'IdentificacaoAutomacaoComercial', @xIdentificacaoAutomacaoComercial);
  PayKitFunctionDetect(sLibName, 'ConfiguraModoDesfazimento', @xConfiguraModoDesfazimento);
  PayKitFunctionDetect(sLibName, 'DefineParametroTransacao', @xDefineParametroTransacao);
  PayKitFunctionDetect(sLibName, 'ConfiguraCNPJEstabelecimento', @xConfiguraCNPJEstabelecimento);
  PayKitFunctionDetect(sLibName, 'ConfiguraEmpresaLojaPDV', @xConfiguraEmpresaLojaPDV);
  PayKitFunctionDetect(sLibName, 'ConfiguraComunicacaoDTEF', @xConfiguraComunicacaoDTEF);
  PayKitFunctionDetect(sLibName, 'BuscaCertificado', @xBuscaCertificado);
  PayKitFunctionDetect(sLibName, 'TransacaoEspecial', @xTransacaoEspecial);
  PayKitFunctionDetect(sLibName, 'LeIdentificacaoPinPad', @xLeIdentificacaoPinPad);
  PayKitFunctionDetect(sLibName, 'TransacaoFuncoesAdministrativas', @xTransacaoFuncoesAdministrativas);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoCreditoCompleta', @xTransacaoCartaoCreditoCompleta);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoDebitoCompleta', @xTransacaoCartaoDebitoCompleta);
  PayKitFunctionDetect(sLibName, 'TransacaoCartaoVoucherCompleta', @xTransacaoCartaoVoucherCompleta);
  PayKitFunctionDetect(sLibName, 'TransacaoManualPOSCompleta', @xTransacaoManualPOSCompleta);
  PayKitFunctionDetect(sLibName, 'ObtemLogTransacaoJson', @xObtemLogTransacaoJson);
  PayKitFunctionDetect(sLibName, 'ForcaAtualizacaoTabelasPinpad', @xForcaAtualizacaoTabelasPinpad);
  PayKitFunctionDetect(sLibName, 'ExibeImagemPinPadPayKit', @xExibeImagemPinPadPayKit);
  PayKitFunctionDetect(sLibName, 'ApagaImagemPinPadPayKit', @xApagaImagemPinPadPayKit);
  PayKitFunctionDetect(sLibName, 'ObtemDadosEmpresaLojaTEF', @xObtemDadosEmpresaLojaTEF);

  PayKitFunctionDetect(sLibName, 'RegPDVDisplayTerminal', @xRegPDVDisplayTerminal);
  PayKitFunctionDetect(sLibName, 'RegPDVDisplayErro', @xRegPDVDisplayErro);
  PayKitFunctionDetect(sLibName, 'RegPDVMensagem', @xRegPDVMensagem);
  PayKitFunctionDetect(sLibName, 'RegPDVBeep', @xRegPDVBeep);
  PayKitFunctionDetect(sLibName, 'RegPDVSolicitaConfirmacao', @xRegPDVSolicitaConfirmacao);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraCartao', @xRegPDVEntraCartao);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraDataValidade', @xRegPDVEntraDataValidade);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraData', @xRegPDVEntraData);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraCodigoSeguranca', @xRegPDVEntraCodigoSeguranca);
  PayKitFunctionDetect(sLibName, 'RegPDVSelecionaOpcao', @xRegPDVSelecionaOpcao);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraValor', @xRegPDVEntraValor);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraNumero', @xRegPDVEntraNumero);
  PayKitFunctionDetect(sLibName, 'RegPDVOperacaoCancelada', @xRegPDVOperacaoCancelada);
  PayKitFunctionDetect(sLibName, 'RegPDVSetaOperacaoCancelada', @xRegPDVSetaOperacaoCancelada);
  PayKitFunctionDetect(sLibName, 'RegPDVProcessaMensagens', @xRegPDVProcessaMensagens);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraString', @xRegPDVEntraString);
  PayKitFunctionDetect(sLibName, 'RegPDVConsultaAVS', @xRegPDVConsultaAVS);
  PayKitFunctionDetect(sLibName, 'RegPDVMensagemAdicional', @xRegPDVMensagemAdicional);
  PayKitFunctionDetect(sLibName, 'RegPDVImagemAdicional', @xRegPDVImagemAdicional);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraCodigoBarras', @xRegPDVEntraCodigoBarras);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraCodigoBarrasLido', @xRegPDVEntraCodigoBarrasLido);
  PayKitFunctionDetect(sLibName, 'RegPDVMensagemAlerta', @xRegPDVMensagemAlerta);
  PayKitFunctionDetect(sLibName, 'RegPDVPreviewComprovante', @xRegPDVPreviewComprovante);
  PayKitFunctionDetect(sLibName, 'RegPDVSelecionaPlanos', @xRegPDVSelecionaPlanos);
  PayKitFunctionDetect(sLibName, 'RegPDVSelecionaPlanosEx', @xRegPDVSelecionaPlanosEx);
  PayKitFunctionDetect(sLibName, 'RegPDVEntraValorEspecial', @xRegPDVEntraValorEspecial);
  PayKitFunctionDetect(sLibName, 'RegPDVComandos', @xRegPDVComandos);

  fCarregada := True;
end;

procedure TACBrTEFPayKitAPI.UnLoadLibFunctions;
var
  sLibName: String;
begin
  if not fCarregada then
    Exit;

  GravarLog('TACBrTEFPayKitAPI.UnLoadLibFunctions');

  sLibName := CalcPayKitPath(CPayKitDirBin) + CPayKitLib;
  UnLoadLibrary( sLibName );
  fCarregada := False;
  ClearMethodPointers;
end;

procedure TACBrTEFPayKitAPI.ClearMethodPointers;
begin
  xTransacaoCheque := Nil;
  xTransacaoCartaoCredito := Nil;
  xTransacaoCartaoDebito := Nil;
  xTransacaoCartaoVoucher := Nil;
  xTransacaoCartaoFrota := Nil;
  xTransacaoQRCode := Nil;
  xTransacaoCancelamentoPagamento := Nil;
  xTransacaoPreAutorizacaoCartaoCredito := Nil;
  xTransacaoConsultaParcelas := Nil;
  xTransacaoResumoVendas := Nil;
  xTransacaoReimpressaoCupom := Nil;
  xConfirmaCartao := Nil;
  xDesfazCartao := Nil;
  xFinalizaTransacao := Nil;
  xConsultaTransacao := Nil;
  xVersaoDPOS := Nil;
  xInicializaDPOS := Nil;
  xFinalizaDPOS := Nil;
  xIdentificacaoAutomacaoComercial := Nil;
  xConfiguraModoDesfazimento := Nil;
  xDefineParametroTransacao := Nil;
  xConfiguraCNPJEstabelecimento := Nil;
  xConfiguraEmpresaLojaPDV := Nil;
  xConfiguraComunicacaoDTEF := Nil;
  xBuscaCertificado := Nil;
  xTransacaoEspecial := Nil;
  xLeIdentificacaoPinPad := Nil;
  xTransacaoFuncoesAdministrativas := Nil;
  xTransacaoCartaoCreditoCompleta := Nil;
  xTransacaoCartaoDebitoCompleta := Nil;
  xTransacaoCartaoVoucherCompleta := Nil;
  xTransacaoManualPOSCompleta := Nil;
  xObtemLogTransacaoJson := Nil;
  xForcaAtualizacaoTabelasPinpad := Nil;
  xExibeImagemPinPadPayKit := Nil;
  xApagaImagemPinPadPayKit := Nil;
  xObtemDadosEmpresaLojaTEF := Nil;

  xRegPDVDisplayTerminal := Nil;
  xRegPDVDisplayErro := Nil;
  xRegPDVMensagem := Nil;
  xRegPDVBeep := Nil;
  xRegPDVSolicitaConfirmacao := Nil;
  xRegPDVEntraCartao := Nil;
  xRegPDVEntraDataValidade := Nil;
  xRegPDVEntraData := Nil;
  xRegPDVEntraCodigoSeguranca := Nil;
  xRegPDVSelecionaOpcao := Nil;
  xRegPDVEntraValor := Nil;
  xRegPDVEntraNumero := Nil;
  xRegPDVOperacaoCancelada := Nil;
  xRegPDVSetaOperacaoCancelada := Nil;
  xRegPDVProcessaMensagens := Nil;
  xRegPDVEntraString := Nil;
  xRegPDVConsultaAVS := Nil;
  xRegPDVMensagemAdicional := Nil;
  xRegPDVImagemAdicional := Nil;
  xRegPDVEntraCodigoBarras := Nil;
  xRegPDVEntraCodigoBarrasLido := Nil;
  xRegPDVMensagemAlerta := Nil;
  xRegPDVPreviewComprovante := Nil;
  xRegPDVSelecionaPlanos := Nil;
  xRegPDVSelecionaPlanosEx := Nil;
  xRegPDVEntraValorEspecial := Nil;
  xRegPDVComandos := Nil;
end;

procedure TACBrTEFPayKitAPI.RegisterCallBackFunctions;
begin
  xRegPDVDisplayTerminal(CallBackDisplayTerminal);
  xRegPDVDisplayErro(CallBackDisplayErro);
  xRegPDVMensagem(CallBackMensagem);
  xRegPDVBeep(CallBackBeep);
  xRegPDVSolicitaConfirmacao(CallBackSolicitaConfirmacao);
  xRegPDVEntraCartao(CallBackEntraCartao);
  xRegPDVEntraDataValidade(CallBackEntraDataValidade);
  xRegPDVEntraData(CallBackEntraData);
  xRegPDVEntraCodigoSeguranca(CallBackEntraCodigoSeguranca);
  xRegPDVSelecionaOpcao(CallBackSelecionaOpcao);
  xRegPDVEntraValor(CallBackEntraValor);
  xRegPDVEntraNumero(CallBackEntraNumero);
  xRegPDVOperacaoCancelada(CallBackOperacaoCancelada);
  xRegPDVSetaOperacaoCancelada(CallBackSetaOperacaoCancelada);
  xRegPDVProcessaMensagens(CallBackProcessaMensagens);
  xRegPDVEntraString(CallBackEntraString);
  xRegPDVConsultaAVS(CallBackConsultaAVS);
  xRegPDVMensagemAdicional(CallBackMensagemAdicional);
  xRegPDVImagemAdicional(CallBackImagemAdicional);
  xRegPDVEntraCodigoBarras(CallBackEntraCodigoBarras);
  xRegPDVEntraCodigoBarrasLido(CallBackEntraCodigoBarrasLido);
  xRegPDVMensagemAlerta(CallBackMensagemAlerta);
  xRegPDVPreviewComprovante(CallBackPreviewComprovante);
  xRegPDVSelecionaPlanos(CallBackSelecionaPlanos);
  xRegPDVSelecionaPlanosEx(CallBackSelecionaPlanosEx);
  xRegPDVEntraValorEspecial(CallBackEntraValorEspecial);
  xRegPDVComandos(CallBackComandos);
end;

procedure TACBrTEFPayKitAPI.TratarErroPayKit(AErrorCode: LongInt);
var
  MsgErro: String;
begin
  case AErrorCode of
    RET_OK: MsgErro := '';
  else
    MsgErro := Format('Erro retornado: %d', [AErrorCode]);
  end;

  if (MsgErro <> '') then
    DoException(MsgErro);
end;

procedure TACBrTEFPayKitAPI.DoException(const AErrorMsg: String);
var
  s: String;
begin
  if (Trim(AErrorMsg) = '') then
    Exit;

  s := ACBrStr(AErrorMsg);
  GravarLog('EACBrTEFPayKitAPI: '+s);
  raise EACBrTEFPayKitAPI.Create(s);
end;

procedure TACBrTEFPayKitAPI.VerificarCarregada;
begin
  if not fCarregada then
    DoException(sErrLibNaoInicializada);
end;

initialization
  vTEFPayKit := Nil;

finalization
  if Assigned(vTEFPayKit) then
    FreeAndNil(vTEFPayKit);

end.

