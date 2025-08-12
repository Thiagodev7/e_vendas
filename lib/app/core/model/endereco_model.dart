// lib/app/core/model/endereco_model.dart

/// Modelo que representa o endereço do cliente
class EnderecoModel {
  final int idCidade;
  final int idTipoLogradouro;
  final String nomeCidade;
  final String siglaUf;
  final String cep;
  final String bairro;
  final String logradouro;
  final int numero;
  final String complemento;

  EnderecoModel({
    required this.idCidade,
    required this.idTipoLogradouro,
    required this.nomeCidade,
    required this.siglaUf,
    required this.cep,
    required this.bairro,
    required this.logradouro,
    required this.numero,
    required this.complemento,
  });

  /// Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      "id_cidade": idCidade,
      "id_tipo_logradouro": idTipoLogradouro,
      "nome_cidade": nomeCidade,
      "sigla_uf": siglaUf,
      "cep": cep,
      "bairro": bairro,
      "logradouro": logradouro,
      "numero": numero,
      "complemento": complemento,
    };
  }

  /// **CORRIGIDO:** Cria o modelo a partir de um JSON, tratando o tipo do campo 'numero'.
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    // Lógica para converter o campo 'numero' de forma segura
    int numeroConvertido = 0;
    final numeroJson = json['numero'];

    if (numeroJson is int) {
      numeroConvertido = numeroJson;
    } else if (numeroJson is String) {
      // Tenta converter a String para int. Se falhar, usa 0.
      numeroConvertido = int.tryParse(numeroJson) ?? 0;
    }

    return EnderecoModel(
      idCidade: json["id_cidade"] ?? 0,
      idTipoLogradouro: json["id_tipo_logradouro"] ?? 1, // Padrão: Rua
      nomeCidade: json["nome_cidade"] ?? json["localidade"] ?? '',
      siglaUf: json["sigla_uf"] ?? json["uf"] ?? '',
      cep: json["cep"] ?? '',
      bairro: json["bairro"] ?? '',
      logradouro: json["logradouro"] ?? '',
      numero: numeroConvertido, // << USA O VALOR CONVERTIDO
      complemento: json["complemento"] ?? '',
    );
  }

  /// Cria uma cópia do modelo com valores atualizados
  EnderecoModel copyWith({
    int? idCidade,
    int? idTipoLogradouro,
    String? nomeCidade,
    String? siglaUf,
    String? cep,
    String? bairro,
    String? logradouro,
    int? numero,
    String? complemento,
  }) {
    return EnderecoModel(
      idCidade: idCidade ?? this.idCidade,
      idTipoLogradouro: idTipoLogradouro ?? this.idTipoLogradouro,
      nomeCidade: nomeCidade ?? this.nomeCidade,
      siglaUf: siglaUf ?? this.siglaUf,
      cep: cep ?? this.cep,
      bairro: bairro ?? this.bairro,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
    );
  }
}