import 'package:mobx/mobx.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

part 'totem_store.g.dart';

class TotemStore = _TotemStoreBase with _$TotemStore;

abstract class _TotemStoreBase with Store {
  @observable
  PlanModel? selectedPlan;

  @action
  void setSelectedPlan(PlanModel? plan) {
    selectedPlan = plan;
  }

  @action
  void clear() {
    selectedPlan = null;
  }
}