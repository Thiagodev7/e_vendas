// lib/app/modules/plans/ui/plans_page.dart
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/core/utils/plano_info.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/gestures.dart'; // <- ADIÇÃO
import '../stores/plans_store.dart';

// Habilita arrastar com o mouse (sem mudar visual)
class _DesktopDragBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class PlansPage extends StatefulWidget {
  final int? vendaIndex;

  const PlansPage({super.key, this.vendaIndex});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final store = Modular.get<PlansStore>();
  final salesStore = Modular.get<SalesStore>();

  // <- ADIÇÃO: controlador para rolar horizontalmente
  late final ScrollController _hCtrl;

  @override
  void initState() {
    super.initState();
    _hCtrl = ScrollController();
    store.loadPlans();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Modular.args.data as Map<String, dynamic>?;
    final vendaIndex = widget.vendaIndex ?? args?['vendaIndex'];

    return DashboardLayout(
      title: 'Escolha seu Plano Odontológico',
      child: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = store.plans;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final cardWidth = isDesktop ? 360.0 : 320.0;
              final cardHeight = constraints.maxHeight * 0.85;

              // <- ENVOLVE a lista com ScrollConfiguration + Listener
              return ScrollConfiguration(
                behavior: _DesktopDragBehavior(),
                child: Listener(
                  onPointerSignal: (signal) {
                    // Mapeia a rodinha do mouse (vertical) para o scroll horizontal
                    if (signal is PointerScrollEvent && _hCtrl.hasClients) {
                      // Usa dy (rodinha) e também dx (trackpad horizontal), priorizando quem tiver maior intensidade
                      final delta = signal.scrollDelta;
                      final move = (delta.dx.abs() > delta.dy.abs())
                          ? delta.dx
                          : delta.dy; // se o usuário estiver rolando “pra cima/baixo” com o mouse, usamos dy

                      final target = (_hCtrl.offset + move).clamp(
                        0.0,
                        _hCtrl.position.maxScrollExtent,
                      );
                      // uso de jumpTo evita “briga” com o scroll vertical do pai
                      _hCtrl.jumpTo(target);
                    }
                  },
                  child: ListView.builder(
                    controller: _hCtrl, // <- controlador
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: plans.length,
                    physics:
                        const ClampingScrollPhysics(), // desktop-like, sem bounce
                    itemBuilder: (context, index) {
                      return Observer(
                        builder: (_) {
                          final plan = plans[index];
                          return Container(
                            width: cardWidth,
                            height: cardHeight,
                            margin: EdgeInsets.only(
                                right: index == plans.length - 1 ? 0 : 20),
                            child: _buildHorizontalCard(plan, vendaIndex),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Card do Plano
  Widget _buildHorizontalCard(PlanModel plan, int? vendaIndex) {
    final vidas = store.getLives(plan.id);
    final isAnnual = store.getIsAnnual(plan.id);
    final isMensal = !isAnnual;

    // Cálculos com parser robusto (aceita "4300" como 43,00)
    final mensalUnit = _parseMoney(plan.getMensalidade());
    final adesaoUnit = _parseMoney(plan.getTaxaAdesao());
    final mensalDouble = mensalUnit * vidas;
    final adesaoDouble = adesaoUnit * vidas;

    final mensal = mensalDouble.toStringAsFixed(2);
    // Anual com 10% de desconto
    final anual = (mensalDouble * 12 * 0.90).toStringAsFixed(2);
    final adesao = adesaoDouble.toStringAsFixed(2);

    final cobertura = PlanoInfo.getInfo(plan.nomeContrato);
    final beneficios = cobertura
        .split('\n')
        .where((line) => line.startsWith('☑️'))
        .map((line) => line.replaceFirst('☑️ ', ''))
        .toList();

    return Container(
      width: 340,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(
              plan.nomeContrato,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Seletor de vidas
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Vidas:', style: TextStyle(fontSize: 14)),
                Row(
                  children: [1, 2, 3, 4].map((v) {
                    final isSelected = v == vidas;
                    return GestureDetector(
                      onTap: () => store.setLives(plan.id, v),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.primary : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$v',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Seletor ciclo de cobrança (Mensal x Anual)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cobrança:', style: TextStyle(fontSize: 14)),
                Wrap(
                  spacing: 8,
                  children: [
                    _choice(
                      label: 'Mensal',
                      selected: isMensal,
                      onTap: () => store.setAnnual(plan.id, false),
                    ),
                    _choice(
                      label: 'Anual (-10%)',
                      selected: isAnnual,
                      onTap: () => store.setAnnual(plan.id, true),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dia de vencimento (apenas quando Mensal) — APENAS Dropdown
          if (isMensal)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  const Text('Dia de vencimento:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: store.getDueDay(plan.id),
                    items: List.generate(28, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('Dia $d')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) store.setDueDay(plan.id, v);
                    },
                  ),
                ],
              ),
            ),

          // Valores (rótulo muda conforme ciclo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueBox(isMensal ? 'Mensalidade' : 'Anual (-10%)',
                    isMensal ? mensal : anual),
                _buildValueBox('Adesão', adesao),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Cobertura:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // Lista de benefícios
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: beneficios.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(beneficios[index],
                            style: const TextStyle(fontSize: 13))),
                  ],
                );
              },
            ),
          ),

          // Botão Selecionar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  // vidas conforme venda (se edição) ou 1 (se nova)
                  int vidas = 1;
                  if (vendaIndex != null) {
                    final venda = salesStore.vendas[vendaIndex];
                    vidas = (venda.dependentes?.length ?? 0) + 1;
                  }

                  final selectedAnnual = store.getIsAnnual(plan.id);
                  final selectedDue =
                      selectedAnnual ? null : store.getDueDay(plan.id);

                  final planoSelecionado = plan.copyWith(
                    vidasSelecionadas: vidas,
                    isAnnual: selectedAnnual,
                    dueDay: selectedDue,
                  );

                  if (vendaIndex != null) {
                    await salesStore.atualizarPlano(
                        vendaIndex, planoSelecionado);
                  } else {
                    await salesStore.criarVendaComPlano(planoSelecionado);
                  }

                  Modular.to.navigate('/sales');
                },
                child: const Text(
                  'Selecionar Plano',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _choice(
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildValueBox(String label, String valor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text('R\$ $valor',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Parser de valores monetários (aceita “43,00”, “43.00”, “4300” como centavos)
  double _parseMoney(String? s) {
    if (s == null) return 0.0;
    final raw = s.trim();
    if (raw.isEmpty) return 0.0;

    // só dígitos => trata como centavos
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

    // Heurística anti “100x”
    if (value >= 1000) {
      final divided = value / 100.0;
      if (divided < 1000) value = divided;
    }
    return double.parse(value.toStringAsFixed(2));
  }
} 