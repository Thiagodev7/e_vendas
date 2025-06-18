import 'package:e_vendas/app/app_module.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'stores/home_store.dart';
import 'home_page.dart';

class HomeModule extends Module {
  @override
  final List<Module> imports = [
    AppModule(),
  ];

  @override
  void binds(i) {
    i.addSingleton(HomeStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const HomePage(),
    );
  }
}
