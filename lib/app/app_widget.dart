import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'core/theme/app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'e_vendas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Usa o tema baseado no sistema (claro ou escuro)
      routerConfig: Modular.routerConfig,
    );
  } 
}