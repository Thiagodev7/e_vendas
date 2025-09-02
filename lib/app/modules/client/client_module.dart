import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/client/pages/client_form_page.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'stores/client_store.dart';

class ClientModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(ClientStore.new);
    i.addLazySingleton(SalesStore.new);
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton(GlobalStore.new);
  }

@override
void routes(r) {
  r.child('/', child: (context) {
    final args = r.args.data as Map<String, dynamic>?;

    return ClientFormPage(
      vendaIndex: args?['index'] as int?,
      selectedPlan: args?['selectedPlan'] as PlanModel?,
    );
  });
}
}