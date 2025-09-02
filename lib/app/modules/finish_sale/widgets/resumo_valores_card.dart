import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'panel.dart';
import 'stat_tile.dart';

class ResumoValoresCard extends StatelessWidget {
  const ResumoValoresCard({super.key});

  String _fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = Modular.get<FinishSaleStore>();

    return Panel(
      icon: Icons.summarize_rounded,
      title: 'Resumo de Valores',
      child: Observer(builder: (_) {
        final r = store.resumo;
        if (r == null) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;

            // menos colunas em áreas estreitas; tiles mais "rasos"
            final cols = w >= 980 ? 3 : (w >= 540 ? 2 : 1);
            final ratio = cols == 3 ? 4.8 : (cols == 2 ? 4.4 : 3.6); // ↑ ratio => ↓ altura

            return Column(
              children: [
                GridView.count(
                  crossAxisCount: cols,
                  childAspectRatio: ratio,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatTile(icon: Icons.people_alt,        label: 'Vidas',            value: '${r.vidas}'),
                    StatTile(icon: Icons.add_card,          label: 'Adesão (ind.)',    value: _fmt(r.adesaoIndividual)),
                    StatTile(icon: Icons.calendar_month,    label: 'Mensal (ind.)',    value: _fmt(r.mensalidadeIndividual)),
                    StatTile(icon: Icons.add_card_outlined, label: 'Pró-rata (ind.)',  value: _fmt(r.proRataIndividual)),
                    StatTile(icon: Icons.stacked_bar_chart, label: 'Mensal (total)',   value: _fmt(r.mensalidadeTotal)),
                    StatTile(icon: Icons.toll,              label: 'Pró-rata (total)', value: _fmt(r.proRataTotal)),
                  ],
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56), // era 64
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cs.surface,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Total 1ª cobrança',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _fmt(r.totalPrimeiraCobranca),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800), // menor
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}