class ContatoModel {
  final int idMeioComunicacao;
  final String? ddd;
  final String descricao;
  final String? contato;
  final String nomeContato;

  ContatoModel({
    required this.idMeioComunicacao,
     this.ddd,
    required this.descricao,
     this.contato,
    required this.nomeContato,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      "id_meio_comunicacao": idMeioComunicacao,
      "ddd": ddd,
      "descricao": descricao,
      "contato": contato,
      "nome_contato": nomeContato,
    };
  }

  /// Construtor a partir de JSON
  factory ContatoModel.fromJson(Map<String, dynamic> json) {
    return ContatoModel(
      idMeioComunicacao: json["id_meio_comunicacao"] ?? 0,
      ddd: json["ddd"] ?? '',
      descricao: json["descricao"] ?? '',
      contato: json["contato"] ?? '',
      nomeContato: json["nome_contato"] ?? '',
    );
  }
}