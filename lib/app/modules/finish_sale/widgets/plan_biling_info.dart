import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:flutter/material.dart';

/// Exibe ciclo (mensal/anual), vencimento (se mensal), vidas e valores.
/// - Mensal: mostra mensalidade total e taxa de adesão.
/// - Anual: aplica -10% no total (12x) e exibe o valor anual com desconto.
class PlanBillingInfo extends StatelessWidget {
  const PlanBillingInfo({super.key, required this.plan});

  final PlanModel plan;

  double _toDouble(String? s) {
    if (s == null) return 0;
    final str = s.trim();
    // Se tiver vírgula, tratamos vírgula como decimal e ponto como milhar.
    if (str.contains(',')) {
      final normalized = str.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }
    // Caso não tenha vírgula, assumimos ponto como decimal (padrão en-US).
    return double.tryParse(str) ?? 0;
  }

  String _fmt(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMensal = !plan.isAnnual;

    final mensalTotal = _toDouble(plan.getMensalidadeTotal());
    final adesaoTotal = _toDouble(plan.getTaxaAdesaoTotal());
    final anualComDesconto = (mensalTotal * 12) * 0.9;

    final vencSuffix =
        isMensal && plan.dueDay != null ? ' — venc. dia ${plan.dueDay}' : '';
    final tituloCiclo = isMensal ? 'Mensal$vencSuffix' : 'Anual (-10%)';

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
          // Título do ciclo
          Row(
            children: [
              Icon(
                isMensal ? Icons.event_repeat : Icons.calendar_month,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                tituloCiclo,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Métricas
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _metric(context, 'Vidas', '${plan.vidasSelecionadas}'),
              if (isMensal) _metric(context, 'Mensal', _fmt(mensalTotal)),
              if (isMensal) _metric(context, 'Adesão', _fmt(adesaoTotal)),
              if (!isMensal)
                _metric(context, 'Total anual (-10%)', _fmt(anualComDesconto)),
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
          Text(label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}