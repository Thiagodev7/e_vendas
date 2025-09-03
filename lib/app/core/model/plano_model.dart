// lib/app/core/model/plano_model.dart
import 'dart:convert';
import 'package:e_vendas/app/core/model/values_of_ccontract_model.dart';

/// Ciclo de cobrança do plano
enum BillingCycle { mensal, anual }

class PlanModel {
  final int id;
  final String codigoPlano;
  final int nroContrato;
  final String nomeContrato;
  final List<ValuesOfContractModel> values;

  /// Quantidade de vidas selecionadas
  final int vidasSelecionadas;

  /// NOVO: ciclo de cobrança (mensal/anual)
  final BillingCycle billingCycle;

  /// NOVO: dia de vencimento (apenas quando mensal). 1..28 recomendado
  final int? dueDay;

  PlanModel({
    required this.id,
    required this.codigoPlano,
    required this.nroContrato,
    required this.nomeContrato,
    required this.values,
    this.vidasSelecionadas = 1,
    this.billingCycle = BillingCycle.mensal,
    this.dueDay,
  });

  PlanModel copyWith({
    int? id,
    String? codigoPlano,
    int? nroContrato,
    String? nomeContrato,
    List<ValuesOfContractModel>? values,
    int? vidasSelecionadas,
    BillingCycle? billingCycle,
    int? dueDay,
  }) {
    return PlanModel(
      id: id ?? this.id,
      codigoPlano: codigoPlano ?? this.codigoPlano,
      nroContrato: nroContrato ?? this.nroContrato,
      nomeContrato: nomeContrato ?? this.nomeContrato,
      values: values ?? this.values,
      vidasSelecionadas: vidasSelecionadas ?? this.vidasSelecionadas,
      billingCycle: billingCycle ?? this.billingCycle,
      dueDay: dueDay ?? this.dueDay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo_plano': codigoPlano,
      'nro_contrato': nroContrato,
      'nome_contrato': nomeContrato,
      'values': values.map((x) => x.toMap()).toList(),
      'vidas_selecionadas': vidasSelecionadas,
      'billing_cycle': billingCycle.name, // 'mensal' | 'anual'
      'due_day': dueDay,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'] ?? 0,
      codigoPlano: map['codigo_plano'] ?? '',
      nroContrato: map['nro_contrato'] ?? 0,
      nomeContrato: map['nome_contrato'] ?? '',
      values: List<ValuesOfContractModel>.from(
        (map['values'] as List<dynamic>).map(
          (x) => ValuesOfContractModel.fromMap(x),
        ),
      ),
      vidasSelecionadas: map['vidas_selecionadas'] ?? 1,
      billingCycle: _parseCycle(map['billing_cycle']),
      dueDay: map['due_day'],
    );
  }

  static BillingCycle _parseCycle(dynamic raw) {
    final s = (raw ?? 'mensal').toString().toLowerCase();
    return s == 'anual' ? BillingCycle.anual : BillingCycle.mensal;
  }

  String toJson() => json.encode(toMap());

  factory PlanModel.fromJson(String source) =>
      PlanModel.fromMap(json.decode(source));

  /// Valor unitário da mensalidade p/ a qtde de vidas selecionadas
  String getMensalidade() {
    final mensal = values.firstWhere(
      (v) => v.descricao == 'Mensalidade' && v.qtdeVida == vidasSelecionadas,
      orElse: () => ValuesOfContractModel(
        plano: nomeContrato,
        descricao: 'Mensalidade',
        qtdeVida: vidasSelecionadas,
        valor: '0.00',
        valorTotal: '0.00',
      ),
    );
    return mensal.valor;
  }

  /// Valor unitário da taxa de adesão p/ a qtde de vidas selecionadas
  String getTaxaAdesao() {
    final adesao = values.firstWhere(
      (v) => v.descricao == 'Taxa de Adesão' && v.qtdeVida == vidasSelecionadas,
      orElse: () => ValuesOfContractModel(
        plano: nomeContrato,
        descricao: 'Taxa de Adesão',
        qtdeVida: vidasSelecionadas,
        valor: '0.00',
        valorTotal: '0.00',
      ),
    );
    return adesao.valor;
  }

  /// Total mensal (somando todas as vidas)
  String getMensalidadeTotal() {
    final mensal = values.firstWhere(
      (v) => v.descricao == 'Mensalidade' && v.qtdeVida == vidasSelecionadas,
      orElse: () => ValuesOfContractModel(
        plano: nomeContrato,
        descricao: 'Mensalidade',
        qtdeVida: vidasSelecionadas,
        valor: '0.00',
        valorTotal: '0.00',
      ),
    );
    return mensal.valorTotal;
  }

  /// Total da taxa de adesão (somando todas as vidas)
  String getTaxaAdesaoTotal() {
    final adesao = values.firstWhere(
      (v) => v.descricao == 'Taxa de Adesão' && v.qtdeVida == vidasSelecionadas,
      orElse: () => ValuesOfContractModel(
        plano: nomeContrato,
        descricao: 'Taxa de Adesão',
        qtdeVida: vidasSelecionadas,
        valor: '0.00',
        valorTotal: '0.00',
      ),
    );
    return adesao.valorTotal;
  }

  String getAnualTotal() {
  final mensal = double.tryParse(getMensalidadeTotal().replaceAll(',', '.')) ?? 0.0;
  final anualComDesconto = mensal * 12 * 0.90;
  return anualComDesconto.toStringAsFixed(2);
}

  @override
  String toString() {
    return 'PlanModel(id: $id, codigoPlano: $codigoPlano, vidasSelecionadas: $vidasSelecionadas, '
           'nomeContrato: $nomeContrato, billingCycle: ${billingCycle.name}, dueDay: $dueDay)';
  }
}