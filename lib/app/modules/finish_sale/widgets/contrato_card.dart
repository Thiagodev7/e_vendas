import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart'; // ❗️ Importe o MobX
import 'package:url_launcher/url_launcher.dart';

import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';

// 1. Transformado em StatefulWidget
class ContratoCard extends StatefulWidget {
  const ContratoCard({super.key});

  @override
  State<ContratoCard> createState() => _ContratoCardState();
}

// 2. Criação do State
class _ContratoCardState extends State<ContratoCard> {
  // Stores e Controller são movidos para o State
  final contractStore = Modular.get<FinishContractStore>();
  final paymentStore = Modular.get<FinishPaymentStore>();
  final _envelopeIdController = TextEditingController();

  ReactionDisposer? _reactionDisposer;

  @override
  void initState() {
    super.initState();

    // 3. Sincronização Inicial: Define o texto inicial do controller
    _envelopeIdController.text = contractStore.contratoEnvelopeId ?? '';

    // 4. Sincronização (UI -> Store):
    //    Quando o usuário digitar, atualiza o store
    _envelopeIdController.addListener(_syncControllerToStore);

    // 5. Sincronização (Store -> UI):
    //    Se o store mudar (ex: "Gerar Contrato" foi clicado),
    //    atualiza o texto no controller.
    _reactionDisposer = reaction(
      (_) => contractStore.contratoEnvelopeId,
      (String? storeId) {
        if (storeId != _envelopeIdController.text) {
          _envelopeIdController.text = storeId ?? '';
        }
      },
    );
  }

  void _syncControllerToStore() {
    // Chama a nova action que criamos no store
    contractStore.setContratoEnvelopeId(_envelopeIdController.text);
  }

  @override
  void dispose() {
    // 6. Limpeza: Essencial para evitar memory leaks
    _envelopeIdController.removeListener(_syncControllerToStore);
    _envelopeIdController.dispose();
    _reactionDisposer?.call();
    super.dispose();
  }

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
          // Os stores já foram buscados no initState
          final plan = paymentStore.venda?.plano;

          final dynamic monthlyRaw =
              plan?.getMensalidade() ?? plan?.getMensalidadeTotal();
          final dynamic enrollmentRaw =
              plan?.getTaxaAdesao() ?? plan?.getTaxaAdesaoTotal();

          final dynamic daysRaw = plan?.getDayue() ?? " ";

          final monthlyFmt = _fmtCurrency(monthlyRaw);
          final enrollmentFmt = _fmtCurrency(enrollmentRaw);

          final contratoAssinado = contractStore.contratoAssinadoServer;
          
          // O 'envelopeId' agora é lido diretamente do controller
          // mas o 'hasEnvelope' ainda vem do computed do store
          final hasEnvelope = contractStore.hasEnvelope;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Cabeçalho (sem mudanças) ----------
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

              // ---------- Linha de ações (sem mudanças) ----------
              // O botão "Atualizar status" já vai funcionar, pois ele
              // lê o `contratoEnvelopeId` do store, que agora é
              // atualizado pelo campo de texto.
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
                                  dueDay: daysRaw,
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
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (contractStore.checking ||
                              contractStore.loading ||
                              !hasEnvelope) // Botão ainda desabilita se não tiver ID
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
                    //
                    // 🔽========= AQUI ESTÁ A MUDANÇA =========🔽
                    //
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 18),
                        const SizedBox(width: 6),
                        // Campo de texto editável
                        Expanded(
                          child: TextFormField(
                            controller: _envelopeIdController,
                            decoration: InputDecoration(
                              labelText: 'Envelope ID',
                              hintText: 'Insira ou cole o ID do envelope',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: cs.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: cs.outlineVariant),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        // Botão de Copiar (agora lê do controller)
                        IconButton(
                          tooltip: 'Copiar ID',
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () async {
                            final id = _envelopeIdController.text;
                            if (id.isNotEmpty) {
                              await Clipboard.setData(ClipboardData(text: id));
                              _toast(context, 'Envelope ID copiado');
                            }
                          },
                        ),
                        // Botão para abrir o PDF (opcional, mantido)
                        IconButton(
                          tooltip: 'Abrir PDF do envelope',
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: !hasEnvelope
                              ? null
                              : () async {
                                  final url = contractStore.getEnvelopePdfUrl();
                                  if (url == null) return;
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                        ),
                      ],
                    ),
                    // 🔼========= FIM DA MUDANÇA =========🔼
                    //

                    // Última verificação (sem mudanças)
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
  // (Movidos para dentro da classe State)

  String _fmtCurrency(dynamic v) {
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

  String _toCurrency(num? v) {
    final n = (v ?? 0);
    final cents = n.round();
    final s = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  String _short(String s) {
    if (s.length <= 12) return s;
    return '${s.substring(0, 6)}…${s.substring(s.length - 4)}';
  }

  String _fmtDt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$h:$m $d/$mo';
  }

  Widget _statusPill({
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

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}