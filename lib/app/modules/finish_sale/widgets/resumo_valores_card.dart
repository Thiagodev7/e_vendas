import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
import 'package:flutter/material.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/panel.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';

class ResumoValoresCard extends StatelessWidget {
  const ResumoValoresCard({super.key, required this.venda});

  final VendaModel venda;

  String _fmt(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final vidas = (venda.dependentes?.length ?? 0) + 1;
    final plan = venda.plano?.copyWith(vidasSelecionadas: vidas);

    if (plan == null) {
      return const Panel(
        icon: Icons.summarize_rounded,
        title: 'Resumo de valores',
        child: Text('Selecione um plano para ver os valores.'),
      );
    }

    final b = computeBilling(plan);

    return Panel(
      icon: Icons.summarize_rounded,
      title: 'Resumo de valores',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            b.kind == BillingKind.mensal
                ? 'Primeira cobrança (pró-rata do mês atual) + adesão'
                : 'Primeiro ciclo anual com desconto',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          _kv('Pró-rata (restam ${b.remainingDays} de ${b.monthDays} dias)', _fmt(b.prorata)),
          if (b.kind == BillingKind.anual)
            _kv('11 parcelas de', _fmt(b.mensal)),
          _kv('Taxa de adesão', _fmt(b.adesao)),
          if (b.kind == BillingKind.anual)
            _kv('Desconto anual (−10%)', '- ${_fmt(b.desconto)}'),

          const Divider(height: 20),

          // ESTE é o valor que vai para o Celcoin:
          _totalRow(
            context,
            b.kind == BillingKind.mensal ? 'Total 1ª cobrança' : 'Total 1º ciclo (à vista)',
            _fmt(b.valorAgora),
          ),

          const SizedBox(height: 8),
          Text(
            b.kind == BillingKind.mensal
                ? 'A partir do próximo mês (venc. dia ${b.dueDay}), a recorrência será ${_fmt(b.mensal)}.'
                : 'O desconto de 10% foi aplicado sobre (pró-rata + 11×mensal).',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          const SizedBox(width: 12),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cs.primary)),
        ],
      ),
    );
  }
}