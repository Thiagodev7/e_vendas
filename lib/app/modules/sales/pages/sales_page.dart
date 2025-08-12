// lib/app/modules/sales/pages/sales_page.dart

import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../stores/sales_store.dart';

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
    // Dispara a busca de dados do servidor sempre que a tela é iniciada.
    store.fetchVendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Nova Venda"),
        onPressed: () {
          Modular.to.pushNamed('/client');
        },
      ),
      body: DashboardLayout(
        title: 'Vendas Abertas',
        child: Observer(
          builder: (_) {
            // Exibe o indicador de progresso enquanto carrega os dados.
            if (store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exibe uma mensagem de erro se a busca falhar.
            if (store.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Erro ao carregar vendas:\n${store.errorMessage}",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Exibe a mensagem se não houver vendas.
            if (store.vendas.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhuma venda em andamento",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // Exibe a grade de vendas se tudo estiver certo.
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                final crossAxisCount = isDesktop ? 2 : 1;
                final spacing = 16.0;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: isDesktop ? 2.6 : 2.2,
                  ),
                  itemCount: store.vendas.length,
                  itemBuilder: (context, index) {
                    final venda = store.vendas[index];
                    final titularNome =
                        venda.pessoaTitular?.nome ?? 'Titular não informado';
                    final plano = venda.plano;
                    final planoNome =
                        plano?.nomeContrato ?? 'Plano não selecionado';
                    final codigoPlano = plano?.codigoPlano ?? '';

                    final vidas = plano?.vidasSelecionadas ?? 1;
                    final mensalidade = plano?.getMensalidadeTotal() ?? '0,00';
                    final adesao = plano?.getTaxaAdesaoTotal() ?? '0,00';

                    return _buildVendaCard(
                      context,
                      index,
                      titularNome,
                      planoNome,
                      codigoPlano,
                      vidas,
                      mensalidade,
                      adesao,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // O widget do card de venda não precisa de alterações.
  Widget _buildVendaCard(
    BuildContext context,
    int index,
    String titularNome,
    String planoNome,
    String codigoPlano,
    int vidas,
    String mensalidade,
    String adesao,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            titularNome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            planoNome,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (codigoPlano.isNotEmpty)
            Text(
              'Código: $codigoPlano',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vidas: $vidas', style: const TextStyle(fontSize: 14)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Mensal: R\$ $mensalidade', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Adesão: R\$ $adesao', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onSelected: (value) {
                  if (value == 'editar_cliente') {
                    Modular.to.pushNamed('/client', arguments: {'index': index, 'selectedPlan': store.vendas[index].plano});
                  } else if (value == 'editar_plano') {
                    Modular.to.pushNamed('/plans', arguments: {'vendaIndex': index});
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'editar_cliente', child: Text('Editar Cliente')),
                  PopupMenuItem(value: 'editar_plano', child: Text('Editar Plano')),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Finalizar Venda',
                onPressed: () {
                  final temPlano = store.vendaTemPlano(index);
                  final temCliente = store.vendaTemCliente(index);
                  if (!temPlano) {
                    _toast(context, 'Selecione um plano para continuar.');
                    return;
                  }
                  if (!temCliente) {
                    _toast(context, 'Complete os dados do cliente para continuar.');
                    return;
                  }
                  Modular.to.pushNamed('/finish-sale', arguments: {'vendaIndex': index});
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remover Venda',
                onPressed: () => store.removerVenda(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}