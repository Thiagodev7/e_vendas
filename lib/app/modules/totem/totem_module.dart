import 'package:e_vendas/app/modules/totem/services/kiosk_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'pages/totem_home_page.dart';

class TotemModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(KioskService.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const TotemHomePage());
  }
}