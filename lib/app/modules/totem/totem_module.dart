// lib/app/modules/totem/totem_module.dart
import 'package:e_vendas/app/modules/finish_sale/service/contract_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/payment_service.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_client_wizard_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_finalize_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_select_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_home_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_contract_webview_page.dart';
import 'package:e_vendas/app/modules/totem/services/kiosk_service.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_payment_store.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TotemModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(KioskService.new);
    i.addLazySingleton(TotemStore.new);
    i.addLazySingleton(FinishContractStore.new);
    i.addLazySingleton(ContractService.new);
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton(TotemPaymentStore.new);
    i.addLazySingleton(PaymentService.new);
  }


  @override
  void routes(r) {
    r.child('/', child: (_) => const TotemHomePage());
    r.child('/planos', child: (_) => const TotemSelectPlanPage());
    r.child('/cliente', child: (_) => const TotemClientWizardPage());
    r.child('/finalizar', child: (_) => const TotemFinalizePage());

    // Rota para a assinatura embutida (WebView)
    r.child('/assinar-contrato', child: (_) {
      final data = Modular.args.data;
      final url =
          (data is Map && data['url'] is String) ? data['url'] as String : null;
      return TotemContractWebviewPage(url: url);
    });
  }
}
