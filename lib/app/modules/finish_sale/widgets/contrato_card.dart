import 'package:flutter/material.dart';
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Observer(builder: (_) {
          final contractStore = Modular.get<FinishContractStore>();
          final paymentStore  = Modular.get<FinishPaymentStore>();

          final plan = paymentStore.venda?.plano;

          // Aceita num OU string (resolve o erro de tipos)
          final dynamic monthlyRaw    = plan?.getMensalidade()    ?? plan?.getMensalidadeTotal();
          final dynamic enrollmentRaw = plan?.getTaxaAdesao()     ?? plan?.getTaxaAdesaoTotal();

          final monthlyFmt    = _fmtCurrency(monthlyRaw);
          final enrollmentFmt = _fmtCurrency(enrollmentRaw);

          final contratoGerado   = contractStore.contratoGerado;
          final contratoAssinado = contractStore.contratoAssinadoServer;
          final envelopeId       = contractStore.contratoEnvelopeId;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton.icon(
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
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Gerar contrato'),
                  ),
                  const SizedBox(width: 8),
                  if (contratoGerado)
                    Chip(
                      label: const Text('Gerado'),
                      backgroundColor: cs.surface,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                  if (!contractStore.podeDispararContrato && !contratoAssinado)
                    Chip(
                      label: const Text('Aguardando…'),
                      backgroundColor: cs.surface,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                  const SizedBox(width: 8),

                  // Atualiza flags do servidor (por nroProposta)
                  OutlinedButton.icon(
                    onPressed: (contractStore.checking || contractStore.loading || contractStore.nroProposta == null)
                        ? null
                        : () async {
                            final flags = await contractStore.syncFlags();
                            if (flags != null) {
                              // reflete pagamento na store de pagamento, se necessário
                              paymentStore.pagamentoConcluidoServer = flags.pagamentoConcluido;
                            }
                            final msg = (flags == null)
                                ? 'Não foi possível atualizar agora.'
                                : (flags.contratoAssinado
                                    ? 'Contrato assinado.'
                                    : 'Contrato ainda pendente.');
                            _toast(context, 'Status atualizado • $msg');
                          },
                    icon: contractStore.checking
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync),
                    label: const Text('Atualizar status'),
                  ),
                  const SizedBox(width: 8),

                  // Conferir assinatura direto no DocuSign
                  OutlinedButton.icon(
                    onPressed: (contractStore.checking || contractStore.loading || envelopeId == null)
                        ? null
                        : () async {
                            final ds = await contractStore.conferirAssinaturaDocuSign();
                            final msg = (ds == null)
                                ? 'Não foi possível consultar agora.'
                                : (ds.signed
                                    ? 'Assinado no DocuSign.'
                                    : 'Status DocuSign: ${ds.status}.');
                            _toast(context, msg);
                          },
                    icon: contractStore.checking
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Conferir assinatura (DocuSign)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _statusPill(
                    ok: contratoAssinado,
                    labelOk: 'Assinado',
                    labelKo: 'Pendente',
                    icon: contratoAssinado ? Icons.verified : Icons.hourglass_bottom_rounded,
                    cs: cs,
                  ),
                  if (envelopeId != null)
                    InkWell(
                      onTap: () async {
                        // Se tiver um viewer direto, troque a URL abaixo
                        final url = Uri.parse('https://example.com/ds/envelope/$envelopeId');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Chip(
                        label: Text('Envelope: ${_short(envelopeId)}'),
                        backgroundColor: cs.surface,
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                  if (contractStore.lastCheckedAt != null)
                    Text(
                      'Última verificação: ${_fmtDt(contractStore.lastCheckedAt!)}',
                      style: TextStyle(color: cs.outline),
                    ),
                ],
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

      final numeric = double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
      if (numeric != null) return _toCurrency(numeric);

      return s; // fallback: devolve como veio
    }

    return 'R\$ 0,00';
  }

  static String _toCurrency(num? v) {
    final n = (v ?? 0) * 100;
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}