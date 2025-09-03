import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.store});
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