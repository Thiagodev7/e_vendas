import 'package:flutter_modular/flutter_modular.dart';
import 'pages/home_page.dart';
import 'stores/home_store.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(HomeStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const HomePage());
  }
}