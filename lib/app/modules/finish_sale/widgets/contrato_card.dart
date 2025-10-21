import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';

class ContratoCard extends StatelessWidget {
  const ContratoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Observer(builder: (_) {
          final contractStore = Modular.get<FinishContractStore>();
          final paymentStore = Modular.get<FinishPaymentStore>();

          final plan = paymentStore.venda?.plano;

          final dynamic monthlyRaw =
              plan?.getMensalidade() ?? plan?.getMensalidadeTotal();
          final dynamic enrollmentRaw =
              plan?.getTaxaAdesao() ?? plan?.getTaxaAdesaoTotal();

          final monthlyFmt = _fmtCurrency(monthlyRaw);
          final enrollmentFmt = _fmtCurrency(enrollmentRaw);

          final contratoAssinado = contractStore.contratoAssinadoServer;
          final envelopeId = contractStore.contratoEnvelopeId;
          final hasEnvelope = envelopeId != null && envelopeId.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Cabeçalho ----------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.description_outlined,
                        color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Text('Contrato',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const Spacer(),
                  _statusPill(
                    ok: contratoAssinado,
                    labelOk: 'Assinado',
                    labelKo: 'Pendente',
                    icon: contratoAssinado
                        ? Icons.verified
                        : Icons.hourglass_bottom_rounded,
                    cs: cs,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),

              // ---------- Linha de ações ----------
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (!contractStore.podeDispararContrato)
                          ? null
                          : () async {
                              try {
                                await contractStore.gerarContrato(
                                  enrollmentFmt: enrollmentFmt,
                                  monthlyFmt: monthlyFmt,
                                );
                                _toast(context, 'Contrato gerado!');
                              } catch (e) {
                                _toast(context, 'Falha ao gerar contrato: $e');
                              }
                            },
                      icon: contractStore.loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_document),
                      label: Text(
                        contractStore.loading
                            ? 'Gerando...'
                            : 'Gerar contrato',
                      ),
                      style: FilledButton.styleFrom(padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (contractStore.checking ||
                              contractStore.loading ||
                              !hasEnvelope)
                          ? null
                          : () async {
                              final ds = await contractStore
                                  .conferirAssinaturaDocuSign();
                              final msg = (ds == null)
                                  ? 'Não foi possível atualizar agora.'
                                  : (ds.signed
                                      ? 'Contrato assinado.'
                                      : 'Contrato ainda pendente.');
                              _toast(context, 'Status atualizado • $msg');
                            },
                      icon: contractStore.checking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: const Text('Atualizar status'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Infos: envelope / última verificação ----------
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (hasEnvelope)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 18),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () async {
                              final url = Modular.get<FinishContractStore>()
                                  .getEnvelopePdfUrl();
                              if (url == null) return;
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Chip(
                              label: Text('Envelope: ${_short(envelopeId!)}'),
                              backgroundColor: cs.surface,
                              side: BorderSide(color: cs.outlineVariant),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copiar ID',
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: envelopeId!));
                              _toast(context, 'Envelope ID copiado');
                            },
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text('Envelope ainda não gerado',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),

                    // Última verificação
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          contractStore.lastCheckedAt != null
                              ? 'Última verificação: ${_fmtDt(contractStore.lastCheckedAt!)}'
                              : 'Ainda não verificado',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ===== helpers visuais/formatadores =====

  static String _fmtCurrency(dynamic v) {
    if (v == null) return 'R\$ 0,00';
    if (v is num) return _toCurrency(v);
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return 'R\$ 0,00';
      if (s.contains('R\$')) return s; // já formatado
      final numeric =
          double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
      if (numeric != null) return _toCurrency(numeric);
      return s; // fallback
    }
    return 'R\$ 0,00';
  }

  static String _toCurrency(num? v) {
    final n = (v ?? 0);
    final cents = n.round();
    final s = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  static String _short(String s) {
    if (s.length <= 12) return s;
    return '${s.substring(0, 6)}…${s.substring(s.length - 4)}';
  }

  static String _fmtDt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$h:$m $d/$mo';
  }

  static Widget _statusPill({
    required bool ok,
    required String labelOk,
    required String labelKo,
    required IconData icon,
    required ColorScheme cs,
  }) {
    final bg = ok ? cs.secondaryContainer : cs.surface;
    final fg = ok ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            ok ? labelOk : labelKo,
            style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}