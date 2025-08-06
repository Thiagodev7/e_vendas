import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../stores/theme_store.dart';
import '../stores/global_store.dart';
import 'app_colors.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final String? title;

  const DashboardLayout({
    super.key,
    required this.child,
    this.title,
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
      drawer: _buildDrawer(context),
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
                  _buildHeader(context),
                  if (widget.title != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                         // width: 48, // Espaço para manter alinhamento
                        ),
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
                        SizedBox(
                          width: 100, // Espaço para manter alinhamento
                        ),
                      ],
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

  /// Header com menu e logo
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão menu (abre drawer)
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(ctx).openDrawer();
                },
              );
            },
          ),

          // Logo clicável
          GestureDetector(
            onTap: () {
              Modular.to.navigate('/home');
            },
            child: Image.asset('assets/images/logo_white.png', height: 40),
          ),

          // Nome vendedor + tema
          Row(
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
        ],
      ),
    );
  }

  /// Drawer estilizado
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.9), AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo_white.png', height: 50),
                  const SizedBox(height: 10),
                  Text(
                    globalStore.vendedorNome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', '/home'),
            _buildDrawerItem(Icons.shopping_cart, 'Vendas', '/sales'),
            _buildDrawerItem(Icons.person, 'Clientes', '/client'),
            _buildDrawerItem(Icons.assignment, 'Planos', '/plans'),
          ],
        ),
      ),
    );
  }

  /// Item do Drawer
  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Modular.to.navigate(route);
      },
    );
  }
}