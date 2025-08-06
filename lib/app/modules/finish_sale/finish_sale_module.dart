import 'package:e_vendas/app/modules/finish_sale/page/finish_sale_page.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../sales/stores/sales_store.dart';
class FinishSaleModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(FinishSaleStore.new);
    i.addLazySingleton(SalesStore.new);
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