// lib/app/core/model/plan_model.dart
import 'dart:convert';

import 'package:e_vendas/app/core/model/values_of_ccontract_model.dart';


class PlanModel {
  final int id;
  final String codigoPlano;
  final int nroContrato;
  final String nomeContrato;
  final List<ValuesOfContractModel> values;

  PlanModel({
    required this.id,
    required this.codigoPlano,
    required this.nroContrato,
    required this.nomeContrato,
    required this.values,
  });

  PlanModel copyWith({
    int? id,
    String? codigoPlano,
    int? nroContrato,
    String? nomeContrato,
    List<ValuesOfContractModel>? values,
  }) {
    return PlanModel(
      id: id ?? this.id,
      codigoPlano: codigoPlano ?? this.codigoPlano,
      nroContrato: nroContrato ?? this.nroContrato,
      nomeContrato: nomeContrato ?? this.nomeContrato,
      values: values ?? this.values,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo_plano': codigoPlano,
      'nro_contrato': nroContrato,
      'nome_contrato': nomeContrato,
      'values': values.map((x) => x.toMap()).toList(),
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
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanModel.fromJson(String source) =>
      PlanModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PlanModel(id: $id, codigoPlano: $codigoPlano, nroContrato: $nroContrato, nomeContrato: $nomeContrato, values: $values)';
  }
}