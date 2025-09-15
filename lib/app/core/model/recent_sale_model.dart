// lib/app/core/model/recent_sale_model.dart
class RecentSaleModel {
  final int nroProposta;
  final DateTime createdAt;
  final String planoNome;
  final String? cpfTitular;
  final int vidas;
  final double? valor; // mensalidade total

  RecentSaleModel({
    required this.nroProposta,
    required this.createdAt,
    required this.planoNome,
    this.cpfTitular,
    required this.vidas,
    required this.valor,
  });

  factory RecentSaleModel.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic v) =>
        v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
     double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();

      final s = v.toString().trim();
      if (s.isEmpty) return 0.0;

      // Se tiver vírgula, trata como "pt_BR": remove separador de milhar (.)
      // e troca vírgula por ponto. Caso contrário, assume que o ponto é decimal.
      if (s.contains(',')) {
        final cleaned = s.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return double.tryParse(s) ?? 0.0;
    }

    final dtRaw = map['created_at'] ?? map['dt_ref'] ?? map['data'];
    final dt = DateTime.tryParse('$dtRaw') ?? DateTime.now();

    return RecentSaleModel(
      nroProposta: parseInt(map['nro_proposta'] ?? map['nroProposta']),
      createdAt: dt,
      planoNome: (map['plano_nome'] ?? map['nome_contrato'] ?? '').toString(),
      cpfTitular: map['cpf']?.toString(),
      vidas: parseInt(map['vidas']),
      valor: _toDouble(map['valor_venda']),
    );
  }
}