// lib/app/modules/totem/pages/totem_home_page.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:e_vendas/app/core/widgets/version_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/kiosk_service.dart';
import '../widgets/inactivity_wrapper.dart';

// Classe principal da página
class TotemHomePage extends StatefulWidget {
  const TotemHomePage({super.key});

  @override
  State<TotemHomePage> createState() => _TotemHomePageState();
}

class _TotemHomePageState extends State<TotemHomePage>
    with TickerProviderStateMixin {
  static const _kioskPin = '1234';

  // Controles de Animação
  late final AnimationController _contentInCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _sheenCtrl;
  late final AnimationController _floatCtrl; // Animação de flutuação

  // Acessibilidade
  double _textScale = 1.0;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    KioskService.enterKioskLandscape();
    _setupAnimations();
  }

  void _setupAnimations() {
    _contentInCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _sheenCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6),)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _contentInCtrl.dispose();
    _pulseCtrl.dispose();
    _sheenCtrl.dispose();
    _floatCtrl.dispose();
    KioskService.exitKiosk();
    super.dispose();
  }

  // ... (O restante dos seus métodos como _askExitPin, _openAccessibilitySheet, etc. permanecem os mesmos)
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
      Modular.to.navigate('/');
    }
  }

  void _increaseText() => setState(() => _textScale = (_textScale + 0.1).clamp(1.0, 1.8));
  void _decreaseText() => setState(() => _textScale = (_textScale - 0.1).clamp(1.0, 1.8));
  void _toggleContrast(bool v) => setState(() => _highContrast = v);

  void _openAccessibilitySheet() {
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
                const Icon(Icons.accessibility_new_rounded),
                const SizedBox(width: 8),
                Text('Acessibilidade', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                FilledButton.tonal(onPressed: _decreaseText, child: const Text('A-')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _increaseText, child: const Text('A+')),
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
          ],
        ),
      ),
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
                await SystemSound.play(SystemSoundType.alert);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atendente foi acionado.')),
                  );
                }
              },
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Chamar atendente'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final baseMQ = MediaQuery.of(context);
    final scaledMQ = baseMQ.copyWith(textScaleFactor: (baseMQ.textScaleFactor * _textScale).clamp(1.0, 1.8));
    final cs = Theme.of(context).colorScheme;

    // Animação de flutuação para o card
    final floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
    final floatOffset = Tween<Offset>(begin: const Offset(0, -0.005), end: const Offset(0, 0.005)).animate(floatAnim);
    
    // Animação de entrada com perspectiva
    final entryAnim = CurvedAnimation(parent: _contentInCtrl, curve: Curves.easeOutCubic);
    final perspective = Tween<double>(begin: -0.4, end: 0.0).animate(entryAnim);
    final titleAnim = CurvedAnimation(parent: _contentInCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic));

    return MediaQuery(
      data: scaledMQ,
      child: WillPopScope(
        onWillPop: () async => false,
        child: GestureDetector(
          onLongPress: _askExitPin,
          child: Scaffold(
            backgroundColor: cs.background,
            body: SafeArea(
              child: Stack(
                children: [
                  // FUNDO ANIMADO COM BLOBS
                  const Positioned.fill(child: AnimatedBlobBackground()),
        
                  // AÇÕES NO TOPO
                  Positioned(
                    right: 12,
                    top: 8,
                    child: Row(
                      children: [
                        IconButton.filledTonal(tooltip: 'Acessibilidade', onPressed: _openAccessibilitySheet, icon: const Icon(Icons.text_increase_rounded)),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(tooltip: 'Ajuda', onPressed: _openHelpSheet, icon: const Icon(Icons.help_rounded)),
                      ],
                    ),
                  ),
        
                  // BLOCO CENTRAL
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TÍTULO "CENTRAL DE VENDAS"
                        FadeTransition(
                          opacity: titleAnim,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(titleAnim),
                            child: Text(
                              'Portal de Vendas',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                                shadows: [
                                  Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                                ]
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
        
                        // CARD ANIMADO
                        SlideTransition(
                          position: floatOffset,
                          child: AnimatedBuilder(
                            animation: perspective,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(perspective.value),
                                child: child,
                              );
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700, minWidth: 450),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: _WhiteCard(
                                  highContrast: _highContrast,
                                  child: _CenterBlock(
                                    pulse: _pulseCtrl,
                                    sheen: _sheenCtrl,
                                    entryAnimation: _contentInCtrl,
                                    highContrast: _highContrast,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // ÍCONES INFERIORES
                  const Positioned(left: 16, bottom: 12, child: VersionBadge()),
                  const Positioned(right: 16, bottom: 12, child: _CornerLogo(heightFactor: 0.08)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS DE COMPOSIÇÃO ---
class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, required this.highContrast});
  final Widget child;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: highContrast ? cs.onSurface.withOpacity(0.3) : cs.onSurface.withOpacity(0.1),
              width: highContrast ? 1.5 : 1.0,
            ),
            boxShadow: highContrast ? null : [
              BoxShadow(offset: const Offset(0, 16), blurRadius: 32, color: Colors.black.withOpacity(0.1)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CenterBlock extends StatelessWidget {
  const _CenterBlock({
    required this.pulse,
    required this.sheen,
    required this.entryAnimation,
    required this.highContrast,
  });

  final AnimationController pulse;
  final AnimationController sheen;
  final Animation<double> entryAnimation;

  final bool highContrast;

  // Widget wrapper para animações de entrada escalonadas
  Widget _animWrapper(Animation<double> anim, Widget child, {double dy = 0.08}) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, dy), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;
    final mainLogoHeight = (h * 0.20).clamp(80.0, 150.0);

    // Curvas de animação para cada elemento
    final logoAnim = CurvedAnimation(parent: entryAnimation, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic));
    final subtitleAnim = CurvedAnimation(parent: entryAnimation, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic));
    final buttonAnim = CurvedAnimation(parent: entryAnimation, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic));

    // Animações contínuas
    final scale = Tween<double>(begin: 0.98, end: 1.01).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut));
    final sheenAnim = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: sheen, curve: Curves.easeInOut));
    
    final subColor = highContrast ? cs.onSurface.withOpacity(0.9) : cs.onSurface.withOpacity(0.7);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _animWrapper(
          logoAnim,
          ScaleTransition(
            scale: scale,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: mainLogoHeight),
              child: Image.asset('assets/images/logo_complete.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _animWrapper(
          subtitleAnim,
          Text(
            'Toque para iniciar sua compra.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: subColor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        _animWrapper(
          buttonAnim,
          SizedBox(
            width: double.infinity,
            child: _SheenButton(
              sheenPosition: sheenAnim.value,
              child: FilledButton(
                onPressed: () {
                  Modular.to.pushNamed('/totem/planos');
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: cs.primary,
                ),
                child: Text('Começar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onPrimary)),
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
  final double sheenPosition;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Transform.scale(
          scale: 1.1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const SizedBox(height: 60, width: double.infinity),
          ),
        ),
        // Botão + Sheen
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final sheenWidth = w * 0.3;
                      return Transform.translate(
                        offset: Offset(sheenPosition * w - (sheenWidth * 1.5), 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: sheenWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
      child: SvgPicture.asset('assets/images/logo_somoscoop_verde.svg', fit: BoxFit.contain),
    );
  }
}

// --- FUNDO ANIMADO (NOVO) ---
class AnimatedBlobBackground extends StatefulWidget {
  const AnimatedBlobBackground({super.key});

  @override
  State<AnimatedBlobBackground> createState() => _AnimatedBlobBackgroundState();
}

class _AnimatedBlobBackgroundState extends State<AnimatedBlobBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CustomPaint(
      painter: BlobPainter(
        animation: _controller,
        color: color,
      ),
      size: Size.infinite,
    );
  }
}

class BlobPainter extends CustomPainter {
  BlobPainter({required this.animation, required this.color})
      : super(repaint: animation);
  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.3);
    final t = animation.value;

    // Blob 1
    final pos1 = Offset(
      size.width * (0.2 + 0.2 * sin(t * pi * 2 + 0.5)),
      size.height * (0.3 - 0.2 * cos(t * pi * 2 + 0.5)),
    );
    final r1 = size.width * (0.35 + 0.1 * sin(t * pi * 2));
    canvas.drawCircle(pos1, r1, paint);

    // Blob 2
    final pos2 = Offset(
      size.width * (0.8 - 0.15 * sin(t * pi * 1.5 + 1.0)),
      size.height * (0.7 + 0.15 * cos(t * pi * 1.5 + 1.0)),
    );
    final r2 = size.width * (0.3 + 0.08 * cos(t * pi * 2.5));
    canvas.drawCircle(pos2, r2, paint);

    // Blob 3
    final pos3 = Offset(
      size.width * (0.6 + 0.2 * cos(t * pi * 2.2 + 2.0)),
      size.height * (0.1 + 0.1 * sin(t * pi * 2.2 + 2.0)),
    );
    final r3 = size.width * (0.25 + 0.05 * sin(t * pi * 1.8));
    canvas.drawCircle(pos3, r3, paint);

    // Adiciona um desfoque geral para o efeito "líquido"
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPaint(Paint()..color = Colors.white.withOpacity(0.01));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}