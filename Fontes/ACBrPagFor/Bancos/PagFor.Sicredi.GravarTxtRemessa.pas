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

unit PagFor.Sicredi.GravarTxtRemessa;

interface

uses
  SysUtils, Classes,
  ACBrPagForClass, ACBrPagForConversao, CNAB240.GravarTxtRemessa;

type
 { TArquivoW_Sicredi }

  TArquivoW_Sicredi = class(TArquivoW_CNAB240)
  private
    function InscricaoToStr(const t: TTipoInscricao): String;
  protected
    procedure GeraRegistro0; override;

    procedure GeraRegistro1(I: Integer); override;

    procedure GeraRegistro5(I: Integer); override;

    procedure GeraRegistro9; override;

    procedure GeraSegmentoA(I: Integer); override;

    procedure GeraSegmentoB(mSegmentoBList: TSegmentoBList); override;

    procedure GeraSegmentoJ52(mSegmentoJ52List: TSegmentoJ52List); override;

    procedure GeraSegmentoN1(I: Integer); override;

    procedure GeraSegmentoN2(I: Integer); override;

    procedure GeraSegmentoN3(I: Integer); override;

    procedure GeraSegmentoN4(I: Integer); override;

    procedure GeraSegmentoN567(I: Integer); override;

    procedure GeraSegmentoN8(I: Integer); override;

    procedure GeraSegmentoN9(I: Integer); override;
  end;

implementation

uses
  ACBrUtil.Strings;

{ TArquivoW_Sicredi }

procedure TArquivoW_Sicredi.GeraRegistro0;
begin
  FpLinha := '';
  FQtdeRegistros := 1;
  FQtdeLotes := 0;
  FQtdeContasConc := 0;

  GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
  GravarCampo(0, 4, tcInt);
  GravarCampo(0, 1, tcInt);
  GravarCampo(' ', 9, tcStr);
  GravarCampo(TpInscricaoToStr(PagFor.Registro0.Empresa.Inscricao.Tipo), 1, tcStr);
  GravarCampo(PagFor.Registro0.Empresa.Inscricao.Numero, 14, tcStrZero);
  GravarCampo(PagFor.Registro0.Empresa.Convenio, 20, tcStr);
  GravarCampo(PagFor.Registro0.Empresa.ContaCorrente.Agencia.Codigo, 5, tcInt);
  GravarCampo(PagFor.Registro0.Empresa.ContaCorrente.Agencia.DV, 1, tcStr);
  GravarCampo(PagFor.Registro0.Empresa.ContaCorrente.Conta.Numero, 12, tcInt64);
  GravarCampo(PagFor.Registro0.Empresa.ContaCorrente.Conta.DV, 1, tcStr);
  GravarCampo(' ', 1, tcStr);
  GravarCampo(PagFor.Registro0.Empresa.Nome, 30, tcStr, True);
  GravarCampo(PagFor.Registro0.NomeBanco, 30, tcStr, True);
  GravarCampo(' ', 10, tcStr);
  GravarCampo(TpArquivoToStr(PagFor.Registro0.Arquivo.Codigo), 1, tcStr);
  GravarCampo(PagFor.Registro0.Arquivo.DataGeracao, 8, tcDat);
  GravarCampo(PagFor.Registro0.Arquivo.HoraGeracao, 6, tcHor);
  GravarCampo(PagFor.Registro0.Arquivo.Sequencia, 6, tcInt);
  GravarCampo('082', 3, tcStr);
  GravarCampo(PagFor.Registro0.Arquivo.Densidade, 5, tcInt);
  GravarCampo(PagFor.Registro0.ReservadoBanco, 20, tcStr);
  GravarCampo(PagFor.Registro0.ReservadoEmpresa, 20, tcStr);
  GravarCampo(' ', 29, tcStr);

  ValidarLinha('0');
  IncluirLinha;
end;

procedure TArquivoW_Sicredi.GeraRegistro1(I: Integer);
begin
  FpLinha := '';
  Inc(FQtdeRegistros);
  Inc(FQtdeLotes);

  if PagFor.Lote.Items[I].Registro1.Servico.Operacao = toExtrato then
    Inc(FQtdeContasConc);

  FQtdeRegistrosLote := 1;
  FSequencialDoRegistroNoLote := 0;

  FpFormaLancamento := PagFor.Lote.Items[I].Registro1.Servico.FormaLancamento;

  GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
  GravarCampo(FQtdeLotes, 4, tcInt);
  GravarCampo(1, 1, tcInt);

  with PagFor.Lote.Items[I].Registro1.Servico do
  begin
    GravarCampo(TpOperacaoToStr(Operacao), 1, tcStr);
    GravarCampo(TpServicoToStr(TipoServico), 2, tcStr);
    GravarCampo(FmLancamentoToStr(FormaLancamento), 2, tcStr);
  end;

  GravarCampo('042', 3, tcStr);
  GravarCampo(' ', 1, tcStr);

  with PagFor.Lote.Items[I].Registro1.Empresa do
  begin
    GravarCampo(TpInscricaoToStr(Inscricao.Tipo), 1, tcStr);
    GravarCampo(Inscricao.Numero, 14, tcStrZero);
    GravarCampo(Convenio, 20, tcStr);
    GravarCampo(ContaCorrente.Agencia.Codigo, 5, tcInt);
    GravarCampo(ContaCorrente.Agencia.DV, 1, tcStr);
    GravarCampo(ContaCorrente.Conta.Numero, 12, tcInt64);
    GravarCampo(ContaCorrente.Conta.DV, 1, tcStr);
    GravarCampo(' ', 1, tcStr);
    GravarCampo(Nome, 30, tcStr, True);
  end;

  with PagFor.Lote.Items[I].Registro1 do
  begin
    GravarCampo(Informacao1, 40, tcStr, True);
    GravarCampo(Endereco.Logradouro, 30, tcStr, True);
    GravarCampo(Endereco.Numero, 5, tcStrZero);
    GravarCampo(Endereco.Complemento, 15, tcStr, True);
    GravarCampo(Endereco.Cidade, 20, tcStr, True);
    GravarCampo(Endereco.CEP, 8, tcInt);
    GravarCampo(Endereco.Estado, 2, tcStr);
  end;

  GravarCampo(' ', 2, tcStr);
  GravarCampo(' ', 6, tcStr);
  GravarCampo(' ', 10, tcStr);

  ValidarLinha('1');
  IncluirLinha;
end;

procedure TArquivoW_Sicredi.GeraRegistro5(I: Integer);
begin
  FpLinha := '';
  Inc(FQtdeRegistros);
  Inc(FQtdeRegistrosLote);

  GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
  GravarCampo(FQtdeLotes, 4, tcInt);
  GravarCampo('5', 1, tcStr);
  GravarCampo(' ', 9, tcStr);
  GravarCampo(FQtdeRegistrosLote, 6, tcInt);
  GravarCampo(PagFor.Lote.Items[I].Registro5.Valor, 18, tcDe2);
  GravarCampo('0', 18, tcStrZero);
  GravarCampo('0', 6, tcStrZero);
  GravarCampo(' ', 165, tcStr);
  GravarCampo(' ', 10, tcStr);

  ValidarLinha('5');
  IncluirLinha;
end;

procedure TArquivoW_Sicredi.GeraRegistro9;
begin
  FpLinha := '';
  Inc(FQtdeRegistros);

  GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
  GravarCampo(9999, 4, tcInt);
  GravarCampo('9', 1, tcStr);
  GravarCampo(' ', 9, tcStr);
  GravarCampo(FQtdeLotes, 6, tcInt);
  GravarCampo(FQtdeRegistros, 6, tcInt);
  GravarCampo('0', 6, tcStrZero);
  GravarCampo(' ', 205, tcStr);

  ValidarLinha('9');
  IncluirLinha;
end;

procedure TArquivoW_Sicredi.GeraSegmentoA(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoA.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoA.Items[J] do
    begin
      Inc(FQtdeRegistros);
      Inc(FQtdeRegistrosLote);
      Inc(FSequencialDoRegistroNoLote);

      GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
      GravarCampo(FQtdeLotes, 4, tcInt);
      GravarCampo('3', 1, tcStr);
      GravarCampo(FSequencialDoRegistroNoLote, 5, tcInt);
      GravarCampo('A', 1, tcStr);
      GravarCampo(TpMovimentoToStr(TipoMovimento), 1, tcStr);
      GravarCampo(InMovimentoToStr(CodMovimento), 2, tcStr);
      GravarCampo(Favorecido.Camara, 3, tcInt);
      GravarCampo(BancoToStr(Favorecido.Banco), 3, tcStr);
      GravarCampo(Favorecido.ContaCorrente.Agencia.Codigo, 5, tcInt);
      GravarCampo(Favorecido.ContaCorrente.Agencia.DV, 1, tcStr);
      GravarCampo(Favorecido.ContaCorrente.Conta.Numero, 12, tcInt64);
      GravarCampo(Favorecido.ContaCorrente.Conta.DV, 1, tcStr);
      GravarCampo(Favorecido.ContaCorrente.DV, 1, tcStr);
      GravarCampo(Favorecido.Nome, 30, tcStr, True);
      GravarCampo(Credito.SeuNumero, 16, tcStr);
      GravarCampo(' ', 4, tcStr);
      GravarCampo(Credito.DataPagamento, 8, tcDat);
      GravarCampo(TpMoedaToStr(Credito.Moeda.Tipo), 3, tcStr);
      GravarCampo(0, 15, tcDe5);
      GravarCampo(Credito.ValorPagamento, 15, tcDe2);
      GravarCampo(Credito.NossoNumero, 20, tcStr);
      GravarCampo(0, 8, tcInt);
      GravarCampo(Credito.ValorReal, 15, tcDe2);
      GravarCampo(Informacao2, 40, tcStr);
      GravarCampo(CodigoDOC, 2, tcStr);
      GravarCampo(CodigoTED, 5, tcStr);
      GravarCampo(' ', 5, tcStr);
      GravarCampo(Aviso, 1, tcInt);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('A');
      IncluirLinha;

      {opcionais do segmento A}
      GeraSegmentoB(SegmentoB);
      GeraSegmentoC(SegmentoC);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoB(mSegmentoBList: TSegmentoBList);
var
  J: Integer;
begin
  for J := 0 to mSegmentoBList.Count - 1 do
  begin
    FpLinha := '';

    with mSegmentoBList.Items[J] do
    begin
      Inc(FQtdeRegistros);
      Inc(FQtdeRegistrosLote);
      Inc(FSequencialDoRegistroNoLote);

      GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
      GravarCampo(FQtdeLotes, 4, tcInt);
      GravarCampo('3', 1, tcStr);
      GravarCampo(FSequencialDoRegistroNoLote, 5, tcInt);
      GravarCampo('B', 1, tcStr);

      if (PixTipoChave <> tcpNenhum) then
      begin
        GravarCampo(TipoChavePixToStr(PixTipoChave), 2, tcStr);
        GravarCampo(' ', 1, tcStr);
        GravarCampo(TpInscricaoToStr(Inscricao.Tipo), 1, tcStr);
        GravarCampo(Inscricao.Numero, 14, tcStrZero);

        if (PixTipoChave = tcpDadosBancarios) then
        begin
          GravarCampo(PixTXID, 35, tcStr);
          GravarCampo(PixMensagem, 24, tcStr);
          GravarCampo(PixChave, 135, tcStr);
        end
        else
        begin
          GravarCampo(PixTXID, 30, tcStr);
          GravarCampo(PixMensagem, 65, tcStr);
          GravarCampo(PixChave, 99, tcStr);
        end;
      end
      else
      begin
        GravarCampo(' ', 3, tcStr);
        GravarCampo(TpInscricaoToStr(Inscricao.Tipo), 1, tcStr);
        GravarCampo(Inscricao.Numero, 14, tcStrZero);
        GravarCampo(Endereco.Logradouro, 30, tcStr, True);
        GravarCampo(Endereco.Numero, 5, tcStrZero);
        GravarCampo(Endereco.Complemento, 15, tcStr, True);
        GravarCampo(Endereco.Bairro, 15, tcStr, True);
        GravarCampo(Endereco.Cidade, 20, tcStr, True);
        GravarCampo(Endereco.CEP, 8, tcInt);
        GravarCampo(Endereco.Estado, 2, tcStr);
        GravarCampo(DataVencimento, 8, tcDat);
        GravarCampo(Valor, 15, tcDe2);
        GravarCampo(Abatimento, 15, tcDe2);
        GravarCampo(Desconto, 15, tcDe2);
        GravarCampo(Mora, 15, tcDe2);
        GravarCampo(Multa, 15, tcDe2);
        GravarCampo(CodigoDOC, 15, tcStr);
        GravarCampo(Aviso, 1, tcInt);
      end;

      if CodigoUG > 0 then
        GravarCampo(CodigoUG, 6, tcInt)
      else
        GravarCampo(' ', 6, tcStr);

      if CodigoISPB > 0 then
        GravarCampo(CodigoISPB, 8, tcInt)
      else
        GravarCampo(' ', 8, tcStr);

      ValidarLinha('B');
      IncluirLinha;
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoJ52(mSegmentoJ52List: TSegmentoJ52List);
var
  J: Integer;
begin
  for J := 0 to mSegmentoJ52List.Count - 1 do
  begin
    FpLinha := '';

    with mSegmentoJ52List.Items[J] do
    begin
      Inc(FQtdeRegistros);
      Inc(FQtdeRegistrosLote);
      Inc(FSequencialDoRegistroNoLote);

      GravarCampo(BancoToStr(PagFor.Geral.Banco), 3, tcStr);
      GravarCampo(FQtdeLotes, 4, tcInt);
      GravarCampo('3', 1, tcStr);
      GravarCampo(FSequencialDoRegistroNoLote, 5, tcInt);
      GravarCampo('J', 1, tcStr);
      GravarCampo(' ', 1, tcStr);
      //Conforme orientado pelo sicredi o J-52 sempre sera 01
      //o codigo do movimento na remessa
      GravarCampo('01', 2, tcStr);
      GravarCampo('52', 2, tcStr);
      GravarCampo(TpInscricaoToStr(Pagador.Inscricao.Tipo), 1, tcStr);
      GravarCampo(Pagador.Inscricao.Numero, 15, tcStrZero);
      GravarCampo(Pagador.Nome, 40, tcStr, True);
      GravarCampo(TpInscricaoToStr(Beneficiario.Inscricao.Tipo), 1, tcStr);
      GravarCampo(Beneficiario.Inscricao.Numero, 15, tcStrZero);
      GravarCampo(Beneficiario.Nome, 40, tcStr, True);

      if Chave = '' then
      begin
        GravarCampo(TpInscricaoToStr(SacadorAvalista.Inscricao.Tipo), 1, tcStr);
        GravarCampo(SacadorAvalista.Inscricao.Numero, 15, tcStrZero);
        GravarCampo(SacadorAvalista.Nome, 40, tcStr, True);
        GravarCampo(' ', 53, tcStr);
      end
      else
      begin
        GravarCampo(Chave, 79, tcStr);
        GravarCampo(TXID, 30, tcStr);
      end;

      ValidarLinha('J52');
      IncluirLinha;
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN1(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN1.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN1.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo('17', 2, tcStr);
      GravarCampo(Competencia, 6, tcInt);
      GravarCampo(ValorTributo, 15, tcDe2);
      GravarCampo(ValorOutrasEntidades, 15, tcDe2);
      GravarCampo(AtualizacaoMonetaria, 15, tcDe2);
      GravarCampo(' ', 45, tcStr);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N1');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN2(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN2.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN2.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo('16', 2, tcStr);
      GravarCampo(Periodo, 8, tcDat);
      GravarCampo(Referencia, 17, tcStrZero);
      GravarCampo(ValorPrincipal, 15, tcDe2);
      GravarCampo(Multa, 15, tcDe2);
      GravarCampo(Juros, 15, tcDe2);
      GravarCampo(DataVencimento, 8, tcDat);
      GravarCampo(' ', 18, tcStr);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N2');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN3(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN3.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN3.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo('18', 2, tcStr);
      GravarCampo(Periodo, 8, tcDat);
      GravarCampo(ReceitaBruta, 15, tcDe2);
      GravarCampo(Percentual, 7, tcDe2);
      GravarCampo(ValorPrincipal, 15, tcDe2);
      GravarCampo(Multa, 15, tcDe2);
      GravarCampo(Juros, 15, tcDe2);
      GravarCampo(' ', 21, tcStr);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N3');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN4(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN4.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN4.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo(TpIndTributoToStr(PagFor.Geral.idTributo), 2, tcStr);
      GravarCampo(DataVencimento, 8, tcDat);
      GravarCampo(InscEst, 12, tcStrZero);
      GravarCampo(NumEtiqueta, 13, tcStrZero);
      GravarCampo(Referencia, 6, tcInt);
      GravarCampo(NumParcela, 13, tcStrZero);
      GravarCampo(ValorReceita, 15, tcDe2);
      GravarCampo(Multa, 14, tcDe2);
      GravarCampo(Juros, 14, tcDe2);
      GravarCampo(' ', 1, tcStr);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N4');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN567(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN567.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN567.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo(TpIndTributoToStr(PagFor.Geral.idTributo), 2, tcStr);
      GravarCampo(Exercicio, 4, tcInt);
      GravarCampo(Renavam, 9, tcStrZero);
      GravarCampo(Estado, 2, tcStr);
      GravarCampo(Municipio, 5, tcInt);
      GravarCampo(Placa, 7, tcStr);

      case PagFor.Geral.idTributo of
        itIPVA:
          begin
            GravarCampo(OpcaoPagamento, 1, tcStr);
            GravarCampo(NovoRenavam, 12, tcStrZero);
            GravarCampo(' ', 55, tcStr);
          end;

        itDPVAT:
          begin
            GravarCampo('5', 1, tcStr);
            GravarCampo(NovoRenavam, 12, tcStrZero);
            GravarCampo(' ', 55, tcStr);
          end;

        itLicenciamento:
          begin
            GravarCampo('5', 1, tcStr);
            GravarCampo(OpcaoRetirada, 1, tcStr);
            GravarCampo(NovoRenavam, 12, tcStrZero);
            GravarCampo(' ', 54, tcStr);
          end;
      else
        begin
          GravarCampo(' ', 1, tcStr);
          GravarCampo(NovoRenavam, 12, tcStrZero);
          GravarCampo(' ', 55, tcStr);
        end;
      end;

      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N567');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN8(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN8.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN8.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(FormatFloat('0000', Receita), 6, tcStr);
      GravarCampo(InscricaoToStr(TipoContribuinte), 2, tcStrZero);
      GravarCampo(idContribuinte, 14, tcStrZero);
      GravarCampo(InscEst, 8, tcStrZero);
      GravarCampo(Origem, 16, tcStrZero);
      GravarCampo(ValorPrincipal, 15, tcDe2);
      GravarCampo(AtualizacaoMonetaria, 15, tcDe2);
      GravarCampo(Mora, 15, tcDe2);
      GravarCampo(Multa, 15, tcDe2);
      GravarCampo(DataVencimento, 8, tcDat);
      GravarCampo(PeriodoParcela, 6, tcInt);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N8');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

procedure TArquivoW_Sicredi.GeraSegmentoN9(I: Integer);
var
  J: Integer;
begin
  for J := 0 to PagFor.Lote.Items[I].SegmentoN9.Count - 1 do
  begin
    FpLinha := '';

    with PagFor.Lote.Items[I].SegmentoN9.Items[J] do
    begin
      GeraSegmentoN(SegmentoN);

      GravarCampo(' ', 120, tcStr);
      GravarCampo(' ', 10, tcStr);

      ValidarLinha('N9');
      IncluirLinha;

      {Adicionais segmento N}
      GeraSegmentoB(SegmentoN.SegmentoB);
      GeraSegmentoW(SegmentoN.SegmentoW);
      GeraSegmentoZ(SegmentoN.SegmentoZ);
    end;
  end;
end;

function TArquivoW_Sicredi.InscricaoToStr(const t: TTipoInscricao): String;
begin
 result := EnumeradoToStr(t, ['1', '2', '3', '9'],
                             [tiCNPJ, tiCPF, tiPISPASEP, tiOutros]);
end;

end.
