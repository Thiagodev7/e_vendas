import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/stores/theme_store.dart';
import '../stores/login_store.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final store = LoginStore();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _logoController;
  late AnimationController _fieldsController;
  late AnimationController _gradientController;

  // Partículas
  final List<Offset> _particles = List.generate(
    15,
    (_) => Offset(
      Random().nextDouble(),
      Random().nextDouble(),
    ),
  );

  @override
  void initState() {
    super.initState();

    // Logo scale/fade
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Campos fade/slide
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Gradiente animado
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fieldsController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final themeStore = Modular.get<ThemeStore>();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final t = _gradientController.value;
          final color1 = Color.lerp(AppColors.primary, AppColors.secondary, t)!;
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
            child: Stack(
              children: [
                // Partículas animadas
                ..._particles.map((p) {
                  final dx = (p.dx * MediaQuery.of(context).size.width +
                      sin(DateTime.now().millisecondsSinceEpoch / 500) * 20);
                  final dy = (p.dy * MediaQuery.of(context).size.height +
                      cos(DateTime.now().millisecondsSinceEpoch / 500) * 20);
                  return Positioned(
                    left: dx,
                    top: dy,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),

                // Conteúdo principal
                Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _logoController,
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _logoController,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          width: isDesktop ? 420 : double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo
                              Center(
                                child: Image.asset(
                                  'assets/images/logo_complete.png',
                                  height: 90,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Bem-vindo ao e-Vendas',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Campos com animação slide/fade
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(_fieldsController),
                                child: FadeTransition(
                                  opacity: _fieldsController,
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        label: 'Usuário',
                                        controller: usernameController,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        label: 'Senha',
                                        controller: passwordController,
                                        obscure: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Botão de login animado
                              Observer(
                                builder: (_) => CustomButton(
                                  text: 'Entrar',
                                  isLoading: store.isLoading,
                                  onPressed: () async {
                                    store.setUsername(usernameController.text);
                                    store.setPassword(passwordController.text);
                                    final success = await store.login();
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Login realizado!')),
                                      );
                                      if (success && mounted) {
                                        Modular.to.navigate('/home/');
                                      }
                                    } else if (store.errorMessage != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(store.errorMessage!)),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextButton(
                                onPressed: () {},
                                child: const Text('Esqueceu a senha?'),
                              ),
                              const SizedBox(height: 16),

                              Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(
                                    themeStore.isDark
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                  ),
                                  onPressed: () => themeStore.toggleTheme(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
