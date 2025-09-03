import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:e_vendas/app/modules/sales/widgets/empty_state.dart';
import 'package:e_vendas/app/modules/sales/widgets/error_banner.dart';
import 'package:e_vendas/app/modules/sales/widgets/filter_bar.dart';
import 'package:e_vendas/app/modules/sales/widgets/vendas_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final store = Modular.get<SalesStore>();

  @override
  void initState() {
    super.initState();
    store.syncOpenProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Nova Venda"),
        onPressed: () => Modular.to.pushNamed('/client'),
      ),
      body: DashboardLayout(
        title: 'Vendas Abertas',
        child: Observer(
          builder: (_) {
            if (store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (store.errorMessage != null) {
              return ErrorBanner(message: store.errorMessage!);
            }

            final items = store.filteredVendas;
            return Column(
              children: [
                FilterBar(store: store),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState(message: "Nenhuma venda em andamento")
                      : VendasGrid(store: store),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}