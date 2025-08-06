// lib/app/core/model/plan_model.dart
import 'dart:convert';
import 'package:e_vendas/app/core/model/values_of_ccontract_model.dart';

class PlanModel {
  final int id;
  final String codigoPlano;
  final int nroContrato;
  final String nomeContrato;
  final List<ValuesOfContractModel> values;

  /// Quantidade de vidas selecionadas
  final int vidasSelecionadas;

  PlanModel({
    required this.id,
    required this.codigoPlano,
    required this.nroContrato,
    required this.nomeContrato,
    required this.values,
    this.vidasSelecionadas = 1,
  });

  PlanModel copyWith({
    int? id,
    String? codigoPlano,
    int? nroContrato,
    String? nomeContrato,
    List<ValuesOfContractModel>? values,
    int? vidasSelecionadas,
  }) {
    return PlanModel(
      id: id ?? this.id,
      codigoPlano: codigoPlano ?? this.codigoPlano,
      nroContrato: nroContrato ?? this.nroContrato,
      nomeContrato: nomeContrato ?? this.nomeContrato,
      values: values ?? this.values,
      vidasSelecionadas: vidasSelecionadas ?? this.vidasSelecionadas,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanModel.fromJson(String source) =>
      PlanModel.fromMap(json.decode(source));

  /// Valor da mensalidade de acordo com vidasSelecionadas
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

  /// Valor da taxa de adesão de acordo com vidasSelecionadas
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

  /// Valor da mensalidade de acordo com vidasSelecionadas
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

  /// Valor da taxa de adesão de acordo com vidasSelecionadas
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

  @override
  String toString() {
    return 'PlanModel(id: $id, codigoPlano: $codigoPlano, vidasSelecionadas: $vidasSelecionadas, nomeContrato: $nomeContrato)';
  }
}