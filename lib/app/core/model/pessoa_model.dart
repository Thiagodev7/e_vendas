/// Modelo que representa uma pessoa (titular, responsável ou dependente)
class PessoaModel {
  final int idSexo;
  final int idEstadoCivil;
  final String nome;
  final String dataNascimento;
  final String nomeMae;
  final String nomePai;
   String cpf;
  final String rg;
  final String rgDataEmissao;
  final String rgOrgaoEmissor;
  final String cns;
  final String naturalde;
  final String observacao;
  final int idOrigem;

  /// Campos extras para dependentes
  final int? idGrauDependencia;
  final String? carteirinhaOrigem;

  PessoaModel({
    required this.idSexo,
    required this.idEstadoCivil,
    required this.nome,
    required this.dataNascimento,
    required this.nomeMae,
    required this.nomePai,
    required this.cpf,
    required this.rg,
    required this.rgDataEmissao,
    required this.rgOrgaoEmissor,
    required this.cns,
    required this.naturalde,
    required this.observacao,
    required this.idOrigem,
    this.idGrauDependencia,
    this.carteirinhaOrigem,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    final data = {
      "id_sexo": idSexo,
      "id_estado_civil": idEstadoCivil,
      "nome": nome,
      "data_nascimento": dataNascimento,
      "nome_mae": nomeMae,
      "nome_pai": nomePai,
      "cpf": cpf,
      "rg": rg,
      "rg_data_emissao": rgDataEmissao,
      "rg_orgao_emissor": rgOrgaoEmissor,
      "cns": cns,
      "naturalde": naturalde,
      "observacao": observacao,
      "id_origem": idOrigem,
    };

    if (idGrauDependencia != null) {
      data["id_grau_dependencia"] = idGrauDependencia!;
    }
    if (carteirinhaOrigem != null) {
      data["carteirinha_origem"] = carteirinhaOrigem!;
    }

    return data;
  }

  /// Cria modelo a partir de JSON do backend
  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      idSexo: json["id_sexo"] ?? 0,
      idEstadoCivil: json["id_estado_civil"] ?? 0,
      nome: json["nome"] ?? '',
      dataNascimento: json["data_nascimento"] ?? '',
      nomeMae: json["nome_mae"] ?? '',
      nomePai: json["nome_pai"] ?? '',
      cpf: json["cpf"] ?? '',
      rg: json["rg"] ?? '',
      rgDataEmissao: json["rg_data_emissao"] ?? '',
      rgOrgaoEmissor: json["rg_orgao_emissor"] ?? '',
      cns: json["cns"] ?? '',
      naturalde: json["naturalde"] ?? '',
      observacao: json["observacao"] ?? '',
      idOrigem: json["id_origem"] ?? 0,
      idGrauDependencia: json["id_grau_dependencia"],
      carteirinhaOrigem: json["carteirinha_origem"],
    );
  }

  /// Cria modelo a partir do retorno de CPF (API CadSUS)
  factory PessoaModel.fromCpfJson(Map<String, dynamic> json) {
    return PessoaModel(
      idSexo: json["Sexo"] ?? 0,
      idEstadoCivil: 0, // API CadSUS não retorna estado civil
      nome: json["Nome"] ?? '',
      dataNascimento: json["DataNascimento"] ?? '',
      nomeMae: json["Mae"] ?? '',
      nomePai: json["Pai"] ?? '',
      cpf: '', // CPF não vem no CadSUS
      rg: '',
      rgDataEmissao: '',
      rgOrgaoEmissor: '',
      cns: json["CNS"] ?? '',
      naturalde: '',
      observacao: '',
      idOrigem: 5433, // Valor padrão de origem do sistema
    );
  }

  /// Cria uma cópia com valores atualizados
  PessoaModel copyWith({
    int? idSexo,
    int? idEstadoCivil,
    String? nome,
    String? dataNascimento,
    String? nomeMae,
    String? nomePai,
    String? cpf,
    String? rg,
    String? rgDataEmissao,
    String? rgOrgaoEmissor,
    String? cns,
    String? naturalde,
    String? observacao,
    int? idOrigem,
    int? idGrauDependencia,
    String? carteirinhaOrigem,
  }) {
    return PessoaModel(
      idSexo: idSexo ?? this.idSexo,
      idEstadoCivil: idEstadoCivil ?? this.idEstadoCivil,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      nomeMae: nomeMae ?? this.nomeMae,
      nomePai: nomePai ?? this.nomePai,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      rgDataEmissao: rgDataEmissao ?? this.rgDataEmissao,
      rgOrgaoEmissor: rgOrgaoEmissor ?? this.rgOrgaoEmissor,
      cns: cns ?? this.cns,
      naturalde: naturalde ?? this.naturalde,
      observacao: observacao ?? this.observacao,
      idOrigem: idOrigem ?? this.idOrigem,
      idGrauDependencia: idGrauDependencia ?? this.idGrauDependencia,
      carteirinhaOrigem: carteirinhaOrigem ?? this.carteirinhaOrigem,
    );
  }
}