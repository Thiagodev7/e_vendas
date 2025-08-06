import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

class VendaModel {
  final PessoaModel? pessoaTitular;
  final PessoaModel? pessoaResponsavelFinanceiro;
  final List<PessoaModel>? dependentes;
  final EnderecoModel? endereco;
  final List<ContatoModel>? contatos;
  final PlanModel? plano;

  VendaModel({
    this.pessoaTitular,
    this.pessoaResponsavelFinanceiro,
    this.dependentes,
    this.endereco,
    this.contatos,
    this.plano,
  });

  VendaModel copyWith({
    PessoaModel? pessoaTitular,
    PessoaModel? pessoaResponsavelFinanceiro,
    List<PessoaModel>? dependentes,
    EnderecoModel? endereco,
    List<ContatoModel>? contatos,
    PlanModel? plano,
  }) {
    return VendaModel(
      pessoaTitular: pessoaTitular ?? this.pessoaTitular,
      pessoaResponsavelFinanceiro:
          pessoaResponsavelFinanceiro ?? this.pessoaResponsavelFinanceiro,
      dependentes: dependentes ?? this.dependentes,
      endereco: endereco ?? this.endereco,
      contatos: contatos ?? this.contatos,
      plano: plano ?? this.plano,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pessoa_titular": pessoaTitular?.toJson(),
      "pessoa_responsavel_financeiro": pessoaResponsavelFinanceiro?.toJson(),
      "dependentes": dependentes?.map((e) => e.toJson()).toList(),
      "endereco": endereco?.toJson(),
      "contatos": contatos?.map((e) => e.toJson()).toList(),
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
          ? (json['dependentes'] as List)
              .map((e) => PessoaModel.fromJson(e))
              .toList()
          : [],
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'])
          : null,
      contatos: json['contatos'] != null
          ? (json['contatos'] as List)
              .map((e) => ContatoModel.fromJson(e))
              .toList()
          : [],
      plano:
          json['plano'] != null ? PlanModel.fromJson(json['plano']) : null,
    );
  }
}