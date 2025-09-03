import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:mobx/mobx.dart';
import '../services/plans_service.dart';

part 'plans_store.g.dart';

class PlansStore = _PlansStoreBase with _$PlansStore;

abstract class _PlansStoreBase with Store {
  final PlansService _service = PlansService();

  @observable
  bool isLoading = false;

  @observable
  ObservableList<PlanModel> plans = ObservableList<PlanModel>();

  /// Vidas selecionadas por plano
  @observable
  ObservableMap<int, int> selectedLives = ObservableMap<int, int>();

  /// NOVO: ciclo de cobrança por plano
  @observable
  ObservableMap<int, BillingCycle> selectedCycle = ObservableMap<int, BillingCycle>();

  /// NOVO: dia de vencimento por plano (apenas para mensal)
  @observable
  ObservableMap<int, int> selectedDueDay = ObservableMap<int, int>();

  /// Carrega planos e inicializa seleção
  @action
  Future<void> loadPlans() async {
    try {
      isLoading = true;
      final result = await _service.fetchPlans();

      plans = ObservableList.of(result);

      for (var plan in result) {
        selectedLives[plan.id] = 1;
        selectedCycle[plan.id] = BillingCycle.mensal;
        selectedDueDay[plan.id] = 10; // default: dia 10
      }
    } catch (e) {
      plans = ObservableList<PlanModel>();
    } finally {
      isLoading = false;
    }
  }

  // ----- Setters / Getters -----

  @action
  void setLives(int planId, int lives) {
    selectedLives[planId] = lives;
  }

  int getLives(int planId) {
    return selectedLives[planId] ?? 1;
  }

  @action
  void setCycle(int planId, BillingCycle cycle) {
    selectedCycle[planId] = cycle;
  }

  BillingCycle getCycle(int planId) {
    return selectedCycle[planId] ?? BillingCycle.mensal;
  }

  @action
  void setDueDay(int planId, int day) {
    // segurando 1..28 para evitar meses com menos dias
    final safe = day.clamp(1, 28);
    selectedDueDay[planId] = safe;
  }

  int getDueDay(int planId) {
    return selectedDueDay[planId] ?? 10;
  }
}