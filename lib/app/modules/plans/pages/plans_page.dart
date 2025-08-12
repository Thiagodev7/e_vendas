import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/core/utils/plano_info.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../stores/plans_store.dart';

class PlansPage extends StatefulWidget {
  final int? vendaIndex;

  const PlansPage({super.key, this.vendaIndex});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final store = Modular.get<PlansStore>();
  final salesStore = Modular.get<SalesStore>();

  @override
  void initState() {
    super.initState();
    store.loadPlans();
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
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          final plans = store.plans;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final cardWidth = isDesktop ? 360.0 : 320.0;
              final cardHeight = constraints.maxHeight * 0.85;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: plans.length,
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
              );
            },
          );
        },
      ),
    );
  }

  /// Card do Plano
  Widget _buildHorizontalCard(PlanModel plan, int? vendaIndex) {
    // Pega quantidade de vidas selecionadas
    final vidas = store.getLives(plan.id);

    // Calcula valores multiplicando pelas vidas
    final mensal =
        (double.parse(plan.getMensalidade()) * vidas).toStringAsFixed(2);
    final adesao =
        (double.parse(plan.getTaxaAdesao()) * vidas).toStringAsFixed(2);

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

          // Valores
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueBox('Mensalidade', mensal),
                _buildValueBox('Adesão', adesao),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Cobertura:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                      child: Text(
                        beneficios[index],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  int vidas = 1;
                  if (vendaIndex != null) {
                    final venda = salesStore.vendas[vendaIndex];
                    vidas = (venda.dependentes?.length ?? 0) + 1;

                    // Atualiza plano com vidas
                    final planoComVidas =
                        plan.copyWith(vidasSelecionadas: vidas);
                    await salesStore.atualizarPlano(vendaIndex, planoComVidas);
                  } else {
                    final planoComVidas = plan.copyWith(vidasSelecionadas: 1);
                    await salesStore.criarVendaComPlano(planoComVidas);
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
          Text(
            'R\$ $valor',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
