// lib/app/modules/finish_sale/ui/widgets/pagamento_card.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'panel.dart';
import 'whats_modal.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';

class PagamentoCard extends StatelessWidget {
  final VendaModel venda;
  const PagamentoCard({super.key, required this.venda});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = Modular.get<FinishSaleStore>();

    Future<void> _openUrl(String url) async {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Não foi possível abrir o link.')));
      }
    }

    Widget idChip(String k, String v) => InputChip(
          label: Text('$k: $v'),
          onPressed: null,
          visualDensity: VisualDensity.compact,
        );

    Widget linkActions(String url) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Link gerado: $url'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openUrl(url),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiado.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await showWhatsModal(
                    context,
                    url,
                    _phonesFromVenda(venda),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('WhatsApp'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Panel(
      icon: Icons.payments_rounded,
      title: 'Pagamento',
      trailing: Observer(builder: (_) {
        final locked = store.pagamentoConcluido;
        return Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Cartão'),
              selected: store.metodo == PayMethod.card,
              onSelected: locked ? null : (sel) => sel ? store.setMetodo(PayMethod.card) : null,
            ),
            ChoiceChip(
              label: const Text('PIX'),
              selected: store.metodo == PayMethod.pix,
              onSelected: locked ? null : (sel) => sel ? store.setMetodo(PayMethod.pix) : null,
            ),
          ],
        );
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner "já pago" / bloqueado
          Observer(builder: (_) {
            if (!store.pagamentoConcluido) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.08),
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_rounded, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pagamento já concluído para esta proposta. Novas cobranças estão bloqueadas.',
                    ),
                  ),
                ],
              ),
            );
          }),

          // IDs
          Observer(builder: (_) {
            final chips = <Widget>[];
            if (store.galaxPayId != null) {
              chips.add(idChip('galaxPayId', '${store.galaxPayId}'));
            }
            if ((store.currentMyId ?? '').isNotEmpty) {
              chips.add(idChip('myId', store.currentMyId!));
            }
            return chips.isEmpty
                ? const SizedBox.shrink()
                : Wrap(spacing: 8, runSpacing: 8, children: chips);
          }),
          const SizedBox(height: 10),

          // CTA gerar cobrança
          Align(
            alignment: Alignment.centerRight,
            child: Observer(builder: (_) {
              final isCard = store.metodo == PayMethod.card;
              final locked = store.pagamentoConcluido;
              return FilledButton.icon(
                onPressed: (store.loading || locked)
                    ? null
                    : () async {
                        try {
                          if (isCard) {
                            await store.gerarLinkCartao();
                            _toast(context, 'Link de pagamento (Cartão) gerado!');
                          } else {
                            await store.gerarPix();
                            _toast(context, 'Cobrança PIX gerada!');
                          }
                        } catch (e) {
                          _toast(context, 'Falha ao gerar cobrança: $e');
                        }
                      },
                icon: Icon(isCard ? Icons.link : Icons.qr_code),
                label: Text(isCard ? 'Gerar link (Cartão)' : 'Gerar PIX'),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Área dinâmica
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Observer(builder: (_) {
              if (store.metodo == PayMethod.card) {
                if (!(store.cardUrl?.isNotEmpty ?? false)) {
                  return const SizedBox.shrink(key: ValueKey('card-empty'));
                }
                return Container(
                  key: const ValueKey('card-ui'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: linkActions(store.cardUrl!),
                );
              } else {
                // PIX
                return Container(
                  key: const ValueKey('pix-ui'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((store.pixEmv ?? '').isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: store.pixEmv!));
                                _toast(context, 'Código PIX (EMV) copiado.');
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copiar EMV'),
                            ),
                          if ((store.pixLink ?? '').isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => _openUrl(store.pixLink!),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Abrir cobrança'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Builder(
                          builder: (_) {
                            // QR vindo da API
                            if ((store.pixImageBase64 ?? '').isNotEmpty) {
                              final bytes = base64Decode(
                                store.pixImageBase64!.replaceFirst(
                                  RegExp('^data:image/\\w+;base64,'),
                                  '',
                                ),
                              );
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(bytes, width: 220, height: 220),
                              );
                            }
                            // Fallback local com EMV
                            if ((store.pixEmv ?? '').isNotEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: cs.outlineVariant),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: QrImageView(
                                  data: store.pixEmv!,
                                  version: QrVersions.auto,
                                  size: 220,
                                ),
                              );
                            }
                            return const SizedBox(height: 8);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),

          const SizedBox(height: 12),

          // Status + Atualizar
          Observer(builder: (_) {
            if (store.paymentStatus == PaymentStatus.none) {
              return const SizedBox.shrink();
            }
            late String label;
            late MaterialColor color;
            switch (store.paymentStatus) {
              case PaymentStatus.aguardando:
                label = 'Aguardando pagamento';
                color = Colors.orange;
                break;
              case PaymentStatus.pago:
                label = 'Pago';
                color = Colors.green;
                break;
              default:
                label = 'Erro';
                color = Colors.red;
            }
            return Row(
              children: [
                Chip(
                  label: Text(label),
                  backgroundColor: color.withOpacity(.1),
                  labelStyle: TextStyle(color: color.shade700),
                  side: BorderSide(color: color.shade200),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: store.loading
                      ? null
                      : () async {
                          try {
                            final s = await store.consultarStatusPagamento();
                            _toast(
                              context,
                              s == PaymentStatus.pago
                                  ? 'Pagamento confirmado! (Proposta atualizada)'
                                  : 'Ainda aguardando pagamento.',
                            );
                          } catch (e) {
                            _toast(context, 'Erro ao consultar status: $e');
                          }
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar status'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<String> _phonesFromVenda(VendaModel v) {
    final list = <String>[];
    for (final c in (v.contatos ?? <ContatoModel>[])) {
      final digits = c.descricao.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) list.add(digits);
    }
    return list.toSet().toList();
  }

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}