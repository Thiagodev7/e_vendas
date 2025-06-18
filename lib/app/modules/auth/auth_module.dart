import 'package:dio/dio.dart';
import 'package:e_vendas/app/app_module.dart';
import 'package:e_vendas/app/core/config/api_config.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'services/auth_service.dart';
import 'stores/auth_store.dart';
import 'login_page.dart';

class AuthModule extends Module {
  @override
  final List<Module> imports = [
    AppModule(),
  ];

  @override
  void binds(i) {
    i.addSingleton(AuthService.new);
    i.addSingleton(AuthStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const LoginPage(),
    );
  }
}
