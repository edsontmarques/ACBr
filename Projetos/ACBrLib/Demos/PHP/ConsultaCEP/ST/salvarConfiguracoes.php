<?php
/* {******************************************************************************}
// { Projeto: Componentes ACBr                                                    }
// {  Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
// { mentos de Automação Comercial utilizados no Brasil                           }
// {                                                                              }
// { Direitos Autorais Reservados (c) 2022 Daniel Simoes de Almeida               }
// {                                                                              }
// { Colaboradores nesse arquivo: Renato Rubinho                                  }
// {                                                                              }
// {  Você pode obter a última versão desse arquivo na pagina do  Projeto ACBr    }
// { Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
// {                                                                              }
// {  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
// { sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela  }
// { Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
// { qualquer versão posterior.                                                   }
// {                                                                              }
// {  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM   }
// { NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU      }
// { ADEQUAÇÃO A UMA FINALIDADE ESPECÝFICA. Consulte a Licença Pública Geral Menor}
// { do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)              }
// {                                                                              }
// {  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto}
// { com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,  }
// { no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
// { Você também pode obter uma copia da licença em:                              }
// { http://www.opensource.org/licenses/lgpl-license.php                          }
// {                                                                              }
// { Daniel Simões de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
// {       Rua Coronel Aureliano de Camargo, 963 - Tatuí - SP - 18270-170         }
// {******************************************************************************}
*/
header('Content-Type: application/json; charset=UTF-8');

include 'ACBrCEP.php';

if (ValidaFFI() != 0)
    exit; 

$dllPath = CarregaDll();

if ($dllPath == -10)
    exit; 

$importsPath = CarregaImports();

if ($importsPath == -10)
    exit; 

$iniPath = CarregaIniPath();

try {
    $processo = "file_get_contents";
    $ffi = CarregaContents($importsPath, $dllPath);

    $webservice = intval($_POST['webservice']);
    $usuario = $_POST['usuario'];
    $senha = $_POST['senha'];
    $chaveacesso = $_POST['chaveacesso'];
    
    $processo = "CEP_Inicializar";
    if (Inicializar($ffi, $iniPath) != 0) 
        exit;

    $processo = "CEP_ConfigGravarValor";
    if (ConfigGravarValor($ffi, "CEP", "WebService", (string)$webservice) != 0) exit;
    if (ConfigGravarValor($ffi, "CEP", "Usuario", (string)$usuario) != 0) exit;
    if (ConfigGravarValor($ffi, "CEP", "Senha", (string)$senha) != 0) exit;
    if (ConfigGravarValor($ffi, "CEP", "ChaveAcesso", (string)$chaveacesso) != 0) exit;
} catch (Exception $e) {
    $erro = $e->getMessage();
    echo json_encode(["mensagem" => "Exceção[$processo]: $erro"]);
    exit;
}

try {
    if ($processo != "CEP_Inicializar") {
        $processo = "CEP_Finalizar";
        if (Finalizar($ffi) != 0) 
            exit;
    }
} catch (Exception $e) {
    $erro = $e->getMessage();
    echo json_encode(["mensagem" => "Exceção[$processo]: $erro"]);
    exit;
}

echo json_encode(["mensagem" => "Configurações salvas com sucesso."]);
?>