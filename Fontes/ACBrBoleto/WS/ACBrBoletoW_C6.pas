{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2024 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Victor Hugo Gonzales - Panda                   }
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
unit ACBrBoletoW_C6;

interface

uses
  Classes, SysUtils, ACBrBoletoWS, pcnConversao, ACBrBoletoConversao,
  synacode, strutils, DateUtils, ACBrDFeSSL, synautil, ACBrBoleto, httpsend, Math,
  ACBrBoletoWS.Rest, ACBrJSON;

type

  { TBoletoW_C6 }
  TBoletoW_C6 = class(TBoletoWSREST)
  private
//    function CodigoTipoTitulo(AEspecieDoc: String): String;
    function DatetoDateTime(const AValue: String): TDateTime;
    function DateTimeToDate( const AValue:TDateTime ):String;
  protected

    procedure DefinirURL; override;
    procedure DefinirContentType; override;
    procedure GerarHeader; override;
    procedure GerarDados; override;
    procedure DefinirAuthorization; override;
    function GerarTokenAutenticacao: string; override;
    function DefinirParametros: String;
    procedure DefinirParamOAuth; override;
    procedure DefinirKeyUser;
    procedure RequisicaoJson;
    procedure RequisicaoAltera;
  public
    constructor Create(ABoletoWS: TBoletoWS); override;

    function GerarRemessa: string; override;
    function Enviar: boolean; override;
  end;

const
  C_URL             = 'https://baas-api.c6bank.info/v1/bank_slips';
  C_URL_HOM         = 'https://baas-api-sandbox.c6bank.info/v1/bank_slips';

  C_URL_OAUTH_PROD  = 'https://baas-api.c6bank.info/v1/auth';
  C_URL_OAUTH_HOM   = 'https://baas-api-sandbox.c6bank.info/v1/auth';

  C_CONTENT_TYPE    = 'application/json';
  C_ACCEPT          = 'application/json';
  C_AUTHORIZATION   = 'Authorization';

  C_ACCEPT_ENCODING = 'gzip, deflate, br';

  C_CHARSET         = 'utf-8';
  C_ACCEPT_CHARSET  = 'utf-8';


implementation

uses
  ACBrUtil.FilesIO,
  ACBrUtil.Strings,
  ACBrUtil.DateTime,
  ACBrUtil.Base,
  ACBrUtil.Math,
  ACBrValidador;

{ TBoletoW_C6 }

procedure TBoletoW_C6.DefinirURL;
var
  LNossoNumeroCorrespondente: string;
begin
  if Assigned(Atitulo) then
    LNossoNumeroCorrespondente := ATitulo.NossoNumeroCorrespondente;

  case Boleto.Configuracoes.WebService.Ambiente of
    tawsProducao    : FPURL.URLProducao    := C_URL;
    tawsHomologacao : FPURL.URLHomologacao := C_URL_HOM;
  end;

  case Boleto.Configuracoes.WebService.Operacao of
    tpInclui           :    FPURL.SetPathURI( '/' );
    tpAltera           :    FPURL.SetPathURI( '/' + LNossoNumeroCorrespondente );
    tpConsultaDetalhe  :    FPURL.SetPathURI( '/' + LNossoNumeroCorrespondente );
    tpCancelar,
    tpBaixa            :    FPURL.SetPathURI( '/' + LNossoNumeroCorrespondente+'/cancel' );
  end;
end;

procedure TBoletoW_C6.DefinirContentType;
begin
  FPContentType := C_CONTENT_TYPE;
end;

procedure TBoletoW_C6.GerarHeader;
begin
  ClearHeaderParams;
  DefinirContentType;
  DefinirKeyUser;
  AddHeaderParam('partner-software-name', 'ProjetoACBr');
end;

procedure TBoletoW_C6.GerarDados;
begin
  if Assigned(Boleto) then
    DefinirURL;

  case Boleto.Configuracoes.WebService.Operacao of
    tpInclui:
      begin
        FMetodoHTTP := htPOST; // Define M�todo POST para Incluir
        RequisicaoJson;
      end;
    tpAltera:
      begin
        FMetodoHTTP := htPUT; // Define M�todo DELETE para Baixa
        RequisicaoAltera;
      end;
    tpConsultaDetalhe:
      begin
        FMetodoHTTP := htGET; // Define M�todo GET Consulta Detalhe
        // Sem Payload
      end;
    tpBaixa, tpCancelar:
      begin
        FMetodoHTTP := htPUT; // Define M�todo DELETE para Baixa
        // Sem Payload
      end;
  else
    raise EACBrBoletoWSException.Create
      (ClassName + Format(S_OPERACAO_NAO_IMPLEMENTADO,
      [TipoOperacaoToStr(Boleto.Configuracoes.WebService.Operacao)]));
  end;

end;

procedure TBoletoW_C6.DefinirAuthorization;
begin
  FPAuthorization := C_AUTHORIZATION + ': Bearer ' + GerarTokenAutenticacao;
end;

function TBoletoW_C6.GerarTokenAutenticacao: string;
begin
  OAuth.Payload := True;
  Result := inherited GerarTokenAutenticacao;
end;

procedure TBoletoW_C6.DefinirKeyUser;
begin
  if Assigned(aTitulo) then
    FPKeyUser := '';
end;

function TBoletoW_C6.DefinirParametros: String;
begin
//
end;

procedure TBoletoW_C6.DefinirParamOAuth;
begin
  FParamsOAuth := Format( 'client_id=%s&client_secret=%s&grant_type=client_credentials',
                   [Boleto.Cedente.CedenteWS.ClientID,
                    Boleto.Cedente.CedenteWS.ClientSecret] );
end;

function TBoletoW_C6.DatetoDateTime(const AValue: String): TDateTime;
begin
  Result := StrToDateDef( StringReplace( AValue,'.','/', [rfReplaceAll] ),0);
end;

function TBoletoW_C6.DateTimeToDate(const AValue: TDateTime): String;
begin
  result := FormatDateBr( aValue, 'YYYY-MM-DD');
end;

procedure TBoletoW_C6.RequisicaoJson;
var
  LJson : TACBrJSONObject;
  LDesconto : TACBrJSONObject;
  LMensagem : TACBrJSONArray;
  I: Integer;
  LValorMoraJuros : Double;
  LCNPJCPFPayer, LEmailPayer : string;
begin
  if Assigned(ATitulo) then
  begin
    if not ((Length(ATitulo.SeuNumero) >= 1) and
            (Length(ATitulo.SeuNumero) <= 10) and
             StrIsAlphaNum(ATitulo.SeuNumero)) then
      raise Exception.Create('Campo SeuNumero [a-zA-Z0-9] � inv�lido min. 1 max. 10!');


    if ATitulo.NossoNumero = '' then
      ATitulo.NossoNumero := '0';

    if not ((ATitulo.NossoNumero = '0') or
            (ATitulo.NossoNumero = Poem_Zeros('',Boleto.Banco.TamanhoMaximoNossoNum)) ) then
      raise Exception.Create('Campo NossoNumero � inv�lido obrigat�riamente deve ser informado valor 0!');

    if not (ATitulo.Carteira = '15') then
      raise Exception.Create('Campo Carteira � inv�lido obrigat�riamente deve ser informado valor 15. N�o previsto outra carteira na API!');


    LCNPJCPFPayer := OnlyNumber(ATitulo.Sacado.CNPJCPF);

    case Length(LCNPJCPFPayer) of
      11 : if ValidarCPF(LCNPJCPFPayer) <> '' then
             raise Exception.Create('Campo CNPJCPF (CPF) do Pagador � inv�lido!');
      14 : if ValidarCNPJ(LCNPJCPFPayer) <> '' then
             raise Exception.Create('Campo CNPJCPF (CNPJ) do Pagador � inv�lido!');
    end;

    LEmailPayer := Copy(ATitulo.Sacado.Email,1,200);

    if (LEmailPayer <> '') and (ValidarEmail(LEmailPayer) <> '') then
      raise Exception.Create('Campo Email do Pagador � inv�lido!');

    try
      LJson := TACBrJSONObject.Create
        .AddPair('external_reference_id',ATitulo.SeuNumero)
        .AddPair('amount',ATitulo.ValorDocumento)
        .AddPair('due_date',DateTimeToDate(ATitulo.Vencimento));


      if (Trim(ATitulo.Mensagem.Text) <> '') then
      begin
        LMensagem := TACBrJSONArray.Create;
        for I := 0 to 3 do
        begin
          LMensagem.AddElement(Trim(Copy(ATitulo.Mensagem[I],0,80)));
          if LMensagem.Count + 1 > I then
            Break;
        end;
        LJson.AddPair('instructions',LMensagem)
      end;

      if (ATitulo.ValorDesconto > 0) or (ATitulo.ValorDesconto2 > 0) or (ATitulo.ValorDesconto3 > 0) then
      begin
        LDesconto :=  TACBrJSONObject.Create;
        LDesconto.AddPair('discount_type',IfThen(ATitulo.CodigoDesconto = cdValorFixo, 'V', 'P'));

        if (ATitulo.ValorDesconto > 0) then
        begin
          LDesconto.AddPair('first',
              TACBrJSONObject.Create
              .AddPair('value',ATitulo.ValorDesconto)
              .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto))
            );
        end;
        if (ATitulo.ValorDesconto2 > 0) then
        begin
          LDesconto.AddPair('second',
              TACBrJSONObject.Create
              .AddPair('value',ATitulo.ValorDesconto2)
              .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto2))
            );
        end;
        if (ATitulo.ValorDesconto3 > 0) then
        begin
          LDesconto.AddPair('third',
              TACBrJSONObject.Create
              .AddPair('value',ATitulo.ValorDesconto3)
              .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto3))
            );
        end;

        LJson.AddPair('discount', LDesconto);
      end;

      if (ATitulo.ValorMoraJuros > 0) then
      begin
        //26/05/2025 - https://developers.c6bank.com.br/apis/bankslip#tag/bank_slips/POST/
        //Valor ou percentual dos juros por atraso.
        //Se o tipo for "V", esse valor ser� fixo por dia.
        //Se for "P", o valor � um percentual do t�tulo, e ser� dividido por 30 para calcular o valor di�rio.
        //(quem faz a divis�o � a API, o valor enviado � integral)
        case ATitulo.CodigoMoraJuros of
          cjValorDia    : LValorMoraJuros := ATitulo.ValorMoraJuros;
          cjValorMensal : LValorMoraJuros := ATitulo.ValorMoraJuros / 30;
          cjTaxaDiaria  : LValorMoraJuros := RoundABNT(ATitulo.ValorMoraJuros * 30,2);
          cjTaxaMensal  : LValorMoraJuros := ATitulo.ValorMoraJuros;
        end;

        LJson.AddPair('interest',
          TACBrJSONObject.Create
            .AddPair('type',IfThen(ATitulo.CodigoMoraJuros in [cjTaxaDiaria,cjTaxaMensal], 'P', 'V') )
            .AddPair('value',LValorMoraJuros )
            .AddPair('dead_line',IfThen(ATitulo.DataMoraJuros > 0,DaysBetween(ATitulo.Vencimento,ATitulo.DataMoraJuros), 1) )
        );
      end;
      if (ATitulo.PercentualMulta > 0) then
      begin
        LJson.AddPair('fine',
          TACBrJSONObject.Create
            .AddPair('type',IfThen(ATitulo.MultaValorFixo, 'V', 'P') )
            .AddPair('value',ATitulo.PercentualMulta )
            .AddPair('dead_line',IfThen(ATitulo.DataMulta > 0, DaysBetween(ATitulo.Vencimento,ATitulo.DataMulta), 1) )
        );
      end;
      LJson.AddPair('payer',
          TACBrJSONObject.Create
            .AddPair('name', Copy(Trim(ATitulo.Sacado.NomeSacado),1,33) )//na documenta��o � 40 mas a API valida 33
            .AddPair('tax_id', LCNPJCPFPayer )
            .AddPair('address',
              TACBrJSONObject.Create
                .AddPair('street', Copy(Trim(ATitulo.Sacado.Logradouro),1,40) )
                .AddPair('number', StrToInt64Def(ATitulo.Sacado.Numero,0) )
                .AddPair('complement',Copy(Trim(ATitulo.Sacado.Complemento),1,24) )
                .AddPair('city',Copy(Trim(ATitulo.Sacado.Cidade),1,40) )
                .AddPair('state',AnsiUpperCase(Trim(ATitulo.Sacado.UF)) )
                .AddPair('zip_code',Copy(OnlyNumber(ATitulo.Sacado.CEP),1,8) )
            )
        );
        if LEmailPayer <> '' then
          LJson.AsJSONObject['payer'].AddPair('email',  LEmailPayer);

      FPDadosMsg := LJson.ToJSON;
    finally
      LJson.Free;
    end;
  end;
end;

procedure TBoletoW_C6.RequisicaoAltera;
var LJson : TACBrJSONObject;
  LValorMoraJuros : Double;
begin
  LJson := TACBrJSONObject.Create;
  try
  case Atitulo.OcorrenciaOriginal.Tipo of
    toRemessaAlterarVencimento :
      begin
        LJson.AddPair('due_date',DateTimeToDate(ATitulo.Vencimento));
      end;
    toRemessaAlterarValorTitulo :
      begin
        LJson.AddPair('amount',ATitulo.ValorDocumento);
      end;
    toRemessaAlterarDesconto :
      begin
        if (ATitulo.ValorDesconto > 0) or (ATitulo.ValorDesconto2 > 0) or (ATitulo.ValorDesconto3 > 0) then
        begin
          LJson.AddPair('discount',
            TACBrJSONObject.Create
              .AddPair('discount_type',IfThen(ATitulo.CodigoDesconto = cdValorFixo, 'V', 'P'))
            );
            if (ATitulo.ValorDesconto > 0) then
            begin
              LJson.AddPair('first',
                 TACBrJSONObject.Create
                   .AddPair('value',ATitulo.ValorDesconto)
                   .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto))
                 );
            end;
            if (ATitulo.ValorDesconto2 > 0) then
            begin
              LJson.AddPair('second',
                TACBrJSONObject.Create
                  .AddPair('value',ATitulo.ValorDesconto2)
                  .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto2))
                );
            end;
            if (ATitulo.ValorDesconto3 > 0) then
            begin
              LJson.AddPair('third',
                TACBrJSONObject.Create
                  .AddPair('value',ATitulo.ValorDesconto3)
                  .AddPair('dead_line',DaysBetween(ATitulo.Vencimento,ATitulo.DataDesconto3))
                );
            end
        end;
      end;
    toRemessaAlterarJurosMora :
      begin
        if (ATitulo.ValorMoraJuros > 0) then
        begin
          case ATitulo.CodigoMoraJuros of
            cjValorDia    : LValorMoraJuros := ATitulo.ValorMoraJuros;
            cjValorMensal : LValorMoraJuros := ATitulo.ValorMoraJuros / 30;
            cjTaxaDiaria  : LValorMoraJuros := RoundABNT(ATitulo.ValorMoraJuros * 30,2);
            cjTaxaMensal  : LValorMoraJuros := ATitulo.ValorMoraJuros;
          end;

          LJson.AddPair('interest',
            TACBrJSONObject.Create
              .AddPair('type',IfThen(ATitulo.CodigoMoraJuros in [cjTaxaDiaria,cjTaxaMensal], 'P', 'V') )
              .AddPair('value',LValorMoraJuros )
              .AddPair('dead_line',IfThen(ATitulo.DataMoraJuros > 0,DaysBetween(ATitulo.Vencimento,ATitulo.DataMoraJuros), 1) )
          );
        end;
      end;
    toRemessaAlterarMulta :
      begin
        if (ATitulo.PercentualMulta > 0) then
        begin
            LJson.AddPair('fine',
              TACBrJSONObject.Create
                .AddPair('type',IfThen(ATitulo.MultaValorFixo, 'V', 'P') )
                .AddPair('value',ATitulo.PercentualMulta )
                .AddPair('dead_line',IfThen(ATitulo.DataMulta > 0, DaysBetween(ATitulo.Vencimento,ATitulo.DataMulta), 1) )
            );  
        end;
      end;
  end;
    FPDadosMsg := LJson.ToJSON;    
  finally
    LJson.Free;
  end;      
end;

constructor TBoletoW_C6.Create(ABoletoWS: TBoletoWS);
begin
  inherited Create(ABoletoWS);

  FPAccept := C_ACCEPT;

  if Assigned(OAuth) then
  begin
    case OAuth.Ambiente of
      tawsProducao    : OAuth.URL.URLProducao    := C_URL_OAUTH_PROD;
      tawsHomologacao : OAuth.URL.URLHomologacao := C_URL_OAUTH_HOM;
    end;

    OAuth.Payload := True;
  end;
end;

function TBoletoW_C6.GerarRemessa: string;
begin
  DefinirCertificado;
  result := inherited GerarRemessa;
end;

function TBoletoW_C6.Enviar: boolean;
var
  LJsonObject : TACBrJSONObject;
begin
  DefinirCertificado;
  Result := inherited Enviar;
end;

end.

