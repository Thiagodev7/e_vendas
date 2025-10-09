// lib/app/modules/totem/pages/totem_contract_webview_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

// API v4 do webview_flutter
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class TotemContractWebviewPage extends StatefulWidget {
  const TotemContractWebviewPage({super.key, this.url});

  /// Se usar Modular, passe em arguments: {'url': 'https://...'}
  final String? url;

  @override
  State<TotemContractWebviewPage> createState() => _TotemContractWebviewPageState();
}

class _TotemContractWebviewPageState extends State<TotemContractWebviewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  String get _initialUrl {
    final arg = Modular.args.data;
    if (arg is Map && arg['url'] is String) return arg['url'] as String;
    if (widget.url != null && widget.url!.isNotEmpty) return widget.url!;
    return 'about:blank';
  }

  @override
  void initState() {
    super.initState();

    // Criação com params específicos por plataforma (API v4)
    final PlatformWebViewControllerCreationParams params;
    if (Platform.isAndroid) {
      params =  AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) async {
            setState(() => _loading = false);
            await _injectSameWindowPatch(); // <-- injeta o patch para window.open/target=_blank
          },
          onWebResourceError: (err) {
            // debugPrint('WebView error: $err');
          },
        ),
      );

    // Ajustes específicos do Android
    if (controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidCtrl =
          controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(true);
      androidCtrl.setMediaPlaybackRequiresUserGesture(false);
      // NÃO usamos setOnCreateWindow (não existe nessa versão) — usamos o patch JS abaixo.
    }

    // Carrega a URL
    final initial = _initialUrl;
    if (initial.startsWith('http')) {
      controller.loadRequest(Uri.parse(initial));
    } else {
      controller.loadHtmlString(
        '<html><body style="font-family:sans-serif;padding:24px">'
        '<h3>Link inválido</h3>'
        '<p>Nenhuma URL de contrato foi informada.</p>'
        '</body></html>',
      );
    }

    _controller = controller;
  }

  /// Patch para forçar qualquer popup/target=_blank a abrir na mesma WebView.
  Future<void> _injectSameWindowPatch() async {
    const js = r"""
      (function() {
        try {
          // 1) Força window.open a navegar na mesma janela
          window.open = function(url) {
            if (url) { window.location.href = url; }
            return null;
          };

          // 2) Converte todos os links target=_blank para target=_self
          document.querySelectorAll('a[target="_blank"]').forEach(function(a) {
            a.setAttribute('target', '_self');
          });

          // 3) Captura cliques que gerariam nova janela e navega aqui
          document.addEventListener('click', function(e) {
            var a = e.target.closest('a[target="_blank"]');
            if (a && a.href) {
              e.preventDefault();
              window.location.href = a.href;
            }
          }, true);
        } catch (e) {}
      })();
    """;
    try {
      await _controller.runJavaScript(js);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura do contrato'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.reload(),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            LinearProgressIndicator(minHeight: 3, color: cs.primary),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () => Modular.to.maybePop(),
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Concluir'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
        ),
      ),
    );
  }
}