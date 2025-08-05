import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/client/client_module.dart';
import 'package:e_vendas/app/modules/plans/plans_module.dart';
import 'package:e_vendas/app/modules/sales/sales_module.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/home/home_module.dart';
import 'core/stores/theme_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(ThemeStore.new);
    i.addSingleton<GlobalStore>(GlobalStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const LoginPage());
    r.module('/home', module: HomeModule());
    r.module('/plans', module: PlansModule());
    r.module('/client', module: ClientModule());
    r.module('/sales', module: SalesModule());

  }
}