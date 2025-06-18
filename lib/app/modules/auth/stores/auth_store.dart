import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/utils/validators.dart';
import '../../../core/models/vendedor_model.dart';
import '../../../core/stores/global_store.dart';
import '../services/auth_service.dart';
import '../../../core/config/jwt_class.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final AuthService _authService = Modular.get<AuthService>();
  final GlobalStore _globalStore = Modular.get<GlobalStore>();

  @observable
  String cpf = '';

  @observable
  String senha = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void setCpf(String value) => cpf = value;

  @action
  void setSenha(String value) => senha = value;

  @action
  Future<void> login() async {
    errorMessage = null;

    if (!Validators.isValidCPF(cpf)) {
      errorMessage = 'CPF inválido';
      return;
    }

    if (senha.isEmpty || senha.length < 4) {
      errorMessage = 'Senha muito curta';
      return;
    }

    isLoading = true;

    try {
      final key = 'hmacKey';
      final passwordEncoded = utf8.encode(senha);
      final keyEncoded = utf8.encode(key);
      final hmacSha256 = Hmac(sha256, keyEncoded);
      final digest = hmacSha256.convert(passwordEncoded);

      final token = JwtSign().getToken({
        'cpf': cpf.replaceAll('.', '').replaceAll('-', ''),
        'senha': digest.toString(),
      });

      final response = await _authService.loginReq(token);

      if (response.isSuccess) {
        final vendedor = VendedorModel.fromJson(response.data);
        _globalStore.setVendedor(vendedor);
        _clearFields();
        Modular.to.navigate('/home');
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = 'Erro inesperado: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  void _clearFields() {
    cpf = '';
    senha = '';
  }
}
