import 'package:e_vendas/app/modules/client/pages/client_form_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'stores/client_store.dart';

class ClientModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(ClientStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const ClientFormPage());
  }
}