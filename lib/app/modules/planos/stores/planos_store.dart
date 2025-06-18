import 'package:mobx/mobx.dart';
import '../../../core/models/plano_model.dart';
import '../services/planos_service.dart';

part 'planos_store.g.dart';

class PlanosStore = _PlanosStoreBase with _$PlanosStore;

abstract class _PlanosStoreBase with Store {
  final PlanosService service;

  _PlanosStoreBase(this.service);

  @observable
  ObservableList<PlanoModel> planos = ObservableList.of([]);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> getPlanos() async {
    isLoading = true;
    errorMessage = null;
    try {
      final data = await service.fetchPlanos();
      planos = ObservableList.of(data);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}