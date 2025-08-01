{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2024 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Jos� M S Junior, Victor H Gonzales - Pandaaa   }
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
unit ACBrBoletoWS.Rest.OAuth;

interface

uses
  SysUtils,
  ACBrBase,
  pcnConversao,
  ACBrOpenSSLUtils,
  httpsend,
  ACBrBoletoConversao,
  ACBrBoleto,
  ACBrUtil.FilesIO,
  ACBr.Auth.JWT,
  ACBrBoletoWS.URL;

type
  EACBrBoletoWSOAuthException = class(Exception);
  TpAuthorizationType = (atNoAuth, atBearer, atJWT);

  TParams = record
    prName, PrValue: String;
  end;

{ TOAuth }
  TOAuth = class
  private
    FURL              : TACBrBoletoWebServiceURL;
    FContentType      : String;
    FGrantType        : String;
    FScope            : String;
    FAmbiente         : TTipoAmbienteWS;
    FClientID         : String;
    FClientSecret     : String;
    FToken            : String;
    FExpire           : TDateTime;
    FErroComunicacao  : String;
    FPayload          : Boolean;
    FHTTPSend         : THTTPSend;
    FParamsOAuth      : string;
    FAuthorizationType: TpAuthorizationType;
    FHeaderParamsList : Array of TParams;
    FACBrBoleto       : TACBrBoleto;
    FArqLOG           : String;
    FExigirClientSecret : Boolean;
    procedure setContentType(const AValue: String);
    procedure setGrantType(const AValue: String);
    procedure setPayload(const AValue: Boolean);

    function getContentType: String;
    function getGrantType: String;
    function getClientID: String;
    function getClientSecret: String;
    function getScope: String;
    procedure GravaLog(const AString: AnsiString);
    procedure ProcessarRespostaOAuth(const ARetorno: AnsiString);
    function Executar(const AAuthBase64: String): Boolean;
    procedure SetAuthorizationType(const Value: TpAuthorizationType);
  protected

  public
    constructor Create(ASSL: THTTPSend; AACBrBoleto: TACBrBoleto = nil);
    destructor Destroy; Override;
    property URL: TACBrBoletoWebServiceURL read FURL write FURL;
    function GerarToken: Boolean;
    property ParamsOAuth: String read FParamsOAuth write FParamsOAuth;
    function AddHeaderParam(AParamName, AParamValue: String): TOAuth;

    function ClearHeaderParams(): TOAuth;
    property ContentType: String read getContentType write setContentType;
    property GrantType: String read getGrantType write setGrantType;
    property Scope: String read getScope;
    property ClientID: String read getClientID;
    property ClientSecret: String read getClientSecret;
    property Ambiente: TTipoAmbienteWS read FAmbiente default tawsHomologacao;
    property Expire: TDateTime read FExpire;
    property ErroComunicacao: String read FErroComunicacao;
    property Token: String read FToken;
    property Payload: Boolean read FPayload write setPayload;
    property AuthorizationType: TpAuthorizationType read FAuthorizationType write SetAuthorizationType;
    procedure DoLog(const AString: String; const ANivelSeveridadeLog : TNivelLog);
    property ExigirClientSecret : Boolean read FExigirClientSecret write FExigirClientSecret;
    procedure CarregaCertificados;
  end;
implementation
uses
  ACBrUtil.DateTime,
  ACBrUtil.Strings,
  ACBrUtil.Base,
  ACBrBoletoWS,
  ACBrJSON,
  DateUtils,
  Classes,
  synacode,
  synautil;
  
{ TOAuth }

procedure TOAuth.setContentType(const AValue: String);
begin
  if FContentType <> AValue then
    FContentType := AValue;
end;

procedure TOAuth.setGrantType(const AValue: String);
begin
  if FGrantType <> AValue then
    FGrantType := AValue;

end;

procedure TOAuth.setPayload(const AValue: Boolean);
begin
  if FPayload <> AValue then
    FPayload := AValue;
end;

procedure TOAuth.GravaLog(const AString: AnsiString);
begin
  if (FArqLOG = '') then
    Exit;

  WriteLog(FArqLOG, FormatDateTime('dd/mm/yy hh:nn:ss:zzz', now) +
                  ' ' +
                  ACBrUtil.DateTime.GetUTCSistema +
                  ' - ' +
                  AString);
end;

function TOAuth.getContentType: String;
begin
  if FContentType = '' then
    Result := 'application/x-www-form-urlencoded'
  else
    Result := FContentType;
end;

function TOAuth.getGrantType: String;
begin
  if FGrantType = '' then
    Result := 'client_credentials'
  else
    Result := FGrantType;
end;

function TOAuth.getClientID: String;
begin
  if FClientID = '' then
    Raise EACBrBoletoWSOAuthException.Create(ACBrStr('Client_ID n�o Informado'));

  Result := FClientID;
end;

function TOAuth.getClientSecret: String;
begin
  Result := '';

  if not FExigirClientSecret then
    Exit;

  if FClientSecret = '' then
    Raise EACBrBoletoWSOAuthException.Create(ACBrStr('Client_Secret n�o Informado'));

  Result := FClientSecret;
end;

function TOAuth.getScope: String;
begin
  if FScope = '' then
    Raise EACBrBoletoWSOAuthException.Create(ACBrStr('Scope n�o Informado'));

  Result := FScope;
end;

procedure TOAuth.ProcessarRespostaOAuth(const ARetorno: AnsiString);
var
  LJson        : TACBrJSONObject;
  LErrorMessage: String;
begin
  FToken           := '';
  FExpire          := 0;
  FErroComunicacao := '';
  try
    LJson := TACBrJSONObject.Parse(UTF8ToNativeString(Trim(ARetorno)));

    try
      if (FHTTPSend.ResultCode in [ 200 .. 205 ]) then
      begin
        FToken := LJson.AsString[ 'access_token' ];
        try
          FExpire := now + (LJson.AsInteger[ 'expires_in' ] * OneSecond);
          DoLog('Validade: ' + DateTimeToStr(FExpire), logSimples);
        except
          FExpire := 0;
        end;
      end
      else
      begin
        FErroComunicacao := 'HTTP_Code=' + IntToStr(FHTTPSend.ResultCode);
        if Assigned(LJson) then
        begin
          LErrorMessage := LJson.AsString[ 'error_description' ];
          if LErrorMessage = '' then
            LErrorMessage  := LJson.AsString[ 'error_title' ];
          FErroComunicacao := FErroComunicacao + ' Erro=' + LErrorMessage;
        end;
        DoLog('Erro: ' + FErroComunicacao, logSimples);
      end;
    finally
      LJson.Free;
    end;
  except
    FErroComunicacao := 'HTTP_Code=' + IntToStr(FHTTPSend.ResultCode) + ' Erro=' + ARetorno;
    DoLog('Erro: ' + FErroComunicacao, logSimples);
  end;
end;

procedure TOAuth.SetAuthorizationType(const Value: TpAuthorizationType);
begin
  FAuthorizationType := Value;
end;

function TOAuth.Executar(const AAuthBase64: String): Boolean;
var
  LHeaders: TStringList;
  I       : Integer;
  LJWTAuth : TACBrJWTAuth;
  LParamsOAuth : String;
begin
  FErroComunicacao := '';

  if not Assigned(FHTTPSend) then
    Raise EACBrBoletoWSOAuthException.Create(ClassName + Format(S_METODO_NAO_IMPLEMENTADO, [ C_DFESSL ]));

  CarregaCertificados;

  //Definido Valor para Timeout com a configura��o da Classe
  FHTTPSend.Timeout := FACBrBoleto.Configuracoes.WebService.TimeOut;

  //Definindo Header da requisi��o OAuth
  FHTTPSend.Headers.Clear;
  LHeaders := TStringList.Create;
  try
      //LHeaders.Add(C_CONTENT_TYPE  + ': ' + ContentType);
    if Self.AuthorizationType = atBearer then
      LHeaders.Add(C_AUTHORIZATION + ': ' + AAuthBase64);
    if Self.AuthorizationType = atJWT then
    begin
      LJWTAuth := TACBrJWTAuth.Create(FHTTPSend.Sock.SSL.PrivateKey);
      if not FACBrBoleto.Configuracoes.WebService.UseCertificateHTTP then
      begin
        FHTTPSend.Sock.SSL.PrivateKey      := '';
        FHTTPSend.Sock.SSL.CertificateFile := '';
        FHTTPSend.Sock.SSL.Certificate     := '';
      end;
      try
        LParamsOAuth := FParamsOAuth;
        FParamsOAuth := 'grant_type=' + FGrantType +'&'+
                        'assertion=' + LJWTAuth.GenerateJWT(LParamsOAuth);
      finally
        LJWTAuth.Free;
      end;
    end;
      //LHeaders.Add(C_CACHE_CONTROL + ': ' + C_NO_CACHE);

    for I := 0 to Length(FHeaderParamsList) - 1 do
      LHeaders.Add(FHeaderParamsList[ I ].prName + ': ' + FHeaderParamsList[ I ].PrValue);
    FHTTPSend.Headers.AddStrings(LHeaders);
  finally
    LHeaders.Free;
  end;

  FHTTPSend.MimeType := ContentType;
  try
    try
        //Utiliza HTTPMethod para envio
      DoLog('Comando Enviar: ' + Self.ClassName, logSimples);
      DoLog('Header Envio:' + FHTTPSend.Headers.Text, logParanoico);


      if FPayload then
      begin
        DoLog('URL: [' + MetodoHTTPToStr(htPOST) +'] '+ URL.GetURL, logSimples);
        DoLog('Body Envio (Payload):' + FParamsOAuth, logParanoico);

        FHTTPSend.Document.Position := 0;
        WriteStrToStream(FHTTPSend.Document, AnsiString(FParamsOAuth));
        FHTTPSend.HTTPMethod(MetodoHTTPToStr(htPOST), URL.GetURL);
      end
      else
      begin
        DoLog('URL: [' + MetodoHTTPToStr(htPOST) + '] ' + URL.GetURL + '?' + FParamsOAuth, logSimples);
        FHTTPSend.HTTPMethod(MetodoHTTPToStr(htPOST), URL.GetURL + '?' + FParamsOAuth);
      end;

      //FErroComunicacao := FHTTPSend.ResultString;
      FHTTPSend.Document.Position := 0;
      ProcessarRespostaOAuth(ReadStrFromStream(FHTTPSend.Document, FHTTPSend.Document.Size));
      DoLog('Cookies:', logParanoico);
      DoLog(FHTTPSend.Cookies.Text, logParanoico);
      DoLog(FHTTPSend.Sock.SSL.CertificateFile, logParanoico);
      DoLog(FHTTPSend.Sock.SSL.PrivateKeyFile, logParanoico);
      DoLog('Header:', logParanoico);
      DoLog(FHTTPSend.Headers.Text, logParanoico);
      Result := true;
    except
      on E: Exception do
      begin
        Result           := False;
        FErroComunicacao := E.Message;
      end;
    end;
  finally
    DoLog('Header Resposta:' + FHTTPSend.Headers.Text, logParanoico);

    FHTTPSend.Document.Position := 0;

    DoLog('Body Resposta (payload):' + ReadStrFromStream(FHTTPSend.Document, FHTTPSend.Document.Size), logParanoico);
    if FErroComunicacao <> '' then
      Raise EACBrBoletoWSOAuthException.Create('Falha na Autentica��o: ' + FErroComunicacao);
   URL.Clear;
  end;
end;

function TOAuth.AddHeaderParam(AParamName, AParamValue: String): TOAuth;
begin
  Result := Self;
  SetLength(FHeaderParamsList, Length(FHeaderParamsList) + 1);
  FHeaderParamsList[ Length(FHeaderParamsList) - 1 ].prName := AParamName;
  FHeaderParamsList[ Length(FHeaderParamsList) - 1 ].PrValue := AParamValue;
end;

procedure TOAuth.CarregaCertificados;
var LStringList : TStringList;
begin
  if FACBrBoleto.Configuracoes.WebService.UseCertificateHTTP then
  begin
    // adiciona a chave privada
    if NaoEstaVazio(FACBrBoleto.Configuracoes.WebService.ChavePrivada) then
    begin
      if StringIsPEM(FACBrBoleto.Configuracoes.WebService.ChavePrivada) then
        FHTTPSend.Sock.SSL.PrivateKey := ConvertPEMToASN1(FACBrBoleto.Configuracoes.WebService.ChavePrivada)
      else
        FHTTPSend.Sock.SSL.PrivateKey := FACBrBoleto.Configuracoes.WebService.ChavePrivada;
    end
    else
      if NaoEstaVazio(FACBrBoleto.Configuracoes.WebService.ArquivoKEY) then
      begin
        FHTTPSend.Sock.SSL.PrivateKeyFile := FACBrBoleto.Configuracoes.WebService.ArquivoKEY;
      end;
      // adiciona o certificado
    if NaoEstaVazio(FACBrBoleto.Configuracoes.WebService.Certificado) then
    begin
      if StringIsPEM(FACBrBoleto.Configuracoes.WebService.Certificado) then
        FHTTPSend.Sock.SSL.Certificate := ConvertPEMToASN1(FACBrBoleto.Configuracoes.WebService.Certificado)
      else
        FHTTPSend.Sock.SSL.Certificate := FACBrBoleto.Configuracoes.WebService.Certificado;
    end
    else
      if NaoEstaVazio(FACBrBoleto.Configuracoes.WebService.ArquivoCRT) then
        FHTTPSend.Sock.SSL.CertificateFile := FACBrBoleto.Configuracoes.WebService.ArquivoCRT;

    FHTTPSend.Sock.SSL.Connect;

  end else
  begin
    if Self.AuthorizationType = atJWT then
    begin
      LStringList := TStringList.Create;
      try
        //FHTTPSend.Sock.SSL.PrivateKeyFile := AACBrBoleto.Configuracoes.WebService.ArquivoKEY;
        LStringList.LoadFromFile(FACBrBoleto.Configuracoes.WebService.ArquivoKEY);
        FHTTPSend.Sock.SSL.PrivateKey     := LStringList.Text;
      finally
        LStringList.Free;
      end;
    end;
  end;
end;

function TOAuth.ClearHeaderParams: TOAuth;
begin
  SetLength(FHeaderParamsList, 0);
  Result := Self;
end;

constructor TOAuth.Create(ASSL: THTTPSend; AACBrBoleto: TACBrBoleto = nil);
begin
  if Assigned(ASSL) then
    FHTTPSend := ASSL;

  FURL := TACBrBoletoWebServiceURL.Create(AACBrBoleto.Configuracoes.WebService);

  FACBrBoleto := AACBrBoleto;
  FAmbiente          := AACBrBoleto.Configuracoes.WebService.Ambiente;
  FClientID          := AACBrBoleto.Cedente.CedenteWS.ClientID;
  FClientSecret      := AACBrBoleto.Cedente.CedenteWS.ClientSecret;
  FScope             := AACBrBoleto.Cedente.CedenteWS.Scope;
  FContentType       := '';
  FGrantType         := '';
  FToken             := '';
  FExpire            := 0;
  FErroComunicacao   := '';
  FPayload           := False;
  FAuthorizationType := atBearer;
  FExigirClientSecret := True;

  if AACBrBoleto.Configuracoes.Arquivos.NomeArquivoLog = '' then
    AACBrBoleto.Configuracoes.Arquivos.NomeArquivoLog := C_ARQBOLETOWS_LOG;

  if not (DirectoryExists(AACBrBoleto.Configuracoes.Arquivos.PathGravarRegistro)) then
    FArqLOG := AACBrBoleto.Configuracoes.Arquivos.NomeArquivoLog
  else
    FArqLOG := PathWithDelim(AACBrBoleto.Configuracoes.Arquivos.PathGravarRegistro) + ExtractFileName(AACBrBoleto.Configuracoes.Arquivos.NomeArquivoLog);

end;

destructor TOAuth.Destroy;
begin
  URL.Free;
  inherited Destroy;
end;

procedure TOAuth.DoLog(const AString: String; const ANivelSeveridadeLog : TNivelLog);
var
  Tratado: Boolean;
  LLog : string;
begin
  Tratado := False;

  if ANivelSeveridadeLog = logNenhum then
    Exit;

  LLog := NativeStringToAnsi(AString);
  if Assigned(FACBrBoleto.Configuracoes.Arquivos.OnGravarLog) then
    FACBrBoleto.Configuracoes.Arquivos.OnGravarLog(LLog, Tratado);

  if Tratado or (FACBrBoleto.Configuracoes.Arquivos.LogNivel >= ANivelSeveridadeLog) then
    GravaLog(LLog);
end;

function TOAuth.GerarToken: Boolean;
var
  LToken : String;
  LExpire: TDateTime;
begin

  if (Assigned(FACBrBoleto.OnAntesAutenticar)) then
  begin
    CarregaCertificados;
    FACBrBoleto.OnAntesAutenticar(LToken, LExpire);
    FToken  := LToken;
    FExpire := LExpire;
  end;

  if (Token <> '') and (CompareDateTime(Expire, now) = 1) then //Token ja gerado e ainda v�lido
    Result := true
  else //Converte Basic da Autentica��o em Base64
    Result := Executar('Basic ' + String(EncodeBase64(AnsiString(ClientID + ':' + ClientSecret))));

  if (Assigned(FACBrBoleto.OnDepoisAutenticar)) then
    FACBrBoleto.OnDepoisAutenticar(Token, Expire);
end;

end.
