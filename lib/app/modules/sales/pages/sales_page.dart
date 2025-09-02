// lib/app/modules/sales/pages/sales_page.dart
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
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

  int _mapFilteredIndexToMaster(int filteredIndex) {
    final venda = store.filteredVendas[filteredIndex];
    final masterIndex = store.vendas.indexWhere((v) => identical(v, venda));
    return masterIndex >= 0 ? masterIndex : filteredIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              return _ErrorBanner(message: store.errorMessage!);
            }

            final items = store.filteredVendas;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1000;
                final crossAxisCount = isDesktop ? 2 : 1;
                const spacing = 16.0;

                if (items.isEmpty) {
                  return Column(
                    children: [
                      _FilterBar(store: store),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Nenhuma venda em andamento",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _FilterBar(store: store),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: isDesktop ? 2.4 : 1.9,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, filteredIndex) {
                          final venda = items[filteredIndex];

                          final titularNome =
                              venda.pessoaTitular?.nome ?? 'Titular não informado';

                          // vidas = dependentes + 1
                          final vidas = (venda.dependentes?.length ?? 0) + 1;

                          // usa plano sincronizado para exibir valores corretos
                          final planCalc = venda.plano?.copyWith(
                            vidasSelecionadas: vidas,
                          );
                          final mensalidade =
                              planCalc?.getMensalidadeTotal() ?? '0,00';
                          final adesao =
                              planCalc?.getTaxaAdesaoTotal() ?? '0,00';

                          final planoNome =
                              planCalc?.nomeContrato ?? 'Plano não selecionado';
                          final codigoPlano = planCalc?.codigoPlano ?? '';

                          return _VendaCard(
                            titularNome: titularNome,
                            planoNome: planoNome,
                            codigoPlano: codigoPlano,
                            vidas: vidas,
                            mensalidade: mensalidade,
                            adesao: adesao,
                            origin: venda.origin,
                            onEditarCliente: () {
                              final master =
                                  _mapFilteredIndexToMaster(filteredIndex);
                              Modular.to.pushNamed(
                                '/client',
                                arguments: {
                                  'index': master,
                                  'selectedPlan': store.vendas[master].plano,
                                },
                              );
                            },
                            onEditarPlano: () {
                              final master =
                                  _mapFilteredIndexToMaster(filteredIndex);
                              Modular.to.pushNamed(
                                '/plans',
                                arguments: {'vendaIndex': master},
                              );
                            },
                            onFinalizar: () async {
                              final master =
                                  _mapFilteredIndexToMaster(filteredIndex);

                              final temPlano = store.vendaTemPlano(master);
                              final temCliente = store.vendaTemCliente(master);

                              if (!temPlano) {
                                _toast('Selecione um plano para continuar.');
                                Modular.to.pushNamed(
                                  '/plans',
                                  arguments: {'vendaIndex': master},
                                );
                                return;
                              }

                              if (!temCliente) {
                                _toast('Complete os dados do cliente para continuar.');
                                Modular.to.pushNamed(
                                  '/client',
                                  arguments: {
                                    'index': master,
                                    'selectedPlan': store.vendas[master].plano,
                                  },
                                );
                                return;
                              }

                              try {
                                // Cria/garante a proposta no backend e retorna o nro
                                final nro = await store.finalizarVenda(master);

                                // Navega para tela de finalização (sem marcar venda_finalizada ainda)
                                Modular.to.pushNamed(
                                  '/finish-sale',
                                  arguments: {
                                    'vendaIndex': master, // <- chave esperada pelo módulo
                                    'nroProposta': nro,   // opcional pra exibir/usar depois
                                  },
                                );
                              } catch (e) {
                                _toast('Falha ao preparar finalização: $e');
                              }
                            },
                            onRemover: () async {
                              final master =
                                  _mapFilteredIndexToMaster(filteredIndex);

                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir venda'),
                                  content: const Text(
                                      'Tem certeza que deseja excluir esta venda?\n'
                                      'Se ela já está no servidor, será cancelada/retirada da lista de abertas.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );

                              if (ok != true) return;

                              try {
                                await store.removerVenda(master);
                                _toast('Venda excluída com sucesso');
                              } catch (e) {
                                _toast('Falha ao excluir: $e');
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(msg)));
    });
  }
}

/// Banner de erro discreto
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Erro ao carregar vendas:\n$message",
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onErrorContainer, fontSize: 16),
        ),
      ),
    );
  }
}

/// Card bonitão com badge de origem e ações
class _VendaCard extends StatelessWidget {
  const _VendaCard({
    required this.titularNome,
    required this.planoNome,
    required this.codigoPlano,
    required this.vidas,
    required this.mensalidade,
    required this.adesao,
    required this.origin,
    required this.onEditarCliente,
    required this.onEditarPlano,
    required this.onFinalizar,
    required this.onRemover,
  });

  final String titularNome;
  final String planoNome;
  final String codigoPlano;
  final int vidas;
  final String mensalidade;
  final String adesao;
  final VendaOrigin origin;

  final VoidCallback onEditarCliente;
  final VoidCallback onEditarPlano;
  final VoidCallback onFinalizar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCloud = origin == VendaOrigin.cloud;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Conteúdo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título + ícone de origem
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: (isCloud ? AppColors.primary : Colors.grey)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          isCloud ? Icons.cloud_done : Icons.smartphone,
                          size: 16,
                          color: isCloud ? AppColors.primary : Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCloud ? 'Nuvem' : 'Local',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isCloud ? AppColors.primary : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titularNome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Plano + código
              Text(
                planoNome,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (codigoPlano.isNotEmpty)
                Text(
                  'Código: $codigoPlano',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),

              const Divider(height: 24),

              // Vidas + valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(label: 'Vidas', value: '$vidas'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Metric(label: 'Mensal', value: 'R\$ $mensalidade'),
                      _Metric(label: 'Adesão', value: 'R\$ $adesao'),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.edit, color: AppColors.primary),
                    onSelected: (value) {
                      if (value == 'editar_cliente') {
                        onEditarCliente();
                      } else if (value == 'editar_plano') {
                        onEditarPlano();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'editar_cliente',
                        child: Text('Editar Cliente'),
                      ),
                      PopupMenuItem(
                        value: 'editar_plano',
                        child: Text('Editar Plano'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Finalizar Venda',
                    onPressed: onFinalizar,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remover Venda',
                    onPressed: onRemover,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Barra de filtro (Todas | Nuvem | Local)
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.store});
  final SalesStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip({
      required IconData icon,
      required String label,
      required int count,
      required bool selected,
      required VoidCallback onTap,
    }) {
      final bg = selected ? AppColors.primary.withOpacity(0.12) : cs.surface;
      final fg = selected ? AppColors.primary : cs.onSurfaceVariant;
      final border = selected ? AppColors.primary : cs.outlineVariant;

      return ChoiceChip(
        backgroundColor: bg,
        selectedColor: bg,
        shape: StadiumBorder(side: BorderSide(color: border)),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: fg)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: fg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      );
    }

    return Observer(builder: (_) {
      final selected = store.originFilter;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            chip(
              icon: Icons.all_inbox,
              label: 'Todas',
              count: store.totalCount,
              selected: selected == null,
              onTap: () => store.setFilter(null),
            ),
            chip(
              icon: Icons.cloud_done,
              label: 'Nuvem',
              count: store.cloudCount,
              selected: selected == VendaOrigin.cloud,
              onTap: () => store.setFilter(VendaOrigin.cloud),
            ),
            chip(
              icon: Icons.smartphone,
              label: 'Local',
              count: store.localCount,
              selected: selected == VendaOrigin.local,
              onTap: () => store.setFilter(VendaOrigin.local),
            ),
          ],
        ),
      );
    });
  }
}