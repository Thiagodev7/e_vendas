class PlanoModel {
  final int id;
  final String codigoPlano;
  final int nroContrato;
  final String nomeContrato;
  final int diasCarencia;
  final List<PlanoValorModel> valores;

  PlanoModel({
    required this.id,
    required this.codigoPlano,
    required this.nroContrato,
    required this.nomeContrato,
    required this.diasCarencia,
    required this.valores,
  });

  factory PlanoModel.fromJson(Map<String, dynamic> json) {
    return PlanoModel(
      id: json['id'],
      codigoPlano: json['codigo_plano'],
      nroContrato: json['nro_contrato'],
      nomeContrato: json['nome_contrato'],
      diasCarencia: json['dias_carencia'],
      valores: (json['values'] as List)
          .map((e) => PlanoValorModel.fromJson(e))
          .toList(),
    );
  }
}

class PlanoValorModel {
  final String plano;
  final String descricao;
  final int qtdeVida;
  final String valor;
  final String valorTotal;

  PlanoValorModel({
    required this.plano,
    required this.descricao,
    required this.qtdeVida,
    required this.valor,
    required this.valorTotal,
  });

  factory PlanoValorModel.fromJson(Map<String, dynamic> json) {
    return PlanoValorModel(
      plano: json['plano'],
      descricao: json['descricao'],
      qtdeVida: json['qtde_vida'],
      valor: json['valor'],
      valorTotal: json['valor_total'],
    );
  }
}