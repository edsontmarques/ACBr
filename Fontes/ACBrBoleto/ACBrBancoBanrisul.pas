{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliana Tamizou                                 }
{                                                                              }
{  Você pode obter a última versão desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior.                                                   }
{                                                                              }
{  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU      }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto}
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,  }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Você também pode obter uma copia da licença em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Simões de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatuí - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit ACBrBancoBanrisul;

interface

uses
  Classes, SysUtils,
  ACBrBoleto, ACBrBoletoConversao;

type

  { TACBrBancoBanrisul }

  TACBrBanrisul=class(TACBrBancoClass)
  private
    FiQtdSegmentoR, FiQtdSegmentoY: integer;
  Protected
    procedure EhObrigatorioAgenciaDV; override;
  Public
    constructor create(AOwner: TACBrBanco);
    function MontarCodigoBarras(const ACBrTitulo: TACBrTitulo): string; Override;
    function MontarCampoNossoNumero(const ACBrTitulo: TACBrTitulo): string; Override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): string; Override;
    procedure GerarRegistroHeader400(NumeroRemessa: Integer; aRemessa: TStringList); Override;
    procedure GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; aRemessa: TStringList); Override;
    procedure GerarRegistroTrailler400(ARemessa: TStringList); Override;
    function CalculaDigitosChaveASBACE(const ChaveASBACESemDigito: string): string;
    procedure LerRetorno400(ARetorno: TStringList); override;
    function GerarRegistroHeader240(NumeroRemessa: Integer): String; override;
    function GerarRegistroTransacao240(ACBrTitulo: TACBrTitulo): String; override;
    function GerarRegistroTrailler240(ARemessa: TStringList): String; override;
    procedure LerRetorno240(ARetorno: TStringList); override;

    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo: String): String; override;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String; override;
    function TipoOcorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
  end;

implementation

uses
  {$IFDEF COMPILER6_UP}dateutils{$ELSE}ACBrD5{$ENDIF},
  StrUtils, ACBrUtil.Base, ACBrUtil.FilesIO, ACBrUtil.Strings, ACBrUtil.DateTime,
  ACBrUtil.Math;

var
  aTotal: Extended;

{ TACBrBancoBanrisul }

constructor TACBrBanrisul.create(AOwner: TACBrBanco);
begin
  inherited create(AOwner);
  fpDigito                := 8;
  fpNome                  := 'Banrisul';
  fpNumero                := 041;
  fpTamanhoMaximoNossoNum := 8;
  fpTamanhoAgencia        := 4;
  fpTamanhoConta          := 12;
  fpTamanhoCarteira       := 1;
  fpLayoutVersaoArquivo   := 40;
  fpLayoutVersaoLote      := 20;
  fpCodigosMoraAceitos    :='0123';
  fpOrientacoesBanco.Clear;
  fpOrientacoesBanco.Add(ACBrStr('SAC       BANRISUL - 0800 646 1515'+sLineBreak+
                                 'OUVIDORIA BANRISUL - 0800 644 2200'));
  FiQtdSegmentoR := 0;
  FiQtdSegmentoY := 0;
end;

procedure TACBrBanrisul.EhObrigatorioAgenciaDV;
begin
  //sem validação
end;

function Modulo11(const Valor: string; Base: Integer=9; Resto: boolean=false): string;
var
  Soma, Contador, Peso, Digito: integer;
begin
  Soma:=0;
  Peso:=2;
  for Contador:=Length(Valor)downto 1 do
  begin
    Soma:=Soma+(StrToInt(Valor[Contador])*Peso);
    if Peso<Base then
      Peso:=Peso+1
    else
      Peso:=2;
  end;

  if Resto then
    Result:=IntToStr(Soma mod 11)
  else
  begin
    Digito:=11-(Soma mod 11);
    if (Digito>9) then
      Digito:=0;
    Result:=IntToStr(Digito);
  end
end;

function TACBrBanrisul.CalculaDigitosChaveASBACE(const ChaveASBACESemDigito: string): string;
{Calcula os 2 dígitos usados na CHAVE ASBACE - Código usado por bancos estaduais}
var
  Digito1, Digito2: integer;

  function CalcularDigito1(ChaveASBACESemDigito: string): integer;
   {
    Calcula o primeiro dígito.
    O cálculo é parecido com o da rotina Modulo10. Porém, não faz diferença o
    número de dígitos de cada subproduto.
    Se o resultado da operação for 0 (ZERO) o dígito será 0 (ZERO). Caso contrário,
    o dígito será igual a 10 - Resultado.
   }
  var
    Auxiliar, Soma, Contador, Peso, Digito1: integer;
  begin
    Soma:=0;
    Peso:=2;
    for Contador:=Length(ChaveASBACESemDigito)downto 1 do
    begin
      Auxiliar:=(StrToInt(ChaveASBACESemDigito[Contador])*Peso);
      if Auxiliar>9 then
        Auxiliar:=Auxiliar-9;
      Soma:=Soma+Auxiliar;
      if Peso=1 then
        Peso:=2
      else
        Peso:=1;
    end;

    Digito1:=Soma mod 10;
    if (Digito1=0) then
      Result:=Digito1
    else
      Result:=10-Digito1;
  end;

  function CalcularDigito2(ChaveASBACESemDigito: string; var Digito1: integer):
      integer;
   {Calcula o segundo dígito}
  var
    Digito2: integer;
    ChaveASBACEComDigito1: string;
  begin
    ChaveASBACEComDigito1:=ChaveASBACESemDigito+IntToStr(Digito1);
    Digito2:=StrToInt(Modulo11(ChaveASBACEComDigito1, 7, true));
    {Se dígito2 = 1, deve-se incrementar o dígito1 e recalcular o dígito2}
    if Digito2=1 then
    begin
      Digito1:=Digito1+1;
         {Se, após incrementar o dígito1, ele ficar maior que 9, deve-se
          substituí-lo por 0}
      if Digito1>9 then
        Digito1:=0;
      Digito2:=CalcularDigito2(ChaveASBACESemDigito, Digito1);
    end
    else if Digito2>1 then
    begin
      Digito2:=11-Digito2;
    end;

    Result:=Digito2;
  end;

begin
  Digito1:=CalcularDigito1(ChaveASBACESemDigito);
  Digito2:=CalcularDigito2(ChaveASBACESemDigito, Digito1);

  Result:=IntToStr(Digito1)+IntToStr(Digito2);
end;

function TACBrBanrisul.MontarCodigoBarras(const ACBrTitulo: TACBrTitulo): string;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras, CampoLivre, Modalidade,digitoVerificador, LCedente: string;
  DigitoNum: Integer;
begin
  with ACBrTitulo do
  begin
    if ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
      Modalidade:='2'
    else
      Modalidade:='1';

    FatorVencimento:=CalcularFatorVencimento(ACBrTitulo.Vencimento);

    if ((fpLayoutVersaoArquivo >= 103) and (Length(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente) = 13)) then
      LCedente := copy(ACBrBoleto.Cedente.CodigoCedente,5,13)
    else
      LCedente := ACBrBoleto.Cedente.CodigoCedente;

     CampoLivre:= Modalidade +'1'+
                  PadLeft(copy(trim(ACBrBoleto.Cedente.Agencia),1,4), 4, '0')+{ Código agência (cooperativa) }
                  PadLeft(OnlyNumber(LCedente), 7, '0')+{ Código cedente = codigoCedente }
                  PadLeft(NossoNumero, 8, '0')+{ Nosso número }
                  '40';

     

    DigitoVerificador:= CalculaDigitosChaveASBACE(CampoLivre);

    CampoLivre := CampoLivre + DigitoVerificador;

     
     CodigoBarras:= PadLeft(IntToStr(Numero), 3, '0')+'9'+
                    FatorVencimento+{ Fator de vencimento, não obrigatório }
                    IntToStrZero(Round(ACBrTitulo.ValorDocumento*100), 10)+{ valor do documento }
                    CampoLivre; { Campo Livre }

    DigitoCodBarras:=CalcularDigitoCodigoBarras(CodigoBarras);
    DigitoNum:=StrToIntDef(DigitoCodBarras, 0);

    if (DigitoNum = 0) or (DigitoNum > 9) then
      DigitoCodBarras:='1';
  end;

  Result:=PadLeft(IntToStr(Numero), 3, '0')+'9'+DigitoCodBarras+Copy(CodigoBarras, 5, 39);
end;

function TACBrBanrisul.MontarCampoNossoNumero(const ACBrTitulo: TACBrTitulo): string;
begin
  Result:=PadLeft(ACBrTitulo.NossoNumero, 8, '0');
  result:=Result+'.'+CalculaDigitosChaveASBACE(Result);
end;

function TACBrBanrisul.MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): string;
begin
  // Código da Agência
  Result := copy(ACBrTitulo.ACBrBoleto.Cedente.Agencia, 1, 4);
  // Prosseguir somente se a Agência tiver dígito
  if ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito <> '' then
    begin
      // Separador do dígito da Agência
      Result := Result + '-';
      // Dígito da Agência
      Result := Result + ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito;
    end;
  // Separador entre a Agência e o Código Cedente
  Result := Result + '/';
  // Código do cedente
  Result := Result + Copy(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente,1,6) ;
  Result := Result + Copy(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente,7,1) + '-';
  Result := Result + Copy(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente,8,2);

  if(fpLayoutVersaoArquivo >= 103) then
    Result := IfThen(Length(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente) <> 13,
                     ACBrTitulo.ACBrBoleto.Cedente.Agencia
                     + ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente,
                     ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente);

end;

procedure TACBrBanrisul.GerarRegistroHeader400(NumeroRemessa: Integer; aRemessa: TStringList);
var
  cd,wLinha: string;
begin
  aTotal:=0;
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    cd:= OnlyNumber(CodigoCedente);

    wLinha:= '0'                                          + // ID do Registro
             '1'                                          + // ID do Arquivo( 1 - Remessa)
             'REMESSA'                                    + // Literal de Remessa
             space(17)                                    + // Brancos
             PadLeft(copy(trim(Agencia), 1, 4)+cd, 13, '0')  + // Código Agencia + Cedente AAAACCCCCCCCC
             space(7)                                     + // Brancos
             PadRight(Nome, 30, ' ')                          + // Nome da empresa Cedente
             PadRight('041BANRISUL', 11)                      + // Código e Nome do Banco Constante(041Banrisul)
             space(7)                                     + // Brancos
             FormatDateTime('ddmmyy', Now)                + // Data de gravação do arquivo
             Space(9)                                     + // Brancos
             space(4)                                     + // Código do serviço - Somente para carteiras R, S e X
             ' '                                          + // Brancos
             space(1)                                     + // Tipo de processamento - Somente para carteiras R, S e X
             ' '                                          + // Brancos
            space(10)                                     + // Código do cliente no Office Banking - Somente para carteiras R, S e X
            Space(268)                                    + // Brancos
            IntToStrZero(1, 6);                             // Constante (000001)

    aRemessa.Text := aRemessa.Text + UpperCase(wLinha);
  end;
end;

procedure TACBrBanrisul.GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; aRemessa: TStringList);
var
  AMensagem,
  Ocorrencia, cd, TipoSacado     :String;
  aTipoAceite , aTipoCobranca, TipoBoleto, wLinha :String;
begin
  with ACBrTitulo do
  begin
    {Pegando Código da Ocorrencia}
    case OcorrenciaOriginal.Tipo of
      toRemessaBaixar                        : Ocorrencia:='02'; {Pedido de Baixa}
      toRemessaConcederAbatimento            : Ocorrencia:='04'; {Concessão de Abatimento}
      toRemessaCancelarAbatimento            : Ocorrencia:='05'; {Cancelamento de Abatimento concedido}
      toRemessaAlterarVencimento             : Ocorrencia:='06'; {Alteração de vencimento}
      toRemessaProtestar                     : Ocorrencia:='09'; {Pedido de protesto}
      toRemessaSustarProtesto                : Ocorrencia:='10'; {Sustação de protesto}
      toRemessaAlterarNumeroDiasProtesto     : Ocorrencia:='16'; {Alteração do numero de dias para protesto}
      //toRemessaCancelarInstrucaoProtestoBaixa: Ocorrencia:='18'; {Sustar protesto e baixar} //---Estão erradas essas ocorrencias comentadas
      //toRemessaCancelarInstrucaoProtesto     : Ocorrencia:='19'; {Sustar protesto e manter na carteira}
      //toRemessaOutrasOcorrencias             : Ocorrencia:='31'; {Alteração de Outros Dados}
    else
      Ocorrencia:='01'; {Remessa}
    end;
    
    {Pegando Tipo de Boleto}
    case ACBrBoleto.Cedente.ResponEmissao of
      tbCliEmite    : TipoBoleto:='08';   //Cobrança credenciada Banrisul
      tbBancoReemite: TipoBoleto:='04'; //Cobrança Direta
      tbBancoEmite: TipoBoleto:='06'; //Cobrança Direta
    else
      TipoBoleto:='08'; //Cobrança credenciada Banrisul
    end;

    { Pegando o Aceite do Titulo }
    case Aceite of
      atSim: ATipoAceite:='A';
      atNao: ATipoAceite:='N';
    end;

    {Pegando Tipo de Sacado}
    case Sacado.Pessoa of
      pFisica  : TipoSacado := '01';
      pJuridica: TipoSacado := '02';
    else
      TipoSacado:='99';
    end;

    { Pegando Tipo de Cobrança - Tipo de Carteira}
    case CaracTitulo of
      tcSimples: aTipoCobranca := '1';
      //tcDescontada: aTipoCobranca:='';
      tcVendor: aTipoCobranca:='F';
      tcVinculada: aTipoCobranca:='C';
    else
      aTipoCobranca:='1';
    end;

    if CodigoMora='' then
      CodigoMora:='0'; //0-Valor Diario, 1-Taxa Mensal

    {Instruções}
    if ((DataProtesto <> 0) and (DataProtesto > Vencimento)) then //Se tiver protesto
    begin
      if (Trim(Instrucao1) = '') then
        Instrucao1 := '09';  //Protestar caso impago em NN dias após vencimento.
    end
    else
    if (DataBaixa <> 0) and (DataBaixa > Vencimento) then  // Devolução / BAixa
    begin
      if (Trim(Instrucao1) = '') then
        Instrucao1 := '15';  //Devolver caso impago em NN dias após vencimento.
    end
    else
      Instrucao1 := '23'; //Não protestar

    if (PercentualMulta > 0) then
    begin
      if (Trim(Instrucao2) = '') then
        Instrucao2 := '18'; //Apos NN dias vencimento com percentual multa
    end;

    AMensagem   := '';
    if Mensagem.Text <> '' then
      AMensagem   := Mensagem.Strings[0];

    with ACBrBoleto do
    begin
      cd:= OnlyNumber(Cedente.CodigoCedente);

      wLinha:= '1'                                                              + // ID Registro(1-Constante)
               space(16)                                                        + // Brancos
               PadLeft(copy(trim(Cedente.Agencia), 1, 4) + cd, 13, '0')            + // Codigo da Agencia e Cedente AAAACCCCCCCCC
               space(7)                                                         + // Brancos
               PadRight(SeuNumero,25)                                               + // Identificação do título para o cedente (usado no arquivo de retorno)
               PadRight(NossoNumero, 8, '0')+CalculaDigitosChaveASBACE(NossoNumero) + // Nosso Número
               PadRight( AMensagem, 32)                                         + // Mensagem no bloqueto
               space(3)                                                         + // Brancos
               aTipoCobranca                                                    + // Tipo de Carteira (Simples, Vinculada, Descontada, Vendor)
               Ocorrencia                                                       + // Código de ocorrência
               PadRight(NumeroDocumento, 10)                                        + // Seu Número
               FormatDateTime('ddmmyy', Vencimento)                             + // Data de vencimento do título
               IntToStrZero(Round(ValorDocumento*100), 13)                      + // Valor do título
               '041'                                                            + // Constante (041)
               space(5)                                                         + // Brancos
               TipoBoleto                                                       + // Tipo de Documento (04-Cobrança Direta, 06-Cobrança Escritural, 08-Cobrança credenciada Banrisul, 09-Títulos de terceiros)
               aTipoAceite                                                      + // Código de aceite (A, N)
               FormatDateTime('ddmmyy', DataDocumento)                          + // Data de Emissão do título
               PadLeft(trim(Instrucao1), 2)                                        + // 1ª Instrução
               PadLeft(trim(Instrucao2), 2)                                        + // 2ª Instrução
               PadLeft(trim(CodigoMora), 1)                                        + // Código de mora (0=Valor diário; 1=Taxa Mensal)

               ifthen(ValorMoraJuros > 0,
                       IntToStrZero(Round(ValorMoraJuros*100), 12), Space(12))  + // Valor ao dia ou Taxa Mensal de juros
               IfThen(DataDesconto = 0, space(6),                                 //se nao tem valor deve ser branco os campos numéricos
                      FormatDateTime('ddmmyy', DataDesconto))                   + // Data para concessão de desconto
               ifthen(ValorDesconto > 0,
                      IntToStrZero(Round(ValorDesconto*100), 13), Space(13))    + // Valor do desconto a ser concedido
               ifthen(ValorIOF > 0,
                      IntToStrZero(Round(ValorIOF*100), 13), Space(13))         + // Valor IOF (para carteira "X" é: taxa juros + IOF + zeros)
               ifthen(ValorAbatimento > 0,
                      IntToStrZero(Round(ValorAbatimento*100), 13), Space(13))  + // Valor do abatimento

               TipoSacado                                                       + // Tipo do Sacado (01-CPF, 02-CNPJ, 03-Outros)
               PadLeft(OnlyCPFCNPJAlphaNum(Sacado.CNPJCPF), 14, '0')                     + // Número da inscrição do Sacado (CPF, CNPJ)
               PadRight(Sacado.NomeSacado, 35)                                  + // Nome do Sacado
               space(5)                                                         + // Brancos
               PadRight(Sacado.Logradouro+' '+
                    Sacado.Numero+' '+
                    Sacado.Complemento, 40)                                     + // Endereço Sacado
               space(7)                                                         + // Brancos
               ifthen(PercentualMulta > 0,
               IntToStrZero(Round( PercentualMulta * 10), 3), Space(3))         + // Taxa de multa após o Vencimento -- estava '000' é apenas uma casa decimal
               IfThen((DataMoraJuros <> 0) and (DataMoraJuros > Vencimento),
                      PadLeft(IntToStr(DaysBetween(DataMoraJuros, Vencimento)),
                      2, '0'), '00')                                                + // Nº dias para multa após o vencimento (00 considera-se Após Vencimento)
               PadRight(OnlyNumber(Sacado.CEP), 8, '0')                             + // CEP
               PadRight(Sacado.Cidade, 15)                                          + // Cidade do Sacado
               PadRight(Sacado.UF, 2)                                               + // UF do Sacado
               space(18)                                                            + // Brancos
               IfThen((DataProtesto <> 0) and (DataProtesto > Vencimento),
                      PadLeft(IntToStr(DaysBetween(DataProtesto, Vencimento)),2,'0'),   // Dias para protesto/
                      IfThen((DataBaixa <> 0) and (DataBaixa > Vencimento),
                            PadLeft(IntToStr(DaysBetween(DataBaixa, Vencimento)),2,'0'),  // Dias para devolução automática
                      Space(2)) )                                                      +

               space(23)                                                        + // Brancos
               IntToStrZero(aRemessa.Count + 1, 6);                               // Número sequencial do registro  

      aTotal:=aTotal+ValorDocumento;

      aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
    end;
  end;
end;

procedure TACBrBanrisul.GerarRegistroTrailler400(ARemessa: TStringList);
var
  wLinha: String;
begin
  wLinha:= '9'                                     + // Constante (9)
           space(26)                               + // Brancos
           FormatCurr('0000000000000', aTotal*100) + // Total Somatório dos valores dos títulos
           space(354)                              + // Brancos
           IntToStrZero(ARemessa.Count+1, 6);        // Número sequencial do Registro

  ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
end;

function TACBrBanrisul.GerarRegistroHeader240(
  NumeroRemessa: Integer): String;
var TipoInsc: String;
begin
  case ACBrBanco.ACBrBoleto.Cedente.TipoInscricao of
     pFisica:   TipoInsc := '1';
     pJuridica: TipoInsc := '2';
  else 
     TipoInsc := '9';
  end;

  with ACBrBanco.ACBrBoleto.Cedente do 
  begin
     Result := '041'+                                             //   1 -   3   Código do banco
               DupeString('0', 4) +                               //   4 -   7   Lote de serviço
               '0' +                                              //   8 -   8   Registro header de arquivo
               Space(9) +                                         //   9 -  17   Uso exclusivo FEBRABAN/CNAB
               TipoInsc +                                         //  18 -  18   Tipo de inscrição
               OnlyCPFCNPJAlphaNum(CNPJCPF) +                              //  19 -  32   Número de inscrição da empresa (Não considerado)
               PadLeft(OnlyNumber(Convenio), 13, '0') +           //  33 -  45   Código do convênio
               Space(7) +                                         //  46 -  52   Brancos
               '0'+                                               //  53 -  53   Zeros
               PadLeft(OnlyNumber(Agencia), 4, '0') +             //  54 -  57   Agência (Não considerado)
               PadLeft(AgenciaDigito, 1, ' ') +                   //  58 -  58   Dígito agência (Não considerado)
               PadLeft(OnlyNumber(Conta), 12, '0') +              //  59 -  70   Número da conta (Não considerado)
               ContaDigito +                                      //  71 -  71   Dígito da conta (Não considerado)
               Space(1) +                                         //  72 -  72   Dígito verificador da agência/conta (Não considerado)
               PadRight(Nome, 30) +                               //  73 - 102   Nome do cedente
               PadRight(UpperCase(ACBrBanco.Nome), 30) +          // 103 - 132   Nome do banco
               Space(10) +                                        // 133 - 142   Uso exclusivo FEBRABAN/CNAB
               '1'+                                               // 143 - 143   Código remessa
               FormatDateTime('ddmmyyyyhhnnss', Now) +            // 144 - 157   Data e hora da geração do arquivo
               IntToStrZero(NumeroRemessa, 6) +                   // 158 - 163   Número sequencial do arquivo
               PadLeft(IntToStr(fpLayoutVersaoArquivo), 3, '0')+  // 164 - 166   Número da versão do layout do arquivo
               DupeString('0', 5) +                               // 167 - 171   Densidade de gravação do arquivo
               Space(69);                                         // 172 - 240   Outros campos

     Result := Result + #13#10 +
               '041' +                                            //   1 -   3   Código do banco
               '0001' +                                           //   4 -   7   Lote de serviço
               '1'+                                               //   8 -   8   Registro header de lote
               'R'+                                               //   9 -   9   Tipo de operação
               '01';                                              //  10 -  11   Tipo de serviço
     if(fpLayoutVersaoArquivo < 103) then
     begin
       Result := Result +
               '00' +                                               //  12 -  13   Forma de lançamento
               PadLeft(IntToStr(fpLayoutVersaoLote), 3, '0') +    //  14 -  16   Número da versão do layout do lote
               Space(1) +                                         //  17 -  17   Uso exclusivo FEBRABAN/CNAB
               TipoInsc +                                         //  18 -  18   Tipo de inscrição da empresa
               PadLeft(OnlyCPFCNPJAlphaNum(CNPJCPF), 15, '0') +            //  19 -  33   Número de inscrição da empresa
               PadLeft(OnlyNumber(Convenio), 13, '0') +           //  34 -  46   Código do convênio
               Space(7) +                                         //  47 -  53   Brancos
               PadLeft(OnlyNumber(Agencia), 5, '0') +             //  54 -  58   Agência
               PadLeft(AgenciaDigito, 1, ' ') +                   //  59 -  59   Dígito da agência
               PadLeft(OnlyNumber(Conta), 12, '0') +              //  60 -  71   Número da conta
               ContaDigito +                                      //  72 -  72   Dígito da conta
               Space(1) +                                         //  73 -  73   Dígito verificador da agência/conta
               PadLeft(Nome, 30) +                                //  74 - 103   Nome da empresa
               Space(80) +                                        // 104 - 183   Mensagens
               IntToStrZero(NumeroRemessa, 8) +                   // 184 - 191   Número sequencial do arquivo
               FormatDateTime('ddmmyyyy', Now) +                  // 192 - 199   Data de geração do arquivo
               DupeString('0', 8) +                               // 200 - 207   Data do crédito
               DupeString(' ', 33);                               // 208 - 240   Uso exclusivo FEBRABAN/CNAB
     end else
     begin
       Result := Result +
               '  ' +                                             //  12 -  13   BRANCOS
               PadLeft(IntToStr(fpLayoutVersaoLote), 3, '0') +    //  14 -  16   Número da versão do layout do lote
               Space(1) +                                         //  17 -  17   Uso exclusivo FEBRABAN/CNAB
               TipoInsc +                                         //  18 -  18   Tipo de inscrição da empresa
               PadLeft(OnlyCPFCNPJAlphaNum(CNPJCPF), 15, '0') +            //  19 -  33   Número de inscrição da empresa
               PadLeft(OnlyCPFCNPJAlphaNum(Convenio), 13, '0') +           //  34 -  46   Código do convênio
               Space(7) +                                         //  47 -  53   Brancos
               PadLeft(OnlyNumber(Agencia), 5, '0') +             //  54 -  58   Agência
               PadLeft(AgenciaDigito, 1, ' ') +                   //  59 -  59   Dígito da agência
               PadLeft(OnlyNumber(Conta), 12, '0') +              //  60 -  71   Número da conta
               ContaDigito +                                      //  72 -  72   Dígito da conta
               Space(1) +                                         //  73 -  73   Dígito verificador da agência/conta
               PadRight(Nome, 30) +                                //  74 - 103   Nome da empresa
               Space(80) +                                        // 104 - 183   Mensagens
               IntToStrZero(NumeroRemessa, 8) +                   // 184 - 191   Número sequencial do arquivo
               FormatDateTime('ddmmyyyy', Now) +                  // 192 - 199   Data de geração do arquivo
               DupeString(' ', 8) +                               // 200 - 207   Data do crédito
               DupeString(' ', 33);                               // 208 - 240   Uso exclusivo FEBRABAN/CNAB
     end;
  end;
end;

function TACBrBanrisul.GerarRegistroTrailler240(
  ARemessa: TStringList): String;
var Valor: Currency;
    i, Ps: Integer;
    iQtdRegistros: integer;
begin
   Valor := 0.00;
   Ps := 1;
   for i := 0 to ARemessa.Count - 1 do
   begin
      if (ARemessa.Strings[i][14] = 'P') then
         Valor := Valor + (StrToCurr(Copy(ARemessa.Strings[i], 86, 15)) / 100);

      while (Pos('*****', ARemessa.Strings[i]) > 0) do
      begin
         ARemessa.Strings[i] := StringReplace(ARemessa.Strings[i], '*****', IntToStrZero(Ps, 5), []);
         Inc(Ps);
      end;
   end;
   // Calcular o total de registro do Trailler de lote
   iQtdRegistros := (ARemessa.Count * 2) + FiQtdSegmentoR + FiQtdSegmentoY;
   // Adicionar linha do Trailler de lote
   Result := '04100015'+
           DupeString(' ', 9) +
           IntToStrZero(iQtdRegistros, 6) +
           IntToStrZero(((ARemessa.Count * 2) - 2) div 2, 6) +
           PadLeft(StringReplace(FormatFloat('#####0.00', Valor), ',', '', []), 17, '0');
   if(fpLayoutVersaoLote < 60) then
   begin
      Result := Result +
               DupeString('0', 77) +
               DupeString(' ', 117);
   end else
   begin
     Result := Result +
               DupeString('0', 69) +
               DupeString(' ', 125);
   end;
   // Calcular o total de registro do Trailler de arquivo
   iQtdRegistros := ((ARemessa.Count + 1) * 2) + FiQtdSegmentoR + FiQtdSegmentoY;
   // Adicionar linha do Trailler de arquivo
   Result := Result + #13#10 +
             '04199999' +
             DupeString(' ', 9) +
             '000001' +
             IntToStrZero(iQtdRegistros, 6) +
             DupeString('0', 6) +
             DupeString(' ', 205);

   FiQtdSegmentoR := 0;
   FiQtdSegmentoY := 0;
end;

function TACBrBanrisul.GerarRegistroTransacao240(
  ACBrTitulo: TACBrTitulo): String;
var
    aAceite, DiasProt, Juros, TipoInscSacado, Ocorrencia, LEspecie: String;
    sDiasBaixaDevol, ACaracTitulo, ATipoBoleto, AEspecieCobranca : String;
    LTipoMoraJuros : byte;
begin
   with ACBrTitulo do begin
      case Aceite of
         atSim: aAceite := 'A';
         atNao: aAceite := 'N';
      end;

      DiasProt := '00';

      if (DataProtesto > 0) then
         DiasProt := PadLeft(IntToStr(DaysBetween(Vencimento, DataProtesto)), 2, '0');

      if (DiasProt = '00') then
         DiasProt := '0'+ DiasProt
      else
         DiasProt := '1'+ DiasProt;

      if(fpLayoutVersaoArquivo >= 103) and (CodigoNegativacao = cnNaoProtestar) then
        DiasProt := '300';
      // Se a instrução relativa ao código de baixa estiver vazia
      if (Instrucao2 = '') then
        begin
          // Se tiver uma data de baixa definida, e está for maior que a data de vencimento
          if (DataBaixa <> 0) and (DataBaixa > Vencimento) then
            Instrucao2 := '1' // BAIXAR / DEVOLVER
          else // Não realizar baixa caso não tenha uma data definida
            Instrucao2 := ' ' // NAO BAIXAR / NAO DEVOLVER
        end
      else // Se a instrução estiver preenchida
        begin
          // Validar se a instrução passada é válida
          if not MatchText(Trim(Instrucao2), ['0', '1', '2']) then
            raise Exception.Create('Código de Baixa/Devolução informado incorretamente!');
        end;
      // Número de dias para baixa/devolução
      sDiasBaixaDevol:= ifThen(DataBaixa > 0, IntToStrZero(DaysBetween(Vencimento,DataBaixa),3), '   ');
      {quando latyout >= 103}
      if (fpLayoutVersaoArquivo >= 103) then
      begin
       if (CaracTitulo = tcDescontada) then
         Juros := '3'+DupeString('0', 23)
       else
         begin
          case StrToIntDef(CodigoMora,0) of
          1 : LTipoMoraJuros := 1;
          2 : LTipoMoraJuros := 2;
          else
            LTipoMoraJuros := 3;
          end;
          if ((ValorMoraJuros > 0) and (LTipoMoraJuros in [1,2])) then
           begin
             if (LTipoMoraJuros = 2) then
               if ValorMoraJuros > 99.99 then
                  raise Exception.Create('Percentual ValorMoraJuros não pode ser maior que 99,99% !');
             Juros := IntToStr(LTipoMoraJuros) + IfThen(DataMoraJuros = 0, '00000000', FormatDateTime('ddmmyyyy', DataMoraJuros)) + PadLeft(StringReplace(FormatFloat('#####0.00', ValorMoraJuros), ',', '', []), 15, '0')
           end
          else
             Juros := '3'+DupeString('0', 23)
         end;
      end
      else  {quando latyout < 103}
        if (DataMoraJuros > 0) then
           Juros := '1'+ FormatDateTime('ddmmyyyy', DataMoraJuros) + PadLeft(StringReplace(FormatFloat('#####0.00', ValorMoraJuros), ',', '', []), 15, '0')
        else
           Juros := DupeString('0', 24);

      case Sacado.Pessoa of
         pFisica:   TipoInscSacado := '1';
         pJuridica: TipoInscSacado := '2';
      end;

      case OcorrenciaOriginal.Tipo of
         toRemessaBaixar:             Ocorrencia := '02'; {Pedido de Baixa}
         toRemessaConcederAbatimento: Ocorrencia := '04'; {Concessão de Abatimento}
         toRemessaCancelarAbatimento: Ocorrencia := '05'; {Cancelamento de Abatimento concedido}
         toRemessaAlterarVencimento:  Ocorrencia := '06'; {Alteração de vencimento}
         toRemessaProtestar:          Ocorrencia := '09'; {Pedido de protesto}
         toRemessaAlterarJurosMora:   Ocorrencia := '12'; {Alteração de Juros}
         toRemessaAlterarMulta:       Ocorrencia := '14'; {Alteração de Multa}
         toRemessaCancelarInstrucaoProtestoBaixa: Ocorrencia := '18'; {Sustar protesto e baixar}
         toRemessaCancelarInstrucaoProtesto:     Ocorrencia := '19'; {Sustar protesto e manter na carteira}
         toRemessaOutrasOcorrencias:  Ocorrencia := '31'; {Alteração de Outros Dados}
      else
         Ocorrencia := '01'; {Remessa}
      end;

      {Definindo o tipo da Especie do Titulo}
      if Trim(EspecieDoc) = 'DM' then
         LEspecie := '02'
      else if Trim(EspecieDoc) = 'DMI' then
         LEspecie := '03'
      else if Trim(EspecieDoc) = 'DS' then
         LEspecie := '04'
      else if Trim(EspecieDoc) = 'DSI' then
         LEspecie := '05'
      else if Trim(EspecieDoc) = 'LC' then
         LEspecie := '07'
      else if Trim(EspecieDoc) = 'NP' then
         LEspecie := '12'
      else if Trim(EspecieDoc) = 'PC' then
         LEspecie := '22'
      else if Trim(EspecieDoc) = 'CC' then
         LEspecie := '31'
      else if Trim(EspecieDoc) = 'BDP' then
         LEspecie := '32'
      else if Trim(EspecieDoc) = 'OUTROS' then
         LEspecie := '99'
      else
         LEspecie := '02';  // valor padrão DM

     {Pegando Tipo de Boleto}
     ATipoBoleto := '1';
     case ACBrBoleto.Cedente.ResponEmissao of
       tbCliEmite : ATipoBoleto := '2';
       tbBancoEmite : ATipoBoleto := '1';
     end;

      ACaracTitulo := '1';
      case CaracTitulo of
        tcSimples     :
          begin
            ACaracTitulo  := '1';
            AEspecieCobranca := '805076'
          end;
        tcVinculada   : ACaracTitulo  := '2';
        tcCaucionada  : ACaracTitulo  := '3';
        tcDescontada  :
          begin
            ACaracTitulo     := '4';
            AEspecieCobranca := '603015';
          end
      end;
      {Segmento "P"}
      if(fpLayoutVersaoArquivo < 103) then
      begin
        Result := '041'  +                                                                                                              //  1-3    CODIGO DO BANCO
                  '0001'+                                                                                                               //  4-7    LOTE
                  '3' +                                                                                                                 //  8-8    REGISTRO DETALHE 3
                  DupeString('*', 5) +                                                                                                  //  9-13   NUM. SEQUENCIAL DO LOTE
                  'P'+                                                                                                                  //  14-14  CODIGO SEGUIMENTO P
                  Space(1) +                                                                                                            //  15-15  BRANCOS
                  Ocorrencia +                                                                                                          //  16-17  CODIGO DO MOVIMENTO
                  PadLeft(OnlyNumber(ACBrBanco.ACBrBoleto.Cedente.Agencia), 5, '0') +                                                   //  18-22  Agência mantenedora da conta
                  PadLeft( ACBrBanco.ACBrBoleto.Cedente.AgenciaDigito, 1, ' ') +                                                        //  23-23  Dígito verificador da agência
                  PadLeft(OnlyNumber(ACBrBanco.ACBrBoleto.Cedente.Conta), 12, '0') +                                                    //  24-35  Número da conta corrente
                  PadLeft( ACBrBanco.ACBrBoleto.Cedente.ContaDigito, 1, ' ') +                                                          //  36-36  Dígito verificador da conta
                  Space(1) +                                                                                                            //  37-37  Dígito verificador da ag/conta
                  PadLeft(OnlyNumber(MontarCampoNossoNumero(ACBrTitulo)), 10, '0') +                                                    //  38-57  NOSSO NUMERO (SOMENTE 10 POSICOES DEMAIS BRANCOS
                  DupeString(' ', 10) +                                                                                                 //         RESTANTE DO NOSSO NUMERO EM BRANCO - 10 POSIÇÕES RESTANTES
                  ACaracTitulo +                                                                                                        //  58-58  CARTEIRA
                  '1' +                                                                                                                 //  59-59  CADASTRAMENTO
                  '0' +                                                                                                                 //  60-60  TIPO DE DOCUMENTO
                  ATipoBoleto +                                                                                                         //  61-61  EMISSAO DO BLOQUETO
                  '0' +                                                                                                                 //  62-62  DISTRIBUIÇÃO DO BLOQUETO
                  PadRight(NumeroDocumento, 15) +                                                                                       //  63-77  NUMERO DO DOCUMENTO
                  FormatDateTime('ddmmyyyy', Vencimento) +                                                                              //  78-85  VENCIMENTO DO BOLETO
                  PadLeft(StringReplace(FormatFloat('#####0.00', ValorDocumento), ',', '', []), 15, '0') +                              //  86-100 VALOR DO TITULO
                  '00000' +                                                                                                             // 101-105 AGENCIA COBRADORA
                  '0' +                                                                                                                 // 106-106 DV AGENCIA COBRADORA
                  PadRight(LEspecie,2) +                                                                                                // 107-108 ESPECIDE DO TITULO
                  aAceite +                                                                                                             // 109-109 ACEITE
                  FormatDateTime('ddmmyyyy', DataProcessamento) +                                                                       // 110-117 DATA DE EMISSAO
                  Juros +                                                                                                               // 118-141 JUROS
                  IfThen(ValorDesconto > 0, IfThen(DataDesconto > 0, '1','3'), '0')                                                   + // 142-142 codigo desconto
                  IfThen(ValorDesconto > 0, IfThen(DataDesconto > 0, FormatDateTime('ddmmyyyy',DataDesconto),'00000000'), '00000000') + // 143-150 Data do desconto
                  IfThen(ValorDesconto > 0, IntToStrZero( round(ValorDesconto * 100), 15),PadRight('', 15, '0'))                      + // 151-165 Valor do desconto por dia
                  IntToStrZero( round(ValorIOF * 100), 15)                                                                            + // 166-180 valor do IOF a ser recolhido
                  IntToStrZero( round(ValorAbatimento * 100), 15)                                                                     + // 181-195 Valor do abatimento
                  PadRight(IfThen(SeuNumero <> '',SeuNumero,NumeroDocumento), 25, ' ')                                                + // 196-220 Identificação do Título na Empresa 25 - Alfa G072
                  DiasProt +                                                                                                            // 222-223 NUMERO DE DIAS PARA PROTESTO
                  PadRight(Trim(Instrucao2), 1, ' ') +                                                                                  // 224-224 CODIGO PARA BAIXA
                  sDiasBaixaDevol +                                                                                                     // 225-227 DIAS PARA BAIXA DO BOLETO
                  '09' +                                                                                                                // 228-229 CODIGO DA MOEDA - 09 REAL
                  DupeString('0', 10) +                                                                                                 // 230-239 NUMERO DO CONTRATO
                  ' ';                                                                                                                  // 240-240 BRANCOS
      end else
      begin
        Result := '041'  +                                                                                                              //  1-3    CODIGO DO BANCO
                  '0001'+                                                                                                               //  4-7    LOTE
                  '3' +                                                                                                                 //  8-8    REGISTRO DETALHE 3
                  DupeString('*', 5) +                                                                                                  //  9-13   NUM. SEQUENCIAL DO LOTE
                  'P'+                                                                                                                  //  14-14  CODIGO SEGUIMENTO P
                  Space(1) +                                                                                                            //  15-15  BRANCOS
                  Ocorrencia +                                                                                                          //  16-17  CODIGO DO MOVIMENTO
                  PadLeft(OnlyNumber(ACBrBanco.ACBrBoleto.Cedente.Agencia), 5, '0') +                                                   //  18-22  Agência mantenedora da conta
                  PadLeft( ACBrBanco.ACBrBoleto.Cedente.AgenciaDigito, 1, ' ') +                                                        //  23-23  Dígito verificador da agência
                  PadLeft(OnlyNumber(ACBrBanco.ACBrBoleto.Cedente.Conta), 12, '0') +                                                    //  24-35  Número da conta corrente
                  PadLeft( ACBrBanco.ACBrBoleto.Cedente.ContaDigito, 1, ' ') +                                                          //  36-36  Dígito verificador da conta
                  Space(1) +                                                                                                            //  37-37  Dígito verificador da ag/conta
                  PadLeft(OnlyNumber(MontarCampoNossoNumero(ACBrTitulo)), 10, '0') +                                                    //  38-57  NOSSO NUMERO (SOMENTE 10 POSICOES DEMAIS BRANCOS
                  DupeString(' ', 10) +                                                                                                 //         RESTANTE DO NOSSO NUMERO EM BRANCO - 10 POSIÇÕES RESTANTES
                  ACaracTitulo +                                                                                                        //  58-58  CARTEIRA
                  '1' +                                                                                                                 //  59-59  CADASTRAMENTO
                  '1' +                                                                                                                 //  60-60  TIPO DE DOCUMENTO 1 TRADICIONAL - 2 ESCRITURAL
                  ATipoBoleto +                                                                                                         //  61-61  EMISSAO DO BLOQUETO
                  IfThen(NaoEstaVazio(ACBrBoleto.Cedente.PIX.Chave),'P', IfThen(ACBrBoleto.Cedente.IdentDistribuicao = tbClienteDistribui,'2','1')) + //  62-62  DISTRIBUIÇÃO DO BLOQUETO
                  PadRight(NumeroDocumento, 15) +                                                                                       //  63-77  NUMERO DO DOCUMENTO
                  FormatDateTime('ddmmyyyy', Vencimento) +                                                                              //  78-85  VENCIMENTO DO BOLETO
                  PadLeft(StringReplace(FormatFloat('#####0.00', ValorDocumento), ',', '', []), 15, '0') +                              //  86-100 VALOR DO TITULO
                  '00000' +                                                                                                             // 101-105 AGENCIA COBRADORA
                  '0' +                                                                                                                 // 106-106 DV AGENCIA COBRADORA
                  PadRight(LEspecie,2) +                                                                                                // 107-108 ESPECIDE DO TITULO
                  aAceite +                                                                                                             // 109-109 ACEITE
                  FormatDateTime('ddmmyyyy', DataProcessamento) +                                                                       // 110-117 DATA DE EMISSAO
                  Juros +                                                                                                               // 118-141 JUROS
                  IfThen(ValorDesconto > 0, IfThen(DataDesconto > 0, '1','3'), '0')                                                   + // 142-142 codigo desconto
                  IfThen(ValorDesconto > 0, IfThen(DataDesconto > 0, FormatDateTime('ddmmyyyy',DataDesconto),'00000000'), '00000000') + // 143-150 Data do desconto
                  IfThen(ValorDesconto > 0, IntToStrZero( round(ValorDesconto * 100), 15),PadRight('', 15, '0'))                      + // 151-165 Valor do desconto por dia
                  IntToStrZero( round(ValorIOF * 100), 15)                                                                            + // 166-180 valor do IOF a ser recolhido
                  IntToStrZero( round(ValorAbatimento * 100), 15)                                                                     + // 181-195 Valor do abatimento
                  PadRight(IfThen(SeuNumero <> '',SeuNumero,NumeroDocumento), 25, ' ')                                                + // 196-220 USO DA EMPRESA BENEFICIÁRIA
                  DiasProt +                                                                                                            // 222-223 NUMERO DE DIAS PARA PROTESTO
                  PadRight(Trim(Instrucao2), 1, ' ') +                                                                                  // 224-224 CODIGO PARA BAIXA
                  sDiasBaixaDevol +                                                                                                     // 225-227 DIAS PARA BAIXA DO BOLETO
                  '09' +                                                                                                                // 228-229 CODIGO DA MOEDA - 09 REAL
                  PadLeft(AEspecieCobranca,10,'0') +                                                                                    // 230-239 ESPECIE DE COBRANCA
                  '1';                                                                                                                  // 240-240 NÃO PERMITE RECEBIMENTO PARCIAL
      end;


      {Segmento "Q" }
      Result := Result + #13#10 +
                '04100013' +
                DupeString('*', 5) +
                'Q ' +
                Ocorrencia +
                TipoInscSacado +
                PadLeft(OnlyCPFCNPJAlphaNum(Sacado.CNPJCPF), 15, '0') +
                PadRight(Sacado.NomeSacado, 40) +
                PadRight(Sacado.Logradouro+' '+
                    Sacado.Numero+' '+
                    Sacado.Complemento, 40) +
                PadRight(Sacado.Bairro, 15) +
                StringReplace(Sacado.CEP, '-', '', []) +
                PadRight(Sacado.Cidade, 15) +
                Sacado.UF +
                DupeString('0', 16) +
                DupeString(' ', 40) +
                '000' +
                DupeString(' ', 28);

      if (PercentualMulta > 0) then
      begin
       {Segmento "R"}
       Result := Result +
                 #13#10 +
                 '041'  +                                                                                                                           //   1-3  BANCO
                 '0001' +                                                                                                                           //   4-7  LOTE
                 '3'    +                                                                                                                           //   8-8   REGISTRO
                 DupeString('*', 5) +                                                                                                               //   9-13  SEQ. LOTE
                 'R'    +                                                                                                                           //  14-14  SEGMENTO
                 ' '    +                                                                                                                           //  15-15  BRANCOS
                 Ocorrencia +                                                                                                                       //  16-17  CODIGO MOVIMENTO
                 DupeString('0', 1)  +                                                                                                              //  18-18  CÓDIGO DESCONTO 2
                 DupeString('0', 8)  +                                                                                                              //  19-26  DATA DESCONTO 2
                 DupeString('0', 15) +                                                                                                              //  27-41  VALOR DESCONTO 2
                 DupeString('0', 1)  +                                                                                                              //  42-42  CODIGO DESCONTO 3
                 DupeString('0', 8)  +                                                                                                              //  43-50  DATA DESCONTO 3
                 DupeString('0', 15) +                                                                                                              //  51-65  VALOR DESCONTO 3
                 ifthen(MultaValorFixo, '1', '2') +                                                                                                 //  66-66  CODIGO DA MULTA
                 IfThen(DataMulta = 0, '00000000', FormatDateTime('ddmmyyyy', DataMulta)) +                                                             //  67-74  DATA DA MULTA

                 PadLeft(OnlyNumber(IfThen(MultaValorFixo,FloatToIntStr(PercentualMulta,2),
                                                          FloatToIntStr(PercentualMulta,1) + '0') )
                                      , 15, '0') +                                                                  //  75-89  VALOR/PERCENTUAL MULTA
                 DupeString(' ', 10) +                                                                                                              //  90-99  INFORMAÇÃO DO BANCO PAGADOR
                 DupeString(' ', 40) +                                                                                                              // 100-139 MENSAGEM 3
                 DupeString(' ', 40);                                                                                                               // 140-179 MENSAGEM 4
        if(fpLayoutVersaoArquivo < 103) then
        begin
          Result := Result +
                 DupeString('0', 3)  +                                                                                                              // 180-182 CODIGO DO BANCO DA CONTA DO DEBITO
                 DupeString('0', 4)  +                                                                                                              // 183-186 CODIGO DA AGENCIA DO DEBITO
                 DupeString('0', 13) +                                                                                                              // 187-199 CONTA CORRENTE /DV DO DEBITO
                 DupeString('0', 8)  +                                                                                                              // 200-207 CODIGO DE OCORRENCIA DO PAGADOR
                 DupeString(' ', 33);                                                                                                               // 208-240 BRANCOS
        end else
        begin
          Result := Result +
                 DupeString(' ', 20) +                                                                                                              // 180-199 BRANCOS
                 DupeString('0', 8)  +                                                                                                              // 200-207 CODIGO OCORRENCIA DO PAGADOR
                 DupeString('0', 3)  +                                                                                                              // 208-210 CODIGO DO BANCO DA CONTA DO DEBITO
                 DupeString('0', 5)  +                                                                                                              // 211-215 CODIGO DA AGENCIA DO DEBITO
                 DupeString(' ', 1)  +                                                                                                              // 216-216 DV AGENCIA DO DEBITO
                 DupeString('0', 12) +                                                                                                              // 217-228 CONTA CORRENTE DO DEBITO
                 DupeString(' ', 1)  +                                                                                                              // 229-229 DV CONTA CORRENTE DO DEBITO
                 DupeString(' ', 1)  +                                                                                                              // 230-230 DV AGENCIA/CONTA
                 DupeString('0', 1)  +                                                                                                              // 231-231 AVISO DEBITO AUTOMATICO
                 DupeString(' ', 9);                                                                                                                // 232-240 BRANCOS
        end;
       // Atualizar o contador do Segmento R
       Inc(FiQtdSegmentoR);
      end;

      // Segmento "Y-04"
      if (NaoEstaVazio(ACBrBoleto.Cedente.PIX.Chave)) then
      begin
        Result := Result +
                  #13#10 +
                  '041'  +                                // 001 a 003 Código do Banco na compensação
                  '0001' +                                // 004 a 007 Lote de serviço
                  '3'    +                                // 008 a 008 Tipo de registro
                  DupeString('*', 5)  +                   // 009 a 013 Nº sequencial do registro no lote
                  'Y'    +                                // 014 a 014 Cód. segmento do detalhe
                  ' '    +                                // 015 a 015 Brancos
                  Ocorrencia +                            // 016 a 017 Código de movimento
                  '04'   +                                // 018 a 019 Identificação registro
                  DupeString(' ', 50) +                   // 020 a 069 E-mail para envio da informação
                  DupeString(' ', 2)  +                   // 070 a 071 Código DDD do celular
                  DupeString(' ', 9)  +                   // 072 a 080 Número de celular
                  '5'    +                                // 081 a 081 Tipo de Chave PIX
                  DupeString(' ', 77) +                   // 082 a 158 Chave PIX / URL do QR Code
                  DupeString(' ', 35) +                   // 159 a 193 Código de Identificação do QR Code
                  DupeString(' ', 47);                    // 194 a 240 Brancos

        // Atualizar o contador do Segmento Y
        Inc(FiQtdSegmentoY);
      end;
      if(fpLayoutVersaoArquivo >= 103) then
      begin
        if ListaDadosNFe.Count > 0 then // Se tem informacoes de NFe associadas ao titulo
        begin
          if ListaDadosNFe[0].ValorNFe > 0 then
          begin
            Result := Result +
                      #13#10 +
                      '041'  +                                                                                                                   //  001-003 BANCO
                      '0001' +                                                                                                                   //  004-007 LOTE
                      '3'    +                                                                                                                   //  008-008 REGISTRO
                      DupeString('*', 5) +                                                                                                       //  009-013 SEQ. LOTE
                      'Y'    +                                                                                                                   //  014-014 SEGMENTO
                      ' '    +                                                                                                                   //  015-015 BRANCOS
                      Ocorrencia +                                                                                                               //  016-017 CODIGO MOVIMENTO
                      '52'  +                                                                                                                    //  018-019 Identificação Registro Opcional 52
                      PadRight(ListaDadosNFe[0].NumNFe, 15) +                                                                                    //  020-034 Número da Nota Fiscal 1
                      IntToStrZero( round(ListaDadosNFe[0].ValorNFe * 100), 15) +                                                                //  035-049 Valor da Nota Fiscal 1
                      FormatDateTime('ddmmyyyy', ListaDadosNFe[0].EmissaoNFe)  +                                                                 //  050-057 Data Emissão da Nota Fiscal 1
                      PadRight(ListaDadosNFe[0].ChaveNFe, 44);                                                                                   //  058-101 Chave de acesso DANFE NF 1
                      if ACBrTitulo.ListaDadosNFe.Count <  2 then
                        Result := Result +
                        Space(15) +
                        StringOfChar('0',67) +
                        Space (57)                                                                                                              // 184-240 Uso Exclusivo FEBRABAN/CNAB
                      else
                      begin
                        Result := Result +
                        PadRight(ListaDadosNFe[1].NumNFe, 15, ' ') +                                                                           // 020-034 Nota Fiscal 1 Número da Nota Fiscal
                        IntToStrZero(round(ListaDadosNFe[1].ValorNFe * 100), 15) +                                                             // 035-049 Valor N. Fiscal Valor da Nota Fiscal
                        FormatDateTime('ddmmyyyy', ListaDadosNFe[1].EmissaoNFe) +                                                              // 050-057 Data Emissão Data Emissão da Nota Fiscal
                        PadRight(ListaDadosNFe[1].ChaveNFe, 44, ' ') +                                                                         // 058-101 Chave Acesso Chave de Acesso DANFE NF
                        Space (57);                                                                                                            // 184-240 Uso Exclusivo FEBRABAN/CNAB
                      end;
            // Atualizar o contador do Segmento Y
            Inc(FiQtdSegmentoY);
          end;
        end;
      end;
   end;
end;

procedure TACBrBanrisul.LerRetorno240(ARetorno: TStringList);
var Titulo: TACBrTitulo;
    FSegT, FSegU, FSegY: String;
    FTituloErro: TStringList;
    Index, IdxMotivo: Integer;
    rCNPJCPF,rCedente,rConvenio: String;
    rAgencia,rAgenciaDigito: String;
    rConta,rContaDigito: String;
begin
  if (StrToInt(Copy(ARetorno.Strings[0], 1, 3)) <> Numero) then
      raise Exception.Create(ACBrStr('"'+ ACBrBanco.ACBrBoleto.NomeArqRetorno +
                                     '" não é um arquivo de retorno do(a) '+ UpperCase(Nome)));

  rCedente       := trim(copy(ARetorno[0], 73, 30));
  rConvenio      := trim(Copy(ARetorno.Strings[1], 34, 13));
  rAgencia       := trim(Copy(ARetorno.Strings[1], 54,  5));
  rAgenciaDigito := trim(Copy(ARetorno.Strings[1], 59,  1));
  rConta         := trim(Copy(ARetorno.Strings[1], 60, 12));
  rContaDigito   := trim(Copy(ARetorno.Strings[1], 72,  1));

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno.Strings[0], 158, 6), 0);

  try
    ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno.Strings[0], 144, 2) +'/'+
                                                            Copy(ARetorno.Strings[0], 146, 2) +'/'+
                                                            Copy(ARetorno.Strings[0], 148, 4),
                                                            0, 'DD/MM/YYYY');
  except
    ACBrBanco.ACBrBoleto.DataArquivo   := 0;
  end;

  try
    ACBrBanco.ACBrBoleto.DataCreditoLanc := StringToDateTimeDef(Copy(ARetorno.Strings[1], 200, 2) +'/'+
                                                                 Copy(ARetorno.Strings[1], 202, 2) +'/'+
                                                                 Copy(ARetorno.Strings[1], 204, 4),
                                                                 0, 'DD/MM/YYYY');
  except
    ACBrBanco.ACBrBoleto.DataCreditoLanc := 0;
  end;

  rCNPJCPF := OnlyCPFCNPJAlphaNum(copy(ARetorno[1], 20, 14));

  try
    ValidarDadosRetorno(rAgencia, rConta, rCNPJCPF);
    with ACBrBanco.ACBrBoleto do
    begin

      Cedente.Nome   := rCedente;
      Cedente.CNPJCPF:= rCNPJCPF;

      case StrToIntDef(Copy(ARetorno.Strings[0], 18, 1),0) of
        1:
         Cedente.TipoInscricao := pFisica;
        else
         Cedente.TipoInscricao := pJuridica;
      end;

      Cedente.Convenio      := rConvenio;
      Cedente.Agencia       := rAgencia;
      Cedente.AgenciaDigito := rAgenciaDigito;
      Cedente.Conta         := rConta;
      Cedente.ContaDigito   := rContaDigito;

      ListadeBoletos.Clear;
    end;

    FTituloErro := TStringList.Create;
    try
      Index := 2;
      while Index < ARetorno.Count - 3 do
      begin
        FSegT := ARetorno.Strings[Index];
        FSegU := ARetorno.Strings[Index + 1];
        if (FSegT[14] <> 'T') then
        begin
          Inc(Index);
          Continue;
        end;

        FSegY := ARetorno.Strings[Index + 2];
        if (FSegY[14] <> 'Y') then
          FSegY := '';

        try
          Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;
          with Titulo do
          begin
            if (FSegT[133] = '1') then
              Sacado.Pessoa := pFisica
            else if (FSegT[133] = '2') then
              Sacado.Pessoa := pJuridica
            else
              Sacado.Pessoa := pOutras;
            case Sacado.Pessoa of
              pFisica:   Sacado.CNPJCPF := Copy(FSegT, 138, 11);
              pJuridica: Sacado.CNPJCPF := Copy(FSegT, 135, 14);
              else
                Sacado.CNPJCPF := Copy(FSegT, 134, 15);
            end;
            Sacado.NomeSacado := Trim(Copy(FSegT, 149, 40));

            NumeroDocumento      := Trim(Copy(FSegT, 59, 15));
            if trim(Copy(FSegT,106, 25)) <> '' then
               SeuNumero            := Copy(FSegT,106, 25)
            else
               SeuNumero            := NumeroDocumento;

            Carteira             := Copy(FSegT, 58, 1);
            NossoNumero          := Trim(Copy(FSegT, 38, TamanhoMaximoNossoNum));
//            NossoNumero          := Trim(Copy(FSegT, 38, 20));
            Vencimento           := StringToDateTimeDef(Copy(FSegT, 74, 2) +'/'+
                                                        Copy(FSegT, 76, 2) +'/'+
                                                        Copy(FSegT, 78, 4), 0, 'DD/MM/YYYY');
            ValorDocumento       := StrToInt64Def(Copy(FSegT,  82, 15), 0) / 100;
            ValorDespesaCobranca := StrToInt64Def(Copy(FSegT, 199, 15), 0) / 100;
            ValorMoraJuros       := StrToInt64Def(Copy(FSegU,  18, 15), 0) / 100;
            ValorDesconto        := StrToInt64Def(Copy(FSegU,  33, 15), 0) / 100;
            ValorAbatimento      := StrToInt64Def(Copy(FSegU,  48, 15), 0) / 100;
            ValorIOF             := StrToInt64Def(Copy(FSegU,  63, 15), 0) / 100;
            ValorPago            := StrToInt64Def(Copy(FSegU,  78, 15), 0) / 100;
            ValorRecebido        := StrToInt64Def(Copy(FSegU,  93, 15), 0) / 100;
            ValorOutrasDespesas  := StrToInt64Def(Copy(FSegU, 108, 15), 0) / 100;
            ValorOutrosCreditos  := StrToInt64Def(Copy(FSegU, 123, 15), 0) / 100;

            try
              DataOcorrencia     := StringToDateTimeDef(Copy(FSegU, 138, 2) +'/'+
                                                        Copy(FSegU, 140, 2) +'/'+
                                                        Copy(FSegU, 142, 4), 0, 'DD/MM/YYYY');
            except
              DataOcorrencia     := 0;
            end;

            try
              DataCredito        := StringToDateTimeDef(Copy(FSegU, 146, 2) +'/'+
                                                        Copy(FSegU, 148, 2) +'/'+
                                                        Copy(FSegU, 150, 4), 0, 'DD/MM/YYYY');
            except
              DataCredito        := 0;
            end;

            if(Copy(FSegT, 16, 2) = 'AB')then
              OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(999)
            else
              OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(StrToIntDef(Copy(FSegT, 16, 2), 0));

            IdxMotivo := 214;
            while (IdxMotivo < 223) do
            begin
              if (Copy(FSegT, IdxMotivo, 2) <> '  ') then begin
                Titulo.MotivoRejeicaoComando.Add(Copy(FSegT, IdxMotivo, 2));
                Titulo.DescricaoMotivoRejeicaoComando.Add(
                   CodMotivoRejeicaoToDescricao(Titulo.OcorrenciaOriginal.Tipo, Trim(Copy(FSegT, IdxMotivo, 2))));
              end;
              Inc(IdxMotivo, 2);
            end;

            if Trim(Copy(FSegY,82,77)) <> '' then
              Titulo.QrCode.PIXQRCodeDinamico(Trim(Copy(FSegY,82,77)),Trim(Copy(FSegY,159,35)), Titulo);
          end;
        except
          FTituloErro.Add(' - Linhas '+ IntToStr(Index) +' e '+ IntToStr(Index + 1));
        end;

        Inc(Index);
      end;

      if (FTituloErro.Count > 0) then
      begin
        raise Exception.Create(ACBrStr('No arquivo de retorno "'+ ACBrBanco.ACBrBoleto.NomeArqRetorno +
                           '", não foi possível realizar a leitura do(s) seguinte(s) título(s):'+ #13#10 +
                           FTituloErro.Text));
      end;
    finally
      FTituloErro.Free;
    end;
  except
    raise Exception.Create(ACBrStr('Não foi possível realizar a leitura do arquivo de retorno "'+
                       ACBrBanco.ACBrBoleto.NomeArqRetorno +'" do(a) '+ UpperCase(Nome)));
  end;
end;

procedure TACBrBanrisul.LerRetorno400(ARetorno: TStringList);
var Titulo: TACBrTitulo;
    Linha: String;
    CodOcorrencia, IdxMotivo, ContLinha: Integer;
    rCedente,rConvenio: String;
    rAgencia,rAgenciaDigito: String;
    rConta,rContaDigito: String;
begin
  if (StrToInt(Copy(ARetorno.Strings[0], 77, 3)) <> Numero) then
      raise Exception.Create(ACBrStr('"'+ ACBrBanco.ACBrBoleto.NomeArqRetorno +
                                     '" não é um arquivo de retorno do(a) '+ UpperCase(Nome)));

  fpTamanhoMaximoNossoNum:=10;

  rCedente       := trim(copy(ARetorno[0], 47, 30));   //Nome da Empresa
  rConvenio      := ''; //Não possui essa info
  rAgencia       := trim(Copy(ARetorno.Strings[0], 27, 4));
  rAgenciaDigito := ''; //Não possui essa info
  rConta         := trim(Copy(ARetorno.Strings[0], 31, 9));
  rContaDigito   := ''; //Não possui essa info
  if Length(OnlyNumber(trim(Copy(ARetorno.Strings[0], 27, 4)) + trim(Copy(ARetorno.Strings[0], 31, 9)))) = 12 then//significa que a agencia tem somente 3 digitos + 9 digitos para a conta
  begin
    rAgencia       := PadLeft(trim(Copy(ARetorno.Strings[0], 27, 3)), 4, '0');
    rConta         := trim(Copy(ARetorno.Strings[0], 30, 9));
  end;

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno.Strings[0], 386, 9), 0);

  try
    ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno.Strings[0], 95, 2) +'/'+
                                                            Copy(ARetorno.Strings[0], 97, 2) +'/'+
                                                            Copy(ARetorno.Strings[0], 99, 2),
                                                            0, 'DD/MM/YY');
  except
    ACBrBanco.ACBrBoleto.DataArquivo := 0;
  end;

  with ACBrBanco.ACBrBoleto do
  begin
    if (not LeCedenteRetorno) and ((rAgencia <> OnlyNumber(Cedente.Agencia)) or
    (rConta <> OnlyNumber(Cedente.CodigoCedente))) then
      raise Exception.Create(ACBrStr('Agência\Conta do arquivo inválido'));

    Cedente.Nome   := rCedente;
    Cedente.CNPJCPF:= '';
    {case StrToIntDef(Copy(ARetorno.Strings[0], 18, 1),0) of
      1:
       Cedente.TipoInscricao := pFisica;
      else
       Cedente.TipoInscricao := pJuridica;
    end;}

    Cedente.Convenio      := rConvenio;
    Cedente.Agencia       := rAgencia;
    Cedente.AgenciaDigito := rAgenciaDigito;
    Cedente.Conta         := rConta;
    Cedente.ContaDigito   := rContaDigito;

    ListadeBoletos.Clear;
  end;

  for ContLinha := 1 to ARetorno.Count - 2 do
  begin
    Linha := ARetorno[ContLinha];

    if (Copy(Linha,1,1) <> '1') then
      Continue;

    Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;
    with Titulo do
    begin
      NossoNumero          := Copy(Linha,63,10);
      SeuNumero            := copy(Linha,38,25);
      NumeroDocumento      := copy(Linha,117,10);

      ValorDocumento       := StrToFloatDef(Copy(Linha,153,13),0)/100;
      ValorAbatimento      := StrToFloatDef(Copy(Linha,228,13),0)/100;
      ValorDesconto        := StrToFloatDef(Copy(Linha,241,13),0)/100;
      ValorRecebido        := StrToFloatDef(Copy(Linha,254,13),0)/100;
      ValorMoraJuros       := StrToFloatDef(Copy(Linha,267,13),0)/100;
      ValorOutrosCreditos  := StrToFloatDef(Copy(Linha,280,13),0)/100;    //Multa estava faltando
      //Anderson
      ValorDespesaCobranca := StrToFloatDef(Copy(Linha,176,13),0)/100;
      ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;
      if (StrToIntDef(Copy(Linha,147,6),0) <> 0) then
        Vencimento := StringToDateTimeDef( Copy(Linha,147,2)+'/'+
                                           Copy(Linha,149,2)+'/'+
                                           Copy(Linha,151,2),0, 'DD/MM/YY' );

      if StrToIntDef(Copy(Linha,296,6),0) <> 0 then
      begin
        try
          DataCredito:= StringToDateTimeDef( Copy(Linha,296,2)+'/'+
                                            Copy(Linha,298,2)+'/'+
                                            Copy(Linha,300,2),0, 'DD/MM/YY' );
        except
          DataCredito := 0;
        end;
      end;

      try
        DataOcorrencia := StringToDateTimeDef( Copy(Linha,111,2)+'/'+
                                              Copy(Linha,113,2)+'/'+
                                              Copy(Linha,115,2),0, 'DD/MM/YY' );
      except
        DataOcorrencia := 0;
      end;

      OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(Copy(Linha,109,2),0));
      CodOcorrencia := StrToIntDef(Copy(Linha,109,2), 0);
      if ((CodOcorrencia = 3) or (CodOcorrencia = 16) or (CodOcorrencia = 18)) then
      begin
        IdxMotivo := 383;   
        while (IdxMotivo < 392) do
        begin
          if (Copy(Linha, IdxMotivo, 2) <> '  ') then
          begin
            MotivoRejeicaoComando.Add(Copy(Linha, IdxMotivo, 2));
            DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo, Trim(Copy(Linha, IdxMotivo, 2))));
          end;
          Inc(IdxMotivo, 2);
        end;
      end;
    end;
  end;
end;

function TACBrBanrisul.CodMotivoRejeicaoToDescricao(
  const TipoOcorrencia: TACBrTipoOcorrencia; Const CodMotivo: String): String;
begin
  case TipoOcorrencia of

    toRetornoRegistroConfirmado:
    begin
      if (CodMotivo = 'A4') then
        Result := 'Sacado DDA'
      else Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
    end;

    toRetornoLiquidado,
    toRetornoLiquidadoAposBaixaouNaoRegistro:
    begin
      case StrToIntDef(CodMotivo, 0) of
        01: Result := 'Por saldo - Reservado';
        02: Result := 'Por conta (parcial)';
        03: Result := 'No próprio banco';
        04: Result := 'Compensação Eletrônica';
        05: Result := 'Compensação Convencional';
        06: Result := 'Por meio Eletrônico';
        07: Result := 'Reservado';
        08: Result := 'Em Cartório';
        else Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
      end;
    end;

    toRetornoBaixado:
    begin
      case StrToIntDef(CodMotivo, 0) of
        0:
        begin
          if (CodMotivo = 'AA') then
            Result := 'Baixa por pagamento'
          else Result := '00 - Outros Motivos';
        end;
        09: Result := 'Comandado Banco';
        10: Result := 'Comandado cliente Arquivo';
        11: Result := 'Comandado cliente On-Line';
        12: Result := 'Decurso prazo - cliente';
        else Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
      end;
    end;

    toRetornoTituloEmSer:
    begin
      case StrToIntDef(CodMotivo, 0) of
        70: Result := 'Título não selecionado por erro no CNPJ/CPF ou endereço';
        76: Result := 'Banco aguarda cópia autenticada do documento';
        77: Result := 'Título selecionado falta seu número';
        78: Result := 'Título rejeitado pelo cartório por estar irregular';
        79: Result := 'Título não selecionado - praça não atendida';
        80: Result := 'Cartório aguarda autorização para protestar por edital';
        90: Result := 'Protesto sustado por solicitação do cedente';
        91: Result := 'Protesto sustado por alteração no vencimento';
        92: Result := 'Aponte cobrado de título sustado';
        93: Result := 'Protesto sustado por alteração no prazo do protesto';
        95: Result := 'Entidade Pública';
        97: Result := 'Título em cartório';
        else Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
      end;
    end;

    toRetornoDebitoTarifas:
    begin
      case StrToIntDef(CodMotivo, 0) of
        00:
        begin
          if (CodMotivo = 'AA') then
            Result := 'Tarifa de formulário Pré-Impresso'
          else Result := '00 - Outros Motivos';
        end;
        01: Result := 'Tarifa de extrato de posição';
        02: Result := 'Tarifa de manutenção de título vencido';
        03: Result := 'Tarifa de sustação e envio para cartório';
        04: Result := 'Tarifa de protesto';
        05: Result := 'Tarifa de outras instruções';
        06: Result := 'Tarifa de outras ocorrências(Registro/Liquidação)';
        07: Result := 'Tarifa de envio de duplicata ao sacado';
        08: Result := 'Custas de protesto';
        09: Result := 'Custas de Sustação de Protesto';
        10: Result := 'Custas do cartório distribuidor';
        11: Result := 'Reservado';
        else Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
      end;
    end;

    toRetornoRegistroRecusado,
    toRetornoInstrucaoRejeitada,
    toRetornoAlteracaoDadosRejeitados:
    begin
      case StrToIntDef(CodMotivo, 0) of
        01: Result := '01-Código do Banco inválido';
        02: Result := '02-Agencia/Conta/Numero de controle - Invalido cobranca partilhada';
        04: Result := '04-Código do movimento nao permitido para a carteira';
        05: Result := '05-Código do movimento inválido';
        08: Result := '08-Nosso Número inválido';
        09: Result := '09-Nosso Número duplicado';
        10: Result := '10-Carteira inválida';
        15: Result := '15-Características da cobrança incompatíveis - Analisar motivos(*)';
        16: Result := '16-Data de vencimento inválida - Analisar motivos(*)';
        17: Result := '17-Data de vencimento anterior a data de emissão';
        18: Result := '18-Vencimento fora do prazo de operação';
        20: Result := '20-Valor do título inválido (não numérico)';
        21: Result := '21-Espécie de título inválida (arquivo de registro)';
        23: Result := '23-Aceite inválido - verifica conteúdo válido';
        24: Result := '24-Data de emissão inválida - verifica se a data é numérica e se está no formato válido';
        25: Result := '25-Data de emissão posterior à data de processamento';
        26: Result := '26-Código de juros de mora inválido';
        27: Result := '27-Valor/Taxa de juros de mora inválido';
        28: Result := '28-Código de desconto inválido';
        29: Result := '29-Valor do desconto maior ou igual ao valor do título';
        30: Result := '30-Desconto a conceder não confere - Analisar motivos(*)';
        32: Result := '32-Valor de IOF inválido - Analisar motivos(*)';
        33: Result := '33-Valor do abatimento inválido - Analisar motivos(*)';
        34: Result := '34-Valor do abatimento maior ou igual ao valor do título';
        37: Result := '37-Código para protesto inválido - rejeita o título se o campo for diferente de branco,0,1 ou 3';
        38: Result := '38-Prazo para protesto inválido - se o código for 1 verifica se o campo é numérico';
        39: Result := '39-Pedido de protesto não permitido para o título - não permite protesto para as carteiras R,S,N e X';
        40: Result := '40-Título com ordem de protesto emitida (para retorno de alteração)';
        41: Result := '41-Pedido de cancelamento/sustação de protesto inválido';
        42: Result := '42-Código para baixa/devolução ou instrução inválido - verifica se o código é branco,0,1 ou 2';
        43: Result := '43-Prazo para baixa/devolução inválido - se o código é 1 verifica se o campo prazo é numérico';
        44: Result := '44-Código da moeda inválido';
        45: Result := '45-Nome do Pagador inválido ou alteração do Pagador não permitida';
        46: Result := '46-Tipo/número de inscrição do Pagador inválido';
        47: Result := '47-Endereço não informado ou alteração de endereço não permitida';
        48: Result := '48-CEP inválido ou alteração de CEP não permitida';
        49: Result := '49-CEP sem praça de cobrança ou alteração de cidade não permitida';
        50: Result := '50-CEP referente a um Banco correspondente';
        52: Result := '52-UF inválida ou alteração de UF não permitida';
        53: Result := '53-Tipo/número de inscrição do Sacador/Avalista inválido';
        54: Result := '54-Sacador/Avalista não informado - para a espécie AD o nome do Sacador é obrigatório';
        57: Result := '57-Código da multa inválido';
        58: Result := '58-Data da multa inválida';
        59: Result := '59-Valor/Percentual da multa inválido';
        60: Result := '60-Movimento para título não cadastrado - alteração ou devolução';
        62: Result := '62-Tipo de impressão inválido - Segmento 3S - Analisar motivos(*)';
        63: Result := '63-Entrada de título já cadastrado';
        79: Result := '79-Data de juros de mora inválido - valida data ou prazo na instrução de juros';
        80: Result := '80-Data do documento inválida - valida data ou prazo da instrução de desconto';
        81: Result := '81-CEP inválido do Sacador';
        83: Result := '83-Tipo/número de inscrição do Sacador inválido';
        84: Result := '84-Sacador não informado';
        86: Result := '86-Seu número inválido (para retorno de alteração)';
      else
        Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
      end;
    end;
  else
    Result := IntToStrZero(StrToIntDef(CodMotivo, 0), 2) +' - Outros Motivos';
  end;

  Result := ACBrSTr(Result);
end;

function TACBrBanrisul.CodOcorrenciaToTipo(
  const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
   Result := toTipoOcorrenciaNenhum;

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case CodOcorrencia of
      04: Result := toRetornoTransferenciaCarteira;
      05: Result := toRetornoReembolsoDevolucaoDescontoVendor;
      07: Result := toRetornoLiquidadoParcialmente;                  //Liquidação Parcial
      09: Result := toRetornoBaixado;
      11: Result := toRetornoTituloEmSer;
      15: Result := toRetornoProtestoImediatoFalencia;
      17: Result := toRetornoLiquidadoAposBaixaOuNaoRegistro;
      24: Result := toRetornoReservado;
      25: Result := toRetornoBaixaPorProtesto;
      26: Result := toRetornoInstrucaoRejeitada;
      27: Result := toRetornoDadosAlterados;
      28: Result := toRetornoDebitoTarifas;
      30: Result := toRetornoAlteracaoDadosRejeitados;
    end;
  end
  else
  begin
    case CodOcorrencia of
      04: Result := toRetornoBaixaLiquidadoEdital;
      07: Result := toRetornoLiquidadoParcialmente;
      08: Result := toRetornoLiquidadoSaldoRestante;
      10: Result := toRetornoBaixadoInstAgencia;
      15: Result := toRetornoLiquidadoEmCartorio;
      16: Result := toRetornoDadosAlterados;
      18: Result := toRetornoAlteracaoInstrucao;
      21: Result := toRetornoAguardandoAutorizacaoProtestoEdital;
      22: Result := toRetornoProtestoSustado;
      25: Result := toRetornoBaixadoPorDevolucao;
      26: Result := toRetornoDevolvidoPeloCartorio;
      30: Result := toRetornoCobrancaCreditar;
      31: Result := toRetornoTransitoPagoCartorio;
      32: Result := toRetornoReembolsoTransferenciaDescontoVendor;
      33: Result := toRetornoReembolsoDevolucaoDescontoVendor;
      34: Result := toRetornoReembolsoNaoEfetuado;
      40: Result := toRetornoBaixaPorProtesto;
      41: Result := toRetornoDespesasProtesto;
      42: Result := toRetornoRecebimentoInstrucaoAlterarDados;
      43: Result := toRetornoRelacaoDeTitulos;
      44: Result := toRetornoDebitoMensalTarifasManutencaoTitulosVencidos;
      45: Result := toRetornoSustacaoEnvioCartorio;
      46: Result := toRetornoDebitoTarifas;
      47: Result := toRetornoPagadorDDA;
      68: Result := toRetornoAcertoDadosRateioCredito;
      69: Result := toRetornoCancelamentoDadosRateio;
    end;
  end;

  if (Result <> toTipoOcorrenciaNenhum) then
    Exit;

  case CodOcorrencia of
    02:  Result := toRetornoRegistroConfirmado;
    03:  Result := toRetornoRegistroRecusado;
    06:  Result := toRetornoLiquidado;
    12:  Result := toRetornoAbatimentoConcedido;
    13:  Result := toRetornoAbatimentoCancelado;
    14:  Result := toRetornoVencimentoAlterado;
    19:  Result := toRetornoRecebimentoInstrucaoProtestar;
    20:  Result := toRetornoInstrucaoCancelada;
    23:  Result := toRetornoEntradaEmCartorio;
    999: Result := toRetornoEmTransito;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBanrisul.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concessão de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Alteração de vencimento}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaSustarProtesto;                  {Sustação de protesto}
    16 : Result:= toRemessaAlterarNumeroDiasProtesto;       {Alteração do numero de dias para protesto}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBanrisul.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
 CodOcorrencia: Integer;
begin
    CodOcorrencia := StrToIntDef(TipoOcorrenciaToCod(TipoOcorrencia),0);

    if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
    begin
      case CodOcorrencia of
        02: Result:= '02–Entrada Confirmada';
        03: Result:= '03–Entrada Rejeitada';
        04: Result:= '04–Reembolso e Transf. ou Transf. de Carteira';
        05: Result:= '05–Reembolso e Devolucao Desconto e Vendor';
        06: Result:= '06–Liquidação';
        09: Result:= '09–Baixa';
        11: Result:= '11–Títulos em Carteira (em ser)';
        12: Result:= '12–Confirmação Recebimento Instrução de Abatimento';
        13: Result:= '13–Confirmação Recebimento Instrução de Cancelamento Abatimento';
        14: Result:= '14–Confirmação Recebimento Instrução Alteração de Vencimento';
        15: Result:= '15–Confirmação de Protesto Imediato por Falencia';
        17: Result:= '17–Liquidação Após Baixa ou Liquidação Título Não Registrado';
        19: Result:= '19–Confirmação Recebimento Instrução de Protesto';
        20: Result:= '20–Confirmação Recebimento Instrução de Sustação/Cancelamento de Protesto';
        23: Result:= '23–Remessa a Cartório';
        24: Result:= '24–Reservado';
        25: Result:= '25–Protestado e Baixado';
        26: Result:= '26–Instrução Rejeitada';
        27: Result:= '27–Confirmação do Pedido de Alteração de Outros Dados';
        28: Result:= '28–Débito de Tarifas/Custo';
        30: Result:= '30–Alteração de Dados Rejeitada';
        999: Result := 'AB – Cobrança a Creditar (em trânsito)*';
      end;
    end
    else
    begin
      case CodOcorrencia of
        02: Result:= '02–Confirmação de entrada';
        03: Result:= '03–Entrada Rejeitada';
        04: Result:= '04-Baixa de Título Liquidado por Edital';
        06: Result:= '06-Liquidação Normal';
        07: Result:= '07-Liquidação Parcial';
        08: Result:= '08-Baixa por Pagamento, Liquidação pelo Saldo';
        09: Result:= '09-Devolução Automática';
        10: Result:= '10-Baixado Conforme Instruções';
        11: Result:= '11-Arquivo Levantamento';
        12: Result:= '12-Concessão de Abatimento';
        13: Result:= '13-Cancelamento de Abatimento';
        14: Result:= '14-Vencimento Alterado';
        15: Result:= '15-Pagamento em Cartório';
        16: Result:= '16-Alteração de Dados';
        18: Result:= '18-Alteração de Instruções';
        19: Result:= '19-Confirmação de Instrução Protesto';
        20: Result:= '20-Confirmação de Instrução para Sustar Protesto';
        21: Result:= '21-Aguardando Autorização para Protesto por Edital';
        22: Result:= '22-Protesto Sustado por Alteração de Vencimento e Prazo de Cartório';
        23: Result:= '23-Confirmação da Entrada em Cartório';
        25: Result:= '25-Devolução, Liquidado Anteriormente';
        26: Result:= '26-Devolvido pelo Cartório - Erro de Informação';
        30: Result:= '30-Cobrança a Creditar';
        31: Result:= '31-Título em Trânsito pago em Cartório';
        32: Result:= '32-Reembolso e Transferência Desconto e Vendor ou Carteira em Garantia';
        33: Result:= '33-Reembolso e Devolução Desconto e Vendor';
        34: Result:= '34-Reembolso não Efetuado por Falta de Saldo';
        40: Result:= '40-Baixa de Títulos Protestados';
        41: Result:= '41-Despesas de Aponte';
        42: Result:= '42-Alteração de Título';
        43: Result:= '43-Relação de Títulos';
        44: Result:= '44-Manutenção Mensal';
        45: Result:= '45-Sustação de Cartório e Envio de Título a Cartório';
        46: Result:= '46-Fornecimento de Formulário Pré-Impresso';
        47: Result:= '47-Confirmação de Entrada-Pagador DDA';
        68: Result:= '68-Acerto dos Dados do Rateio de Crédito';
        69: Result:= '69-Cancelamento dos Dados do Rateio';
      else
        Result := 'Outras ocorrências';
      end;
    end;

    Result := ACBrSTr(Result);
end;
 

function TACBrBanrisul.TipoOcorrenciaToCod(
  const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
  Result := '';

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
   case TipoOcorrencia of
     toRetornoTransferenciaCarteira                        : Result:= '04';
     toRetornoReembolsoDevolucaoDescontoVendor             : Result:= '05';
     toRetornoBaixado                                      : Result:= '09';
     toRetornoTituloEmSer                                  : Result:= '11';
     toRetornoProtestoImediatoFalencia                     : Result:= '15';
     toRetornoLiquidadoAposBaixaOuNaoRegistro              : Result:= '17';
     toRetornoReservado                                    : Result:= '24';
     toRetornoBaixaPorProtesto                             : Result:= '25';
     toRetornoInstrucaoRejeitada                           : Result:= '26';
     toRetornoDadosAlterados                               : Result:= '27';
     toRetornoDebitoTarifas                                : Result:= '28';
     toRetornoAlteracaoDadosRejeitados                     : Result:= '30';
   end;
  end
  else
  begin
   case TipoOcorrencia of
     toRetornoBaixaLiquidadoEdital                         : Result:= '04';
     toRetornoLiquidadoParcialmente                        : Result:= '07';
     toRetornoLiquidadoSaldoRestante                       : Result:= '08';
     toRetornoBaixadoInstAgencia                           : Result:= '10';
     toRetornoLiquidadoEmCartorio                          : Result:= '15';
     toRetornoDadosAlterados                               : Result:= '16';
     toRetornoAlteracaoInstrucao                           : Result:= '18';
     toRetornoAguardandoAutorizacaoProtestoEdital          : Result:= '21';
     toRetornoProtestoSustado                              : Result:= '22';
     toRetornoBaixadoPorDevolucao                          : Result:= '25';
     toRetornoDevolvidoPeloCartorio                        : Result:= '26';
     toRetornoCobrancaCreditar                             : Result:= '30';
     toRetornoTransitoPagoCartorio                         : Result:= '31';
     toRetornoReembolsoTransferenciaDescontoVendor         : Result:= '32';
     toRetornoReembolsoDevolucaoDescontoVendor             : Result:= '33';
     toRetornoReembolsoNaoEfetuado                         : Result:= '34';
     toRetornoBaixaPorProtesto                             : Result:= '40';
     toRetornoDespesasProtesto                             : Result:= '41';
     toRetornoRecebimentoInstrucaoAlterarDados             : Result:= '42';
     toRetornoRelacaoDeTitulos                             : Result:= '43';
     toRetornoDebitoMensalTarifasManutencaoTitulosVencidos : Result:= '44';
     toRetornoSustacaoEnvioCartorio                        : Result:= '45';
     toRetornoDebitoTarifas                                : Result:= '46';
     toRetornoPagadorDDA                                   : Result:= '47';
     toRetornoAcertoDadosRateioCredito                     : Result:= '68';
     toRetornoCancelamentoDadosRateio                      : Result:= '69';
   end;
  end;

  if (Result <> '') then
   Exit;

  case TipoOcorrencia of
   toRetornoRegistroConfirmado                             : Result:= '02';
   toRetornoRegistroRecusado                               : Result:= '03';
   toRetornoLiquidado                                      : Result:= '06';
   toRetornoAbatimentoConcedido                            : Result:= '12';
   toRetornoAbatimentoCancelado                            : Result:= '13';
   toRetornoVencimentoAlterado                             : Result:= '14';
   toRetornoRecebimentoInstrucaoProtestar                  : Result:= '19';
   toRetornoInstrucaoCancelada                             : Result:= '20';
   toRetornoEntradaEmCartorio                              : Result:= '23';
   toRetornoEmTransito                                     : Result:= '999';
  else
   Result := '02';
  end;
end;


end.

