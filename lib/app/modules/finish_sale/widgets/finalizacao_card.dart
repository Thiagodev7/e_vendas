import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'panel.dart';

// Stores já existentes no fluxo
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';

// Novo store de finalização
import 'package:e_vendas/app/modules/finish_sale/store/finalizacao_store.dart';

// Para pré-preencher o CPF do vendedor
import 'package:e_vendas/app/core/stores/global_store.dart';

class FinalizacaoCard extends StatefulWidget {
  const FinalizacaoCard({super.key});

  @override
  State<FinalizacaoCard> createState() => _FinalizacaoCardState();
}

class _FinalizacaoCardState extends State<FinalizacaoCard> {
  final _cpfCtrl = TextEditingController();
  final _cpfFocus = FocusNode();

  late final FinalizacaoStore _finalizacaoStore;
  late final FinishSaleStore _saleStore;
  late final GlobalStore _globalStore;

  @override
  void initState() {
    super.initState();
    _finalizacaoStore = Modular.get<FinalizacaoStore>();
    _saleStore = Modular.get<FinishSaleStore>();
    _globalStore = Modular.get<GlobalStore>();

    // Pré-preenche com o CPF do vendedor logado (se existir)
    final prefill = _globalStore.vendedorCpf.replaceAll(RegExp(r'\D'), '');
    _cpfCtrl.text = prefill;
  }

  @override
  void dispose() {
    _cpfCtrl.dispose();
    _cpfFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Panel(
      title: 'Finalização',
      icon: Icons.rocket_launch_outlined,
      child: Observer(builder: (_) {
        final st = _finalizacaoStore.status;
        final loading = st == FinalizacaoStatus.loading;
        final sucesso = st == FinalizacaoStatus.success;
        final erro = st == FinalizacaoStatus.error;

        // extrai lista_erros do payload (quando houver)
        final listaErros = (() {
          final le = _finalizacaoStore.lastError;
          if (le is Map &&
              le?['erro'] is Map &&
              (le?['erro']['lista_erros'] is List)) {
            return List<Map<String, dynamic>>.from(
              le?['erro']['lista_erros'] as List,
            );
          }
          return const <Map<String, dynamic>>[];
        })();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PropostaInfoRow(nro: _saleStore.nroProposta),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cpfCtrl,
              focusNode: _cpfFocus,
              decoration: const InputDecoration(
                labelText: 'CPF do vendedor',
                hintText:
                    'Somente números (deixe em branco para usar o CPF do vendedor logado)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              enabled: !loading,
            ),
            const SizedBox(height: 12),

            // Feedbacks
            if (erro && (_finalizacaoStore.errorMessage?.isNotEmpty ?? false))
              ...[
                _InfoBanner.error(_finalizacaoStore.errorMessage!),
                const SizedBox(height: 8),
                if (listaErros.isNotEmpty)
                  _DatasysErrorDetails(listaErros: listaErros),
              ],

            if (sucesso) ...[
              _InfoBanner.success(
                _finalizacaoStore.lastSuccess?['message']?.toString() ??
                    'Enviado ao Datasys com sucesso.',
              ),
              const SizedBox(height: 8),
            ],

            // Botões
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading ? null : _onFinalizar,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch_outlined),
                    label: Text(loading ? 'Enviando...' : 'Finalizar venda'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: loading ? null : _finalizacaoStore.reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpar'),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Future<void> _onFinalizar() async {
    final nro = _saleStore.nroProposta;
    if (nro == null) {
      _toast('Número da proposta não disponível.');
      return;
    }

    final ok = await _finalizacaoStore.finalizarVenda(
      nroProposta: nro,
      cpfVendedor: _cpfCtrl.text, // pode vir vazio -> store usa GlobalStore
    );

    if (ok) {
      _toast('Venda finalizada enviada ao Datasys.');
      // Abre o pop-up bonito com carteirinha e ação de voltar à home
      final data = _finalizacaoStore.lastSuccess ?? <String, dynamic>{};
      // aguarda fechar o diálogo antes de prosseguir
      await _showSuccessDialog(context, data);
    } else {
      _toast(_finalizacaoStore.errorMessage ?? 'Falha ao finalizar.');
      _cpfFocus.requestFocus();
    }
  }

  // ============== POPUP DE SUCESSO =================

  Future<void> _showSuccessDialog(
      BuildContext context, Map<String, dynamic> data) async {
    final cs = Theme.of(context).colorScheme;
    final nro = _extractNroProposta(data) ?? _saleStore.nroProposta;
    final carteirinha = _extractCarteirinha(data);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header com ícone
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.check_rounded,
                        color: cs.onPrimaryContainer, size: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Venda concluída!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['message']?.toString() ??
                        'Enviado ao Datasys com sucesso.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Chips informativos
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (nro != null)
                        _chip(
                          context,
                          icon: Icons.tag_rounded,
                          label: 'Proposta #$nro',
                        ),
                      if (data['faturamento'] is Map &&
                          (data['faturamento']['executado'] == true))
                        _chip(
                          context,
                          icon: Icons.receipt_long_rounded,
                          label: 'Faturamento emitido',
                          color: cs.secondaryContainer,
                          fg: cs.onSecondaryContainer,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Carteirinha destacada (quando houver)
                  if (carteirinha != null && carteirinha.isNotEmpty) ...[
                    _CarteirinhaCard(
                      cardNumber: carteirinha,
                      onCopy: () async {
                        await Clipboard.setData(
                            ClipboardData(text: carteirinha));
                        _toast('Carteirinha copiada!');
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Detalhes (expansível)
                  _SuccessDetailsInline(data: data),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Expanded(
                      //   child: OutlinedButton.icon(
                      //     onPressed: () {
                      //       Navigator.of(ctx, rootNavigator: true).pop();
                      //     },
                      //     icon: const Icon(Icons.close),
                      //     label: const Text('Fechar'),
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // navega para a Home; ajuste a rota se necessário
                            Modular.to.navigate('/home');
                          },
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Voltar para a Home'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int? _extractNroProposta(Map<String, dynamic> data) {
    final raw = data['nro_proposta'] ?? data['nroProposta'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
    // se não achar, volta null -> UI já trata
  }

  String? _extractCarteirinha(Map<String, dynamic> data) {
    try {
      final pessoa = (data['pessoa_composicao'] ?? {}) as Map;
      final ret = (pessoa['retorno'] ?? {}) as Map;
      final titular = (ret['titular'] ?? {}) as Map;
      final card = titular['carteirinha']?.toString();
      if (card != null && card.trim().isNotEmpty) return card.trim();
    } catch (_) {}
    return null;
  }

  // ================= UI helpers =================

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _PropostaInfoRow extends StatelessWidget {
  const _PropostaInfoRow({required this.nro});
  final int? nro;

  @override
  Widget build(BuildContext context) {
    final text = nro == null ? '—' : '#$nro';
    return Row(
      children: [
        const Icon(Icons.assignment_outlined, size: 18),
        const SizedBox(width: 6),
        Text('Proposta: $text', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner._(this.color, this.icon, this.text);
  factory _InfoBanner.error(String text) =>
      _InfoBanner._(Colors.red.shade50, Icons.error_outline, text);
  factory _InfoBanner.success(String text) =>
      _InfoBanner._(Colors.green.shade50, Icons.check_circle_outline, text);

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _DatasysErrorDetails extends StatelessWidget {
  const _DatasysErrorDetails({required this.listaErros});
  final List<Map<String, dynamic>> listaErros;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withOpacity(.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalhes do erro do Datasys:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...listaErros.map((e) {
            final msg = (e['msg'] ?? '').toString();
            final reg = (e['registro'] ?? '').toString();
            final origem = (e['id_origem'] ?? '').toString();

            final line = [
              if (msg.isNotEmpty) msg,
              if (reg.isNotEmpty) '[$reg]',
              if (origem.isNotEmpty) '(origem: $origem)',
            ].join(' ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(line)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SuccessDetailsInline extends StatelessWidget {
  const _SuccessDetailsInline({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    // Mostra um bloco “Ver detalhes” com o JSON completo de sucesso
    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('Ver detalhes'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            pretty,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _CarteirinhaCard extends StatelessWidget {
  const _CarteirinhaCard({
    required this.cardNumber,
    required this.onCopy,
  });

  final String cardNumber;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withOpacity(.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_rounded, color: cs.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carteirinha',
                    style: TextStyle(
                        color: cs.onSecondaryContainer.withOpacity(.9),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                SelectableText(
                  cardNumber,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }
}

// pequeno helper visual (chip)
Widget _chip(
  BuildContext context, {
  required IconData icon,
  required String label,
  Color? color,
  Color? fg,
}) {
  final cs = Theme.of(context).colorScheme;
  final bg = color ?? cs.surface;
  final txt = fg ?? cs.onSurfaceVariant;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: cs.outlineVariant),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: txt),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt),
        ),
      ],
    ),
  );
}