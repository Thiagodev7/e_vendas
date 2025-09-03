import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'pages/sales_page.dart';
import 'stores/sales_store.dart';

class SalesModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton(SalesStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const SalesPage());
  }
}