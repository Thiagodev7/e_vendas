import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app/app_module.dart';
import 'app/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init(); // Configura interceptor global
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}