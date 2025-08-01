﻿using System;
using System.IO;
using System.Windows.Forms;
using ACBrLib;
using ACBrLib.Core;
using ACBrLib.Core.DFe;
using ACBrLib.Core.Extensions;
using ACBrLib.PIXCD;
using ACBrLib.Core.Config;
using System.Linq;
using ACBrLib.Core.PIXCD;

namespace ACBrLibPIXCD.Demo
{
    public partial class FrmMain : Form
    {
        #region Fields

        private ACBrPIXCD ACBrPIXCD;

        #endregion Fields

        #region Constructors

        public FrmMain()
        {
            InitializeComponent();

            // Inicializando a classe e carregando a dll
            ACBrPIXCD = new ACBrPIXCD();
        }

        #endregion Constructors

        #region Methods

        #region EventHandlers

        private void FrmMain_Shown(object sender, EventArgs e)
        {
            SplashScreenManager.Show<FrmWait>();
            SplashScreenManager.ShowInfo(SplashInfo.Message, "Carregando...");

            try
            {
                cmbPSP.EnumDataSource(PSP.pspBradesco);
                cmbAmbiente.EnumDataSource(Ambiente.ambTeste);
                cmbBBAPIVersao.EnumDataSource(BBAPIVersao.apiVersao1);
                cmbPixPDVAPIVersao.EnumDataSource(PixPDVAPIVersao.apiVersao1);
                cmbNivelLogPSP.EnumDataSource(NivelLogPSP.logPSPNenhum);
                cmbTipoChave.EnumDataSource(TipoChave.tchNenhuma);
                ACBrPIXCD.Config.ProxyPort = 0;
                
                // Altera as config de log
                ACBrPIXCD.Config.Principal.LogNivel = NivelLog.logParanoico;

                var logPath = Path.Combine(Application.StartupPath, "Logs");
                if (!Directory.Exists(logPath))
                    Directory.CreateDirectory(logPath);

                ACBrPIXCD.Config.Principal.LogPath = logPath;
                ACBrPIXCD.ConfigGravar();

                LoadConfig();
            }
            finally
            {
                SplashScreenManager.Close();
            }
        }

        private void FrmMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Liberando a dll
            ACBrPIXCD.Dispose();
        }

        #endregion EventHandlers

        #endregion Methods

        private void btnSalvarConfiguracoes_Click(object sender, EventArgs e)
        {
            try
            {
                SalvarConfig();
            }
            catch (Exception exception)
            {
                MessageBox.Show(exception.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void SalvarConfig()
        {
            SplashScreenManager.Show<FrmWait>();
            SplashScreenManager.ShowInfo(SplashInfo.Message, "Salvando...");

            try
            {
                //PIXCD
                ACBrPIXCD.Config.Ambiente = cmbAmbiente.GetSelectedValue<Ambiente>();
                ACBrPIXCD.Config.ArqLog = txtArqLogPSP.Text;
                ACBrPIXCD.Config.NivelLog = cmbNivelLogPSP.GetSelectedValue<NivelLogPSP>();
                ACBrPIXCD.Config.TipoChave = cmbTipoChave.GetSelectedValue<TipoChave>();
                ACBrPIXCD.Config.PSP = cmbPSP.GetSelectedValue<PSP>();
                ACBrPIXCD.Config.Timeout = (int)nudPSPTimeout.Value;
                ACBrPIXCD.Config.ProxyHost = txtProxyServidor.Text;
                ACBrPIXCD.Config.ProxyPass = txtProxySenha.Text;
                ACBrPIXCD.Config.ProxyPort = (int)nudProxyPorta.Value;
                ACBrPIXCD.Config.ProxyUser = txtProxyUsuario.Text;
                ACBrPIXCD.Config.CEPRecebedor = txtCEPRecebedor.Text;
                ACBrPIXCD.Config.CidadeRecebedor = txtCidadeRecebedor.Text;
                ACBrPIXCD.Config.NomeRecebedor = txtNomeRecebedor.Text;
                ACBrPIXCD.Config.UFRecebedor = txtUFRecebedor.Text;

                //Bradesco
                ACBrPIXCD.Config.Bradesco.ChavePIX = txtChavePIXBradesco.Text;
                ACBrPIXCD.Config.Bradesco.ClientID = txtClientIDBradesco.Text;
                ACBrPIXCD.Config.Bradesco.ClientSecret = txtClientSecretBradesco.Text;
                ACBrPIXCD.Config.Bradesco.ArqPFX = txtArquivoPFXBradesco.Text;
                ACBrPIXCD.Config.Bradesco.SenhaPFX = txtSenhaCertificadoBradesco.Text;
                ACBrPIXCD.Config.Bradesco.Scopes = txtScopesBradesco.Text;
                ACBrPIXCD.Config.Bradesco.ArqChavePrivada = txtArquivoChavePrivadaBradesco.Text;
                ACBrPIXCD.Config.Bradesco.ArqCertificado = txtArquivoCertificadoBradesco.Text;

                //Sicredi
                ACBrPIXCD.Config.Sicredi.ChavePIX = txtChavePIXSicredi.Text;
                ACBrPIXCD.Config.Sicredi.ClientID = txtClientIDSicredi.Text;
                ACBrPIXCD.Config.Sicredi.ClientSecret = txtClientSecretSicredi.Text;
                ACBrPIXCD.Config.Sicredi.ArqChavePrivada = txtArquivoChavePrivadaSicredi.Text;
                ACBrPIXCD.Config.Sicredi.ArqCertificado = txtArquivoCertificadoSicredi.Text;
                ACBrPIXCD.Config.Sicredi.Scopes = txtScopesSicredi.Text;

                //Sicoob
                ACBrPIXCD.Config.Sicoob.ChavePIX = txtChavePIXSicoob.Text;
                ACBrPIXCD.Config.Sicoob.ClientID = txtClientIDSicoob.Text;
                ACBrPIXCD.Config.Sicoob.TokenSandbox = txtTokenSandboxSicoob.Text;
                ACBrPIXCD.Config.Sicoob.ArqChavePrivada = txtArquivoChavePrivadaSicoob.Text;
                ACBrPIXCD.Config.Sicoob.ArqCertificado = txtArquivoCertificadoSicoob.Text;
                ACBrPIXCD.Config.Sicoob.Scopes = txtScopesSicoob.Text;

                //Shipay
                ACBrPIXCD.Config.Shipay.ClientID = txtClientIDShipay.Text;
                ACBrPIXCD.Config.Shipay.SecretKey = txtSecretKeyShipay.Text;
                ACBrPIXCD.Config.Shipay.AccessKey = txtAccessKeyShipay.Text;
                ACBrPIXCD.Config.Shipay.Scopes = txtScopesShipay.Text;

                //Santander
                ACBrPIXCD.Config.Santander.ChavePIX = txtChavePIXSantander.Text;
                ACBrPIXCD.Config.Santander.ConsumerKey = txtConsumerKeySantander.Text;
                ACBrPIXCD.Config.Santander.ConsumerSecret = txtConsumerSecretSantander.Text;
                ACBrPIXCD.Config.Santander.ArqCertificadoPFX = txtArquivoCertificadoPFXSantander.Text;
                ACBrPIXCD.Config.Santander.SenhaCertificadoPFX = txtSenhaCertificadoPFXSantander.Text;
                ACBrPIXCD.Config.Santander.Scopes = txtScopesSantander.Text;

                //PixPDV
                ACBrPIXCD.Config.PixPDV.CNPJ = txtCNPJPixPDV.Text;
                ACBrPIXCD.Config.PixPDV.Token = txtPixPDVToken.Text;
                ACBrPIXCD.Config.PixPDV.SecretKey = txtSecretKeyPixPDV.Text;
                ACBrPIXCD.Config.PixPDV.PixPDVAPIVersao = cmbPixPDVAPIVersao.GetSelectedValue<PixPDVAPIVersao>();
                ACBrPIXCD.Config.PixPDV.Scopes = txtScopesPixPDV.Text;

                //PagSeguro
                ACBrPIXCD.Config.PagSeguro.ChavePIX = txtChavePIXPagSeguro.Text;
                ACBrPIXCD.Config.PagSeguro.ClientID = txtClientIDPagSeguro.Text;
                ACBrPIXCD.Config.PagSeguro.ClientSecret = txtClientSecretPagSeguro.Text;
                ACBrPIXCD.Config.PagSeguro.ArqChavePrivada = txtArquivoChavePrivadaPagSeguro.Text;
                ACBrPIXCD.Config.PagSeguro.ArqCertificado = txtArquivoCertificadoPagSeguro.Text;
                ACBrPIXCD.Config.PagSeguro.Scopes = txtScopesPagSeguro.Text;

                //Itau
                ACBrPIXCD.Config.Itau.ChavePIX = txtChavePIXItau.Text;
                ACBrPIXCD.Config.Itau.ClientID = txtClientIDItau.Text;
                ACBrPIXCD.Config.Itau.ClientSecret = txtClientSecretItau.Text;
                ACBrPIXCD.Config.Itau.ArqChavePrivada = txtArquivoChavePrivadaItau.Text;
                ACBrPIXCD.Config.Itau.ArqCertificado = txtArquivoCertificadoItau.Text;
                ACBrPIXCD.Config.Itau.Scopes = txtScopesItau.Text;

                //Inter
                ACBrPIXCD.Config.Inter.ChavePIX = txtChavePIXInter.Text;
                ACBrPIXCD.Config.Inter.ClientID = txtClientIDInter.Text;
                ACBrPIXCD.Config.Inter.ClientSecret = txtClientSecretInter.Text;
                ACBrPIXCD.Config.Inter.ArqChavePrivada = txtArquivoChavePrivadaInter.Text;
                ACBrPIXCD.Config.Inter.ArqCertificado = txtArquivoCertificadoInter.Text;
                ACBrPIXCD.Config.Inter.Scopes = txtScopesInter.Text;

                //GerenciaNet
                ACBrPIXCD.Config.GerenciaNet.ChavePIX = txtChavePIXGerenciaNet.Text;
                ACBrPIXCD.Config.GerenciaNet.ClientID = txtClientIDGerenciaNet.Text;
                ACBrPIXCD.Config.GerenciaNet.ClientSecret = txtClientSecretGerenciaNet.Text;
                ACBrPIXCD.Config.GerenciaNet.ArqPFX = txtArquivoCertificadoGerenciaNet.Text;
                ACBrPIXCD.Config.GerenciaNet.Scopes = txtScopesGerenciaNet.Text;

                //BancoBrasil
                ACBrPIXCD.Config.BancoBrasil.ChavePIX = txtChavePIXBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.ClientID = txtClientIDBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.ClientSecret = txtClientSecretBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.DeveloperApplicationKey = txtDeveloperApplicationKeyBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.ArqChavePrivada = txtArquivoChavePrivadaBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.ArqCertificado = txtArquivoCertificadoBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.ArqPFX = txtArquivoPXFBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.SenhaPFX = txtSenhaPFXBancoBrasil.Text;
                ACBrPIXCD.Config.BancoBrasil.BBAPIVersao = cmbBBAPIVersao.GetSelectedValue<BBAPIVersao>();
                ACBrPIXCD.Config.BancoBrasil.Scopes = txtScopesBancoBrasil.Text;

                //Ailos
                ACBrPIXCD.Config.Ailos.ChavePIX = txtChavePIXAilos.Text;
                ACBrPIXCD.Config.Ailos.ClientID = txtClientIDAilos.Text;
                ACBrPIXCD.Config.Ailos.ClientSecret = txtClientSecretAilos.Text;
                ACBrPIXCD.Config.Ailos.ArqChavePrivada = txtArquivoChavePrivadaAilos.Text;
                ACBrPIXCD.Config.Ailos.ArqCertificado = txtArquivoCertificadoAilos.Text;
                ACBrPIXCD.Config.Ailos.ArqCertificadoRoot = txtArquivoCeriticadoRootAilos.Text;
                ACBrPIXCD.Config.Ailos.Scopes = txtScopesAilos.Text;

                //Matera
                ACBrPIXCD.Config.Matera.ChavePIX = txtChavePIXMatera.Text;
                ACBrPIXCD.Config.Matera.ClientID = txtClientIDMatera.Text;
                ACBrPIXCD.Config.Matera.SecretKey = txtSecretKeyMatera.Text;
                ACBrPIXCD.Config.Matera.ClientSecret = txtClientSecretMatera.Text;
                ACBrPIXCD.Config.Matera.ArqCertificado = txtArquivoCertificadoMatera.Text;
                ACBrPIXCD.Config.Matera.ArqChavePrivada = txtArquivoChavePrivadaMatera.Text;
                ACBrPIXCD.Config.Matera.AccountID = txtAccountIDMatera.Text;
                ACBrPIXCD.Config.Matera.MediatorFee = txtMediatorFeeMatera.Text;
                ACBrPIXCD.Config.Matera.Scopes = txtScopesMatera.Text;

                //Cielo
                ACBrPIXCD.Config.Cielo.ChavePIX = txtChavePIXCielo.Text;
                ACBrPIXCD.Config.Cielo.ClientID = txtClientIDCielo.Text;
                ACBrPIXCD.Config.Cielo.ClientSecret = txtClientSecretCielo.Text;
                ACBrPIXCD.Config.Cielo.ArqChavePrivada = txtArquivoChavePrivadaCielo.Text;
                ACBrPIXCD.Config.Cielo.ArqCertificado = txtArquivoCertificadoCielo.Text;
                ACBrPIXCD.Config.Cielo.Scopes = txtScopesCielo.Text;

                //MercadoPago
                ACBrPIXCD.Config.MercadoPago.ChavePIX = txtChavePIXMercadoPago.Text;
                ACBrPIXCD.Config.MercadoPago.AccessToken = txtAccessTokenMercadoPago.Text;
                ACBrPIXCD.Config.MercadoPago.Scopes = txtScopesMercadoPago.Text;

                //AppLess
                ACBrPIXCD.Config.AppLess.ClientID = txtClientIDAppLess.Text;
                ACBrPIXCD.Config.AppLess.ClientSecret = txtClientSecretAppLess.Text;
                ACBrPIXCD.Config.AppLess.SecretKeyHMAC = txtSecretKeyHMACAppLess.Text;
                ACBrPIXCD.Config.AppLess.Scopes = txtScopesAppLess.Text;

                ACBrPIXCD.ConfigGravar();

                Application.DoEvents();
            }
            finally
            {
                SplashScreenManager.Close();
            }
        }

        private void btnCarregarConfiguracoes_Click(object sender, EventArgs e)
        {
            var file = Helpers.OpenFile("Arquivos Ini (*.ini)|*.ini|Todos os Arquivos (*.*)|*.*");
            if (!File.Exists(file)) return;

            LoadConfig(file);
        }

        private void LoadConfig(string file = "ACBrLib.ini")
        {
            ACBrPIXCD.ConfigLer(file);

            //PIXCD
            cmbAmbiente.SetSelectedValue(ACBrPIXCD.Config.Ambiente);
            txtArqLogPSP.Text = ACBrPIXCD.Config.ArqLog;
            cmbNivelLogPSP.SetSelectedValue(ACBrPIXCD.Config.NivelLog);
            cmbTipoChave.SetSelectedValue(ACBrPIXCD.Config.TipoChave);
            cmbPSP.SetSelectedValue(ACBrPIXCD.Config.PSP);
            nudPSPTimeout.Value = ACBrPIXCD.Config.Timeout;
            txtProxyServidor.Text = ACBrPIXCD.Config.ProxyHost;
            txtProxySenha.Text = ACBrPIXCD.Config.ProxyPass;
            nudProxyPorta.Value = ACBrPIXCD.Config.ProxyPort;
            txtProxyUsuario.Text = ACBrPIXCD.Config.ProxyUser;
            txtCEPRecebedor.Text = ACBrPIXCD.Config.CEPRecebedor;
            txtCidadeRecebedor.Text = ACBrPIXCD.Config.CidadeRecebedor;
            txtNomeRecebedor.Text = ACBrPIXCD.Config.NomeRecebedor;
            txtUFRecebedor.Text = ACBrPIXCD.Config.UFRecebedor;

            //Bradesco
            txtChavePIXBradesco.Text = ACBrPIXCD.Config.Bradesco.ChavePIX;
            txtClientIDBradesco.Text = ACBrPIXCD.Config.Bradesco.ClientID;
            txtClientSecretBradesco.Text = ACBrPIXCD.Config.Bradesco.ClientSecret;
            txtArquivoPFXBradesco.Text = ACBrPIXCD.Config.Bradesco.ArqPFX;
            txtSenhaCertificadoBradesco.Text = ACBrPIXCD.Config.Bradesco.SenhaPFX;
            txtScopesBradesco.Text = ACBrPIXCD.Config.Bradesco.Scopes;
            txtArquivoChavePrivadaBradesco.Text = ACBrPIXCD.Config.Bradesco.ArqChavePrivada;
            txtArquivoCertificadoBradesco.Text = ACBrPIXCD.Config.Bradesco.ArqCertificado;

            //Sicredi
            txtChavePIXSicredi.Text = ACBrPIXCD.Config.Sicredi.ChavePIX;
            txtClientIDSicredi.Text = ACBrPIXCD.Config.Sicredi.ClientID;
            txtClientSecretSicredi.Text = ACBrPIXCD.Config.Sicredi.ClientSecret;
            txtArquivoChavePrivadaSicredi.Text = ACBrPIXCD.Config.Sicredi.ArqChavePrivada;
            txtArquivoCertificadoSicredi.Text = ACBrPIXCD.Config.Sicredi.ArqCertificado;
            txtScopesSicredi.Text = ACBrPIXCD.Config.Sicredi.Scopes;

            //Sicoob
            txtChavePIXSicoob.Text = ACBrPIXCD.Config.Sicoob.ChavePIX;
            txtClientIDSicoob.Text = ACBrPIXCD.Config.Sicoob.ClientID;
            txtTokenSandboxSicoob.Text = ACBrPIXCD.Config.Sicoob.TokenSandbox;
            txtArquivoChavePrivadaSicoob.Text = ACBrPIXCD.Config.Sicoob.ArqChavePrivada;
            txtArquivoCertificadoSicoob.Text = ACBrPIXCD.Config.Sicoob.ArqCertificado;
            txtScopesSicoob.Text = ACBrPIXCD.Config.Sicoob.Scopes;

            //Shipay
            txtClientIDShipay.Text = ACBrPIXCD.Config.Shipay.ClientID;
            txtSecretKeyShipay.Text = ACBrPIXCD.Config.Shipay.SecretKey;
            txtAccessKeyShipay.Text = ACBrPIXCD.Config.Shipay.AccessKey;
            txtScopesShipay.Text = ACBrPIXCD.Config.Shipay.Scopes;

            //Santander
            txtChavePIXSantander.Text = ACBrPIXCD.Config.Santander.ChavePIX;
            txtConsumerKeySantander.Text = ACBrPIXCD.Config.Santander.ConsumerKey;
            txtConsumerSecretSantander.Text = ACBrPIXCD.Config.Santander.ConsumerSecret;
            txtArquivoCertificadoPFXSantander.Text = ACBrPIXCD.Config.Santander.ArqCertificadoPFX;
            txtSenhaCertificadoPFXSantander.Text = ACBrPIXCD.Config.Santander.SenhaCertificadoPFX;
            txtScopesSantander.Text = ACBrPIXCD.Config.Santander.Scopes;

            //PixPDV
            txtCNPJPixPDV.Text = ACBrPIXCD.Config.PixPDV.CNPJ;
            txtPixPDVToken.Text = ACBrPIXCD.Config.PixPDV.Token;
            txtSecretKeyPixPDV.Text = ACBrPIXCD.Config.PixPDV.SecretKey;
            cmbPixPDVAPIVersao.SetSelectedValue(ACBrPIXCD.Config.PixPDV.PixPDVAPIVersao);
            txtScopesPixPDV.Text = ACBrPIXCD.Config.PixPDV.Scopes;

            //PagSeguro
            txtChavePIXPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.ChavePIX;
            txtClientIDPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.ClientID;
            txtClientSecretPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.ClientSecret;
            txtArquivoChavePrivadaPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.ArqChavePrivada;
            txtArquivoCertificadoPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.ArqCertificado;
            txtScopesPagSeguro.Text = ACBrPIXCD.Config.PagSeguro.Scopes;

            //Itau
            txtChavePIXItau.Text = ACBrPIXCD.Config.Itau.ChavePIX;
            txtClientIDItau.Text = ACBrPIXCD.Config.Itau.ClientID;
            txtClientSecretItau.Text = ACBrPIXCD.Config.Itau.ClientSecret;
            txtArquivoChavePrivadaItau.Text = ACBrPIXCD.Config.Itau.ArqChavePrivada;
            txtArquivoCertificadoItau.Text = ACBrPIXCD.Config.Itau.ArqCertificado;
            txtScopesItau.Text = ACBrPIXCD.Config.Itau.Scopes;

            //Inter
            txtChavePIXInter.Text = ACBrPIXCD.Config.Inter.ChavePIX;
            txtClientIDInter.Text = ACBrPIXCD.Config.Inter.ClientID;
            txtClientSecretInter.Text = ACBrPIXCD.Config.Inter.ClientSecret;
            txtArquivoChavePrivadaInter.Text = ACBrPIXCD.Config.Inter.ArqChavePrivada;
            txtArquivoCertificadoInter.Text = ACBrPIXCD.Config.Inter.ArqCertificado;
            txtScopesInter.Text = ACBrPIXCD.Config.Inter.Scopes;

            //GerenciaNet
            txtChavePIXGerenciaNet.Text = ACBrPIXCD.Config.GerenciaNet.ChavePIX;
            txtClientIDGerenciaNet.Text = ACBrPIXCD.Config.GerenciaNet.ClientID;
            txtClientSecretGerenciaNet.Text = ACBrPIXCD.Config.GerenciaNet.ClientSecret;
            txtArquivoCertificadoGerenciaNet.Text = ACBrPIXCD.Config.GerenciaNet.ArqPFX;
            txtScopesGerenciaNet.Text = ACBrPIXCD.Config.GerenciaNet.Scopes;

            //BancoBrasil
            txtChavePIXBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ChavePIX;
            txtClientIDBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ClientID;
            txtClientSecretBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ClientSecret;
            txtDeveloperApplicationKeyBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.DeveloperApplicationKey;
            txtArquivoChavePrivadaBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ArqChavePrivada;
            txtArquivoCertificadoBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ArqCertificado;
            txtArquivoPXFBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.ArqPFX;
            txtSenhaPFXBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.SenhaPFX;
            cmbBBAPIVersao.SetSelectedValue(ACBrPIXCD.Config.BancoBrasil.BBAPIVersao);
            txtScopesBancoBrasil.Text = ACBrPIXCD.Config.BancoBrasil.Scopes;           

            //Ailos
            txtChavePIXAilos.Text = ACBrPIXCD.Config.Ailos.ChavePIX;
            txtClientIDAilos.Text = ACBrPIXCD.Config.Ailos.ClientID;
            txtClientSecretAilos.Text = ACBrPIXCD.Config.Ailos.ClientSecret;
            txtArquivoChavePrivadaAilos.Text = ACBrPIXCD.Config.Ailos.ArqChavePrivada;
            txtArquivoCertificadoAilos.Text = ACBrPIXCD.Config.Ailos.ArqCertificado;
            txtArquivoCeriticadoRootAilos.Text = ACBrPIXCD.Config.Ailos.ArqCertificadoRoot;
            txtScopesAilos.Text = ACBrPIXCD.Config.Ailos.Scopes;

            //Matera
            txtChavePIXMatera.Text = ACBrPIXCD.Config.Matera.ChavePIX;
            txtClientIDMatera.Text = ACBrPIXCD.Config.Matera.ClientID;
            txtSecretKeyMatera.Text = ACBrPIXCD.Config.Matera.SecretKey;
            txtClientSecretMatera.Text = ACBrPIXCD.Config.Matera.ClientSecret;
            txtArquivoCertificadoMatera.Text = ACBrPIXCD.Config.Matera.ArqCertificado;
            txtArquivoChavePrivadaMatera.Text = ACBrPIXCD.Config.Matera.ArqChavePrivada;
            txtAccountIDMatera.Text = ACBrPIXCD.Config.Matera.AccountID;
            txtMediatorFeeMatera.Text = ACBrPIXCD.Config.Matera.MediatorFee;
            txtScopesMatera.Text = ACBrPIXCD.Config.Matera.Scopes;

            //Cielo
            txtChavePIXCielo.Text = ACBrPIXCD.Config.Cielo.ChavePIX;
            txtClientIDCielo.Text = ACBrPIXCD.Config.Cielo.ClientID;
            txtClientSecretCielo.Text = ACBrPIXCD.Config.Cielo.ClientSecret;
            txtArquivoChavePrivadaCielo.Text = ACBrPIXCD.Config.Cielo.ArqChavePrivada;
            txtArquivoCertificadoCielo.Text = ACBrPIXCD.Config.Cielo.ArqCertificado;
            txtScopesCielo.Text = ACBrPIXCD.Config.Cielo.Scopes;

            //MercadoPago
            txtChavePIXMercadoPago.Text = ACBrPIXCD.Config.MercadoPago.ChavePIX;
            txtAccessTokenMercadoPago.Text = ACBrPIXCD.Config.MercadoPago.AccessToken;
            txtScopesMercadoPago.Text = ACBrPIXCD.Config.MercadoPago.Scopes;

            //AppLess
            txtClientIDAppLess.Text = ACBrPIXCD.Config.AppLess.ClientID;
            txtClientSecretAppLess.Text = ACBrPIXCD.Config.AppLess.ClientSecret;
            txtSecretKeyHMACAppLess.Text = ACBrPIXCD.Config.AppLess.SecretKeyHMAC;
            txtScopesAppLess.Text = ACBrPIXCD.Config.AppLess.Scopes;
        }

        private void btnCertificadoBradesco_Click(object sender, EventArgs e)
        {
            txtArquivoPFXBradesco.Text = Helpers.OpenFile("Arquivos PFX (*.pfx)|*.pfx|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaSicredi_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaSicredi.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoSicredi_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoSicredi.Text = Helpers.OpenFile("Arquivos CER (*.cer)|*.cer|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaSicoob_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaSicoob.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoSicoob_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoSicoob.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoPFXSantander_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoPFXSantander.Text = Helpers.OpenFile("Arquivos PFX (*.pfx)|*.pfx|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaPagSeguro_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaPagSeguro.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoPagSeguro_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoPagSeguro.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaItau_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaItau.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoItau_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoItau.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaInter_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaInter.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoInter_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoInter.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoGerenciaNet_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoGerenciaNet.Text = Helpers.OpenFile("Arquivos P12 (*.p12)|*.p12|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaBancoBrasil_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaBancoBrasil.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoBancoBrasil_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoBancoBrasil.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoPXFBancoBrasil_Click(object sender, EventArgs e)
        {
            txtArquivoPXFBancoBrasil.Text = Helpers.OpenFile("Arquivos PFX (*.pfx)|*.pfx|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaAilos_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaAilos.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoAilos_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoAilos.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCeriticadoRootAilos_Click(object sender, EventArgs e)
        {
            txtArquivoCeriticadoRootAilos.Text = Helpers.OpenFile("Arquivos CRT (*.crt)|*.crt|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoChavePrivadaMatera_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaMatera.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoMatera_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoMatera.Text = Helpers.OpenFile("Arquivos PEM (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }
        private void btnArquivoChavePrivadaCielo_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaCielo.Text = Helpers.OpenFile("Arquivos KEY (*.key)|*.key|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArquivoCertificadoCielo_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoCielo.Text = Helpers.OpenFile("Arquivos CER (*.cer)|*.cer|Todos os Arquivos (*.*)|*.*");
        }
        private void btnGerarQRCodeEstatico_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.GerarQRCodeEstatico(double.Parse(txtValor.Text), txtInformacoesAdicionais.Text, txtTxIdQRCodeEstatico.Text);
                rtbRespostas.AppendText(ret);
            } 
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarPix_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarPix(txte2eidConsultarPIX.Text);
                rtbRespostas.AppendText(ret);
            } 
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarPixRecebidos_Click(object sender, EventArgs e)
        {
            try
            { 
                var ret = ACBrPIXCD.ConsultarPixRecebidos(DateTime.Parse(txtDataInicialConsultarPIXRecebidos.Text), DateTime.Parse(txtDataFinalConsultarPIXRecebidos.Text), txtTxIdConsultarPIXRecebidos.Text, txtCPFCNPJConsultarPIXRecebidos.Text, (int)nudPagAtualConsultarPIXRecebidos.Value, (int)nudItensPorPaginaConsultarPIXRecebidos.Value);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnSolicitarDevolucaoPix_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.SolicitarDevolucaoPix(rtbSolicitarDevolucaoPIX.Text, txte2eidSolicitarDevolucaoPIX.Text, txtIdDevolucaoSolicitarDevolucaoPIX.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarDevolucaoPix_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarDevolucaoPix(txte2eidConsultarDevolucaoPIX.Text, txtIdDevolucaoConsultarDevolucaoPIX.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCriarCobrancaImediata_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.CriarCobrancaImediata(rtbCriarCobrancaImediata.Text, txtTxIdCriarCobrancaImediata.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarCobrancaImediata_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarCobrancaImediata(txtTxIdConsultarCobrancaImediata.Text, int.Parse(txtRevisaoConsultarCobrancaImediata.Text));
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarCobrancasCob_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarCobrancasCob(DateTime.Parse(txtDataInicialConsultarCobrancasCob.Text), DateTime.Parse(txtDataFinalConsultarCobrancasCob.Text), txtCPFCNPJConsultarCobrancasCob.Text, ckbLocationConsultarCobrancasCob.Checked, cmbStatusConsultarCobrancasCob.SelectedIndex, (int)nudPagAtualConsultarCobrancasCob.Value, (int)nudItensPorPaginaConsultarCobrancasCob.Value);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarCobrancasCobV_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarCobrancasCobV(DateTime.Parse(txtDataInicialConsultarCobrancasCobV.Text), DateTime.Parse(txtDataFinalConsultarCobrancasCobV.Text), txtCPFCNPJConsultarCobrancasCobV.Text, ckbLocationConsultarCobrancasCobV.Checked, cmbStatusConsultarCobrancasCobV.SelectedIndex, (int)nudPagAtualConsultarCobrancasCobV.Value, (int)nudItensPorPaginaConsultarCobrancasCobV.Value);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnRevisarCobrancaImediata_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.RevisarCobrancaImediata(rtbRevisarCobrancaImediata.Text, txtTxIdRevisarCobrancaImediata.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCancelarCobrancaImediata_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.CancelarCobrancaImediata(txtTxIdCancelarCobrancaImediata.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCriarCobranca_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.CriarCobranca(rtbCriarCobranca.Text, txtTxIdCriarCobranca.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnConsultarCobranca_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.ConsultarCobranca(txtTxIdConsultarCobranca.Text, int.Parse(txtRevisaoConsultarCobranca.Text));
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnRevisarCobranca_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.RevisarCobranca(rtbRevisarCobranca.Text, txtTxIdRevisarCobranca.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCancelarCobranca_Click(object sender, EventArgs e)
        {
            try
            {
                var ret = ACBrPIXCD.CancelarCobranca(txtTxIdCancelarCobranca.Text);
                rtbRespostas.AppendText(ret);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, @"Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnOpenSSLInfo_Click(object sender, EventArgs e)
        {
            var ret = ACBrPIXCD.OpenSSLInfo();
            rtbRespostas.AppendText(ret);
        }

        private void btnLimparRespostas_Click(object sender, EventArgs e)
        {
            rtbRespostas.Clear();
        }

        private void btnChavePrivadaBradesco_Click(object sender, EventArgs e)
        {
            txtArquivoChavePrivadaBradesco.Text = Helpers.OpenFile("Arquivos pem (*.pem)|*.pem|Todos os Arquivos (*.*)|*.*");
        }

        private void btnArqCertificadoBradesco_Click(object sender, EventArgs e)
        {
            txtArquivoCertificadoBradesco.Text = Helpers.OpenFile("Arquivos cer (*.cer)|*.cer|Todos os Arquivos (*.*)|*.*");
        }
    }
}