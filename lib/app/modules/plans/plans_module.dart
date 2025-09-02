import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'pages/plans_page.dart';
import 'stores/plans_store.dart';

class PlansModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(PlansStore.new);
    i.addLazySingleton(SalesStore.new);
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton(GlobalStore.new);
  }

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>?;
        return PlansPage(
          vendaIndex: args?['vendaIndex'] as int?,
        );
      },
    );
  }
}