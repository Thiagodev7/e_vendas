import 'package:mobx/mobx.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'finish_types.dart';

part 'finish_resumo_store.g.dart';

class FinishResumoStore = _FinishResumoStoreBase with _$FinishResumoStore;

abstract class _FinishResumoStoreBase with Store {
  _FinishResumoStoreBase();

  @observable
  VendaModel? venda;

  /// Vincula a venda atual
  @action
  void bindVenda(VendaModel v) {
    venda = v;
  }

  // -------- cálculos --------

  @computed
  int get vidas => ((venda?.dependentes?.length ?? 0) + 1);

  @computed
  double get mensalInd => _parseMoney(
        venda?.plano?.getMensalidade() ?? venda?.plano?.getMensalidadeTotal(),
      );

  @computed
  double get mensalTotal => (mensalInd * vidas);

  @computed
  double get adesaoInd => _parseMoney(
        venda?.plano?.getTaxaAdesao() ?? venda?.plano?.getTaxaAdesaoTotal(),
      );

  @computed
  double get adesaoTotal => (adesaoInd * vidas);

  @computed
  double get proRataInd => calculateProrata(monthly: mensalInd);

  @computed
  double get proRataTotal => (proRataInd * vidas);

  @computed
  double get totalPrimeiraCobranca => adesaoTotal + proRataTotal + mensalTotal;

  @computed
  ResumoValores? get resumo {
    final v = venda;
    if (v == null) return null;
    return ResumoValores(
      vidas: vidas,
      adesaoIndividual: adesaoInd,
      mensalidadeIndividual: mensalInd,
      proRataIndividual: proRataInd,
      mensalidadeTotal: mensalTotal,
      proRataTotal: proRataTotal,
      totalPrimeiraCobranca: totalPrimeiraCobranca,
    );
  }

  @action
  double calculateProrata({required double monthly}) {
    final today = DateTime.now();
    final totalDaysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final currentDay = today.day;
    final daysToPay = totalDaysInMonth - currentDay;
    if (daysToPay <= 0) return 0.0;
    final valueByDay = monthly / totalDaysInMonth;
    final proRata = valueByDay * daysToPay;
    return double.parse(proRata.toStringAsFixed(2));
  }

  // -------- helpers --------

  double _parseMoney(String? s) {
    if (s == null) return 0.0;
    final raw = s.trim();
    if (raw.isEmpty) return 0.0;

    if (RegExp(r'^\d+$').hasMatch(raw)) {
      final cents = int.tryParse(raw) ?? 0;
      return (cents / 100).toDouble();
    }

    var cleaned = raw.replaceAll(RegExp(r'[^\d,\.]'), '');
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');

    if (lastComma > lastDot) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll(',', '');
    }

    var value = double.tryParse(cleaned) ?? 0.0;

    if (value >= 1000) {
      final divided = value / 100.0;
      if (divided < 1000) value = divided;
    }

    return double.parse(value.toStringAsFixed(2));
  }
}