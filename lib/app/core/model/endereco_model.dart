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

  /// Cria o modelo a partir de um JSON
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      idCidade: json["id_cidade"] ?? 0,
      idTipoLogradouro: json["id_tipo_logradouro"] ?? 1, // Padrão: Rua
      nomeCidade: json["localidade"] ?? '',
      siglaUf: json["uf"] ?? '',
      cep: json["cep"] ?? '',
      bairro: json["bairro"] ?? '',
      logradouro: json["logradouro"] ?? '',
      numero: json["numero"] ?? 0,
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