{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliomar Marchetti                              }
{                              Claudemir Vitor Pereira                         }
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

unit pgnreConfigUF;

interface

uses
  SysUtils, Classes,
  pcnConversao;

type
  TInfReceita = class;
  TRetInfReceita = class;
  TInfDetalhamentoReceita = class;
  TRetInfDetalhamentoReceita = class;
  TInfProduto = class;
  TRetInfProduto = class;

  TInfReceita = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
    Fcourier: string;
    FexigeDetalhamentoReceita: string;
    FexigeProduto: string;
    FexigePeriodoReferencia: string;
    FexigePeriodoApuracao: string;
    FexigeParcela: string;
    FvalorExigido: string;
    FexigeDocumentoOrigem: string;
    FexigeContribuinteDestinatario: string;
    FexigeCamposAdicionais: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
    property courier: string read Fcourier write Fcourier;
    property exigeDetalhamentoReceita: string read FexigeDetalhamentoReceita write FexigeDetalhamentoReceita;
    property exigeProduto: string read FexigeProduto write FexigeProduto;
    property exigePeriodoReferencia: string read FexigePeriodoReferencia write FexigePeriodoReferencia;
    property exigePeriodoApuracao: string read FexigePeriodoApuracao write FexigePeriodoApuracao;
    property exigeParcela: string read FexigeParcela write FexigeParcela;
    property valorExigido: string read FvalorExigido write FvalorExigido;
    property exigeDocumentoOrigem: string read FexigeDocumentoOrigem write FexigeDocumentoOrigem;
    property exigeContribuinteDestinatario: string read FexigeContribuinteDestinatario write FexigeContribuinteDestinatario;
    property exigeCamposAdicionais: string read FexigeCamposAdicionais write FexigeCamposAdicionais;
  end;

  TRetInfReceita = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
    Fcourier: string;
    FexigeContribuinteEmitente: string;
    FexigeDetalhamentoReceita: string;
    FexigeProduto: string;
    FexigePeriodoReferencia: string;
    FexigePeriodoApuracao: string;
    FexigeParcela: string;
    FvalorExigido: string;
    FexigeDocumentoOrigem: string;
    FexigeContribuinteDestinatario: string;
    FexigeDataVencimento: string;
    FexigeDataPagamento: string;
    FexigeConvenio: string; 
    FexigeCamposAdicionais: string;
    FaceitaPgPix: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
    property courier: string read Fcourier write Fcourier;
    property exigeContribuinteEmitente: string read FexigeContribuinteEmitente write FexigeContribuinteEmitente;
    property exigeDetalhamentoReceita: string read FexigeDetalhamentoReceita write FexigeDetalhamentoReceita;
    property exigeProduto: string read FexigeProduto write FexigeProduto;
    property exigePeriodoReferencia: string read FexigePeriodoReferencia write FexigePeriodoReferencia;
    property exigePeriodoApuracao: string read FexigePeriodoApuracao write FexigePeriodoApuracao;
    property exigeParcela: string read FexigeParcela write FexigeParcela;
    property valorExigido: string read FvalorExigido write FvalorExigido;
    property exigeDocumentoOrigem: string read FexigeDocumentoOrigem write FexigeDocumentoOrigem;
    property exigeContribuinteDestinatario: string read FexigeContribuinteDestinatario write FexigeContribuinteDestinatario;
    property exigeDataVencimento: string read FexigeDataVencimento write FexigeDataVencimento;
    property exigeDataPagamento: string read FexigeDataPagamento write FexigeDataPagamento;    
    property exigeConvenio: string read FexigeConvenio write FexigeConvenio;
    property exigeCamposAdicionais: string read FexigeCamposAdicionais write FexigeCamposAdicionais;
    property aceitaPgPix: string read FaceitaPgPix write FaceitaPgPix;
  end;

  TInfDetalhamentoReceita = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TRetInfDetalhamentoReceita = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TInfProduto = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TRetInfProduto = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TInfPeriodoApuracao = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TRetInfPeriodoApuracao = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TInfTipoDocumentoOrigem = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TRetInfTipoDocumentoOrigem = class(TObject)
  private
    Fcodigo: Integer;
    Fdescricao: string;
  public
    property codigo: Integer read Fcodigo write Fcodigo;
    property descricao: string read Fdescricao write Fdescricao;
  end;

  TInfCampoAdicional = class(TObject)
  private
    Fobrigatorio: string;
    Fcodigo: Integer;
    Ftipo: string;
    Ftamanho: Integer;
    FcasasDecimais: Integer;
    Ftitulo: string;
  public
    property obrigatorio: string read Fobrigatorio write Fobrigatorio;
    property codigo: Integer read Fcodigo write Fcodigo;
    property tipo: string read Ftipo write Ftipo;
    property tamanho: Integer read Ftamanho write Ftamanho;
    property casasDecimais: Integer read FcasasDecimais write FcasasDecimais;
    property titulo: string read Ftitulo write Ftitulo;
  end;

  TRetInfCampoAdicional = class(TObject)
  private
    Fobrigatorio: string;
    Fcodigo: Integer;
    Ftipo: string;
    Ftamanho: Integer;
    FcasasDecimais: Integer;
    Ftitulo: string;
  public
    property obrigatorio: string read Fobrigatorio write Fobrigatorio;
    property codigo: Integer read Fcodigo write Fcodigo;
    property tipo: string read Ftipo write Ftipo;
    property tamanho: Integer read Ftamanho write Ftamanho;
    property casasDecimais: Integer read FcasasDecimais write FcasasDecimais;
    property titulo: string read Ftitulo write Ftitulo;
  end;

implementation

end.
 
