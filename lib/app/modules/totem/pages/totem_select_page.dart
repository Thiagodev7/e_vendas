// lib/app/modules/totem/modules/plans/pages/totem_plans_page.dart (ou o nome que você deu ao arquivo)
import 'package:e_vendas/app/core/utils/plano_info.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/modules/plans/services/plans_service.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'dart:ui';
import 'dart:math';

// Habilita arrastar com o mouse na PageView
class _DesktopDragBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class TotemSelectPlanPage extends StatefulWidget {
  const TotemSelectPlanPage({super.key});

  @override
  State<TotemSelectPlanPage> createState() => _TotemSelectPlanPageState();
}

class _TotemSelectPlanPageState extends State<TotemSelectPlanPage>
    with TickerProviderStateMixin {
  final _service = PlansService();
  final _totem = Modular.get<TotemStore>();

  late Future<List<PlanModel>> _future;
  late final AnimationController _animationCtrl;
  late final AnimationController _auroraCtrl; // <--- Controlador para o título animado
  final _pageCtrl = PageController(viewportFraction: 0.82);

  // Controle de estado local
  int? _selectedPlanId;
  final Map<int, bool> _isAnnualMap = {}; // planId -> isAnnual

  @override
  void initState() {
    super.initState();
    _future = _service.fetchPlans();
    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    // Inicializa o controlador da animação do título
    _auroraCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    if (_totem.selectedPlan != null) {
      _selectedPlanId = _totem.selectedPlan!.id;
      _isAnnualMap[_selectedPlanId!] = _totem.selectedPlan!.isAnnual;
    }
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    _auroraCtrl.dispose(); // <--- Dispose do controlador
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onSelect(PlanModel plan) {
    setState(() {
      _selectedPlanId = plan.id;
      _isAnnualMap.putIfAbsent(plan.id, () => false);
    });
  }

  void _onToggleAnnual(int planId, bool isAnnual) {
    setState(() {
      _isAnnualMap[planId] = isAnnual;
      _selectedPlanId = planId;
    });
  }

  void _onContinue() {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um plano para continuar.')),
      );
      return;
    }
    _future.then((plans) {
      final selectedPlan = plans.firstWhere((p) => p.id == _selectedPlanId);
      final isAnnual = _isAnnualMap[_selectedPlanId] ?? false;
      
      final finalPlan = selectedPlan.copyWith(isAnnual: isAnnual);
      _totem.setSelectedPlan(finalPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${finalPlan.nomeContrato} selecionado!')),
      );
      Modular.to.pushNamed('/totem/cliente');
    });
  }

  void _showInfoSheet(BuildContext context, PlanModel plan) {
    final info = PlanoInfo.getInfo(plan.nomeContrato);
    final beneficios = info
        .split('\n')
        .where((line) => line.startsWith('☑️'))
        .toList();
    
    final observacao = info.contains('\n\n') ? info.split('\n\n').last : null;


    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.nomeContrato,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: beneficios.length,
                    itemBuilder: (context, index) => _BenefitItem(text: beneficios[index].replaceFirst('☑️ ', '')),
                  ),
                ),
                if (observacao != null) ...[
                  const Divider(height: 32),
                  Text(
                    'Observação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(observacao),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBlobBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  // *** TÍTULO ATUALIZADO AQUI ***
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _AuroraText(
                      text: 'Escolha o Melhor Plano Para Você',
                      animation: _auroraCtrl,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<PlanModel>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return _ErrorView(
                          error: snap.error.toString(),
                          onRetry: () => setState(() => _future = _service.fetchPlans()),
                        );
                      }
                      final plans = snap.data ?? [];
                      if (plans.isEmpty) return const Center(child: Text('Nenhum plano disponível.'));

                      return ScrollConfiguration(
                        behavior: _DesktopDragBehavior(),
                        child: PageView.builder(
                          controller: _pageCtrl,
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            final plan = plans[index];
                            final isSelected = plan.id == _selectedPlanId;
                            final isAnnual = _isAnnualMap[plan.id] ?? false;
                            
                            final cardAnimation = CurvedAnimation(
                              parent: _animationCtrl,
                              curve: Interval(
                                (0.1 * index).clamp(0.0, 1.0),
                                (0.5 + 0.1 * index).clamp(0.0, 1.0),
                                curve: Curves.easeOutCubic,
                              ),
                            );

                            return FadeTransition(
                              opacity: cardAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(cardAnimation),
                                child: _PlanCard(
                                  plan: plan,
                                  isSelected: isSelected,
                                  isAnnual: isAnnual,
                                  onSelect: () => _onSelect(plan),
                                  onCycleChanged: (annual) => _onToggleAnnual(plan.id, annual),
                                  onInfoTap: () => _showInfoSheet(context, plan),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => Modular.to.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                onPressed: _onContinue,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Continuar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DO TÍTULO COM EFEITO AURORA (ADICIONADO) ---
class _AuroraText extends AnimatedWidget {
  const _AuroraText({
    required this.text,
    required Animation<double> animation,
    this.style,
  }) : super(listenable: animation);

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final animation = listenable as Animation<double>;

    final baseStyle = (style ?? DefaultTextStyle.of(context).style).copyWith(color: Colors.white);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        final angle = animation.value * 2 * pi;

        return SweepGradient(
          center: FractionalOffset.center,
          colors: [
            cs.primary,
            cs.secondary,
            cs.tertiary ?? cs.primary,
            cs.primary,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
          transform: GradientRotation(angle),
        ).createShader(bounds);
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: baseStyle,
      ),
    );
  }
}

// ================== CARD DO PLANO (AJUSTADO) ==================

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isAnnual,
    required this.onSelect,
    required this.onCycleChanged,
    required this.onInfoTap,
  });

  final PlanModel plan;
  final bool isSelected;
  final bool isAnnual;
  final VoidCallback onSelect;
  final ValueChanged<bool> onCycleChanged;
  final VoidCallback onInfoTap;
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mensal = _parseMoney(plan.getMensalidade());
    final anual = mensal * 12 * 0.90;
    final adesao = _parseMoney(plan.getTaxaAdesao());

    final cobertura = PlanoInfo.getInfo(plan.nomeContrato);
    final beneficios = cobertura
        .split('\n')
        .where((line) => line.startsWith('☑️'))
        .map((line) => line.replaceFirst('☑️ ', ''))
        .toList();

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.12 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: cs.surface.withOpacity(0.85),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CardHeader(title: plan.nomeContrato, adesao: adesao),
                    _CycleSelector(isAnnual: isAnnual, onChanged: onCycleChanged),
                    _PriceDisplay(isAnnual: isAnnual, mensal: mensal, anual: anual),
                    const Divider(height: 24, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Principais Coberturas', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: beneficios.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) => _BenefitItem(text: beneficios[index]),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: onInfoTap, 
                        child: const Text('Ver cobertura completa')
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FilledButton(
                        onPressed: onSelect,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isSelected ? cs.primary : cs.primaryContainer,
                          foregroundColor: isSelected ? cs.onPrimary : cs.onPrimaryContainer,
                        ),
                        child: Text(
                          isSelected ? 'Plano Selecionado' : 'Escolher Este Plano',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ... O restante do código (Widgets de Suporte, Fundo Animado, etc.) permanece o mesmo.

// ================== WIDGETS DE SUPORTE ==================
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.adesao});
  final String title;
  final double adesao;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Taxa de Adesão: R\$ ${adesao.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _CycleSelector extends StatelessWidget {
  const _CycleSelector({required this.isAnnual, required this.onChanged});
  final bool isAnnual;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: _CycleButton(
                  label: 'Mensal',
                  isSelected: !isAnnual,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _CycleButton(
                  label: 'Anual (-10%)',
                  isSelected: isAnnual,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleButton extends StatelessWidget {
  const _CycleButton({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  const _PriceDisplay({required this.isAnnual, required this.mensal, required this.anual});
  final bool isAnnual;
  final double mensal;
  final double anual;
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: isAnnual
            ? _PriceText(
                key: const ValueKey('anual'),
                price: anual.toStringAsFixed(2),
                period: '/ano',
                subtitle: 'Economize 10% no plano anual!',
              )
            : _PriceText(
                key: const ValueKey('mensal'),
                price: mensal.toStringAsFixed(2),
                period: '/mês',
              ),
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText({super.key, required this.price, required this.period, this.subtitle});
  final String price;
  final String period;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ $price',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: cs.primary),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8),
              child: Text(period, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w500),
          )
        ]
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Ops! Algo deu errado', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Não foi possível carregar os planos. Verifique sua conexão e tente novamente.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry, 
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente')
            ),
          ],
        ),
      ),
    );
  }
}

// ================== FUNDO ANIMADO E HELPERS ==================

class AnimatedBlobBackground extends StatefulWidget {
  const AnimatedBlobBackground({super.key});
  @override
  State<AnimatedBlobBackground> createState() => _AnimatedBlobBackgroundState();
}

class _AnimatedBlobBackgroundState extends State<AnimatedBlobBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 30), vsync: this)..repeat(reverse: true);
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
      painter: BlobPainter(animation: _controller, color: color),
      size: Size.infinite,
    );
  }
}

class BlobPainter extends CustomPainter {
  BlobPainter({required this.animation, required this.color}) : super(repaint: animation);
  final Animation<double> animation;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.2);
    final t = animation.value;
    final pos1 = Offset(size.width * (0.2 + 0.2 * sin(t * pi * 2 + 0.5)), size.height * (0.3 - 0.2 * cos(t * pi * 2 + 0.5)));
    final r1 = size.width * (0.35 + 0.1 * sin(t * pi * 2));
    canvas.drawCircle(pos1, r1, paint);
    final pos2 = Offset(size.width * (0.8 - 0.15 * sin(t * pi * 1.5 + 1.0)), size.height * (0.7 + 0.15 * cos(t * pi * 1.5 + 1.0)));
    final r2 = size.width * (0.3 + 0.08 * cos(t * pi * 2.5));
    canvas.drawCircle(pos2, r2, paint);
    final pos3 = Offset(size.width * (0.6 + 0.2 * cos(t * pi * 2.2 + 2.0)), size.height * (0.1 + 0.1 * sin(t * pi * 2.2 + 2.0)));
    final r3 = size.width * (0.25 + 0.05 * sin(t * pi * 1.8));
    canvas.drawCircle(pos3, r3, paint);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPaint(Paint()..color = Colors.white.withOpacity(0.01));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double _parseMoney(String? s) {
  if (s == null) return 0.0;
  final raw = s.trim();
  if (raw.isEmpty) return 0.0;
  if (RegExp(r'^\d+$').hasMatch(raw)) {
    final cents = int.tryParse(raw) ?? 0;
    return (cents / 100).toDouble();
  }
  var cleaned = raw.replaceAll(RegExp(r'[^\d,\.]'), '');
  final lastComma = cleaned.lastIndexOf(',');
  final lastDot = cleaned.lastIndexOf('.');
  if (lastComma > lastDot) {
    cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
  } else {
    cleaned = cleaned.replaceAll(',', '');
  }
  var value = double.tryParse(cleaned) ?? 0.0;
  if (value >= 1000) {
    final divided = value / 100.0;
    if (divided < 1000) value = divided;
  }
  return double.parse(value.toStringAsFixed(2));
}