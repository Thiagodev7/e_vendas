// lib/app/modules/plans/stores/plans_store.dart
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

  /// Novo: ciclo de cobrança por plano (true = anual, false = mensal)
  @observable
  ObservableMap<int, bool> selectedAnnual = ObservableMap<int, bool>();

  /// Novo: dia de vencimento por plano (apenas para mensal)
  @observable
  ObservableMap<int, int> selectedDueDay = ObservableMap<int, int>();

  /// Carrega planos e inicializa seleção
  @action
  Future<void> loadPlans() async {
    try {
      isLoading = true;
      final result = await _service.fetchPlans();

      plans = ObservableList.of(result);

      for (final plan in result) {
        // defaults
        selectedLives[plan.id]   = plan.vidasSelecionadas > 0 ? plan.vidasSelecionadas : 1;
        selectedAnnual[plan.id]  = plan.isAnnual; // vem do back (is_anual) ou default do model
        selectedDueDay[plan.id]  = plan.isAnnual ? 10 : (plan.dueDay ?? 10);
      }
    } catch (_) {
      plans = ObservableList<PlanModel>();
    } finally {
      isLoading = false;
    }
  }

  // ---------- Setters / Getters ----------

  @action
  void setLives(int planId, int lives) {
    selectedLives[planId] = lives < 1 ? 1 : lives;
  }

  int getLives(int planId) => selectedLives[planId] ?? 1;

  /// Define ciclo (true = anual, false = mensal)
  @action
  void setAnnual(int planId, bool annual) {
    selectedAnnual[planId] = annual;
    // anual não usa dueDay; mantém um default só pra UX
    if (annual) {
      selectedDueDay[planId] = 10;
    }
  }

  bool getIsAnnual(int planId) => selectedAnnual[planId] ?? false;

  /// Define dia de vencimento (1..28). Ignorado se anual, mas guardamos o valor.
  @action
  void setDueDay(int planId, int day) {
    final safe = day.clamp(1, 28).toInt();
    selectedDueDay[planId] = safe;
  }

  int getDueDay(int planId) => selectedDueDay[planId] ?? 10;

  /// Retorna o dia efetivo a enviar pro backend (null se anual)
  int? getEffectiveDueDay(int planId) {
    return getIsAnnual(planId) ? null : getDueDay(planId);
  }

  /// Aplica as escolhas do usuário no modelo (útil pra enviar/mostrar)
  PlanModel applySelection(PlanModel plan) {
    final annual = getIsAnnual(plan.id);
    return plan.copyWith(
      vidasSelecionadas: getLives(plan.id),
      isAnnual: annual,
      dueDay: annual ? null : getDueDay(plan.id),
    );
  }
}