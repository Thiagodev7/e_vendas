// lib/app/core/model/venda_model.dart
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

enum VendaOrigin { local, cloud }

class VendaModel {
  final PessoaModel? pessoaTitular;
  final PessoaModel? pessoaResponsavelFinanceiro;
  final List<PessoaModel>? dependentes;
  final EnderecoModel? endereco;
  final List<ContatoModel>? contatos;
  final PlanModel? plano;

  /// Identificador da proposta na nuvem (quando origin == cloud)
  final int? nroProposta;

  /// ID do gateway salvo no backend (agora guarda o myId como texto)
  final String? gatewayPagamentoId;

  /// ID do envelope DocuSign no backend (coluna `envelope_id`)
  final String? envelopeId;

  /// Sinalizadores da proposta (vêm do backend)
  final bool pagamentoConcluido;
  final bool contratoAssinado;
  final bool vendaFinalizada;

  /// Valor da venda (mensalidade total). Preenchido localmente ou vindo do back.
  final double? valorVenda;

  /// Origem (local x nuvem)
  final VendaOrigin origin;

  VendaModel({
    this.pessoaTitular,
    this.pessoaResponsavelFinanceiro,
    this.dependentes,
    this.endereco,
    this.contatos,
    this.plano,
    this.nroProposta,
    this.gatewayPagamentoId,
    this.envelopeId,
    this.origin = VendaOrigin.local,
    this.pagamentoConcluido = false,
    this.contratoAssinado = false,
    this.vendaFinalizada = false,
    this.valorVenda,
  });

  /// Vidas = dependentes + 1 (titular)
  int get vidasSelecionadas => (dependentes?.length ?? 0) + 1;

  VendaModel copyWith({
    PessoaModel? pessoaTitular,
    PessoaModel? pessoaResponsavelFinanceiro,
    List<PessoaModel>? dependentes,
    EnderecoModel? endereco,
    List<ContatoModel>? contatos,
    PlanModel? plano,
    int? nroProposta,
    VendaOrigin? origin,
    String? gatewayPagamentoId,
    String? envelopeId,
    bool? pagamentoConcluido,
    bool? contratoAssinado,
    bool? vendaFinalizada,
    double? valorVenda,
  }) {
    return VendaModel(
      pessoaTitular: pessoaTitular ?? this.pessoaTitular,
      pessoaResponsavelFinanceiro:
          pessoaResponsavelFinanceiro ?? this.pessoaResponsavelFinanceiro,
      dependentes: dependentes ?? this.dependentes,
      endereco: endereco ?? this.endereco,
      contatos: contatos ?? this.contatos,
      plano: plano ?? this.plano,
      nroProposta: nroProposta ?? this.nroProposta,
      origin: origin ?? this.origin,
      gatewayPagamentoId: gatewayPagamentoId ?? this.gatewayPagamentoId,
      envelopeId: envelopeId ?? this.envelopeId,
      pagamentoConcluido: pagamentoConcluido ?? this.pagamentoConcluido,
      contratoAssinado: contratoAssinado ?? this.contratoAssinado,
      vendaFinalizada: vendaFinalizada ?? this.vendaFinalizada,
      valorVenda: valorVenda ?? this.valorVenda,
    );
  }

  // --------- Persistência local ---------

  Map<String, dynamic> toLocalJson() {
    return {
      'pessoaTitular': pessoaTitular?.toJson(),
      'pessoaResponsavelFinanceiro': pessoaResponsavelFinanceiro?.toJson(),
      'dependentes': dependentes?.map((e) => e.toJson()).toList(),
      'endereco': endereco?.toJson(),
      'contatos': contatos?.map((e) => e.toJson()).toList(),
      'plano': plano?.toJson(),
      'nroProposta': nroProposta,
      'origin': origin.name,
      'gatewayPagamentoId': gatewayPagamentoId, // String (myId)
      'envelopeId': envelopeId, // persiste localmente em camelCase
      'pagamentoConcluido': pagamentoConcluido,
      'contratoAssinado': contratoAssinado,
      'vendaFinalizada': vendaFinalizada,
      'valorVenda': valorVenda,
    };
  }

  factory VendaModel.fromLocalJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String? _toStringOrNull(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    final nro = json['nroProposta'];
    final int? nroProp =
        (nro is int) ? nro : int.tryParse(nro?.toString() ?? '');

    return VendaModel(
      pessoaTitular: json['pessoaTitular'] != null
          ? PessoaModel.fromJson(json['pessoaTitular'])
          : null,
      pessoaResponsavelFinanceiro: json['pessoaResponsavelFinanceiro'] != null
          ? PessoaModel.fromJson(json['pessoaResponsavelFinanceiro'])
          : null,
      dependentes: (json['dependentes'] as List?)
          ?.map((e) => PessoaModel.fromJson(e))
          .toList(),
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'])
          : null,
      contatos: (json['contatos'] as List?)
          ?.map((e) => ContatoModel.fromJson(e))
          .toList(),
      plano: json['plano'] != null ? PlanModel.fromJson(json['plano']) : null,
      nroProposta: nroProp,
      origin: switch (json['origin']) {
        'cloud' => VendaOrigin.cloud,
        _ => VendaOrigin.local,
      },
      gatewayPagamentoId: _toStringOrNull(json['gatewayPagamentoId']),
      envelopeId: _toStringOrNull(json['envelopeId']),
      pagamentoConcluido: _asBool(json['pagamentoConcluido']),
      contratoAssinado: _asBool(json['contratoAssinado']),
      vendaFinalizada: _asBool(json['vendaFinalizada']),
      valorVenda: _toDouble(json['valorVenda']),
    );
  }

  /// Constrói a venda vinda do backend (propostas abertas)
  factory VendaModel.fromProposalJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String? _toStringOrNull(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    final dependentesList = (json['dependentes'] as List<dynamic>?)
        ?.map(
            (depJson) => PessoaModel.fromJson(depJson as Map<String, dynamic>))
        .toList();

    final contatosList = (json['contatos'] as List<dynamic>?)
        ?.map((cJson) => ContatoModel.fromJson(cJson as Map<String, dynamic>))
        .toList();

    final planBase = (json['plano'] != null)
        ? PlanModel.fromMap(json['plano'] as Map<String, dynamic>)
        : null;

    // nro_proposta pode vir como string/number
    final rawNro = json['nro_proposta'] ?? json['nroProposta'];
    final int? nroProp =
        (rawNro is int) ? rawNro : int.tryParse(rawNro?.toString() ?? '');

    // gateway_pagamento_id: aceita snake_case ou camelCase; sempre convertemos para String
    final String? gwId = _toStringOrNull(
        json['gateway_pagamento_id'] ?? json['gatewayPagamentoId']);

    // envelope_id: snake/camel
    final String? envId =
        _toStringOrNull(json['envelope_id'] ?? json['envelopeId']);

    // Suportar tanto "pessoaTitular" quanto "pessoatitular"
    final titularJson = (json['pessoaTitular'] ?? json['pessoatitular'])
        as Map<String, dynamic>?;
    final Map<String, dynamic>? respFinJson = (json[
                'pessoaResponsavelFinanceiro'] ??
            json['pessoaresponsavelfinanceiro'] ?? // ⬅️ forma do seu backend
            json[
                'responsavel_financeiro'] ?? // ⬅️ caso o back mude pra snake_case
            json['responsavelfinanceiro']) // ⬅️ variações comuns
        as Map<String, dynamic>?;

    final parcial = VendaModel(
      pessoaTitular:
          titularJson != null ? PessoaModel.fromJson(titularJson) : null,
      pessoaResponsavelFinanceiro:
          respFinJson != null ? PessoaModel.fromJson(respFinJson) : null,
      dependentes: dependentesList,
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'] as Map<String, dynamic>)
          : null,
      contatos: contatosList,
      nroProposta: nroProp,
      origin: VendaOrigin.cloud,
      gatewayPagamentoId: gwId, // << String (myId)
      envelopeId: envId,

      // flags (snake/camel)
      pagamentoConcluido:
          _asBool(json['pagamento_concluido'] ?? json['pagamentoConcluido']),
      contratoAssinado:
          _asBool(json['contrato_assinado'] ?? json['contratoAssinado']),
      vendaFinalizada:
          _asBool(json['venda_finalizada'] ?? json['vendaFinalizada']),

      // se o back retornar, guardamos
      valorVenda: _toDouble(json['valor_venda'] ?? json['valorVenda']),
    );

    // Ajusta vidas no plano após saber quantos dependentes tem
    final vidas = parcial.vidasSelecionadas;
    final planSynced =
        planBase != null ? planBase.copyWith(vidasSelecionadas: vidas) : null;

    return parcial.copyWith(plano: planSynced);
  }

  // --------- Helpers ---------

  static bool _asBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes' || s == 'y' || s == 'sim';
  }
}