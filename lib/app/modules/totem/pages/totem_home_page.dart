// lib/app/modules/totem/pages/totem_home_page.dart
import 'dart:async';
import 'dart:math';
import 'package:e_vendas/app/core/widgets/version_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/kiosk_service.dart';
import '../widgets/inactivity_wrapper.dart';

class TotemHomePage extends StatefulWidget {
  const TotemHomePage({super.key});

  @override
  State<TotemHomePage> createState() => _TotemHomePageState();
}

class _TotemHomePageState extends State<TotemHomePage>
    with TickerProviderStateMixin {
  static const _kioskPin = '1234';

  // Controls
  late final AnimationController _bgCtrl;     // partículas
  late final AnimationController _logoInCtrl; // entrada do conteúdo
  late final AnimationController _pulseCtrl;  // “breathing” logo
  late final AnimationController _sheenCtrl;  // brilho (sheen) botão

  final _rng = Random();
  late final List<_Particle> _particles;

  // Acessibilidade
  double _textScale = 1.0;        // 1.0 .. 1.8
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    KioskService.enterKioskLandscape(); // horizontal + tela ligada + imersivo

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _logoInCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _sheenCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _particles = List.generate(10, (i) {
      return _Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: _rng.nextDouble() * 12 + 8, // 8..20
        phase: _rng.nextDouble() * pi * 2,
        speed: 0.004 + _rng.nextDouble() * 0.008,
        opacity: 0.025 + _rng.nextDouble() * 0.025, // 2.5%..5%
      );
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoInCtrl.dispose();
    _pulseCtrl.dispose();
    _sheenCtrl.dispose();
    KioskService.exitKiosk();
    super.dispose();
  }

  Future<void> _askExitPin() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do modo Tótem'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN'),
          autofocus: true,
          onSubmitted: (_) => Navigator.of(context).pop(ctrl.text == _kioskPin),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(ctrl.text == _kioskPin), child: const Text('Confirmar')),
        ],
      ),
    );

    if (ok == true && mounted) {
      Modular.to.navigate('/'); // volta pro login
    }
  }

  void _increaseText() => setState(() => _textScale = (_textScale + 0.1).clamp(1.0, 1.8));
  void _decreaseText() => setState(() => _textScale = (_textScale - 0.1).clamp(1.0, 1.8));
  void _toggleContrast(bool v) => setState(() => _highContrast = v);

  void _openAccessibilitySheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.accessibility_new_rounded),
                  const SizedBox(width: 8),
                  Text('Acessibilidade', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: _decreaseText,
                    child: const Text('A-'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _increaseText,
                    child: const Text('A+'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Tamanho do texto'),
                  Expanded(
                    child: Slider(
                      value: _textScale,
                      min: 1.0,
                      max: 1.8,
                      divisions: 8,
                      label: _textScale.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _textScale = v),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alto contraste'),
                subtitle: const Text('Melhora leitura com bordas e cores mais fortes.'),
                value: _highContrast,
                onChanged: _toggleContrast,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openHelpSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.help_center_rounded),
                const SizedBox(width: 8),
                Text('Ajuda', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.touch_app_rounded),
              title: Text('Toque em “Começar” para iniciar sua compra.'),
            ),
            const ListTile(
              leading: Icon(Icons.zoom_in_rounded),
              title: Text('Use o botão de Acessibilidade para aumentar as letras.'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                await SystemSound.play(SystemSoundType.alert); // feedback rápido
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atendente foi acionado.')),
                  );
                }
              },
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Chamar atendente'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseMQ = MediaQuery.of(context);
    final cs = Theme.of(context).colorScheme;

    // Aplica escala de texto global nesta página
    final scaledMQ = baseMQ.copyWith(
      textScaleFactor: (baseMQ.textScaleFactor * _textScale).clamp(1.0, 1.8),
    );

    return MediaQuery(
      data: scaledMQ,
      child: WillPopScope(
        onWillPop: () async => false,
        child: InactivityWrapper(
          timeout: const Duration(minutes: 3),
          onTimeout: () => Modular.to.navigate('/'),
          child: GestureDetector(
            onLongPress: _askExitPin,
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (context, _) {
                final bgColor = cs.background; // branco
                final particleColor = _highContrast ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.035);

                return Scaffold(
                  backgroundColor: bgColor,
                  body: SafeArea(
                    child: Stack(
                      children: [
                        // FUNDO: partículas discretas
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final w = box.maxWidth;
                              final h = box.maxHeight;
                              return Stack(
                                children: _particles.map((p) {
                                  final t = _bgCtrl.value * 2 * pi;
                                  final dx = (p.x + sin(t * p.speed + p.phase) * 0.015) * w;
                                  final dy = (p.y + cos(t * p.speed + p.phase) * 0.015) * h;
                                  return Positioned(
                                    left: dx,
                                    top: dy,
                                    child: Container(
                                      width: p.r,
                                      height: p.r,
                                      decoration: BoxDecoration(
                                        color: particleColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: p.r * 0.9,
                                            spreadRadius: 0.4,
                                            color: particleColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // LOGO COOPS (SVG) — topo esquerdo
                        const Positioned(
                          left: 16,
                          top: 12,
                          child: _CornerLogo(heightFactor: 0.08),
                        ),

                        // AÇÕES — topo direito: Acessibilidade e Ajuda
                        Positioned(
                          right: 12,
                          top: 8,
                          child: Row(
                            children: [
                              IconButton.filledTonal(
                                tooltip: 'Acessibilidade',
                                onPressed: _openAccessibilitySheet,
                                icon: const Icon(Icons.text_increase_rounded),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                tooltip: 'Ajuda',
                                onPressed: _openHelpSheet,
                                icon: const Icon(Icons.help_rounded),
                              ),
                            ],
                          ),
                        ),

                        // BLOCO CENTRAL
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 900,
                              minWidth: 560,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: FadeTransition(
                                opacity: CurvedAnimation(parent: _logoInCtrl, curve: Curves.easeOut),
                                child: SlideTransition(
                                  position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                                      .animate(CurvedAnimation(parent: _logoInCtrl, curve: Curves.easeOutCubic)),
                                  child: _WhiteCard(
                                    highContrast: _highContrast,
                                    child: _CenterBlock(
                                      pulse: _pulseCtrl,
                                      sheen: _sheenCtrl,
                                      highContrast: _highContrast,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Positioned(right: 12, bottom: 12, child: VersionBadge()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, required this.highContrast});
  final Widget child;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highContrast ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.06),
          width: highContrast ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(offset: const Offset(0, 14), blurRadius: 28, color: Colors.black.withOpacity(highContrast ? 0.10 : 0.06)),
          BoxShadow(offset: const Offset(0, 4), blurRadius: 10, color: Colors.black.withOpacity(highContrast ? 0.08 : 0.04)),
        ],
      ),
      child: child,
    );
  }
}

class _CenterBlock extends StatelessWidget {
  const _CenterBlock({
    required this.pulse,
    required this.sheen,
    required this.highContrast,
  });

  final AnimationController pulse;
  final AnimationController sheen;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;
    final mainLogoHeight = (h * 0.20).clamp(80.0, 150.0);

    // breathing ~1.5%
    final scale = Tween<double>(begin: 0.985, end: 1.0).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut));

    // sheen no botão
    final sheenAnim = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: sheen, curve: Curves.easeInOut));

    final titleColor = highContrast ? Colors.black : Colors.black.withOpacity(0.88);
    final subColor = highContrast ? Colors.black : Colors.black.withOpacity(0.68);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: scale,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mainLogoHeight),
            child: Image.asset(
              'assets/images/logo_complete.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Central de Vendas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        Opacity(
          opacity: 0.95,
          child: Text(
            'Toque para iniciar sua compra.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: subColor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),

        // Botão principal (glow + sheen)
        SizedBox(
          width: double.infinity,
          child: _SheenButton(
            sheenPosition: sheenAnim.value,
            child: FilledButton(
              onPressed: () {
                // TODO: Modular.to.pushNamed('/totem/selecionar-plano');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fluxo de compra: implemente aqui o 1º passo.')),
                );
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(56)),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                elevation: MaterialStateProperty.all(0),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  final base = cs.primary;
                  return highContrast ? base : base;
                }),
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return cs.onPrimary.withOpacity(0.08);
                  }
                  return null;
                }),
              ),
              child: Text(
                'Começar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheenButton extends StatelessWidget {
  const _SheenButton({required this.child, required this.sheenPosition});
  final Widget child;
  final double sheenPosition; // -1.0 .. 2.0

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Glow atrás do botão
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 28,
                    spreadRadius: 1,
                    color: cs.primary.withOpacity(0.18),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Próprio botão + overlay do "sheen"
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              child,

              // Camada de brilho
              IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final sheenWidth = w * 0.28; // ~28% da largura

                    return Transform.translate(
                      offset: Offset(sheenPosition * w, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: sheenWidth,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerLogo extends StatelessWidget {
  const _CornerLogo({required this.heightFactor});
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final coopsLogoHeight = (h * heightFactor).clamp(28.0, 64.0);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: coopsLogoHeight),
      child: SvgPicture.asset(
        'assets/images/logo_somoscoop_verde.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.phase,
    required this.speed,
    required this.opacity,
  });

  final double x;       // 0..1
  final double y;       // 0..1
  final double r;       // raio
  final double phase;   // fase inicial
  final double speed;   // velocidade (0.004..0.012)
  final double opacity; // 0.025..0.05
}