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
  List<PlanModel> plans = [];

  /// Mapa para controlar o número de vidas selecionadas por plano
  @observable
  ObservableMap<int, int> selectedLives = ObservableMap<int, int>();

  /// Carrega os planos da API
  @action
  Future<void> loadPlans() async {
    try {
      isLoading = true;
      final result = await _service.fetchPlans(); // já retorna List<PlanModel>
      plans = result;

      // Inicializa as vidas selecionadas como 1 para cada plano
      for (var plan in plans) {
        selectedLives[plan.id] = 1;
      }
    } catch (e) {
      plans = [];
    } finally {
      isLoading = false;
    }
  }

  /// Define quantidade de vidas para um plano
  @action
  void setLives(int planId, int lives) {
    selectedLives[planId] = lives;
  }

  /// Retorna vidas selecionadas de um plano
  int getLives(int planId) {
    return selectedLives[planId] ?? 1;
  }
}