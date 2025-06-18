class VendedorModel {
  final int id;
  final String cpf;
  final String nomeCompleto;
  final String localAtuacao;
  final String email;

  VendedorModel({
    required this.id,
    required this.cpf,
    required this.nomeCompleto,
    required this.localAtuacao,
    required this.email,
  });

  /// 🔄 Construtor para transformar JSON em objeto
  factory VendedorModel.fromJson(Map<String, dynamic> json) {
    return VendedorModel(
      id: json['id'],
      cpf: json['cpf'],
      nomeCompleto: json['nome_completo'],
      localAtuacao: json['local_atuacao'],
      email: json['email'],
    );
  }

  /// 🔄 Transforma objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cpf': cpf,
      'nome_completo': nomeCompleto,
      'local_atuacao': localAtuacao,
      'email': email,
    };
  }
}