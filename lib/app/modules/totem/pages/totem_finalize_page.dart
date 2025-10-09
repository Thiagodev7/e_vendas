// lib/app/modules/totem/pages/totem_finalize_page.dart
import 'dart:math';
import 'dart:ui';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/generic_state_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

// ====== mesma enum/peças do arquivo anterior ======
enum _PayMethod { pix, card, boleto }

class TotemFinalizePage extends StatefulWidget {
  const TotemFinalizePage({super.key});

  @override
  State<TotemFinalizePage> createState() => _TotemFinalizePageState();
}

class _TotemFinalizePageState extends State<TotemFinalizePage>
    with TickerProviderStateMixin {
  late final AnimationController _titleAnimCtrl;
  late final AnimationController _cardAnimCtrl;

  final _totem = Modular.get<TotemStore>();
  final _contract = Modular.get<FinishContractStore>();

  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _titleAnimCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
          ..forward();
    _cardAnimCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
          ..forward();
  }

  @override
  void dispose() {
    _titleAnimCtrl.dispose();
    _cardAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ===== Cálculo de valores (usa billing_calculator) =====
    final vidas = _totem.dependentes.length + 1;
    final PlanModel? planBase = _totem.selectedPlan;
    final PlanModel? planForBilling =
        planBase?.copyWith(vidasSelecionadas: vidas);
    final BillingBreakdown? billing =
        (planForBilling != null) ? computeBilling(planForBilling) : null;

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AnimatedBlobBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: FadeTransition(
                    opacity: _titleAnimCtrl,
                    child: Text(
                      'Finalizar compra',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Revise os dados e escolha como deseja concluir.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FadeTransition(
                    opacity: _cardAnimCtrl,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: _cardAnimCtrl,
                              curve: Curves.easeOutCubic)),
                      child: _SummaryCard(
                        billing: billing,
                        vidas: vidas,
                        totem: _totem,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Modular.to.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // === Gerar contrato + abrir WebView de assinatura (embutido)
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: (_generating || planForBilling == null) ? null : () => _onGenerateAndSign(planForBilling),
                icon: _generating
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.draw_rounded),
                label: const Text('Gerar contrato e assinar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // === Pagamento (opcional, permanece se você quiser cobrar antes)
            Expanded(
              child: FilledButton.icon(
                onPressed: (billing == null) ? null : () => _onPay(context, billing),
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Realizar pagamento'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // CONTRATO + ASSINATURA
  // ======================

  Future<void> _onGenerateAndSign(PlanModel planForBilling) async {
    try {
      setState(() => _generating = true);

      // 1) Monta a venda a partir do TotemStore
      final venda = _buildVendaFromTotem(planForBilling);

      // 2) Vincula no store
      _contract.bindVenda(venda);

      // 3) Formata mensalidade/adesão no mesmo padrão do seu ContratoCard
      final dynamic monthlyRaw    = planForBilling.getMensalidade() ?? planForBilling.getMensalidadeTotal();
      final dynamic enrollmentRaw = planForBilling.getTaxaAdesao()  ?? planForBilling.getTaxaAdesaoTotal();
      final String monthlyFmt     = _fmtCurrency(monthlyRaw);
      final String enrollmentFmt  = _fmtCurrency(enrollmentRaw);

      // 4) Envia para gerar o envelope (DocuSign)
      await _contract.gerarContrato(
        enrollmentFmt: enrollmentFmt,
        monthlyFmt: monthlyFmt,
      );

      // 5) Cria a URL de Recipient View (embutida) e abre WebView
      final url = await _contract.criarRecipientViewUrl(
        // se quiser, passe uma returnUrl custom:
        // returnUrl: 'https://seuapp.com/retorno-assinatura'
      );

      if (url == null || url.isEmpty) {
        _toast('Não foi possível criar o link de assinatura.');
        return;
      }

      // Abra a página de webview do totem (defina a rota no seu módulo)
      Modular.to.pushNamed('/totem/assinar-contrato', arguments: {'url': url});
    } catch (e) {
      _toast('Falha ao gerar/abrir contrato: $e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  // Constrói uma VendaModel usando os dados do TotemStore
  VendaModel _buildVendaFromTotem(PlanModel plan) {
    // Se seu VendaModel tiver factory/copyWith diferentes, ajuste aqui.
    return VendaModel(
      plano: plan,
      pessoaTitular: _totem.titular,
      endereco: _totem.endereco,
      dependentes: _totem.dependentes.toList(),
      contatos: _totem.contatos.toList(),
      pessoaResponsavelFinanceiro: _totem.responsavelFinanceiro,
    );
  }

  // ======================
  // PAGAMENTO (mesmo do arquivo anterior)
  // ======================

  Future<void> _onPay(BuildContext context, BillingBreakdown billing) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaymentSheet(billing: billing),
    );
  }

  // ===== helpers =====

  static String _fmtCurrency(dynamic v) {
    if (v == null) return 'R\$ 0,00';
    if (v is num) return _toCurrency(v);

    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return 'R\$ 0,00';
      if (s.contains('R\$')) return s;
      final numeric = double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
      if (numeric != null) return _toCurrency(numeric);
      return s;
    }
    return 'R\$ 0,00';
  }

  static String _toCurrency(num? v) {
    final n = (v ?? 0) * 100;
    final cents = n.round();
    final s = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ============================================================================
// RESUMO (CARD) — igual ao anterior, apenas mantido
// ============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.billing,
    required this.vidas,
    required this.totem,
  });

  final BillingBreakdown? billing;
  final int vidas;
  final TotemStore totem;

  String _fmt(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final plan = totem.selectedPlan;
    final endereco = totem.endereco;
    final titular = totem.titular;
    final responsavel = totem.responsavelFinanceiro ?? titular;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: _glass(cs),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 900),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Section(
                        title: 'Plano',
                        trailing: plan != null
                            ? Chip(
                                label: Text(
                                  plan.isAnnual ? 'Anual (-10%)' : 'Mensal',
                                  style: TextStyle(color: cs.onPrimaryContainer),
                                ),
                                backgroundColor: cs.primaryContainer,
                              )
                            : null,
                        child: plan == null
                            ? const Text('Nenhum plano selecionado.')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${plan.nomeContrato} • $vidas vida(s)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  if (billing == null)
                                    const Text('Não foi possível calcular os valores.')
                                  else
                                    _ResumoValoresTotem(b: billing!, fmt: _fmt),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'Endereço',
                        child: endereco == null
                            ? const Text('Não informado')
                            : _TwoCol(
                                left: [
                                  _InfoRow('Logradouro', endereco.logradouro ?? '-'),
                                  _InfoRow('Bairro', endereco.bairro ?? '-'),
                                  _InfoRow('CEP', endereco.cep ?? '-'),
                                ],
                                right: [
                                  _InfoRow('Cidade', endereco.nomeCidade ?? '-'),
                                  _InfoRow('UF', endereco.siglaUf ?? '-'),
                                  _InfoRow('Número/Compl.',
                                      '${endereco.numero ?? '-'}${(endereco.complemento?.isNotEmpty ?? false) ? ' — ${endereco.complemento}' : ''}'),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'Titular',
                        child: titular == null
                            ? const Text('Não informado')
                            : _TwoCol(
                                left: [
                                  _InfoRow('Nome', titular.nome),
                                  _InfoRow('CPF', titular.cpf ?? '-'),
                                  _InfoRow('Nascimento', titular.dataNascimento ?? '-'),
                                ],
                                right: [
                                  if ((titular.cns ?? '').isNotEmpty)
                                    _InfoRow('CNS', titular.cns!),
                                  if ((titular.nomeMae ?? '').isNotEmpty)
                                    _InfoRow('Mãe', titular.nomeMae!),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'Contatos',
                        child: totem.contatos.isEmpty
                            ? const Text('Nenhum contato informado')
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: totem.contatos
                                    .map((c) => _ContactChip(c))
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'Responsável Financeiro',
                        child: responsavel == null
                            ? const Text('Não informado')
                            : _TwoCol(
                                left: [
                                  _InfoRow('Nome', responsavel.nome),
                                  _InfoRow('CPF', responsavel.cpf ?? '-'),
                                ],
                                right: [
                                  _InfoRow(
                                    'Tipo',
                                    (titular?.cpf ?? '') == (responsavel.cpf ?? '')
                                        ? 'O titular'
                                        : 'Outra pessoa',
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'Dependentes',
                        child: totem.dependentes.isEmpty
                            ? const Text('Nenhum')
                            : Column(
                                children: [
                                  ...List.generate(totem.dependentes.length, (i) {
                                    final d = totem.dependentes[i];
                                    final grau = _grauDependenciaName(d.idGrauDependencia);
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.person),
                                      title: Text(d.nome),
                                      subtitle: Text(
                                        '${grau.isEmpty ? '—' : grau}'
                                        '${(d.cpf ?? '').isNotEmpty ? ' • CPF: ${d.cpf}' : ''}',
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _glass(ColorScheme cs) => BoxDecoration(
        color: cs.surface.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      );

  String _grauDependenciaName(int? id) {
    var list = [
       GenericStateModel(name: 'BENEFICIÁRIO', id: 1),
      GenericStateModel(name: 'CÔNJUGE/COMPANHEIRO', id: 2),
       GenericStateModel(name: 'FILHO/FILHA', id: 3),
       GenericStateModel(name: 'PAI/MÃE/SOGRO/SOGRA', id: 5),
       GenericStateModel(name: 'AGREGADOS/OUTROS', id: 6),
       GenericStateModel(name: 'ENTEADO/MENOR SOB GUARDA', id: 7),
    ];
    return list.firstWhere(
      (e) => e.id == id,
      orElse: () =>  GenericStateModel(name: '', id: 0),
    ).name;
  }
}

// -----------------------------------------------------------------
// Resumo de valores (usa BillingBreakdown exatamente como no módulo)
// -----------------------------------------------------------------
class _ResumoValoresTotem extends StatelessWidget {
  const _ResumoValoresTotem({required this.b, required this.fmt});
  final BillingBreakdown b;
  final String Function(num) fmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          b.kind == BillingKind.mensal
              ? 'Primeira cobrança (pró-rata do mês atual) + adesão'
              : 'Primeiro ciclo anual com desconto',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),

        _kv('Pró-rata (restam ${b.remainingDays} de ${b.monthDays} dias)', fmt(b.prorata)),
        if (b.kind == BillingKind.anual)
          _kv('11 parcelas de', fmt(b.mensal)),
        _kv('Taxa de adesão', fmt(b.adesao)),
        if (b.kind == BillingKind.anual)
          _kv('Desconto anual (−10%)', '- ${fmt(b.desconto)}'),

        const Divider(height: 20),

        _totalRow(
          context,
          b.kind == BillingKind.mensal ? 'Total 1ª cobrança' : 'Total 1º ciclo (à vista)',
          fmt(b.valorAgora),
        ),

        const SizedBox(height: 8),
        Text(
          b.kind == BillingKind.mensal
              ? 'A partir do próximo mês (venc. dia ${b.dueDay}), a recorrência será ${fmt(b.mensal)}.'
              : 'O desconto de 10% foi aplicado sobre (pró-rata + 11×mensal).',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          const SizedBox(width: 12),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cs.primary)),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM SHEET DE PAGAMENTO (igual ao anterior)
// ============================================================================

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.billing});
  final BillingBreakdown billing;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  _PayMethod? _method;
  bool _processing = false;
  String? _pixCode;

  double get _amount => widget.billing.valorAgora;

  String _fmt(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  Future<void> _startPayment() async {
    if (_method == null) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      switch (_method!) {
        case _PayMethod.pix:
          setState(() {
            _pixCode = '000201010212...5408${_amount.toStringAsFixed(2)}...'; // mock
          });
          break;
        case _PayMethod.card:
          _showDone('Pagamento via cartão iniciado (exemplo).');
          break;
        case _PayMethod.boleto:
          _showDone('Boleto gerado (exemplo).');
          break;
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _copyPix() async {
    if (_pixCode == null) return;
    await Clipboard.setData(ClipboardData(text: _pixCode!));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Código PIX copiado.')));
    }
  }

  void _showDone(String msg) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Escolha a forma de pagamento', style: t.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PayTile(
                selected: _method == _PayMethod.pix,
                icon: Icons.qr_code_2_rounded,
                label: 'PIX',
                onTap: () => setState(() => _method = _PayMethod.pix),
              ),
              _PayTile(
                selected: _method == _PayMethod.card,
                icon: Icons.credit_card_rounded,
                label: 'Cartão',
                onTap: () => setState(() => _method = _PayMethod.card),
              ),
              _PayTile(
                selected: _method == _PayMethod.boleto,
                icon: Icons.receipt_long_rounded,
                label: 'Boleto',
                onTap: () => setState(() => _method = _PayMethod.boleto),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Total a pagar agora',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt(_amount),
            style: t.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.billing.kind == BillingKind.mensal
                ? 'Inclui pró-rata (${widget.billing.remainingDays}/${widget.billing.monthDays}) + adesão.'
                : 'Total do 1º ciclo anual (desconto aplicado) + adesão.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (_method == _PayMethod.pix && _pixCode != null) ...[
            const SizedBox(height: 8),
            Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 120),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _copyPix,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar código PIX'),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _processing ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _processing ? null : _startPayment,
                  icon: _processing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_method == _PayMethod.pix
                      ? (_pixCode == null ? 'Gerar PIX' : 'Concluir')
                      : 'Iniciar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayTile extends StatelessWidget {
  const _PayTile({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  const _TwoCol({required this.left, required this.right});
  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        if (c.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...left,
              const SizedBox(height: 8),
              ...right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: left)),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: right)),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isEmpty = value.trim().isEmpty || value == '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(
              isEmpty ? '-' : value,
              style: t.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip(this.c);
  final ContatoModel c;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCel = c.idMeioComunicacao == 1;
    return Chip(
      avatar: Icon(isCel ? Icons.phone_iphone : Icons.email_outlined, size: 18),
      label: Text('${isCel ? 'Celular' : 'E-mail'}: ${c.descricao}'),
      backgroundColor: cs.surfaceVariant.withOpacity(0.7),
      shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
    );
  }
}

// ===== Fundo animado (mesmo estilo) =====
class _AnimatedBlobBackground extends StatefulWidget {
  const _AnimatedBlobBackground();

  @override
  State<_AnimatedBlobBackground> createState() => _AnimatedBlobBackgroundState();
}

class _AnimatedBlobBackgroundState extends State<_AnimatedBlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 26), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CustomPaint(
      painter: _BlobPainter(animation: _controller, color: color),
      size: Size.infinite,
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.animation, required this.color})
      : super(repaint: animation);
  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.18);
    final t = animation.value;

    final pos1 = Offset(
      size.width * (0.2 + 0.2 * sin(t * pi * 2 + 0.5)),
      size.height * (0.3 - 0.2 * cos(t * pi * 2 + 0.5)),
    );
    final r1 = size.width * (0.35 + 0.1 * sin(t * pi * 2));
    canvas.drawCircle(pos1, r1, paint);

    final pos2 = Offset(
      size.width * (0.8 - 0.15 * sin(t * pi * 1.5 + 1.0)),
      size.height * (0.7 + 0.15 * cos(t * pi * 1.5 + 1.0)),
    );
    final r2 = size.width * (0.3 + 0.08 * cos(t * pi * 2.5));
    canvas.drawCircle(pos2, r2, paint);

    final pos3 = Offset(
      size.width * (0.6 + 0.2 * cos(t * pi * 2.2 + 2.0)),
      size.height * (0.1 + 0.1 * sin(t * pi * 2.2 + 2.0)),
    );
    final r3 = size.width * (0.25 + 0.05 * sin(t * pi * 1.8));
    canvas.drawCircle(pos3, r3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}