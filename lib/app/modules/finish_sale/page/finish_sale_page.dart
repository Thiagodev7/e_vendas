import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:e_vendas/app/core/theme/dashboard_layout.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FinishSalePage extends StatefulWidget {
  final int? vendaIndex;

  const FinishSalePage({super.key, this.vendaIndex});

  @override
  State<FinishSalePage> createState() => _FinishSalePageState();
}

class _FinishSalePageState extends State<FinishSalePage> {
  final finishStore = Modular.get<FinishSaleStore>();
  final salesStore = Modular.get<SalesStore>();

  @override
  Widget build(BuildContext context) {
    final venda = widget.vendaIndex != null && widget.vendaIndex! < salesStore.vendas.length
        ? salesStore.vendas[widget.vendaIndex!]
        : null;

    return DashboardLayout(
      title: 'Finalizar Venda',
      child: venda == null
          ? const Center(child: Text("Venda não encontrada"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo do titular
                  _buildSectionTitle("Titular"),
                  _buildCardInfo([
                    "Nome: ${venda.pessoaTitular?.nome ?? 'Não informado'}",
                    "CPF: ${venda.pessoaTitular?.cpf ?? 'Não informado'}",
                  ]),

                  const SizedBox(height: 16),

                  // Resumo do plano
                  _buildSectionTitle("Plano Selecionado"),
                  _buildCardInfo([
                    "Plano: ${venda.plano?.nomeContrato ?? 'Não selecionado'}",
                    "Código: ${venda.plano?.codigoPlano ?? ''}",
                    "Mensalidade: R\$ ${venda.plano?.getMensalidade() ?? '--'}",
                    "Taxa de Adesão: R\$ ${venda.plano?.getTaxaAdesao() ?? '--'}",
                    "Vidas: ${venda.plano?.vidasSelecionadas ?? 1}",
                  ]),

                  const SizedBox(height: 16),

                  // Resumo do endereço
                  _buildSectionTitle("Endereço"),
                  _buildCardInfo([
                    "Cidade: ${venda.endereco?.nomeCidade ?? ''}",
                    "Bairro: ${venda.endereco?.bairro ?? ''}",
                    "Logradouro: ${venda.endereco?.logradouro ?? ''}",
                    "Número: ${venda.endereco?.numero ?? ''}",
                  ]),

                  const SizedBox(height: 16),

                  // Dependentes
                  if (venda.dependentes!.isNotEmpty) ...[
                    _buildSectionTitle("Dependentes"),
                    _buildCardInfo(
                      venda.dependentes!
                          .map((d) => "${d.nome} - Grau: ${d.idGrauDependencia ?? ''}")
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.receipt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            finishStore.gerarPagamento(venda);
                          },
                          label: const Text("Gerar Pagamento"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.description),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            finishStore.gerarContrato(venda);
                          },
                          label: const Text("Gerar Contrato"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCardInfo(List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((text) => Text(text)).toList(),
      ),
    );
  }
}