import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../stores/theme_store.dart';
import '../stores/global_store.dart';
import 'app_colors.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final String? title;
  final bool showBackButton; // NOVO

  const DashboardLayout({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = true, // default: exibe
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;

  final themeStore = Modular.get<ThemeStore>();
  final globalStore = Modular.get<GlobalStore>();

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final t = _gradientController.value;
          final color1 = Color.lerp(AppColors.primary, AppColors.whiteBlue, t)!;
          final color2 =
              Color.lerp(AppColors.secondary, AppColors.lilac, 1 - t)!;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  if (widget.title != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Botão Voltar (só mostra se habilitado)
          if (widget.showBackButton)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Modular.to.pop();
                },
              ),
            ),

          // Logo central
          Image.asset('assets/images/logo_white.png', height: 40),

          // Nome do vendedor + botão tema
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  globalStore.vendedorNome,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    themeStore.isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white,
                  ),
                  onPressed: () => themeStore.toggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}