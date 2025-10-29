// lib/app/modules/totem/pages/totem_success_page.dart
import 'dart:async';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar a carteirinha
import 'package:flutter_modular/flutter_modular.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
// import 'package:url_launcher/url_launcher.dart'; // Removido, focando nos QR Codes

class TotemSuccessPage extends StatefulWidget {
  final String? carteirinha; // Recebe a carteirinha
  const TotemSuccessPage({super.key, this.carteirinha});

  @override
  State<TotemSuccessPage> createState() => _TotemSuccessPageState();
}

class _TotemSuccessPageState extends State<TotemSuccessPage> {
  Timer? _redirectTimer;
  bool _copied = false; // Estado para feedback de cópia

  // URLs CORRIGIDAS das lojas
  final String playStoreUrl = "https://play.google.com/store/apps/details?id=com.tiuniodontogoiania.uniodontogoianiaandroid&hl=pt_BR";
  final String appStoreUrl = "https://apps.apple.com/br/app/uniodonto-goi%C3%A2nia/id1510444310"; // Corrigido (removido texto extra)

  @override
  void initState() {
    super.initState();
    _startRedirectTimer();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _startRedirectTimer() {
    _redirectTimer?.cancel();
    _redirectTimer = Timer(const Duration(seconds: 180), () { // Mantém 60s
      if (mounted) {
        _returnHome();
      }
    });
  }

  void _returnHome() {
    _redirectTimer?.cancel();
    final totemStore = Modular.get<TotemStore>();
    // ADICIONE e chame o método reset no TotemStore
    // try { totemStore.reset(); } catch (e) { print("Erro ao resetar TotemStore: $e"); }
    Modular.to.popUntil(ModalRoute.withName('/totem/'));
  }

  void _copyCarteirinha() {
    if (widget.carteirinha != null && widget.carteirinha!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: widget.carteirinha!));
      setState(() => _copied = true);
      // Remove o feedback após alguns segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copied = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasCarteirinha = widget.carteirinha != null && widget.carteirinha!.isNotEmpty;
    final totemStore = Modular.get<TotemStore>();
    final nomeTitular = totemStore.titular?.nome?.split(' ').first ?? 'Cliente';
    // Pega o email para exibir na mensagem do contrato
    final emailTitular = totemStore.contatos
        .firstWhere((c) => c.descricao.contains('@'), orElse: () => ContatoModel(idMeioComunicacao: 0, descricao: '', nomeContato: ''))
        .descricao;

    return Scaffold(
      body: Container(
        width: double.infinity, // Garante que o gradiente ocupe tudo
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.green.shade50,
              cs.primaryContainer.withOpacity(0.15),
            ],
            stops: const [0.0, 0.4, 1.0], // Ajusta a transição do gradiente
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: cs.primary,
                  size: 90,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bem-vindo(a), $nomeTitular!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua solicitação foi concluída!', // Mensagem mais genérica
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: cs.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Aviso sobre o Contrato (CORRIGIDO) ---
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: cs.surfaceVariant.withOpacity(0.6), // Leve transparência
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_email_read_outlined, color: cs.onSurfaceVariant), // Ícone diferente
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'O contrato foi enviado para o seu e-mail (${emailTitular.isNotEmpty ? emailTitular : 'informado'}) para assinatura digital. Verifique sua caixa de entrada.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- Fim Aviso Contrato ---

                // --- Exibição da Carteirinha ---
                if (hasCarteirinha) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Sua Carteirinha Digital Provisória:',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  InkWell( // Permite clicar para copiar
                    onTap: _copyCarteirinha,
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      elevation: _copied ? 0 : 3, // Remove sombra ao copiar
                      color: _copied ? Colors.grey.shade300 : cs.primary, // Muda cor ao copiar
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row( // Adiciona ícone de cópia
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Para centralizar o Row
                          children: [
                            Text( // Usando Text normal para melhor renderização
                              widget.carteirinha!,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _copied ? Colors.black54 : cs.onPrimary,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              _copied ? Icons.check_rounded : Icons.copy_rounded,
                              color: _copied ? Colors.green.shade700 : cs.onPrimary.withOpacity(0.7),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                     _copied ? 'Copiado!' : '(Clique no número para copiar)',
                    style: TextStyle(
                      color: _copied ? Colors.green.shade700 : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: _copied ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
                // --- Fim Carteirinha ---

                const SizedBox(height: 40),
                Divider(color: Colors.grey.shade400, indent: 30, endIndent: 30),
                const SizedBox(height: 32),

                // --- Instruções App ---
                Icon(Icons.phone_android_rounded, size: 40, color: cs.secondary),
                const SizedBox(height: 12),
                Text(
                  'Baixe o App Uniodonto Goiânia',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Tenha acesso rápido à sua carteirinha digital definitiva, encontre dentistas na rede credenciada, consulte seu histórico e muito mais.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start, // Mantém alinhado ao topo
                  children: [
                    Flexible( // Usa Flexible para evitar overflow se os nomes forem longos
                      child: _buildStoreQrCode(
                        context: context,
                        storeName: 'Google Play',
                        url: playStoreUrl,
                        // Adicione o asset da imagem se tiver
                        // imageAsset: 'assets/images/google_play_badge.png',
                        icon: Icons.android // Fallback
                      ),
                    ),
                    const SizedBox(width: 20), // Espaço entre os QR Codes
                     Flexible(
                       child: _buildStoreQrCode(
                        context: context,
                        storeName: 'App Store',
                        url: appStoreUrl,
                        // imageAsset: 'assets/images/app_store_badge.png',
                        icon: Icons.apple // Fallback
                                         ),
                     ),
                  ],
                ),
                // --- Fim Instruções App ---

                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _returnHome,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Concluir e Voltar ao Início'),
                ),
                 const SizedBox(height: 16),
                Text(
                  'Esta tela fechará automaticamente em alguns instantes.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar QR Code (melhorado)
  Widget _buildStoreQrCode({
    required BuildContext context,
    required String storeName,
    required String url,
    IconData? icon,
    String? imageAsset,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Mostra imagem se fornecida (ajuste altura), senão ícone
        if (imageAsset != null)
           Image.asset(imageAsset, height: 40) // Altura maior para badges
        else if (icon != null)
           Icon(icon, size: 35, color: cs.onSurfaceVariant), // Ícone um pouco maior
        const SizedBox(height: 8),
        Text(storeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withOpacity(0.1),
                 blurRadius: 10,
                 offset: const Offset(0, 4),
               )
             ]
           ),
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: 140.0,
            gapless: false,
            // Adicione um logo da Uniodonto se tiver a imagem em assets/images/
            // embeddedImage: AssetImage('assets/images/logo_icon_uniodonto.png'),
            // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
          ),
        ),
      ],
    );
  }
}