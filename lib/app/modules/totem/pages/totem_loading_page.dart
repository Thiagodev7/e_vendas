// lib/app/modules/totem/pages/totem_loading_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_finalization_store.dart';
import 'dart:async'; // Para Timer

class TotemLoadingPage extends StatefulWidget {
  final VendaModel venda;
  const TotemLoadingPage({super.key, required this.venda});

  @override
  State<TotemLoadingPage> createState() => _TotemLoadingPageState();
}

class _TotemLoadingPageState extends State<TotemLoadingPage> with SingleTickerProviderStateMixin { // Adiciona TickerProvider
  final store = Modular.get<TotemFinalizationStore>();
  late final ReactionDisposer _disposer;
  late final AnimationController _animationController; // Para animação
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração da Animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Faz a animação pulsar
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );


    // Inicia a finalização após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
         store.finalizarVendaTotem(venda: widget.venda);
       }
    });

    // Reage à mudança de status para navegar
    _disposer = reaction(
      (_) => store.status,
      (status) {
        if (!mounted) return;
        if (status == TotemFinalizationStatus.success) {
          // Extrai a carteirinha da resposta
          final carteirinha = store.lastSuccessData?['titular']?['carteirinha']?.toString();
          // Navega para a tela de sucesso, passando a carteirinha
          Modular.to.pushReplacementNamed('/totem/success', arguments: carteirinha);
        } else if (status == TotemFinalizationStatus.error) {
          _showErrorDialog(store.errorMessage ?? 'Ocorreu um erro.');
        }
      },
       // delay: 500 // Opcional
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Descarta o controller da animação
    _disposer();
    store.reset();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro na Finalização'),
        content: Text('Não foi possível enviar os dados para o sistema:\n\n$message'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Fecha o dialog
              Modular.to.pop(); // Volta para TotemFinalizePage
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface, // Fundo mais neutro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animação de Opacidade no Indicador
            FadeTransition(
              opacity: _opacityAnimation,
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Finalizando sua contratação...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Estamos enviando seus dados para o sistema e gerando sua carteirinha. Aguarde um instante.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}