import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_config.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'services/auth_service.dart';
import 'stores/auth_store.dart';
import 'login_page.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(AuthService.new);
  i.addSingleton(AuthStore.new);
  // ✅ Registra Dio com BaseOptions embutido
    i.addSingleton(() => Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: ApiConfig.defaultHeaders,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ));
  }
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const LoginPage(),
    );
  }
}