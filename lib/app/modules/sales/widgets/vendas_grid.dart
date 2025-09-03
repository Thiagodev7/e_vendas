import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:e_vendas/app/modules/sales/widgets/venda_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class VendasGrid extends StatelessWidget {
  const VendasGrid({super.key, required this.store});
  final SalesStore store;

  int _mapFilteredIndexToMaster(int filteredIndex) {
    final venda = store.filteredVendas[filteredIndex];
    final masterIndex = store.vendas.indexWhere((v) => identical(v, venda));
    return masterIndex >= 0 ? masterIndex : filteredIndex;
  }

  @override
  Widget build(BuildContext context) {
    final items = store.filteredVendas;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final crossAxisCount = isDesktop ? 2 : 1;
        const spacing = 16.0;

        return GridView.builder(
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
            final planCalc = venda.plano?.copyWith(vidasSelecionadas: vidas);
            final mensalidade = planCalc?.getMensalidadeTotal() ?? '0,00';
            final adesao = planCalc?.getTaxaAdesaoTotal() ?? '0,00';

            final planoNome =
                planCalc?.nomeContrato ?? 'Plano não selecionado';
            final codigoPlano = planCalc?.codigoPlano ?? '';

            return VendaCard(
              titularNome: titularNome,
              planoNome: planoNome,
              codigoPlano: codigoPlano,
              vidas: vidas,
              mensalidade: mensalidade,
              adesao: adesao,
              origin: venda.origin,

              // Número de proposta
              nroProposta: venda.nroProposta,

              // Ciclo e vencimento (se existirem no plano)
              billingCycle: venda.plano?.billingCycle,
              dueDay: venda.plano?.dueDay,

              // OPCIONAL: chips extras
              // pagamentoConcluido: venda.pagamentoConcluido,
              // contratoAssinado: venda.contratoAssinado,

              onEditarCliente: () {
                final master = _mapFilteredIndexToMaster(filteredIndex);
                Modular.to.pushNamed(
                  '/client',
                  arguments: {
                    'index': master,
                    'selectedPlan': store.vendas[master].plano,
                  },
                );
              },
              onEditarPlano: () {
                final master = _mapFilteredIndexToMaster(filteredIndex);
                Modular.to.pushNamed(
                  '/plans',
                  arguments: {'vendaIndex': master},
                );
              },
              onFinalizar: () async {
                final master = _mapFilteredIndexToMaster(filteredIndex);

                final temPlano = store.vendaTemPlano(master);
                final temCliente = store.vendaTemCliente(master);

                if (!temPlano) {
                  _toast(context, 'Selecione um plano para continuar.');
                  Modular.to.pushNamed(
                    '/plans',
                    arguments: {'vendaIndex': master},
                  );
                  return;
                }

                if (!temCliente) {
                  _toast(context, 'Complete os dados do cliente para continuar.');
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
                  final nro = await store.finalizarVenda(master);
                  Modular.to.pushNamed(
                    '/finish-sale',
                    arguments: {
                      'vendaIndex': master,
                      'nroProposta': nro,
                    },
                  );
                } catch (e) {
                  _toast(context, 'Falha ao preparar finalização: $e');
                }
              },
              onRemover: () async {
                final master = _mapFilteredIndexToMaster(filteredIndex);

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
                  _toast(context, 'Venda excluída com sucesso');
                } catch (e) {
                  _toast(context, 'Falha ao excluir: $e');
                }
              },
            );
          },
        );
      },
    );
  }

  void _toast(BuildContext context, String msg) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(msg)));
    });
  }
}