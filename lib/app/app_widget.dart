import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'core/theme/app_theme.dart';
import 'core/stores/theme_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = Modular.get<ThemeStore>();

    return Observer(
      builder: (_) => MaterialApp.router(
        title: 'e-Vendas',
        debugShowCheckedModeBanner: false,
        theme: themeStore.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        routeInformationParser: Modular.routeInformationParser,
        routerDelegate: Modular.routerDelegate,
      ),
    );
  }
}