import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

class VendaModel {
  final PessoaModel? pessoaTitular;
  final PessoaModel? pessoaResponsavelFinanceiro;
  final List<PessoaModel>? dependentes;
  final EnderecoModel? endereco;
  final List<ContatoModel>? contato;
  final PlanModel? plano; // Substituiu ContratoModel

  VendaModel({
    this.pessoaTitular,
    this.pessoaResponsavelFinanceiro,
    this.dependentes,
    this.endereco,
    this.contato,
    this.plano,
  });

  Map<String, dynamic> toJson() {
    return {
      "pessoa_titular": pessoaTitular?.toJson(),
      "pessoa_responsavel_financeiro": pessoaResponsavelFinanceiro?.toJson(),
      "dependentes": dependentes?.map((e) => e.toJson()).toList(),
      "endereco": endereco?.toJson(),
      "contato": contato?.map((e) => e.toJson()).toList(),
      "plano": plano?.toJson(),
    };
  }

  factory VendaModel.fromJson(Map<String, dynamic> json) {
    return VendaModel(
      pessoaTitular: json['pessoa_titular'] != null
          ? PessoaModel.fromJson(json['pessoa_titular'])
          : null,
      pessoaResponsavelFinanceiro: json['pessoa_responsavel_financeiro'] != null
          ? PessoaModel.fromJson(json['pessoa_responsavel_financeiro'])
          : null,
      dependentes: json['dependentes'] != null
          ? (json['dependentes'] as List<dynamic>)
              .map((e) => PessoaModel.fromJson(e))
              .toList()
          : [],
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'])
          : null,
      contato: json['contato'] != null
          ? (json['contato'] as List<dynamic>)
              .map((e) => ContatoModel.fromJson(e))
              .toList()
          : [],
      plano: json['plano'] != null
          ? PlanModel.fromJson(json['plano'])
          : null,
    );
  }
}