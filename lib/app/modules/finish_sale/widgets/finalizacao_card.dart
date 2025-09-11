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
          if (le is Map && le?['erro'] is Map && le?['erro']['lista_erros'] is List) {
            return List<Map<String, dynamic>>.from(le?['erro']['lista_erros'] as List);
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
            if (erro && (_finalizacaoStore.errorMessage?.isNotEmpty ?? false)) ...[
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
              if ((_finalizacaoStore.lastSuccess?['retorno_datasys']) != null)
                _SuccessDetails(
                  ret: _finalizacaoStore.lastSuccess!['retorno_datasys'],
                ),
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
    } else {
      _toast(_finalizacaoStore.errorMessage ?? 'Falha ao finalizar.');
      _cpfFocus.requestFocus();
    }
  }

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

class _SuccessDetails extends StatelessWidget {
  const _SuccessDetails({required this.ret});
  final dynamic ret;

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(ret);
    return ExpansionTile(
      title: const Text('Detalhes do retorno do Datasys'),
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
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

/// Mostra a lista de erros específicos retornados pelo Datasys:
/// cada item pode conter { msg, registro, id_origem }
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