import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/panel.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/kv_list.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/resumo_valores_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/pagamento_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/contrato_card.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/finalizacao_card.dart';

// Stores
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_resumo_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart'; // legado/compat

class FinishSalePage extends StatefulWidget {
  final int? vendaIndex;
  final int? nroProposta;

  const FinishSalePage({super.key, this.vendaIndex, this.nroProposta});

  @override
  State<FinishSalePage> createState() => _FinishSalePageState();
}

class _FinishSalePageState extends State<FinishSalePage> {
  // Stores globais
  final salesStore     = Modular.get<SalesStore>();

  // Stores novas (divididas)
  final paymentStore   = Modular.get<FinishPaymentStore>();
  final contractStore  = Modular.get<FinishContractStore>();
  final resumoStore    = Modular.get<FinishResumoStore>();

  // Store antiga (ainda usada para finalizar venda)
  final legacyStore    = Modular.get<FinishSaleStore>();

  @override
  void initState() {
    super.initState();

    final venda = (widget.vendaIndex != null &&
            widget.vendaIndex! < salesStore.vendas.length)
        ? salesStore.vendas[widget.vendaIndex!]
        : null;

    if (venda != null) {
      final nro = widget.nroProposta ?? venda.nroProposta;

      // Binds para as stores novas
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

      // Sincroniza flags atuais do servidor sem travar UI
      contractStore.syncFlags();
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = paymentStore.venda ?? contractStore.venda;

    return DashboardLayout(
      title: 'Finalizar Venda',
      child: v == null
          ? const Center(child: Text('Venda não encontrada'))
          : LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 1160;

                final left = SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Panel(
                        icon: Icons.person_rounded,
                        title: 'Titular',
                        child: KvList(items: [
                          ('Nome', v.pessoaTitular?.nome ?? '-'),
                          ('CPF', v.pessoaTitular?.cpf ?? '-'),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      Panel(
                        icon: Icons.health_and_safety_rounded,
                        title: 'Plano',
                        child: KvList(items: [
                          ('Plano', v.plano?.nomeContrato ?? '-'),
                          if ((v.plano?.codigoPlano ?? '').isNotEmpty)
                            ('Código', v.plano?.codigoPlano ?? ''),
                          ('Vidas', '${(v.dependentes?.length ?? 0) + 1}'),
                        ]),
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
                            children: v.dependentes!
                                .map((d) => ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading:
                                          const Icon(Icons.person_outline),
                                      title: Text(d.nome ?? d.cpf ?? ''),
                                      subtitle: Text(
                                        'Grau: ${d.idGrauDependencia ?? ''}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );

                final right = SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const ResumoValoresCard(),
                      const SizedBox(height: 12),
                      // PagamentoCard precisa da venda atual
                      PagamentoCard(venda: v),
                      const SizedBox(height: 12),
                      const ContratoCard(),
                      const SizedBox(height: 12),
                      const FinalizacaoCard(),
                    ],
                  ),
                );

                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 6, child: left),
                      Expanded(flex: 5, child: right),
                    ],
                  );
                }
                return Column(children: [left, right]);
              },
            ),
    );
  }
}