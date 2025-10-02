import 'package:e_vendas/app/modules/totem/pages/totem_client_wizard_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_finalize_page.dart';
import 'package:e_vendas/app/modules/totem/pages/totem_select_page.dart';
import 'package:e_vendas/app/modules/totem/services/kiosk_service.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'pages/totem_home_page.dart';

class TotemModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(KioskService.new);
    i.addLazySingleton(TotemStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const TotemHomePage());
    r.child('/planos', child: (_) => const TotemSelectPlanPage());
    r.child('/cliente', child: (_) => const TotemClientWizardPage());
    r.child('/finalizar', child: (_) => const TotemFinalizePage());
  }
}