import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../stores/sales_store.dart';

class SalesPage extends StatelessWidget {
  final store = Modular.get<SalesStore>();

  SalesPage({super.key});

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
            if (store.vendas.isEmpty) {
              return Center(
                child: Text(
                  "Nenhuma venda em andamento",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.vendas.length,
              itemBuilder: (context, index) {
                final venda = store.vendas[index];

                final titularNome =
                    venda.pessoaTitular?.nome ?? 'Titular não informado';
                final planoNome =
                    venda.plano?.nomeContrato ?? 'Plano não selecionado';
                final codigoPlano = venda.plano?.codigoPlano ?? '';

                return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        titularNome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(planoNome, style: const TextStyle(fontSize: 14)),
                          if (codigoPlano.isNotEmpty)
                            Text('Código: $codigoPlano',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'continuar') {
                            final venda = store.vendas[index];

                            // Se cliente existe mas não tem plano → vai para Planos
                            if (venda.pessoaTitular != null &&
                                venda.plano == null) {
                              Modular.to.pushNamed(
                                '/plans',
                                arguments: {'vendaIndex': index},
                              );
                              return;
                            }

                            // Se plano existe mas não tem cliente → vai para Cliente
                            if (venda.plano != null &&
                                venda.pessoaTitular == null) {
                              Modular.to.pushNamed(
                                '/client',
                                arguments: {
                                  'vendaIndex': index,
                                  'selectedPlan': venda.plano
                                },
                              );
                              return;
                            }

                            // Se cliente existe mas não tem plano → vai para Planos
                            if (venda.pessoaTitular != null &&
                                venda.plano == null) {
                              Modular.to.pushNamed(
                                '/plans',
                                arguments: {'vendaIndex': index},
                              );
                              return;
                            }

// Se nenhum preenchido → começa pelo plano
                            if (venda.plano == null &&
                                venda.pessoaTitular == null) {
                              Modular.to.pushNamed(
                                '/plans',
                                arguments: {'vendaIndex': index},
                              );
                              return;
                            }

                            Modular.to.pushNamed(
  '/finish-sale',
  arguments: {'vendaIndex': index},
);
                          } else if (value == 'remover') {
                            store.removerVenda(index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'continuar',
                            child: Text('Continuar'),
                          ),
                          const PopupMenuItem(
                            value: 'remover',
                            child: Text('Remover'),
                          ),
                        ],
                      ),
                    ));
              },
            );
          },
        ),
      ),
    );
  }
}
