import 'package:mobx/mobx.dart';
import '../../auth/services/auth_service.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  final AuthService authService = AuthService();

  @observable
  Map<String, dynamic>? vendedorData;

  @observable
  bool isLoading = false;

  @action
  Future<void> loadVendedor() async {
    isLoading = true;
    vendedorData = await authService.getVendedorByCpf();
    isLoading = false;
  }
}