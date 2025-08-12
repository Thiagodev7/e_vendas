import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/finish_sale/page/finish_sale_page.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
class FinishSaleModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(FinishSaleStore.new);
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton<SalesStore>(
      () => SalesStore(i.get<SalesService>(), i.get<GlobalStore>()),
    );
  }

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>?;
        final vendaIndex = args?['vendaIndex'] as int?;
        return FinishSalePage(vendaIndex: vendaIndex);
      },
    );
  }
}