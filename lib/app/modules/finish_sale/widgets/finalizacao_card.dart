import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'panel.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_types.dart' as ft;

class FinalizacaoCard extends StatelessWidget {
  const FinalizacaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final paymentStore  = Modular.get<FinishPaymentStore>();
    final contractStore = Modular.get<FinishContractStore>();

    bool _podeFinalizar() {
      final pago = paymentStore.pagamentoConcluidoServer ||
          paymentStore.paymentStatus == ft.PaymentStatus.pago ||
          contractStore.pagamentoConcluidoServer;
      final temContrato = contractStore.contratoAssinadoServer ||
          contractStore.contratoGerado;
      return pago && temContrato && (contractStore.nroProposta != null);
    }

    String _fmtLast(DateTime? dt) {
      if (dt == null) return '—';
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    return Panel(
      icon: Icons.check_circle_rounded,
      title: 'Finalização',
      child: Observer(builder: (_) {
        final pode = _podeFinalizar();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Para finalizar a venda é necessário ter contrato gerado/assinado e pagamento confirmado.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Ações
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                
                FilledButton.icon(
                  onPressed: (!pode || contractStore.loading)
                      ? null
                      : () async {
                          try {
                            await contractStore.finalizarVenda();
                            _toast(context, 'Venda finalizada com sucesso!');
                            Modular.to.navigate('/sales');
                          } catch (e) {
                            _toast(context, 'Erro ao finalizar: $e');
                          }
                        },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar venda'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Chips de status
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (paymentStore.pagamentoConcluidoServer ||
                    contractStore.pagamentoConcluidoServer ||
                    paymentStore.paymentStatus == ft.PaymentStatus.pago)
                  Chip(
                    label: const Text('Pagamento confirmado'),
                    backgroundColor: Colors.green.withOpacity(.12),
                    labelStyle: const TextStyle(color: Colors.green),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                if (contractStore.contratoAssinadoServer)
                  Chip(
                    label: const Text('Contrato assinado'),
                    backgroundColor: Colors.blue.withOpacity(.12),
                    labelStyle: const TextStyle(color: Colors.blue),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                if (contractStore.vendaFinalizadaServer)
                  Chip(
                    label: const Text('Venda já finalizada'),
                    backgroundColor: Colors.purple.withOpacity(.12),
                    labelStyle: const TextStyle(color: Colors.purple),
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