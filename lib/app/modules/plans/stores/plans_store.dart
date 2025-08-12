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

  /// Mapa para armazenar quantidade de vidas selecionadas (por id do plano)
  @observable
  ObservableMap<int, int> selectedLives = ObservableMap<int, int>();

  /// Carrega planos e inicializa mapa de vidas
  @action
  Future<void> loadPlans() async {
    try {
      isLoading = true;
      final result = await _service.fetchPlans();

      plans = ObservableList.of(result);

      // Inicializa cada plano com 1 vida
      for (var plan in result) {
        selectedLives[plan.id] = 1;
      }
    } catch (e) {
      plans = ObservableList<PlanModel>();
    } finally {
      isLoading = false;
    }
  }

  /// Atualiza quantidade de vidas para um plano
  @action
  void setLives(int planId, int lives) {
    selectedLives[planId] = lives;
  }

  /// Retorna quantidade de vidas selecionadas para um plano
  int getLives(int planId) {
    return selectedLives[planId] ?? 1;
  }
}