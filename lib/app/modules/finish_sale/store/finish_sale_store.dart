import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:e_vendas/app/core/model/venda_model.dart';

part 'finish_sale_store.g.dart';

/// Store “legada” focada APENAS em dados da venda e resumo de valores.
/// (Sem geração de cobrança ou status de pagamento.)
class FinishSaleStore = _FinishSaleStoreBase with _$FinishSaleStore;

abstract class _FinishSaleStoreBase with Store {
  _FinishSaleStoreBase();

  // ===== Bindings / estado base =====
  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  // ===== Init / bind =====
  @action
  void init({required VendaModel v, int? nro}) {
    venda = v;
    nroProposta = nro ?? v.nroProposta;
  }

  // ===== Cálculos (Resumo) =====
  @computed
  int get vidas => ((venda?.dependentes?.length ?? 0) + 1);

  /// Quebra de valores (mensal, adesão, pró-rata e total agora) calculada a partir do plano.
  @computed
  BillingBreakdown? get billing {
    final v = venda;
    if (v == null || v.plano == null) return null;
    final planSync = v.plano!.copyWith(vidasSelecionadas: vidas);
    return computeBilling(planSync);
  }

  /// Totais (já somados considerando as vidas)
  @computed
  double get mensalTotal => (billing?.mensal ?? 0);

  @computed
  double get adesaoTotal => (billing?.adesao ?? 0);

  @computed
  double get proRataTotal => (billing?.prorata ?? 0);

  /// Derivados por vida (se a UI precisar)
  @computed
  double get mensalInd => vidas > 0 ? mensalTotal / vidas : 0;

  @computed
  double get adesaoInd => vidas > 0 ? adesaoTotal / vidas : 0;

  @computed
  double get proRataInd => vidas > 0 ? proRataTotal / vidas : 0;

  /// Total da cobrança “agora” (o mesmo valor que o PaymentStore envia ao Celcoin)
  @computed
  double get totalPrimeiraCobranca => (billing?.valorAgora ?? 0);

  /// Valor em centavos (útil para exibir igual ao pagamento, se necessário na UI)
  @computed
  int get valorAgoraCentavos => (billing?.valorAgoraCentavos ?? 0);

  /// Pró-rata por vida (helper legado; hoje o cálculo real está em [billing])
  @action
  double calculateProrataIndividual() {
    final b = billing;
    if (b == null || vidas <= 0) return 0;
    return b.prorata / vidas;
  }
}