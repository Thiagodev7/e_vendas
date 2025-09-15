// lib/app/modules/home/widgets/recent_sales_card.dart
import 'package:e_vendas/app/modules/home/stores/recent_sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

class RecentSalesCard extends StatefulWidget {
  const RecentSalesCard({super.key, required this.vendedorId, this.limit = 10});
  final int vendedorId;
  final int limit;

  @override
  State<RecentSalesCard> createState() => _RecentSalesCardState();
}

class _RecentSalesCardState extends State<RecentSalesCard> {
  late final RecentSalesStore store;

  @override
  void initState() {
    super.initState();
    store = RecentSalesStore()
      ..load(vendedorId: widget.vendedorId, limit: widget.limit);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = store.vendas;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendas Recentes',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Nenhuma venda finalizada ainda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                // >>> Deixa a lista rolar dentro do card
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final v = list[i];
                      final title = _maskCpf(v.cpfTitular) ?? 'Cliente';
                      final trailing =
                          v.valor != null ? money.format(v.valor) : '—';

                      return Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: cs.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  v.planoNome,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            trailing,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String? _maskCpf(String? cpf) {
    if (cpf == null || cpf.length < 11) return null;
    final d = cpf.replaceAll(RegExp(r'\D'), '').padLeft(11, '0');
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }
}