import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/auth/services/auth_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'modules/auth/auth_module.dart';
import 'modules/home/home_module.dart';
import 'modules/home/stores/home_store.dart';
import 'modules/auth/stores/auth_store.dart';
import 'core/config/api_config.dart';
import 'core/pages/splash_page.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    // ✅ Registra Dio com BaseOptions embutido
    i.addSingleton(() => Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: ApiConfig.defaultHeaders,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ));

    // ✅ Serviços
    i.addSingleton(AuthService.new);

    // ✅ Stores
    i.addSingleton(GlobalStore.new);
    i.addSingleton(HomeStore.new);
    i.addSingleton(AuthStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const SplashPage());
    r.module('/auth', module: AuthModule());
    r.module('/home', module: HomeModule());
  }
}