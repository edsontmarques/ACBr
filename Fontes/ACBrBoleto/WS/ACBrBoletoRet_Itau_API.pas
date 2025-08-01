{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2024 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Jos� M S Junior, Victor Hugo Gonzales          }
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

unit ACBrBoletoRet_Itau_API;

{ TRetornoEnvio_Itau_API_API }

interface

uses
  ACBrBoleto,
  ACBrBoletoRetorno,
  ACBrBoletoWS.Rest,
  ACBrUtil.Base,
  StrUtils;

type

{ TRetornoEnvio_Itau_API_API }

 TRetornoEnvio_Itau_API = class(TRetornoEnvioREST)
  private
    function DateToDateTimeItau(const AValue: String): TDateTime;
    function RetornaCodigoOcorrencia(pSituacaoGeralBoleto: string): String;
    function RetornaDescricaoStatusTitulo(AStatus: string): String;

  public
    constructor Create(ABoletoWS: TACBrBoleto); override;
    destructor  Destroy; Override;
    function LerListaRetorno: Boolean; override;
    function LerRetorno(const ARetornoWS: TACBrBoletoRetornoWS): Boolean;override;
    function RetornoEnvio(const AIndex: Integer): Boolean; override;

  end;

implementation

uses
  SysUtils,
  ACBrJSON,
  ACBrBoletoConversao,
  ACBrUtil.DateTime;

{ TRetornoEnvio }

constructor TRetornoEnvio_Itau_API.Create(ABoletoWS: TACBrBoleto);
begin
  inherited Create(ABoletoWS);
end;

destructor TRetornoEnvio_Itau_API.Destroy;
begin
  inherited Destroy;
end;

function TRetornoEnvio_Itau_API.LerRetorno(const ARetornoWS: TACBrBoletoRetornoWS): Boolean;
var
  LJsonObject, LJsonBoletoObject : TACBrJSONObject;
  LJsonArray, LJsonBoletoIndividualArray, LJsonPagamentoCobrancaArray,LJsonHistoricoCobrancaArray : TACBrJSONArray;
  LListaRejeicao: TACBrBoletoRejeicao;
  I, J, X : Integer;
  TipoOperacao : TOperacao;
begin
  Result := True;
  TipoOperacao := ACBrBoleto.Configuracoes.WebService.Operacao;
  ARetornoWS.HTTPResultCode  := HTTPResultCode;
  ARetornoWS.JSONEnvio       := EnvWs;
  ARetornoWS.Header.Operacao := TipoOperacao;
  if Assigned(ACBrTitulo) then
    ARetornoWS.DadosRet.IDBoleto.NossoNum := ACBrTitulo.NossoNumero;

  if Trim(RetWS) <> '' then
  begin
    try
      LJsonObject := TACBrJsonObject.Parse( RetWS );
      try

        ARetornoWS.JSON := LJsonObject.ToJSON;
        if HTTPResultCode >= 300 then
        begin
          if LJSonObject.IsJSONObject('error') then
          begin
            LListaRejeicao            := ARetornoWS.CriarRejeicaoLista;
            LListaRejeicao.Codigo     := LJSonObject.AsJSONObject['error'].AsString['codigo'] ;
            LListaRejeicao.Mensagem   := LJSonObject.AsJSONObject['error'].AsString['mensagem'];
          end;

          if (LJsonObject.AsString['codigo'] <> '') or (LJsonObject.AsString['mensagem'] <> '') or
             (LJsonObject.AsString['codigo_erro'] <> '') or (LJsonObject.AsString['mensagem_erro'] <> '') then
          begin
            ARetornoWS.CodRetorno := LJsonObject.AsString['codigo'];
            if StrToIntDef(LJsonObject.AsString['codigo'], 0) > 0 then
            begin
              ARetornoWS.MsgRetorno := LJsonObject.AsString['mensagem'];
              LJsonArray := LJsonObject.AsJSONArray['campos'];
              for I := 0 to Pred(LJsonArray.Count) do
              begin
                LListaRejeicao            := ARetornoWS.CriarRejeicaoLista;
                LListaRejeicao.Codigo     := LJsonArray.ItemAsJSONObject[I].AsString['codigo'];
                LListaRejeicao.Versao     := LJsonArray.ItemAsJSONObject[I].AsString['versao'];
                LListaRejeicao.Mensagem   := LJsonArray.ItemAsJSONObject[I].AsString['mensagem'];
                LListaRejeicao.Ocorrencia := LJsonArray.ItemAsJSONObject[I].AsString['ocorrencia'];
                LListaRejeicao.Valor      := LJsonArray.ItemAsJSONObject[I].AsString['valor'];
              end;
            end
            else if StrToIntDef(LJsonObject.AsString['codigo_erro'], 0) > 0 then
            begin
              LListaRejeicao          := ARetornoWS.CriarRejeicaoLista;
              LListaRejeicao.Codigo   := LJsonObject.AsString['codigo_erro'];
              LListaRejeicao.Mensagem := LJsonObject.AsString['mensagem_erro'];
            end;
          end;
        end;

        if (ARetornoWS.ListaRejeicao.Count = 0) then
        begin
          if TipoOperacao = tpInclui then
          begin
              if LJsonObject.ValueExists('data') then
                LJsonBoletoObject  := LJsonObject.AsJSONObject['data'].AsJSONObject['dado_boleto']
              else
                LJsonBoletoObject := LJsonObject.AsJSONObject['dado_boleto'];


              ARetornoWS.DadosRet.TituloRet.Carteira                  := LJsonBoletoObject.AsString['codigo_carteira'];
              ARetornoWS.DadosRet.TituloRet.ValorDocumento            := StrToFloatDef( LJsonBoletoObject.AsString['valor_total_titulo'], 0)/100;
              ARetornoWS.DadosRet.TituloRet.EspecieDoc                := LJsonBoletoObject.AsString['codigo_especie'];
              ARetornoWS.DadosRet.TituloRet.DataDocumento             := StringToDateTimeDef(LJsonBoletoObject.AsString['data_emissao'], 0, 'yyyy-mm-dd');
              ARetornoWS.DadosRet.TituloRet.CodigoCanalTituloCobranca := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsString['descricao_instrumento_cobranca'];

              if LJsonBoletoObject.IsJSONObject('pagador') then
              begin
                ARetornoWS.DadosRet.TituloRet.Sacado.NomeSacado     := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['pessoa'].AsString['nome_pessoa'];
                if (ARetornoWS.DadosRet.TituloRet.Sacado.NomeSacado = '') then
                  ARetornoWS.DadosRet.TituloRet.Sacado.NomeSacado   := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['pessoa'].AsString['nome_razao_social_pagador'];

                if LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['codigo_tipo_pessoa'] = 'F' then
                  ARetornoWS.DadosRet.TituloRet.Sacado.CNPJCPF        := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['numero_cadastro_pessoa_fisica']
                else
                  ARetornoWS.DadosRet.TituloRet.Sacado.CNPJCPF        := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['numero_cadastro_nacional_pessoa_juridica'];

                ARetornoWS.DadosRet.TituloRet.Sacado.Logradouro := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['endereco'].AsString['nome_logradouro'];
                ARetornoWS.DadosRet.TituloRet.Sacado.Bairro     := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['endereco'].AsString['nome_bairro'];
                ARetornoWS.DadosRet.TituloRet.Sacado.Cidade     := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['endereco'].AsString['nome_cidade'];
                ARetornoWS.DadosRet.TituloRet.Sacado.UF         := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['endereco'].AsString['sigla_UF'];
                ARetornoWS.DadosRet.TituloRet.Sacado.Cep        := LJsonBoletoObject.AsJSONObject['pagador'].AsJSONObject['endereco'].AsString['numero_CEP'];
              end;

              if LJsonBoletoObject.IsJSONObject('sacador_avalista') then
              begin
                ARetornoWS.DadosRet.TituloRet.SacadoAvalista.CNPJCPF         := LJsonBoletoObject.AsJSONObject['sacador_avalista'].AsString['numero_cadastro_pessoa_fisica'];
                ARetornoWS.DadosRet.TituloRet.SacadoAvalista.NomeAvalista    := LJsonBoletoObject.AsJSONObject['sacador_avalista'].AsString['nome_pessoa'];
                if ARetornoWS.DadosRet.TituloRet.SacadoAvalista.NomeAvalista = '' then
                  ARetornoWS.DadosRet.TituloRet.SacadoAvalista.NomeAvalista  := LJsonBoletoObject.AsJSONObject['sacador_avalista'].AsString['nome_fantasia'];

              end;

              if LJsonBoletoObject.IsJSONArray('dados_individuais_boleto') then
              begin
                LJsonBoletoIndividualArray := LJsonBoletoObject.AsJSONArray['dados_individuais_boleto'];

                for I := 0 to Pred(LJsonBoletoIndividualArray.Count) do
                begin
                  ARetornoWS.DadosRet.IDBoleto.IDBoleto  := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['id_boleto_individual'];
                  ARetornoWS.DadosRet.IDBoleto.CodBarras := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['codigo_barras'];
                  ARetornoWS.DadosRet.IDBoleto.LinhaDig  := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['numero_linha_digitavel'];
                  ARetornoWS.DadosRet.IDBoleto.NossoNum  := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['numero_nosso_numero'];

                  if Assigned(ACBrTitulo) and EstaVazio(ARetornoWS.DadosRet.IDBoleto.NossoNum) then
                    ARetornoWS.DadosRet.IDBoleto.NossoNum := ACBrTitulo.NossoNumero;

                  ARetornoWS.DadosRet.TituloRet.Vencimento           := StringToDateTimeDef(LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['data_vencimento'], 0, 'yyyy-mm-dd');
                  ARetornoWS.DadosRet.TituloRet.NossoNumero          := ARetornoWS.DadosRet.IDBoleto.NossoNum;
                  ARetornoWS.DadosRet.TituloRet.SeuNumero            := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['texto_seu_numero'];
                  ARetornoWS.DadosRet.TituloRet.CodBarras            := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['codigo_barras'];
                  ARetornoWS.DadosRet.TituloRet.LinhaDig             := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['numero_linha_digitavel'];
                  ARetornoWS.DadosRet.TituloRet.DataProcessamento    := StringToDateTimeDef(LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['data_processamento'], 0, 'yyyy-mm-dd');
                  ARetornoWS.DadosRet.TituloRet.UsoBanco             := LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['uso_banco'];
                  ARetornoWS.DadosRet.TituloRet.ValorDesconto        := StrToFloatDef( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_desconto'], 0);
                  ARetornoWS.DadosRet.TituloRet.ValorDespesaCobranca := StrToFloatDef(LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_outra_deducao'], 0);
                  ARetornoWS.DadosRet.TituloRet.ValorMoraJuros       := StrToFloatDef( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_juro_multa'], 0);
                  ARetornoWS.DadosRet.TituloRet.ValorOutrosCreditos  := StrToFloatDef( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_outro_acrescimo'], 0);
                  ARetornoWS.DadosRet.TituloRet.ValorPago            := StrToFloatDef( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_total_cobrado'], 0);
                  ARetornoWS.DadosRet.TituloRet.ValorDocumento       := StrToFloatDef( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['valor_titulo'], 0);

                  ARetornoWS.DadosRet.TituloRet.Informativo.Add( LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['texto_informacao_cliente_beneficiario'] );
                  ARetornoWS.DadosRet.TituloRet.Mensagem.Add(LJsonBoletoIndividualArray.ItemAsJSONObject[I].AsString['local_pagamento']);

                end;

              end;

              if LJsonObject.IsJSONObject('data') and LJsonObject.AsJSONObject['data'].IsJSONObject('dados_qrcode') then
              begin
                ARetornoWS.DadosRet.TituloRet.EMV    := LJsonObject.AsJSONObject['data'].AsJSONObject['dados_qrcode'].AsString['emv'];
                ARetornoWS.DadosRet.TituloRet.TxId   := LJsonObject.AsJSONObject['data'].AsJSONObject['dados_qrcode'].AsString['txid'];
                ARetornoWS.DadosRet.TituloRet.UrlPix := LJsonObject.AsJSONObject['data'].AsJSONObject['dados_qrcode'].AsString['location'];
                ARetornoWS.DadosRet.TituloRet.Url    := LJsonObject.AsJSONObject['data'].AsJSONObject['dados_qrcode'].AsString['location'];
              end;
          end else
          if TipoOperacao = tpConsultaDetalhe then
          begin
            //retorna quando tiver sucesso
            if (ARetornoWS.ListaRejeicao.Count = 0) then
            begin

              if LJsonObject.ValueExists('data') then
                LJsonArray  := LJsonObject.AsJSONArray['data']
              else
                LJsonArray := LJsonObject.AsJSONArray['dado_boleto'];

              if LJsonArray.Count = 0 then
              begin
                LListaRejeicao            := ARetornoWS.CriarRejeicaoLista;
                LListaRejeicao.Codigo     := '00';
                LListaRejeicao.Mensagem   := 'Lista de retorno vazia!';
              end;


              {Esta condi��o abaixo foi adicionada pois o Itau pode reaproveitar NossoNumero, apos 45 depois do liquidado.
              desta forma, sempre vai exibir o titulo do ultimo NN utilizado caso tenha mais que um no retorno
              � uma consulta detalhe, nao pode vir mais que um}
              X := 0;
              if LJsonArray.Count >= 2 then
                 X := LJsonArray.Count - 1;

              for I := X to Pred(LJsonArray.Count) do
              begin

                LJsonBoletoObject  := LJsonArray.ItemAsJSONObject[I];

                ARetornoWS.DadosRet.IDBoleto.IDBoleto        := LJsonBoletoObject.AsString['id_boleto'];


                ARetornoWS.DadosRet.TituloRet.DataRegistro              := DateToDateTimeItau(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsString['data_emissao']);
                ARetornoWS.DadosRet.TituloRet.DataDocumento             := DateToDateTimeItau(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsString['data_emissao']);
                ARetornoWS.DadosRet.TituloRet.ValorAbatimento           := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsFloat['valor_abatimento'];
                ARetornoWS.DadosRet.TituloRet.CodigoCanalTituloCobranca := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsString['descricao_instrumento_cobranca'];

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONObject('qrcode_pix') then
                  ARetornoWS.DadosRet.TituloRet.EMV := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['qrcode_pix'].AsString['emv'];


                LJsonBoletoIndividualArray := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONArray['dados_individuais_boleto'];

                for j := 0 to Pred(LJsonBoletoIndividualArray.Count) do
                begin
                  ARetornoWS.DadosRet.TituloRet.EstadoTituloCobranca       := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['situacao_geral_boleto'];
                  ARetornoWS.DadosRet.TituloRet.CodigoEstadoTituloCobranca := RetornaCodigoOcorrencia(UpperCase(LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['situacao_geral_boleto']));
                  ARetornoWS.DadosRet.TituloRet.NossoNumero                := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['numero_nosso_numero'];
                  ARetornoWS.DadosRet.TituloRet.Vencimento                 := StringToDateTimeDef(LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['data_vencimento'], 0, 'yyyy-mm-dd');
                  ARetornoWS.DadosRet.TituloRet.SeuNumero                  := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['texto_seu_numero'];
                  ARetornoWS.DadosRet.TituloRet.CodBarras                  := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['codigo_barras'];
                  ARetornoWS.DadosRet.TituloRet.LinhaDig                   := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsString['numero_linha_digitavel'];
                  ARetornoWS.DadosRet.TituloRet.ValorDocumento             := LJsonBoletoIndividualArray.ItemAsJSONObject[J].AsFloat['valor_titulo'];
                  ARetornoWS.DadosRet.IDBoleto.CodBarras                   := ARetornoWS.DadosRet.TituloRet.CodBarras;
                  ARetornoWS.DadosRet.IDBoleto.LinhaDig                    := ARetornoWS.DadosRet.TituloRet.LinhaDig;
                  ARetornoWS.DadosRet.IDBoleto.NossoNum                    := ARetornoWS.DadosRet.TituloRet.NossoNumero;
                end;

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONArray('pagamentos_cobranca') then
                begin
                  LJsonPagamentoCobrancaArray := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONArray['pagamentos_cobranca'];
                  for j := 0 to Pred(LJsonPagamentoCobrancaArray.Count) do
                  begin
                    ARetornoWS.DadosRet.TituloRet.DataProcessamento    := Iso8601ToDateTime(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['data_inclusao_pagamento']);
                    ARetornoWS.DadosRet.TituloRet.DataCredito          := Iso8601ToDateTime(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['data_inclusao_pagamento']);
                    ARetornoWS.DadosRet.TituloRet.ValorPago            := StrToFloatDef( StringReplace(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['valor_pago_total_cobranca'],'.',',',[rfReplaceAll]), 0);
                    ARetornoWS.DadosRet.TituloRet.ValorMulta           := StrToFloatDef( StringReplace(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['valor_pago_multa_cobranca'],'.',',',[rfReplaceAll]), 0);
                    ARetornoWS.DadosRet.TituloRet.ValorMoraJuros       := StrToFloatDef( StringReplace(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['valor_pago_juro_cobranca'],'.',',',[rfReplaceAll]), 0);
                    ARetornoWS.DadosRet.TituloRet.ValorDesconto        := StrToFloatDef( StringReplace(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['valor_pago_desconto_cobranca'],'.',',',[rfReplaceAll]), 0);
                    ARetornoWS.DadosRet.TituloRet.ValorAbatimento      := StrToFloatDef( StringReplace(LJsonPagamentoCobrancaArray.ItemAsJSONObject[J].AsString['valor_pago_abatimento_cobranca'],'.',',',[rfReplaceAll]), 0);
                    if ARetornoWS.DadosRet.TituloRet.ValorPago > ARetornoWS.DadosRet.TituloRet.ValorDocumento then
                       ARetornoWS.DadosRet.TituloRet.ValorOutrasDespesas := (ARetornoWS.DadosRet.TituloRet.ValorPago - ARetornoWS.DadosRet.TituloRet.ValorDocumento)
                  end;
                end;

                //Caso estiver liquidado, pegar a data do cr�dito real, quando cai no conta corrente o dinheiro, e remaneja a data credito para a data movimento, que � a data do pagto
                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONArray('historico') then
                begin
                  LJsonHistoricoCobrancaArray := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONArray['historico'];
                  for j := 0 to Pred(LJsonHistoricoCobrancaArray.Count) do
                  begin
                    if AnsiUpperCase(LJsonHistoricoCobrancaArray.ItemAsJSONObject[J].AsString['operacao'])='TITULO LIQUIDADO' then
                    begin
                       if ARetornoWS.DadosRet.TituloRet.DataCredito > 0 then
                       begin
                          ARetornoWS.DadosRet.TituloRet.DataMovimento := ARetornoWS.DadosRet.TituloRet.DataCredito;
                          ARetornoWS.DadosRet.TituloRet.DataCredito   := DateToDateTimeItau(LJsonHistoricoCobrancaArray.ItemAsJSONObject[J].AsString['data']);
                       end;
                    end;
                  end;
                end;

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONObject('baixa') then
                begin
                  ARetornoWS.DadosRet.TituloRet.DataBaixa              := Iso8601ToDateTime(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['data_inclusao_alteracao_baixa']);
                  ARetornoWS.DadosRet.TituloRet.Mensagem.Text          := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa'];
                  if (UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']) = 'BAIXA POR TER SIDO LIQUIDADO') then
                  begin
                    ARetornoWS.DadosRet.TituloRet.EstadoTituloCobranca       := UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']);
                    ARetornoWS.DadosRet.TituloRet.CodigoEstadoTituloCobranca := RetornaCodigoOcorrencia(UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']));
                  end;
                end;
              end;
            end;
          end;
        end;
      finally
        LJsonObject.free;
      end;
    except
      Result := False;
    end;
  end;
end;

function TRetornoEnvio_Itau_API.RetornoEnvio(const AIndex: Integer): Boolean;
begin
  Result:=inherited RetornoEnvio(AIndex);
end;

function TRetornoEnvio_Itau_API.DateToDateTimeItau(const AValue: String): TDateTime;
begin
  Result :=EncodeDataHora(StringReplace(AValue,'-','/',[rfReplaceAll]));
end;

function TRetornoEnvio_Itau_API.RetornaCodigoOcorrencia(pSituacaoGeralBoleto: string) : String;
var
  LSituacaoBoleto : string;
begin
  LSituacaoBoleto := AnsiUpperCase(pSituacaoGeralBoleto);
  if (LSituacaoBoleto  = 'EM ABERTO') or
     (LSituacaoBoleto  = 'E') then  // Entrada de titulo
    Result := '01'
  else if LSituacaoBoleto  = 'AGUARDANDO PAGAMENTO' then
    Result := '02'
  else if (LSituacaoBoleto = 'PAGO') or
          (LSituacaoBoleto = 'PAGA') or
          (LSituacaoBoleto = 'L') then // Liquidado
    Result := '06'
  else if (LSituacaoBoleto = 'BAIXA POR TER SIDO LIQUIDADO') or
          (LSituacaoBoleto = 'BL') then  // Bolecode Liquidado
    Result := '10'
  else if LSituacaoBoleto  = 'PAGAMENTO DEVOLVIDO' then
    Result := '08'
  else if LSituacaoBoleto  = 'EA' then // entrada por acerto.T�tulo alterados para desconto/garantia
    Result := '99'
  else if LSituacaoBoleto  = 'TM' then // Tarifa Mannutencao Bol.vencido
    Result := '29'
  else if LSituacaoBoleto  = 'BC' then // Baixa por ter sido protestado
    Result := '32'
  else if LSituacaoBoleto  = 'TS' then // Tarifa sustacao de protesto
    Result := '34'
  else if (LSituacaoBoleto  = 'BAIXADO') or
          (LSituacaoBoleto  = 'B') or // Baixado
          (LSituacaoBoleto  = 'BA') or // Baixa para acerto
          (LSituacaoBoleto  = 'BAIXADA')then
    Result := '09'
  else
    Result := '99';
end;


function TRetornoEnvio_Itau_API.RetornaDescricaoStatusTitulo(
  AStatus: string): String;
begin
  {N�o tem nos manuais online at� o momento 29/05/25 esta tabela de status
  obtivemos ela de uma reposta do email so suporte Itau }
  if (AStatus = 'L') then
    result := 'Liquidado'
  else if (AStatus = 'B') then
    result := 'Baixado'
  else if (AStatus = 'E') then
    result := 'Entrada. Titulo Registrado'
  else if (AStatus = 'EA') then
    result := 'Entrada por acerto.Alterado p desconto garantia'
  else if (AStatus = 'BA') then
    result := 'Baixa Para Acerto'
  else if (AStatus = 'BC') then
    result := 'Baixa por ter sido protestado'
  else if (AStatus = 'BL') then
    result := 'Liquidado Bolecode'
  else if (AStatus = 'TM') then
    result := 'Tarifa Manuten��o Titulo Vencido'
  else if (AStatus = 'TS') then
    result := 'Tarifa Susta��o Protesto';
end;

function TRetornoEnvio_Itau_API.LerListaRetorno: Boolean;
var
  LJsonObject, LJsonBoletoObject, LJsonPagadorObject, LErrosObject: TACBrJSONObject;
  LJsonArray, LJsonBoletosArray, LJsonBoletoIndividualArray, LJsonArrayMensagens, LJsonArrayErros, LJsonArrayOperacaoCobranca : TACBrJSONArray;
  ListaRetorno: TACBrBoletoRetornoWS;
  LListaRejeicao : TACBrBoletoRejeicao;
  LTrataBoleto, LSemRegistros : Boolean;
  LValorPago : double;
  LMsgRetorno, LStatusBoleto : String;
  I, j, K: Integer;
begin
  Result := True;
  ListaRetorno := ACBrBoleto.CriarRetornoWebNaLista;
  ListaRetorno.HTTPResultCode := HTTPResultCode;
  ListaRetorno.JSONEnvio      := EnvWs;
  LSemRegistros := True;
  if RetWS <> '' then
  begin
    try
      try
        LJsonObject := TACBrJSONObject.Parse(RetWS);

        case ACBrBoleto.Configuracoes.WebService.Filtro.indicadorSituacao of
        isbNenhum:
          begin
            {
             Respostas das Consultas utilizando EndPoint antigo que devolve qq status do titulos da lista;
             N�o estamos utilizando o novo devido a erro nas respostas que pode devolver um titulo registrado como aberto.
            }


            if HTTPResultCode > 299 then
            begin
              if ( LJsonObject.IsJSONObject('codigo') ) then
                if (LJsonObject.AsString['codigo'] <> '') or (LJsonObject.AsString['mensagem'] <> '') then
                begin
                  CodRetorno := strtointdef(LJsonObject.AsString['codigo'], 0);
                  if CodRetorno < 1 then
                     CodRetorno := strtointdef(LJsonObject.AsString['codigo'], 0);

                   LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                   LListaRejeicao.Codigo     := inttostr(CodRetorno);
                   LListaRejeicao.Mensagem   := LJsonObject.AsString['mensagem'];
                end;

            end;

            //retorna quando tiver sucesso
            if (ListaRetorno.ListaRejeicao.Count = 0) then
            begin
              if LJsonObject.IsJSONObject('page') then
              begin
                  ListaRetorno.indicadorContinuidade := LJsonObject.AsJSONObject['page'].AsInteger['total_pages'] - LJsonObject.AsJSONObject['page'].AsInteger['page'] > 0;
                if ListaRetorno.indicadorContinuidade then
                  ListaRetorno.proximoIndice         := LJsonObject.AsJSONObject['page'].AsInteger['page'] + 1
                else
                  ListaRetorno.proximoIndice         := 0;

              end;
              LJsonArray := LJsonObject.AsJSONArray['data'];
              if LJsonArray.Count = 0 then
              begin
                LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                LListaRejeicao.Codigo     := '00';
                LListaRejeicao.Mensagem   := 'Lista de retorno vazia!';
              end;

              for I := 0 to Pred(LJsonArray.Count) do
              begin
                if I > 0 then
                  ListaRetorno := ACBrBoleto.CriarRetornoWebNaLista;

                LJsonBoletoObject  := LJsonArray.ItemAsJSONObject[I];
                ListaRetorno.DadosRet.IDBoleto.IDBoleto        := LJsonBoletoObject.AsString['id_boleto'];

                ListaRetorno.DadosRet.TituloRet.DataRegistro   := DateToDateTimeItau(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsString['data_emissao']);



                LJsonBoletosArray := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONArray['dados_individuais_boleto'];

                for j := 0 to Pred(LJsonBoletosArray.Count) do
                begin

                  ListaRetorno.DadosRet.TituloRet.EstadoTituloCobranca := LJsonBoletosArray.ItemAsJSONObject[J].AsString['situacao_geral_boleto'];
                  ListaRetorno.DadosRet.TituloRet.CodigoEstadoTituloCobranca := RetornaCodigoOcorrencia(UpperCase(LJsonBoletosArray.ItemAsJSONObject[J].AsString['situacao_geral_boleto']));
                  ListaRetorno.DadosRet.TituloRet.NossoNumero          := LJsonBoletosArray.ItemAsJSONObject[J].AsString['numero_nosso_numero'];
                  ListaRetorno.DadosRet.TituloRet.Vencimento           := StringToDateTimeDef(LJsonBoletosArray.ItemAsJSONObject[J].AsString['data_vencimento'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.SeuNumero            := LJsonBoletosArray.ItemAsJSONObject[J].AsString['texto_seu_numero'];
                  ListaRetorno.DadosRet.TituloRet.CodBarras            := LJsonBoletosArray.ItemAsJSONObject[J].AsString['codigo_barras'];
                  ListaRetorno.DadosRet.TituloRet.LinhaDig             := LJsonBoletosArray.ItemAsJSONObject[J].AsString['numero_linha_digitavel'];
                  ListaRetorno.DadosRet.TituloRet.ValorDocumento       := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_titulo'];
                  ListaRetorno.DadosRet.IDBoleto.NossoNum              := ListaRetorno.DadosRet.TituloRet.NossoNumero;
                  ListaRetorno.DadosRet.IDBoleto.LinhaDig              := ListaRetorno.DadosRet.TituloRet.LinhaDig;
                  ListaRetorno.DadosRet.IDBoleto.CodBarras             := ListaRetorno.DadosRet.TituloRet.CodBarras;

                  ListaRetorno.DadosRet.TituloRet.DataProcessamento    := StringToDateTimeDef(LJsonBoletosArray.ItemAsJSONObject[J].AsString['data_processamento'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.UsoBanco             := LJsonBoletosArray.ItemAsJSONObject[J].AsString['uso_banco'];
                  ListaRetorno.DadosRet.TituloRet.ValorDesconto        := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_desconto'];
                  ListaRetorno.DadosRet.TituloRet.ValorDespesaCobranca := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_outra_deducao'];
                  ListaRetorno.DadosRet.TituloRet.ValorMoraJuros       := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_juro_multa'];
                  ListaRetorno.DadosRet.TituloRet.ValorOutrosCreditos  := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_outro_acrescimo'];

                  ListaRetorno.DadosRet.TituloRet.Informativo.Add( LJsonBoletosArray.ItemAsJSONObject[J].AsString['texto_informacao_cliente_beneficiario'] );
                  ListaRetorno.DadosRet.TituloRet.Mensagem.Add(LJsonBoletosArray.ItemAsJSONObject[J].AsString['local_pagamento']);

                end;

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['pagador'].IsJSONObject('pessoa') then
                begin
                  LJsonPagadorObject := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['pagador'];

                  ListaRetorno.DadosRet.TituloRet.Sacado.NomeSacado     := LJsonPagadorObject.AsJSONObject['pessoa'].AsString['nome_pessoa'];
                  if (ListaRetorno.DadosRet.TituloRet.Sacado.NomeSacado = '') then
                    ListaRetorno.DadosRet.TituloRet.Sacado.NomeSacado   := LJsonPagadorObject.AsJSONObject['pessoa'].AsString['nome_razao_social_pagador'];

                  if LJsonPagadorObject.AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['codigo_tipo_pessoa'] = 'F' then
                    ListaRetorno.DadosRet.TituloRet.Sacado.CNPJCPF        := LJsonPagadorObject.AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['numero_cadastro_pessoa_fisica']
                  else
                    ListaRetorno.DadosRet.TituloRet.Sacado.CNPJCPF        := LJsonPagadorObject.AsJSONObject['pessoa'].AsJSONObject['tipo_pessoa'].AsString['numero_cadastro_nacional_pessoa_juridica'];

                  ListaRetorno.DadosRet.TituloRet.Sacado.Logradouro := LJsonPagadorObject.AsJSONObject['endereco'].AsString['nome_logradouro'];
                  ListaRetorno.DadosRet.TituloRet.Sacado.Bairro     := LJsonPagadorObject.AsJSONObject['endereco'].AsString['nome_bairro'];
                  ListaRetorno.DadosRet.TituloRet.Sacado.Cidade     := LJsonPagadorObject.AsJSONObject['endereco'].AsString['nome_cidade'];
                  ListaRetorno.DadosRet.TituloRet.Sacado.UF         := LJsonPagadorObject.AsJSONObject['endereco'].AsString['sigla_UF'];
                  ListaRetorno.DadosRet.TituloRet.Sacado.Cep        := LJsonPagadorObject.AsJSONObject['endereco'].AsString['numero_CEP'];
                end;

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONArray('pagamentos_cobranca') then
                begin
                  LJsonBoletosArray := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONArray['pagamentos_cobranca'];
                  for J := 0 to Pred(LJsonBoletosArray.Count) do
                  begin
                    ListaRetorno.DadosRet.TituloRet.DataMovimento        := StringToDateTimeDef(LJsonBoletosArray.ItemAsJSONObject[J].AsString['data_inclusao_pagamento'], 0, 'yyyy-mm-dd');
                    ListaRetorno.DadosRet.TituloRet.DataProcessamento    := StringToDateTimeDef(LJsonBoletosArray.ItemAsJSONObject[J].AsString['data_inclusao_pagamento'], 0, 'yyyy-mm-dd');
                    ListaRetorno.DadosRet.TituloRet.ValorPago            := LJsonBoletosArray.ItemAsJSONObject[J].AsCurrency['valor_pago_total_cobranca'];
                  end;
                end;


                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONObject('qrcode_pix') then
                begin
                  ListaRetorno.DadosRet.TituloRet.EMV := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['qrcode_pix'].AsString['emv'];
                end;

                if LJsonBoletoObject.AsJSONObject['dado_boleto'].IsJSONObject('baixa') then
                begin
                  ListaRetorno.DadosRet.TituloRet.DataBaixa              := StringToDateTimeDef(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['data_inclusao_alteracao_baixa'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.Mensagem.Text          := LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa'];
                  if (UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']) = 'BAIXA POR TER SIDO LIQUIDADO') then
                  begin
                    ListaRetorno.DadosRet.TituloRet.EstadoTituloCobranca       := UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']);
                    ListaRetorno.DadosRet.TituloRet.CodigoEstadoTituloCobranca := RetornaCodigoOcorrencia(UpperCase(LJsonBoletoObject.AsJSONObject['dado_boleto'].AsJSONObject['baixa'].AsString['motivo_baixa']));
                  end;
                end;
              end;
            end;
          end
        else
          begin
            {
             Respostas das Consultas utilizando novos EndPoint de Francesinhas;
            }
            if HTTPResultCode > 299 then
            begin
                if LJsonObject.IsJSONArray('messages') then
                begin
                  LJsonArrayMensagens := LJsonObject.AsJSONArray['messages'];
                  for I := 0 to Pred(LJsonArrayMensagens.Count) do
                  begin
                    LErrosObject              := LJsonArrayMensagens.ItemAsJSONObject[I];
                    LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                    LListaRejeicao.Codigo     := LErrosObject.AsString['codigo'];
                    LListaRejeicao.Mensagem   := LErrosObject.AsString['mensagem'];
                    ListaRetorno.MsgRetorno := LMsgRetorno;

                    if LJsonArrayMensagens.ItemAsJSONObject[I].IsJSONArray('campos') then
                    begin
                      LJsonArrayErros := LJsonArrayMensagens.ItemAsJSONObject[I].AsJSONArray['campos'];
                      for J := 0 to Pred(LJsonArrayErros.Count) do
                      begin
                        LErrosObject              := LJsonArrayErros.ItemAsJSONObject[J];
                        LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                        LListaRejeicao.Codigo     := LErrosObject.AsString['codigo'];
                        LListaRejeicao.Mensagem   := LErrosObject.AsString['mensagem'];
                      end;
                      ListaRetorno.MsgRetorno := LMsgRetorno;
                    end;

                  end;
                end;

              if  NaoEstaVazio(LJsonObject.AsString['codigo']) then
                begin
                  LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                  LListaRejeicao.Codigo     := LJsonObject.AsString['codigo'];
                  LListaRejeicao.Mensagem   := LJsonObject.AsString['mensagem'];
                  ListaRetorno.MsgRetorno   := LJsonObject.AsString['mensagem'];

                  if LJsonObject.IsJSONArray('campos') then
                  begin
                    LJsonArrayErros := LJsonObject.AsJSONArray['campos'];
                    for J := 0 to Pred(LJsonArrayErros.Count) do
                    begin
                      LErrosObject              := LJsonArrayErros.ItemAsJSONObject[J];
                      LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                      LListaRejeicao.Codigo     := LJsonObject.AsString['codigo'];
                      LListaRejeicao.Mensagem   := 'Campo: '+LErrosObject.AsString['campo']+', Mensagem '+LErrosObject.AsString['mensagem']+', Valor '+LErrosObject.asString['valor'];
                    end;
                  end;
                end;

            end;

            //retorna quando tiver sucesso
            if (ListaRetorno.ListaRejeicao.Count = 0) then
            begin
              if LJsonObject.IsJSONObject('pagination') then
              begin
                ListaRetorno.indicadorContinuidade := (LJsonObject.AsJSONObject['pagination'].AsInteger['total_pages'] - 1) - LJsonObject.AsJSONObject['pagination'].AsInteger['page'] > 0;
                if ListaRetorno.indicadorContinuidade then
                  ListaRetorno.proximoIndice       := LJsonObject.AsJSONObject['pagination'].AsInteger['page'] + 1
                else
                  ListaRetorno.proximoIndice       := 0;
              end;
              LJsonArray := LJsonObject.AsJSONArray['data'];


              for J := 0 to Pred(LJsonArray.Count) do
              begin


                LJsonBoletoObject  := LJsonArray.ItemAsJSONObject[J];
                LStatusBoleto := AnsiUpperCase(LJsonBoletoObject.AsString['codigo_status']);
                LTrataBoleto := false;
                case ACBrBoleto.Configuracoes.WebService.Filtro.indicadorSituacao of
                  isbBaixado:
                    begin
                      if (LStatusBoleto = 'L') or (LStatusBoleto = 'BA') or (LStatusBoleto = 'BC') or
                         (LStatusBoleto = 'BL') or (LStatusBoleto = 'BC') or (LStatusBoleto = 'TS') or
                         (LStatusBoleto = 'TM')  then
                        LTrataBoleto := true
                    end;
                  isbCancelado:
                    begin
                      {Consulta cancelado devolve BL Bolecode Liquidado !, por isso esta dentro indicadorPIX}
                      if ACBrBoleto.Cedente.CedenteWS.IndicadorPix then
                      begin
                        if (LStatusBoleto = 'L') or (LStatusBoleto = 'BL') or
                           (LStatusBoleto = 'TM') or (LStatusBoleto = 'TS') then
                          LTrataBoleto := true
                      end
                      else
                      begin
                        if (LStatusBoleto = 'BA')  or (LStatusBoleto = 'B')  or
                           (LStatusBoleto = 'BAIXADO') then
                           LTrataBoleto := true
                      end;

                    end;
                end;

                if LTrataBoleto then
                begin
                  if (j > 0) and (LSemRegistros = False) then
                    ListaRetorno := ACBrBoleto.CriarRetornoWebNaLista;

                  LSemRegistros := False;

                  ListaRetorno.DadosRet.IDBoleto.IDBoleto        := LJsonBoletoObject.AsString['nosso_numero'];
                  ListaRetorno.DadosRet.TituloRet.DataRegistro   := DateToDateTimeItau(LJsonBoletoObject.AsString['data_emissao']);
                  ListaRetorno.DadosRet.TituloRet.EstadoTituloCobranca := RetornaDescricaoStatusTitulo(LStatusBoleto);


                  ListaRetorno.DadosRet.TituloRet.CodigoEstadoTituloCobranca := RetornaCodigoOcorrencia(UpperCase(LJsonBoletoObject.AsString['codigo_status']));

                  ListaRetorno.DadosRet.TituloRet.NossoNumero          := LJsonBoletoObject.AsString['nosso_numero'];
                  ListaRetorno.DadosRet.TituloRet.SeuNumero            := LJsonBoletoObject.AsString['seu_numero'];
                  ListaRetorno.DadosRet.TituloRet.Vencimento           := StringToDateTimeDef(LJsonBoletoObject.AsString['data_vencimento'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.CodBarras            := '';
                  ListaRetorno.DadosRet.TituloRet.LinhaDig             := '';
                  ListaRetorno.DadosRet.TituloRet.ValorDocumento       := LJsonBoletoObject.AsCurrency['valor_titulo'];
                  ListaRetorno.DadosRet.IDBoleto.NossoNum              := LJsonBoletoObject.AsString['nosso_numero'];
                  ListaRetorno.DadosRet.IDBoleto.LinhaDig              := ListaRetorno.DadosRet.TituloRet.LinhaDig;
                  ListaRetorno.DadosRet.IDBoleto.CodBarras             := ListaRetorno.DadosRet.TituloRet.CodBarras;

                  ListaRetorno.DadosRet.TituloRet.DataProcessamento    := StringToDateTimeDef(LJsonBoletoObject.AsString['data_movimentacao'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.DataMovimento        := StringToDateTimeDef(LJsonBoletoObject.AsString['data_movimentacao'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.DataCredito          := StringToDateTimeDef(LJsonBoletoObject.AsString['data_movimentacao'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.DataDocumento        := StringToDateTimeDef(LJsonBoletoObject.AsString['data_inclusao_titulo_cobranca'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.DataRegistro         := StringToDateTimeDef(LJsonBoletoObject.AsString['data_inclusao_titulo_cobranca'], 0, 'yyyy-mm-dd');
                  ListaRetorno.DadosRet.TituloRet.UsoBanco             := LJsonBoletoObject.AsString['uso_banco'];
                  ListaRetorno.DadosRet.TituloRet.ValorDocumento       := LJsonBoletoObject.AsCurrency['valor_titulo'];
                  ListaRetorno.DadosRet.TituloRet.ValorDesconto        := LJsonBoletoObject.AsCurrency['valor_decrescimo'];
                  ListaRetorno.DadosRet.TituloRet.ValorDespesaCobranca := 0;
                  ListaRetorno.DadosRet.TituloRet.ValorMoraJuros       := 0;
                  ListaRetorno.DadosRet.TituloRet.ValorOutrasDespesas  := LJsonBoletoObject.AsCurrency['valor_acrescimo'];
                  ListaRetorno.DadosRet.TituloRet.ValorPago            := LJsonBoletoObject.AsCurrency['valor_liquido_lancado'];
                  ListaRetorno.DadosRet.TituloRet.ValorRecebido        := LJsonBoletoObject.AsCurrency['valor_liquido_lancado'];
                  {
                  BL Bolecode ate esta data nao devolve valor juros, descontos, acrescimos etc.
                  ele n�o retorna qdo liquidado (apenas tarja magnetica); bolecode � baixado  (cancelado) para que
                  nao possa ser pago via tarja magnetica (segundo banco).
                  }

                  (*

                  #Mapeamento detalhado Comentado, devido inconsistencias de dados do retorno com o manual da API, questionado Suporte ITAU.

                  if LJsonBoletoObject.IsJSONArray('operacoes_cobranca') then
                  begin
                    LJsonArrayOperacaoCobranca := LJsonBoletoObject.AsJSONArray['operacoes_cobranca'];
                    for K := 0 to Pred(LJsonArrayOperacaoCobranca.Count) do
                    begin
                      if AnsiUpperCase(LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsString['descricao']) = 'TARIFA COBRAN�A' then
                        ListaRetorno.DadosRet.TituloRet.ValorTarifa      := LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsCurrency['valor'];
                      if AnsiUpperCase(LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsString['descricao']) = 'JUROS' then
                        ListaRetorno.DadosRet.TituloRet.ValorMoraJuros   := LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsCurrency['valor'];
                      if AnsiUpperCase(LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsString['descricao']) = 'MULTA' then
                        ListaRetorno.DadosRet.TituloRet.ValorMoraJuros   := LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsCurrency['valor'];
                      if AnsiUpperCase(LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsString['descricao']) = 'DESCONTO' then
                        ListaRetorno.DadosRet.TituloRet.ValorMoraJuros   := LJsonArrayOperacaoCobranca.ItemAsJSONObject[K].AsCurrency['valor'];
                    end;
                  end;

                  *)
                end;

              end;

              if (LJsonArray.Count = 0) or LSemRegistros then
              begin
                LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
                LListaRejeicao.Codigo     := '00';
                LListaRejeicao.Mensagem   := 'Lista de retorno vazia!';
              end;

            end;
            
          end;
        end;


      finally
        LJsonObject.free;
      end;
    except
      Result := False;
    end;
  end else
  begin
    case HTTPResultCode of
      401 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '401';
          LListaRejeicao.Mensagem   := 'Usu�rio n�o autenticado.';
        end;
      403 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '403';
          LListaRejeicao.Mensagem   := 'Acesso n�o autorizado.';
        end;
      404 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '404';
          LListaRejeicao.Mensagem   := 'O servidor n�o conseguiu encontrar o recurso solicitado.';
        end;
      405 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '405';
          LListaRejeicao.Mensagem   := 'M�todo n�o permitido.';
        end;
      422 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '422';
          LListaRejeicao.Mensagem   := 'Erro na execu��o da solicita��o.';
        end;
      428 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '428';
          LListaRejeicao.Mensagem   := 'Pr�-requisito necess�rio.';
        end;
      500 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '500';
          LListaRejeicao.Mensagem   := 'Erro inesperado.';
        end;
      501 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '501';
          LListaRejeicao.Mensagem   := 'N�o implementado.';
        end;
      503 :
        begin
          LListaRejeicao            := ListaRetorno.CriarRejeicaoLista;
          LListaRejeicao.Codigo     := '503';
          LListaRejeicao.Versao     := 'ERRO INTERNO ITAU';
          LListaRejeicao.Mensagem   := 'SERVI�O INDISPON�VEL. O servidor est� impossibilitado de lidar com a requisi��o no momento. Tente mais tarde.';
          LListaRejeicao.Ocorrencia := 'ERRO INTERNO nos servidores do Banco do Ita�.';
        end;
    end;

  end;
end;

end.
