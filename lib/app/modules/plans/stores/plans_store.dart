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

  /// Carrega planos e seta vidasSelecionadas = 1
  @action
  Future<void> loadPlans() async {
    try {
      isLoading = true;
      final result = await _service.fetchPlans();
      plans = ObservableList.of(
        result.map((p) => p.copyWith(vidasSelecionadas: 1)).toList(),
      );
    } catch (e) {
      plans = ObservableList<PlanModel>();
    } finally {
      isLoading = false;
    }
  }

  /// Atualiza quantidade de vidas para um plano
  @action
  void setLives(int planId, int lives) {
    final index = plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      plans[index] = plans[index].copyWith(vidasSelecionadas: lives);
    }
  }
}