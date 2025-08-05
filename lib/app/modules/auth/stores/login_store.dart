import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:mobx/mobx.dart';
import '../services/auth_service.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStoreBase with _$LoginStore;

abstract class _LoginStoreBase with Store {
  final AuthService authService = AuthService();
  final GlobalStore globalStore = Modular.get<GlobalStore>(); // Injetando global

  @observable
  String username = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Map<String, dynamic>? vendedorData;

  @action
  void setUsername(String value) => username = value;

  @action
  void setPassword(String value) => password = value;

  @action
  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;

    final success = await authService.login(username, password);

    if (success) {
      // Busca dados do vendedor
      vendedorData = await authService.getVendedorByCpf();

      if (vendedorData != null) {
        // Salva no GlobalStore
        globalStore.setVendedor(vendedorData!);
      }
    }

    isLoading = false;

    if (!success || vendedorData == null) {
      errorMessage = 'CPF ou senha inválidos ou vendedor não encontrado';
      return false;
    }

    return true;
  }
}