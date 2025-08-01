{$IFNDEF ACBr_INC}
{$DEFINE ACBr_INC}
{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Alexandre Rocha Lima e Marcondes               }
{                               Regys Silveira                                 }
{                               Juliomar Marchetti                             }
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

{-----------------------------------------------------
 Esse arquivo � dividido em duas partes: Configura��es e Implementa��o
     * Configura��es: Nessa parte est�o op��es que podem ser ativadas ou desativadas,
          mudando assim o comportamento do c�digo das solu��es ACBr. 
             Algumas destas op��es s�o editadas pelo ACBrInstall. Voc� tamb�m 
          pode editar os "DEFINE" dessa parte para atingir o comportamento desejado.
     * Implementa��o: Essa parte N�O DEVE SER EDITADA. Fazer isso pode resultar em
          comportamento indefinido e problemas dif�ceis de diagnosticar.
-----------------------------------------------------}

(*//////////////// CONFIGURA��ES  ////////////////////*)

// Descomente a linha abaixo, se voc� quer que seu Execut�vel N�O dependa das DLLs LibXML2, LibXMLSEC, (N�O RECOMENDADO)
{.$DEFINE DFE_SEM_OPENSSL}
// Comente a linha abaixo, se voc� quer que seu Execut�vel dependa das DLLs LibXMLSEC (NAO RECOMENDADO)
{$DEFINE DFE_SEM_XMLSEC}
// Descomente a linha abaixo, se voc� quer que seu Execut�vel N�O dependa das DLLs LibXML2. (NAO RECOMENDADO)
{.$DEFINE DFE_SEM_LIBXML2}
// Descomente a linha abaixo, se voc� n�o utiliza a obsoleta Capicom para Criptografia (RECOMENDADO)
{$DEFINE DFE_SEM_CAPICOM}
// Descomente a linha abaixo, se voc� n�o utiliza a obsoleta MSXML para Assinatura de XML (RECOMENDADO)
{$DEFINE DFE_SEM_MSXML}
// Descomente a linha abaixo, se voc� n�o deseja adicionar a Depend�ncia da INDY nos seus Projetos
{.$DEFINE DFE_SEM_INDY}
// Descomente a linha abaixo, se voc� deseja que sejam utilizadas as classes baseadas na ACBrXMLDocument
// Utiliza��o do ACBrXMLDocument obrigat�ria para as tags da Reforma Tribut�ria nos documentos fiscais
// se estiver comentado, n�o ser� gerado nos XML.
{$DEFINE USE_ACBr_XMLDOCUMENT}

// Descomente essa linha, para usar a carga de DLL tardia, nas Units do OpenSSL  (Apenas Delphi)
{$DEFINE USE_DELAYED}

// Descomente essa linha, para usar a exporta��o de Fast Reports com suporte a SVG
{.$DEFINE USE_REPORT_FR_SVG}

// Descomente essa linha, para usar a exporta��o de Fast Reports com suporte a PNG
{.$DEFINE USE_REPORT_FR_PNG}

// Descomente essa linha, para usar ZLibExGZ de \ACBr\Fontes\Terceiros\ZLibExGZ
// ZLib de D7 cont�m bugs e est� incompleta. Caso contr�rio usar� compacta��o nativa, unit "ZLib"
{.$DEFINE USE_ZLibExGZ}

// Para Remover Warnings de CAST causados por WideString/String/AnsiString, descomente a linha abaixo. (Apenas Delphi)
{.$DEFINE REMOVE_CAST_WARN}

// Para usar CLX no Windows / Delphi descomente essa linha
//------------------------------------------------------------------------------
//{$DEFINE CLX}

// Para usar VCL no Windows / Delphi descomente essa linha
{$DEFINE VCL}

// Para usar FMX (Firemonkey) Windows / Delphi descomente essa linha
//{$DEFINE FMX}

(*//////////////// IMPLEMENTA��O  ////////////////////*)

// Ajusta FreePascal para o modo Delphi
//------------------------------------------------------------------------------
{$IFDEF FPC}
  {$DEFINE USE_UTF8}
  {$UNDEF BORLAND}
  {$DEFINE DFE_SEM_INDY}
  {$DEFINE VCL}
  {$DEFINE UNICODE} // Lazarus 0.9.26 usa UnicodeString como default para String
  {$DEFINE DELPHI7}
  {$DEFINE COMPILER7}
  {$DEFINE HAS_FORMATSETTINGS}
  {$DEFINE HAS_REGEXPR}
  {$DEFINE HAS_INLINE}
  {$DEFINE HAS_STRICTDELIMITER}
  {$DEFINE HAS_PNG}
  {$H+}

  {$UnDef FMX}
  {$UnDef FPC3}
  {$UnDef FPC2}
  {$IFDEF VER2}
   {$DEFINE FPC2}
  {$EndIf}
  {$IFDEF VER3}
   {$DEFINE FPC3}
  {$ENDIF}
  {$IFDEF FPC3}
   {$DEFINE HAS_CHARINSET}
   {$DEFINE SUPPORTS_DEPRECATED_DETAILS}
   {$UnDef FPC2}
  {$ENDIF}
  {$UNDEF REMOVE_CAST_WARN} //Devido a problemas com a mensagem de erro "Message recordind not yet supported"
{$ELSE}
  {$DEFINE BORLAND}
{$ENDIF}

// utilizar para facilitar a manuten��o do ACBr.inc, j� que ele era uma c�pia
// da jedi, essa mudan�a permite uma evolu��o melhor do arquivo.
//------------------------------------------------------------------------------
{$I ACBr_jedi.inc}

{$IFNDEF DELPHIXE2_UP}
  {$IFDEF BORLAND}
    {$UNDEF REMOVE_CAST_WARN}
  {$ENDIF}
{$ENDIF}

{$IFDEF REMOVE_CAST_WARN}
  {$WARN IMPLICIT_STRING_CAST OFF}
  {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {.$WARN SYMBOL_DEPRECATED OFF}
  {$IFDEF BORLAND}
    {$WARN DUPLICATE_CTOR_DTOR OFF}
    {$WARN CVT_ACHAR_TO_WCHAR OFF}
  {$ENDIF}
{$ENDIF}

{$IFNDEF MSWINDOWS}   // Linux, apenas OpenSSL, sem Capicom
  {$DEFINE DFE_SEM_CAPICOM}
  {$DEFINE DFE_SEM_MSXML}
  {$DEFINE DFE_SEM_INDY}
  {$UnDef STDCALL}
{$ENDIF}

{$IFDEF DFE_SEM_OPENSSL}
  {$DEFINE DFE_SEM_XMLSEC}
  {$DEFINE DFE_SEM_LIBXML2}
{$ENDIF}

{$IFDEF DFE_SEM_LIBXML2}
  {$UNDEF DFE_ACBR_LIBXML2}
{$ENDIF}

{$IFDEF USE_ACBr_XMLDOCUMENT}
  {$UNDEF DFE_SEM_LIBXML2} 
{$ENDIF}

{$IFNDEF SUPPORTS_DELAYED_LOADING}
 {$UNDEF USE_DELAYED}
{$ENDIF}

{$IFDEF DELPHI2005_UP}
  {$DEFINE HAS_INLINE}
{$ENDIF}
{$IFDEF DELPHI2006_UP}
  {$DEFINE HAS_STRICTDELIMITER}
{$ENDIF}
{$IFDEF DELPHI2009_UP}
  {$DEFINE HAS_CHARINSET}
  {$DEFINE USE_JSONDATAOBJECTS_UNIT}
{$ENDIF}
{$IFDEF DELPHIXE_UP}
  {$DEFINE HAS_FORMATSETTINGS}
  {$DEFINE HAS_REGEXPR}
{$ENDIF}
{$IfDEF DELPHIXE8_UP}
  {$DEFINE HAS_BLUETOOTH}
  {$DEFINE HAS_SYSTEM_GENERICS}
{$ENDIF}

// Defini��es multi-plataforma
//------------------------------------------------------------------------------
{$IFDEF WIN64}
  {$DEFINE MSWINDOWS}
  {$DEFINE DFE_SEM_CAPICOM}  // apenas 32 bits
  {$DEFINE DFE_SEM_MSXML}    // apenas 32 bits
{$ENDIF}

{$IFDEF DELPHILANGUAGE}
  {$IFDEF POSIX}
    {$IFDEF LINUX}
      {$DEFINE USE_UTF8}
      {$UNDEF HAS_BLUETOOTH}
    {$ENDIF}
    {$DEFINE FMX}
    {$DEFINE HAS_SYSTEM_GENERICS}

    {$UNDEF CLX}
    {$UNDEF VisualCLX}
    {$UNDEF VCL}
    {$DEFINE DFE_SEM_CAPICOM}
    {$DEFINE DFE_SEM_MSXML}
    {$UNDEF USE_DELAYED}
    {$LEGACYIFEND ON}
  {$ENDIF}

  {$IFDEF NEXTGEN}
    {$DEFINE HAS_SYSTEM_GENERICS}
    {$DEFINE USE_UTF8}
    {$DEFINE HAS_BLUETOOTH}
    {$LEGACYIFEND ON}
    {$ZEROBASEDSTRINGS OFF}  //http://riversoftavg.com/blogs/index.php/2015/01/17/zerobasedstrings-just-dont/
  {$ENDIF}

  {$IFDEF CLX}
    {$DEFINE VisualCLX}
  {$ENDIF}

  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF Declared(QEventType_CMQuit) or Declared(Key_Word_Lower)}
        {$DEFINE VisualCLX}
    {$IFEND}
  {$ENDIF}

  {$IFNDEF VisualCLX}
    {$DEFINE VCL}
  {$ENDIF}

  {$IFDEF VisualCLX}
    {$UNDEF VCL}
    {$DEFINE COMPLIB_CLX} // kept for backward compatibility, use VisualCLX instead 
  {$ENDIF}

  {$IFDEF QUnit}
    {$UNDEF VCL}
    {$DEFINE VisualCLX}
  {$ENDIF}

  {$IFDEF FMX}
    {$UNDEF VCL}
  {$ENDIF}

  {$IFDEF VCL}
    {$DEFINE COMPLIB_VCL} // kept for backward compatibility, use VCL instead 
  {$ENDIF}

  {$IFDEF VisualCLX}
    {$DEFINE DELPHI6_UP} // Inserido para Suporte ao D5 e manter compatibilidade com a CLX 
  {$ENDIF}
{$ENDIF DELPHILANGUAGE}

//------------------------------------------------------------------------------
// Defini��es autom�ticas para tipos de licen�a:
//------------------------------------------------------------------------------
{$IFDEF D5Standard}
 {$DEFINE DelphiPersonalEdition}
{$ENDIF}

{$IFDEF D6PersonalEdition}
 {$DEFINE DelphiPersonalEdition}
{$ENDIF}

{$IFDEF D7PersonalEdition}
 {$DEFINE DelphiPersonalEdition}
{$ENDIF}

// Reduz warnings no D7:
//------------------------------------------------------------------------------
{$IFDEF COMPILER7_UP}
  {$IFNDEF FPC}
    {$WARN UNSAFE_TYPE OFF}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_CAST OFF}
  {$ENDIF}
{$ENDIF}

// Verificando se a compila��o deve sem em modo texto "NOGUI"
// Nota: FPC no Linux sempre liga a diretiva "CONSOLE", por isso criamos a NOGUI
{$IFDEF FRAMEWORK}
  {$DEFINE NOGUI}
{$ENDIF}

//  Lazarus Android com LAMW, n�o suporta Dialogs, Forms,
{$IFDEF LAMW}
  {$DEFINE NOGUI}
{$ENDIF}

{$IFDEF NOGUI}
  {$DEFINE CONSOLE}
{$ENDIF}

// Ative a diretiva abaixo, para usar a Libxml2, libxslt, libxmlsec compilada
// com MinGw ftp://ftp.zlatkovic.com/libxml/64bit/
//{$DEFINE USE_MINGW}

// ZLib em D7 contem muitos bugs e n�o suporta GZip de forma correta
{$IfNDef FPC}        
 {$IfNDef DELPHIXE2_UP}
  {$Define USE_ZLibExGZ}
 {$EndIf}
{$Else}
 {$UnDef USE_ZLibExGZ} // ZLibExGZ n�o � compat�vel com FPC
{$EndIf}

// A partir da vers�o XE2 � preciso usar namespaces,se n�o definido "Unit scope names"
{$IFNDEF FPC}        
  {$IFDEF DELPHIXE2_UP}
    {$DEFINE USE_NAMESPACES}
  {$ENDIF}

  {$IFDEF DELPHI14_UP}// delphi 2010 pra cima existe
    {$DEFINE HAS_PNG}
  {$ENDIF}
{$ENDIF}

{$IfDef NOGUI}
  {$UnDef HAS_PNG}
{$EndIf}


{$ENDIF ~ACBr_INC}
