import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:flutter/material.dart';

/// Widget drop-in para exibir ciclo (mensal/anual), vencimento e vidas.
/// Use em qualquer tela do finish-sale.
class PlanBillingInfo extends StatelessWidget {
  const PlanBillingInfo({super.key, required this.plan});

  final PlanModel plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMensal = plan.billingCycle == BillingCycle.mensal;
    final venc = isMensal && plan.dueDay != null ? ' — venc. dia ${plan.dueDay}' : '';
    final title = isMensal ? 'Mensal$venc' : 'Anual (-10%)';

    // Valores
    final mensalTotal = plan.getMensalidadeTotal();
    final anualTotal = (double.tryParse(mensalTotal.replaceAll(',', '.')) ?? 0.0) * 12 * 0.90;
    final anualFmt = anualTotal.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ciclo de cobrança', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),

          const SizedBox(height: 12),
          Row(
            children: [
              _metric(context, 'Vidas', '${plan.vidasSelecionadas}'),
              const SizedBox(width: 16),
              if (isMensal) _metric(context, 'Mensal', 'R\$ $mensalTotal'),
              if (!isMensal) _metric(context, 'Anual (-10%)', 'R\$ $anualFmt'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}