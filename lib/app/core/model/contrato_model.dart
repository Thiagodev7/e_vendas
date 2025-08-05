class ContratoModel {
  final int idContrato;
  final int idPlano;
  final int idTipoCobranca;
  final int diaVencimento;
  final String dataAdesaoContratual;
  final String dataInicioCobranca;
  final String dataAdesaoPlano;
  final String dataInicioUso;
  final String observacao;
  final String nroProposta;

  /// Campos adicionais para exibição local
  final String nomePlano;
  final int vidas;

  ContratoModel({
    required this.idContrato,
    required this.idPlano,
    required this.idTipoCobranca,
    required this.diaVencimento,
    required this.dataAdesaoContratual,
    required this.dataInicioCobranca,
    required this.dataAdesaoPlano,
    required this.dataInicioUso,
    required this.observacao,
    required this.nroProposta,
    required this.nomePlano,
    required this.vidas,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      "id_contrato": idContrato,
      "id_plano": idPlano,
      "id_tipo_cobranca": idTipoCobranca,
      "dia_vencimento": diaVencimento,
      "data_adesao_contratual": dataAdesaoContratual,
      "data_inicio_cobranca": dataInicioCobranca,
      "data_adesao_plano": dataAdesaoPlano,
      "data_inicio_uso": dataInicioUso,
      "observacao": observacao,
      "nro_proposta": nroProposta,
      "nome_plano": nomePlano,
      "vidas": vidas,
    };
  }

  /// Construtor a partir de JSON
  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    return ContratoModel(
      idContrato: json["id_contrato"] ?? 0,
      idPlano: json["id_plano"] ?? 0,
      idTipoCobranca: json["id_tipo_cobranca"] ?? 0,
      diaVencimento: json["dia_vencimento"] ?? 0,
      dataAdesaoContratual: json["data_adesao_contratual"] ?? '',
      dataInicioCobranca: json["data_inicio_cobranca"] ?? '',
      dataAdesaoPlano: json["data_adesao_plano"] ?? '',
      dataInicioUso: json["data_inicio_uso"] ?? '',
      observacao: json["observacao"] ?? '',
      nroProposta: json["nro_proposta"] ?? '',
      nomePlano: json["nome_plano"] ?? '',
      vidas: json["vidas"] ?? 0,
    );
  }
}