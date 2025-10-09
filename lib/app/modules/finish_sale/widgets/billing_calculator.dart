import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:flutter/material.dart';

enum BillingKind { mensal, anual }

class BillingBreakdown {
  BillingBreakdown({
    required this.kind,
    required this.mensal,
    required this.adesao,
    required this.prorata,
    required this.dueDay,
    required this.monthDays,
    required this.remainingDays,
  })  : totalPrimeira = (kind == BillingKind.mensal) ? prorata + adesao : 0,
        desconto = (kind == BillingKind.anual) ? (prorata + (mensal * 11)) * 0.10 : 0,
        totalAnualPrimeiro = (kind == BillingKind.anual)
            ? ((prorata + (mensal * 11)) * 0.90) + adesao
            : 0;

  final BillingKind kind;
  final double mensal;
  final double adesao;
  final double prorata;

  // UI/support
  final int dueDay;       // apenas informativo
  final int monthDays;    // dias do mês atual
  final int remainingDays; // dias restantes incluindo hoje

  // Totais calculados
  final double totalPrimeira;       // mensal: pró-rata + adesão
  final double desconto;            // anual: 10% sobre (pró-rata + 11x mensal)
  final double totalAnualPrimeiro;  // anual: base*0.9 + adesão

  /// Valor que DEVE ser cobrado AGORA (Celcoin)
  double get valorAgora =>
      (kind == BillingKind.mensal) ? totalPrimeira : totalAnualPrimeiro;

  int get valorAgoraCentavos => (valorAgora * 100).round();
}

double _toDoubleBr(String? s) {
  if (s == null) return 0;
  final str = s.trim();
  if (str.contains(',')) {
    final normalized = str.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }
  return double.tryParse(str) ?? 0;
}

/// Pró-rata = dias restantes do mês atual (independe do dia de vencimento).
BillingBreakdown computeBilling(PlanModel plan, {DateTime? now}) {
  final isMensal = !plan.isAnnual;
  final mensal = _toDoubleBr(plan.getMensalidadeTotal());
  final adesao = _toDoubleBr(plan.getTaxaAdesaoTotal());

  final today = now ?? DateTime.now();
  final monthDays = DateUtils.getDaysInMonth(today.year, today.month);
  final remainingDays = (monthDays - today.day ).clamp(0, monthDays);
  final fraction = (remainingDays / monthDays).clamp(0.0, 1.0);
  final prorata = mensal * fraction;

  final due = (plan.dueDay ?? 10).clamp(1, 28);

  return BillingBreakdown(
    kind: isMensal ? BillingKind.mensal : BillingKind.anual,
    mensal: mensal,
    adesao: adesao,
    prorata: prorata,
    dueDay: due,
    monthDays: monthDays,
    remainingDays: remainingDays,
  );
}