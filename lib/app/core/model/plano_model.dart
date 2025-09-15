// lib/app/core/model/plano_model.dart
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

  /// NOVO: cobrança anual?
  final bool isAnnual;

  /// NOVO: dia de vencimento (apenas quando mensal). 1..28 recomendado
  final int? dueDay;

  const PlanModel({
    required this.id,
    required this.codigoPlano,
    required this.nroContrato,
    required this.nomeContrato,
    required this.values,
    this.vidasSelecionadas = 1,
    this.isAnnual = false,
    this.dueDay,
  });

  /// Conveniência
  int get months => isAnnual ? 12 : 1;

  PlanModel copyWith({
    int? id,
    String? codigoPlano,
    int? nroContrato,
    String? nomeContrato,
    List<ValuesOfContractModel>? values,
    int? vidasSelecionadas,
    bool? isAnnual,
    int? dueDay,
  }) {
    return PlanModel(
      id: id ?? this.id,
      codigoPlano: codigoPlano ?? this.codigoPlano,
      nroContrato: nroContrato ?? this.nroContrato,
      nomeContrato: nomeContrato ?? this.nomeContrato,
      values: values ?? this.values,
      vidasSelecionadas: vidasSelecionadas ?? this.vidasSelecionadas,
      isAnnual: isAnnual ?? this.isAnnual,
      // quando anual, dueDay precisa ser null
      dueDay: (isAnnual ?? this.isAnnual) ? null : (dueDay ?? this.dueDay),
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
      // Backend novo
      'is_anual': isAnnual,
      'dia_vencimento': isAnnual ? null : dueDay,
    };
  }

  /// Payload exatamente no formato do backend
  Map<String, dynamic> toBackendMap() => {
        'nro_contrato': nroContrato,
        'vidas': vidasSelecionadas,
        'is_anual': isAnnual,
        'dia_vencimento': isAnnual ? null : (dueDay ?? 10),
      };

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    final int id =
        map['id'] is int ? map['id'] : (int.tryParse('${map['id']}') ?? 0);
    final int nroContrato = map['nro_contrato'] is int
        ? map['nro_contrato']
        : (int.tryParse('${map['nro_contrato']}') ?? 0);

    final bool isAnnual = _asBool(map['is_anual']) ?? false;
    final int? dueDay =
        isAnnual ? null : _asInt(map['dia_vencimento']); // mensal => dia

    final rawValues = (map['values'] as List?) ?? const [];
    final values = rawValues
        .map((x) => ValuesOfContractModel.fromMap(
              x as Map<String, dynamic>,
            ))
        .toList();

    return PlanModel(
      id: id,
      codigoPlano: (map['codigo_plano'] ?? map['codigoPlano'] ?? '').toString(),
      nroContrato: nroContrato,
      nomeContrato:
          (map['nome_contrato'] ?? map['nomeContrato'] ?? '').toString(),
      values: values,
      vidasSelecionadas:
          _asInt(map['vidas_selecionadas'] ?? map['vidasSelecionadas']) ?? 1,
      isAnnual: isAnnual,
      dueDay: dueDay,
    );
  }

  String toJson() => json.encode(toMap());
  factory PlanModel.fromJson(String source) =>
      PlanModel.fromMap(json.decode(source));

  // ===== Helpers de valores (String, compatibilidade) =====
  String getMensalidade() {
    final mensal = _findValue('Mensalidade', vidasSelecionadas);
    return mensal?.valor ?? '0.00';
  }

  String getTaxaAdesao() {
    final adesao = _findValue('Taxa de Adesão', vidasSelecionadas);
    return adesao?.valor ?? '0.00';
  }

  String getMensalidadeTotal() {
    final mensal = _findValue('Mensalidade', vidasSelecionadas);
    return mensal?.valorTotal ?? '0.00';
  }

  String getTaxaAdesaoTotal() {
    final adesao = _findValue('Taxa de Adesão', vidasSelecionadas);
    return adesao?.valorTotal ?? '0.00';
  }

  String getAnualTotal() {
    final mensal = getMensalidadeTotalDouble();
    final anualComDesconto = mensal * 12 * 0.90;
    return anualComDesconto.toStringAsFixed(2);
  }

  // ===== NOVOS Helpers numéricos (double) =====

  /// Mensalidade unitária (por vida) como double.
  double getMensalidadeUnitDouble() => _parseMoneyToDouble(getMensalidade());

  /// Adesão unitária (por vida) como double.
  double getTaxaAdesaoUnitDouble() => _parseMoneyToDouble(getTaxaAdesao());

  /// Mensalidade total (todas as vidas) como double.
  double getMensalidadeTotalDouble() =>
      _parseMoneyToDouble(getMensalidadeTotal());

  /// Adesão total (todas as vidas) como double.
  double getTaxaAdesaoTotalDouble() =>
      _parseMoneyToDouble(getTaxaAdesaoTotal());

  /// Valor anual total com desconto de 10% como double.
  double getAnualTotalDouble() => getMensalidadeTotalDouble() * 12 * 0.90;

  // ===== Internos =====
  ValuesOfContractModel? _findValue(String descricao, int vidas) {
    try {
      return values.firstWhere(
        (v) => v.descricao == descricao && v.qtdeVida == vidas,
      );
    } catch (_) {
      return null;
    }
  }

  /// Parser de valores monetários:
  /// - "43,00" -> 43.00
  /// - "43.00" -> 43.00
  /// - "4300"  -> 43.00 (centavos)
  static double _parseMoneyToDouble(String? s) {
    if (s == null) return 0.0;
    final raw = s.trim();
    if (raw.isEmpty) return 0.0;

    // apenas dígitos => trata como centavos
    final onlyDigits = RegExp(r'^\d+$');
    if (onlyDigits.hasMatch(raw)) {
      final cents = int.tryParse(raw) ?? 0;
      return (cents / 100).toDouble();
    }

    // remove símbolos e normaliza separadores
    var cleaned = raw.replaceAll(RegExp(r'[^\d,\.]'), '');
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    if (lastComma > lastDot) {
      // estilo pt-BR: "1.234,56" -> "1234.56"
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // estilo en-US: "1,234.56" -> "1234.56"
      cleaned = cleaned.replaceAll(',', '');
    }

    var value = double.tryParse(cleaned) ?? 0.0;

    // heurística para casos "multiplicados por 100"
    if (value >= 1000) {
      final divided = value / 100.0;
      if (divided < 1000) value = divided;
    }
    return double.parse(value.toStringAsFixed(2));
  }

  @override
  String toString() {
    return 'PlanModel(id: $id, codigoPlano: $codigoPlano, vidasSelecionadas: $vidasSelecionadas, '
        'nomeContrato: $nomeContrato, isAnnual: $isAnnual, dueDay: $dueDay)';
  }

  // ===== parse helpers =====
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }
}