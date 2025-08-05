// lib/app/core/model/values_of_contract_model.dart
import 'dart:convert';

class ValuesOfContractModel {
  final String plano;
  final String descricao;
  final int qtdeVida;
  final String valor;
  final String valorTotal;

  ValuesOfContractModel({
    required this.plano,
    required this.descricao,
    required this.qtdeVida,
    required this.valor,
    required this.valorTotal,
  });

  ValuesOfContractModel copyWith({
    String? plano,
    String? descricao,
    int? qtdeVida,
    String? valor,
    String? valorTotal,
  }) {
    return ValuesOfContractModel(
      plano: plano ?? this.plano,
      descricao: descricao ?? this.descricao,
      qtdeVida: qtdeVida ?? this.qtdeVida,
      valor: valor ?? this.valor,
      valorTotal: valorTotal ?? this.valorTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plano': plano,
      'descricao': descricao,
      'qtde_vida': qtdeVida,
      'valor': valor,
      'valor_total': valorTotal,
    };
  }

  factory ValuesOfContractModel.fromMap(Map<String, dynamic> map) {
    return ValuesOfContractModel(
      plano: map['plano'] ?? '',
      descricao: map['descricao'] ?? '',
      qtdeVida: map['qtde_vida'] ?? 0,
      valor: map['valor'] ?? '',
      valorTotal: map['valor_total'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ValuesOfContractModel.fromJson(String source) =>
      ValuesOfContractModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ValuesOfContractModel(plano: $plano, descricao: $descricao, qtdeVida: $qtdeVida, valor: $valor, valorTotal: $valorTotal)';
  }
}