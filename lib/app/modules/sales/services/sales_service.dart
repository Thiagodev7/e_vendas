import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';

class SalesService {
  final Dio _dio = ApiClient().dio;

  // Rotas alinhadas com o backend atual (PropostaController)
  static const String _createProposalPath = '/database/propostas/full';
  static String _updateStatusPath(int nro) => '/database/propostas/$nro/status';
  static String _deleteProposalPath(int nro) => '/database/propostas/$nro';

  // =======================================================
  // LISTAR PROPOSTAS ABERTAS (com enriquecimento CPF/CEP)
  // =======================================================
  Future<List<VendaModel>> fetchOpenProposals({required int vendedorId}) async {
    try {
      final r = await _dio.get(
        '/database/propostas/abertas',
        queryParameters: {'vendedorId': vendedorId},
      );

      final data = r.data;
      if (data is! List) {
        throw Exception('Resposta inválida ao buscar propostas (lista ausente)');
      }

      // fromProposalJson já mapeia pagamentoConcluido / contratoAssinado / vendaFinalizada
      final base = data
          .cast<Map<String, dynamic>>()
          .map((e) => VendaModel.fromProposalJson(e))
          .toList();

      final enriched = await _enrichVendas(base);
      return enriched;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao buscar propostas'));
    } catch (e) {
      throw Exception('Erro inesperado ao buscar propostas: $e');
    }
  }

  // =======================================================
  // CRIAR PROPOSTA
  // =======================================================
  Future<int> criarProposta(
    VendaModel v, {
    required int vendedorId,
    int? gatewayPagamentoId,
  }) async {
    try {
      final payload =
          _mapVendaToCreatePayload(v, vendedorId, gatewayPagamentoId: gatewayPagamentoId);

      final res = await _dio.post(_createProposalPath, data: payload);

      final id = _extractPropostaId(res.data);
      if (id == null) {
        throw Exception('Resposta inválida ao criar proposta (ID ausente)');
      }
      return id;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao criar proposta'));
    } catch (e) {
      throw Exception('Erro inesperado ao criar proposta: $e');
    }
  }

  // =======================================================
  // ATUALIZAR STATUS (flags de proposta)
  // =======================================================
  Future<void> atualizarStatusProposta({
    required int nroProposta,
    bool? vendaFinalizada,
    bool? pagamentoConcluido,
    bool? contratoAssinado,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (vendaFinalizada != null) body['vendaFinalizada'] = vendaFinalizada;
      if (pagamentoConcluido != null) body['pagamentoConcluido'] = pagamentoConcluido;
      if (contratoAssinado != null) body['contratoAssinado'] = contratoAssinado;

      await _dio.put(_updateStatusPath(nroProposta), data: body);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao atualizar status da proposta'));
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar status: $e');
    }
  }

  // Atalhos úteis (opcionais)
  Future<void> marcarPagamentoConcluido({
    required int nroProposta,
    required bool value,
  }) =>
      atualizarStatusProposta(
        nroProposta: nroProposta,
        pagamentoConcluido: value,
      );

  Future<void> marcarContratoAssinado({
    required int nroProposta,
    required bool value,
  }) =>
      atualizarStatusProposta(
        nroProposta: nroProposta,
        contratoAssinado: value,
      );

  // =======================================================
  // EXCLUIR (soft delete) PROPOSTA
  // =======================================================
  Future<void> excluirProposta({required int nroProposta}) async {
    try {
      await _dio.delete(_deleteProposalPath(nroProposta));
    } on DioException catch (e) {
      final sc = e.response?.statusCode ?? 0;
      if (sc == 404 || sc == 405) {
        // Fallback: marca como finalizada
        await atualizarStatusProposta(
          nroProposta: nroProposta,
          vendaFinalizada: true,
        );
        return;
      }
      throw Exception(_handleDioError(e, 'Erro ao excluir proposta'));
    } catch (e) {
      throw Exception('Erro inesperado ao excluir proposta: $e');
    }
  }

  // =======================================================
  // MAPEAR VENDA -> PAYLOAD (com sanitização)
  // =======================================================
  String _digits(String? v) => (v ?? '').replaceAll(RegExp(r'\D'), '');
  int? _tryParseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  int? _extractPropostaId(dynamic data) {
    if (data is! Map) return null;
    // Aceita várias chaves que o backend pode retornar
    return _tryParseInt(
          data['nro_proposta'] ??
          data['propostaId'] ??
          data['id'] ??
          data['nroProposta'],
        ) ??
        _tryParseInt((data['data'] ?? const {})['nro_proposta']);
  }

  Map<String, dynamic> _mapVendaToCreatePayload(
    VendaModel v,
    int vendedorId, {
    int? gatewayPagamentoId,
  }) {
    final titular = v.pessoaTitular;
    final resp = v.pessoaResponsavelFinanceiro;
    final end = v.endereco;
    final contatos = v.contatos ?? <ContatoModel>[];

    final vidas = (v.dependentes?.length ?? 0) + 1;
    final mensalTotal = v.plano?.getMensalidadeTotal();
    final adesaoTotal = v.plano?.getTaxaAdesaoTotal();

    return {
      'vendedor_id': vendedorId,
      if (gatewayPagamentoId != null) 'gateway_pagamento_id': gatewayPagamentoId,

      // Plano (backend resolve por contrato_id OU nro_contrato)
      'plano': {
        'nro_contrato': v.plano?.nroContrato,
        'vidas': vidas,
        if (mensalTotal != null) 'mensalidade_total': mensalTotal,
        if (adesaoTotal != null) 'adesao_total': adesaoTotal,
      },

      // Titular
      'titular': {
        'cpf': _digits(titular?.cpf),
        'estado_civil': titular?.idEstadoCivil,
      },

      // Responsável Financeiro (opcional)
      if (resp != null)
        'responsavel_financeiro': {
          'cpf': _digits(resp.cpf),
          'estado_civil': resp.idEstadoCivil,
        },

      // Endereço (titular)
      if (end != null)
        'endereco': {
          'cep': _digits(end.cep),
          'numero': end.numero?.toString(),
          'complemento': end.complemento,
        },

      // Contatos (titular)
      'contatos': contatos
          .where((c) => (c.idMeioComunicacao != null && c.descricao.isNotEmpty))
          .map((c) => {
                'meio_comunicacao_id': c.idMeioComunicacao,
                'descricao': c.descricao,
              })
          .toList(),

      // Dependentes
      'dependentes': (v.dependentes ?? [])
          .where((d) => (d.cpf?.isNotEmpty ?? false))
          .map((d) => {
                'cpf': _digits(d.cpf),
                'grau_dependencia_id': d.idGrauDependencia,
                'estado_civil': d.idEstadoCivil,
              })
          .toList(),
    };
  }

  // =======================================================
  // ENRIQUECIMENTO (CPF / CEP) PARA A SalesPage
  // =======================================================
  Future<List<VendaModel>> _enrichVendas(List<VendaModel> list) async {
    const maxConcurrent = 4;
    final out = <VendaModel>[];

    for (var i = 0; i < list.length; i += maxConcurrent) {
      final end = (i + maxConcurrent > list.length) ? list.length : i + maxConcurrent;
      final slice = list.sublist(i, end);
      final futures = slice.map(_enrichVenda);
      final chunk = await Future.wait(futures);
      out.addAll(chunk);
    }
    return out;
  }

  Future<VendaModel> _enrichVenda(VendaModel v) async {
    try {
      final updatedTitular = v.pessoaTitular == null
          ? null
          : await _buscarPessoaSafely(v.pessoaTitular!);

      final updatedResp = v.pessoaResponsavelFinanceiro == null
          ? null
          : await _buscarPessoaSafely(v.pessoaResponsavelFinanceiro!);

      List<PessoaModel>? updatedDeps;
      if (v.dependentes != null && v.dependentes!.isNotEmpty) {
        updatedDeps = await Future.wait(
          v.dependentes!.map((d) => _buscarPessoaSafely(d)),
        );
      }

      EnderecoModel? updatedEndereco = v.endereco;
      final cep = v.endereco?.cep;
      if (cep != null && cep.trim().isNotEmpty) {
        updatedEndereco = await _buscarCepMerge(cep, v.endereco);
      }

      return v.copyWith(
        pessoaTitular: updatedTitular ?? v.pessoaTitular,
        pessoaResponsavelFinanceiro: updatedResp ?? v.pessoaResponsavelFinanceiro,
        dependentes: updatedDeps ?? v.dependentes,
        endereco: updatedEndereco ?? v.endereco,
      );
    } catch (_) {
      // Se qualquer enriquecimento falhar, retorna a venda original
      return v;
    }
  }

  Future<PessoaModel> _buscarPessoaSafely(PessoaModel current) async {
    final cpf = current.cpf;
    if (cpf == null || cpf.isEmpty) return current;
    try {
      final p = await _buscarPorCpf(_digits(cpf));
      return p.copyWith(
        cpf: current.cpf,
        idEstadoCivil: current.idEstadoCivil,
        idGrauDependencia: current.idGrauDependencia,
      );
    } catch (_) {
      return current;
    }
  }

  Future<EnderecoModel?> _buscarCepMerge(String cep, EnderecoModel? current) async {
    try {
      final e = await _buscarCep(_digits(cep));
      return e.copyWith(
        numero: current?.numero,
        complemento: current?.complemento,
      );
    } catch (_) {
      return current;
    }
  }

  // =======================================================
  // HTTP helpers (CPF / CEP) – usados no enriquecimento
  // =======================================================
  Future<EnderecoModel> _buscarCep(String cep) async {
    final res = await _dio.post('/database/postCep', data: {'cep': cep});
    final data = res.data;
    if (data is Map<String, dynamic> && data['erro'] == 'true') {
      throw Exception('CEP não encontrado');
    }
    return EnderecoModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<PessoaModel> _buscarPorCpf(String cpf) async {
    final res = await _dio.post('/datanext/postcadSus', data: {'cpf': cpf});
    final data = res.data;
    if (data is Map && data['data'] != null && data['data'].isNotEmpty) {
      final registro = data['data'][0];
      if (registro['resultado'] == 0) {
        throw Exception('CPF não encontrado');
      }
      return PessoaModel.fromCpfJson(Map<String, dynamic>.from(registro));
    }
    throw Exception('CPF não encontrado');
  }

  // =======================================================
  // Tratamento de erros (Dio) – mensagens ricas
  // =======================================================
  String _formatServerError(dynamic data, int? status) {
    if (data is Map) {
      final msg = [
        data['message'],
        data['detalhe'],
        data['error_description'],
        data['error'],
      ]
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .join(' | ');
      if (msg.isNotEmpty) return '[HTTP ${status ?? '-'}] $msg';
      return '[HTTP ${status ?? '-'}] ${data.toString()}';
    }
    return '[HTTP ${status ?? '-'}] ${data?.toString() ?? 'Erro desconhecido'}';
  }

  String _handleDioError(DioException e, String defaultMessage) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (status != null) {
      if (status == 422 || status == 400) {
        return _formatServerError(data, status);
      }
      if (data != null) {
        return _formatServerError(data, status);
      }
      return '$defaultMessage (HTTP $status)';
    }
    return defaultMessage;
  }
}