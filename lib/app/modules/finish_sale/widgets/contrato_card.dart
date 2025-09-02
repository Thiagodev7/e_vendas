import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'panel.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';

class ContratoCard extends StatelessWidget {
  const ContratoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final contractStore = Modular.get<FinishContractStore>();
    final paymentStore  = Modular.get<FinishPaymentStore>();

    Future<void> _open(String url) async {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }

    String _toCurrency(String? raw) {
      if (raw == null || raw.trim().isEmpty) return 'R\$ 0,00';
      var s = raw.replaceAll(RegExp(r'[^\d,\. ,]'), '');
      if (RegExp(r'^\d+$').hasMatch(s)) {
        final v = double.tryParse(s) ?? 0.0;
        final val = v / 100.0;
        return 'R\$ ${val.toStringAsFixed(2).replaceAll('.', ',')}';
      }
      final lastC = s.lastIndexOf(',');
      final lastD = s.lastIndexOf('.');
      if (lastC > lastD) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
      var val = double.tryParse(s) ?? 0.0;
      if (val >= 1000) {
        final div = val / 100.0;
        if (div < 1000) val = div;
      }
      return 'R\$ ${val.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return Panel(
      icon: Icons.description_rounded,
      title: 'Contrato',
      child: Observer(builder: (_) {
        final plan = paymentStore.venda?.plano;
        final monthlyFmt    = _toCurrency(plan?.getMensalidade()    ?? plan?.getMensalidadeTotal());
        final enrollmentFmt = _toCurrency(plan?.getTaxaAdesao()     ?? plan?.getTaxaAdesaoTotal());

        final contratoGerado   = contractStore.contratoGerado;
        final contratoAssinado = contractStore.contratoAssinadoServer;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: (!contractStore.podeDispararContrato)
                      ? null
                      : () async {
                          try {
                            await contractStore.gerarContrato(
                              enrollmentFmt: enrollmentFmt,
                              monthlyFmt: monthlyFmt,
                            );
                            _toast(context, 'Contrato gerado!');
                          } catch (e) {
                            _toast(context, 'Falha ao gerar contrato: $e');
                          }
                        },
                  icon: const Icon(Icons.description),
                  label: const Text('Gerar contrato'),
                ),
                const SizedBox(width: 10),
                if (contratoGerado && contractStore.contratoUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => _open(contractStore.contratoUrl!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (contratoGerado)
                  Chip(
                    label: const Text('Contrato gerado'),
                    backgroundColor: Colors.green.withOpacity(.12),
                    labelStyle: const TextStyle(color: Colors.green),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                if (contratoAssinado)
                  Chip(
                    label: const Text('Contrato assinado'),
                    backgroundColor: Colors.blue.withOpacity(.12),
                    labelStyle: const TextStyle(color: Colors.blue),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                if (!contractStore.podeDispararContrato && !contratoAssinado)
                  Chip(
                    label: const Text('Aguardando…'),
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.outlineVariant),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}