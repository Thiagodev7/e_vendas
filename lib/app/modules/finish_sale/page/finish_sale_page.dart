import 'package:e_vendas/app/modules/finish_sale/widgets/pagamento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/panel.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/kv_list.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/resumo_valores_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/contrato_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/finalizacao_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/plan_biling_info.dart';

// Stores
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_resumo_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart'; // legado/compat
import 'package:flutter_mobx/flutter_mobx.dart';

class FinishSalePage extends StatefulWidget {
  final int? vendaIndex;
  final int? nroProposta;

  const FinishSalePage({super.key, this.vendaIndex, this.nroProposta});

  @override
  State<FinishSalePage> createState() => _FinishSalePageState();
}

class _FinishSalePageState extends State<FinishSalePage> {
  // Stores globais
  final salesStore = Modular.get<SalesStore>();
  final paymentStore = Modular.get<FinishPaymentStore>();
  final contractStore = Modular.get<FinishContractStore>();
  final resumoStore = Modular.get<FinishResumoStore>();

  // compat com widgets antigos
  final legacyStore = Modular.get<FinishSaleStore>();

  @override
  void initState() {
    super.initState();

    final venda = (widget.vendaIndex != null &&
            widget.vendaIndex! < salesStore.vendas.length)
        ? salesStore.vendas[widget.vendaIndex!]
        : null;

    if (venda != null) {
      final nro = widget.nroProposta ?? venda.nroProposta;

      // Binds p/ as stores novas
      paymentStore
        ..bindVenda(venda)
        ..bindNroProposta(nro)
        ..pagamentoConcluidoServer = venda.pagamentoConcluido == true;

      contractStore
        ..bindVenda(venda)
        ..bindNroProposta(nro)
        ..contratoAssinadoServer = venda.contratoAssinado == true;

      resumoStore.bindVenda(venda);

      // Compat com componentes que ainda usam a store antiga
      legacyStore.init(v: venda, nro: nro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venda = (widget.vendaIndex != null &&
            widget.vendaIndex! < salesStore.vendas.length)
        ? salesStore.vendas[widget.vendaIndex!]
        : null;

    return DashboardLayout(
      title: 'Finalização da Venda',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 1100;

          // ====== HEADER STRIP (chips) ======
          final header = Observer(builder: (_) {
            final nro = widget.nroProposta ?? venda?.nroProposta;
            final pago = paymentStore.pagamentoConcluidoServer ||
                (venda?.pagamentoConcluido ?? false);
            final assinado = contractStore.contratoAssinadoServer ||
                (venda?.contratoAssinado ?? false);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (nro != null)
                    _pill(
                      context,
                      icon: Icons.tag_rounded,
                      label: 'Proposta #$nro',
                    ),
                  _statusPill(
                    context,
                    icon: Icons.payments_rounded,
                    ok: pago,
                    labelOk: 'Pagamento concluído',
                    labelKo: 'Pagamento pendente',
                  ),
                  _statusPill(
                    context,
                    icon: Icons.description_rounded,
                    ok: assinado,
                    labelOk: 'Contrato assinado',
                    labelKo: 'Contrato pendente',
                  ),
                ],
              ),
            );
          });

          // ====== WIDGETS DA COLUNA ESQUERDA ======
          List<Widget> _leftWidgets() {
            final v = venda;
            if (v == null) {
              return const [Center(child: Text('Venda não encontrada.'))];
            }
            final vidas = (v.dependentes?.length ?? 0) + 1;
            final planSync = v.plano?.copyWith(vidasSelecionadas: vidas);

            return [
              Panel(
                icon: Icons.person_rounded,
                title: 'Titular',
                child: KvList(items: [
                  ('CPF', v.pessoaTitular?.cpf ?? ''),
                  ('Estado civil', '${v.pessoaTitular?.idEstadoCivil ?? ''}'),
                ]),
              ),
              const SizedBox(height: 12),
              Panel(
                icon: Icons.health_and_safety_rounded,
                title: 'Plano',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KvList(items: [
                      ('Plano', v.plano?.nomeContrato ?? '-'),
                      if ((v.plano?.codigoPlano ?? '').isNotEmpty)
                        ('Código', v.plano?.codigoPlano ?? ''),
                      ('Vidas', '$vidas'),
                    ]),
                    if (planSync != null) ...[
                      const SizedBox(height: 12),
                      PlanBillingInfo(plan: planSync),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Panel(
                icon: Icons.home_rounded,
                title: 'Endereço',
                child: KvList(items: [
                  ('Cidade', v.endereco?.nomeCidade ?? ''),
                  ('Bairro', v.endereco?.bairro ?? ''),
                  ('Logradouro', v.endereco?.logradouro ?? ''),
                  ('Número', '${v.endereco?.numero ?? ''}'),
                  ('CEP', v.endereco?.cep ?? ''),
                ]),
              ),
              if ((v.dependentes ?? []).isNotEmpty) ...[
                const SizedBox(height: 12),
                Panel(
                  icon: Icons.group_rounded,
                  title: 'Dependentes',
                  child: Column(
                    children: (v.dependentes ?? [])
                        .map((d) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(d.cpf ?? '')),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ];
          }

          // ====== WIDGETS DA COLUNA DIREITA ======
          List<Widget> _rightWidgets() {
            if (venda == null) return const [];
            return [
              ResumoValoresCard(venda: venda), // ⬅️ agora passando a venda
              const SizedBox(height: 12),
              PagamentoCard(venda: venda),
              const SizedBox(height: 12),
              const ContratoCard(),
              const SizedBox(height: 12),
              const FinalizacaoCard(),
            ];
          }

          // ====== LAYOUT ======
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ESQUERDA SCROLLÁVEL
                          Expanded(
                            flex: 6,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ..._leftWidgets(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // DIREITA SCROLLÁVEL
                          Expanded(
                            flex: 5,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ..._rightWidgets(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ..._leftWidgets(),
                          const SizedBox(height: 16),
                          ..._rightWidgets(),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= UI helpers =================
  Widget _pill(BuildContext context,
      {required IconData icon, required String label}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(
    BuildContext context, {
    required IconData icon,
    required bool ok,
    required String labelOk,
    required String labelKo,
  }) {
    final bg =
        ok ? Colors.green.withOpacity(.10) : Colors.orange.withOpacity(.10);
    final bd = ok ? Colors.green.shade300 : Colors.orange.shade300;
    final fg = ok ? Colors.green.shade800 : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
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
}
