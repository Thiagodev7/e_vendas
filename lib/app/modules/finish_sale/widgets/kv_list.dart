// lib/app/modules/finish_sale/ui/widgets/kv_list.dart
import 'package:flutter/material.dart';

class KvList extends StatelessWidget {
  final List<(String, String)> items;
  const KvList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: items
          .map(
            (kv) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      kv.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(kv.$2)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}