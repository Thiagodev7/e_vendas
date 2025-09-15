import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'pages/home_page.dart';
import 'stores/home_store.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(HomeStore.new);
    i.addLazySingleton(SalesService.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const HomePage());
  }
}