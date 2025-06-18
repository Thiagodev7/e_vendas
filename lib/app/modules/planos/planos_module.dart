import 'package:e_vendas/app/app_module.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'planos_page.dart';
import 'stores/planos_store.dart';
import 'services/planos_service.dart';

class PlanosModule extends Module {
  @override
  final List<Module> imports = [
    AppModule(),
  ];

  @override
  void binds(i) {
    i.addSingleton(PlanosService.new);
    i.addSingleton(PlanosStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const PlanosPage());
  }
}
