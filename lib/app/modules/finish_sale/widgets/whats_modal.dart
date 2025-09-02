// lib/app/modules/finish_sale/ui/widgets/whats_modal.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showWhatsModal(
  BuildContext context,
  String url,
  List<String> contatos,
) async {
  final controller = TextEditingController();
  final cs = Theme.of(context).colorScheme;

  String normalize(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('55')) return d;
    return '55$d';
  }

  String formatPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length < 10) return d;
    final dd = d.substring(0, 2);
    final mid = d.length == 11 ? d.substring(2, 7) : d.substring(2, 6);
    final end = d.length == 11 ? d.substring(7) : d.substring(6);
    return '($dd) $mid-$end';
  }

  Future<void> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Não foi possível abrir o link.')));
    }
  }

  if (contatos.isNotEmpty) controller.text = contatos.first;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enviar link por WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Número (com DDD)',
                    hintText: 'Ex.: 62999999999',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (contatos.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.surfaceVariant.withOpacity(.5),
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          width: double.infinity,
                          child: const Text(
                            'Contatos da venda',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...contatos.map((p) => ListTile(
                              title: Text(formatPhone(p)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => setSt(() => controller.text = p),
                            )),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar'),
                        onPressed: () async {
                          final num = controller.text.trim();
                          if (num.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Informe um número.')),
                              );
                            }
                            return;
                          }
                          final normalized = normalize(num);
                          final msg = 'Segue o link para pagamento: $url';
                          final wa = Uri.parse(
                            'https://wa.me/$normalized?text=${Uri.encodeComponent(msg)}',
                          );
                          await openExternalUrl(wa.toString());
                          if (context.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      );
    },
  );
}