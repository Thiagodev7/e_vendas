import 'package:e_vendas/app/modules/home/widgets/recent_sales_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/dashboard_layout.dart';
import '../../../core/utils/responsive_helper.dart';
import '../stores/home_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = Modular.get<HomeStore>();

  @override
  void initState() {
    super.initState();
    store.loadVendedor();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final vendedorNome =
            store.vendedorData?['nome_completo'] ?? 'Carregando...';

        return DashboardLayout(
          title: 'Portal de Vendas',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActionButtons(context),
                const SizedBox(height: 24),
                Expanded(
                  child: ResponsiveHelper.isDesktop(context)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildMetricsGrid()),
                            const SizedBox(width: 24),
                            Expanded(child: RecentSalesCard(vendedorId: 12, limit: 8),),
                          ],
                        )
                      : ListView(
                          children: [
                            _buildMetricsGrid(),
                            const SizedBox(height: 24),
                            // exemplo dentro do grid/coluna
                            const RecentSalesCard(vendedorId: 12, limit: 8),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BOTÕES DE AÇÃO (Nova Venda, Cadastrar Cliente, Planos)
  Widget _buildActionButtons(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Row(
      mainAxisAlignment:
          isDesktop ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.add_shopping_cart,
          label: 'Vendas',
          color: AppColors.primary,
          onTap: () => Modular.to.pushNamed('/sales'),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.person_add,
          label: 'Cadastrar Cliente',
          color: AppColors.green,
          onTap: () => Modular.to.pushNamed('/client'),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.assignment,
          label: 'Planos',
          color: AppColors.guava,
          onTap: () => Modular.to.pushNamed('/plans'),
        ),
      ],
    );
  }

  // BOTÃO DE AÇÃO GENÉRICO
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  // GRID DE MÉTRICAS
  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          title: 'Total de Vendas',
          value: 'R\$ 25.000',
          color: AppColors.primary,
          icon: Icons.shopping_cart,
        ),
        _buildMetricCard(
          title: 'Comissão',
          value: 'R\$ 3.200',
          color: AppColors.green,
          icon: Icons.monetization_on,
        ),
        _buildMetricCard(
          title: 'Novos Clientes',
          value: '18',
          color: AppColors.whiteBlue,
          icon: Icons.people_alt,
        ),
        _buildMetricCard(
          title: 'Meta Atingida',
          value: '80%',
          color: AppColors.guava,
          icon: Icons.flag,
        ),
      ],
    );
  }

  // CARD DE MÉTRICA
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // LISTA DE VENDAS RECENTES
  Widget _buildRecentSales() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendas Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.lilac,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text('Cliente ${index + 1}'),
              subtitle: const Text('Plano Odontológico Premium'),
              trailing: Text(
                'R\$ 1.200',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
