import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../models/vendedor_model.dart';
import '../../modules/auth/services/auth_service.dart';

part 'global_store.g.dart';

class GlobalStore = _GlobalStoreBase with _$GlobalStore;

abstract class _GlobalStoreBase with Store {
  final AuthService _authService = Modular.get<AuthService>();

  @observable
  VendedorModel? vendedor;

  @observable
  bool isLoggedIn = false;

  @action
  void setVendedor(VendedorModel data) {
    vendedor = data;
    isLoggedIn = true;
  }

  @action
  Future<void> logout() async {
    vendedor = null;
    isLoggedIn = false;
    Modular.to.navigate('/auth');
  }
}