// lib/app/modules/sales/services/sales_service.dart

import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/values_of_ccontract_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';

/// Service responsável por operações de vendas
class SalesService {
  final Dio _dio = ApiClient().dio;

  /// Busca vendas em aberto de um vendedor e mapeia para [VendaModel].
  Future<List<VendaModel>> fetchOpenSales(int vendedorId) async {
    try {
      final response = await _dio.get(
        '/database/propostas/abertas',
        queryParameters: {'vendedorId': vendedorId},
      );

      final data = response.data as List<dynamic>;
      return data
          .map((json) => _mapVenda(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao buscar vendas'));
    } catch (e) {
      throw Exception('Erro inesperado ao buscar vendas: $e');
    }
  }

  /// Converte o JSON da API para [VendaModel], tratando campos divergentes.
  VendaModel _mapVenda(Map<String, dynamic> json) {
    final plano = _mapPlan(json['plano'] as Map<String, dynamic>?);

    return VendaModel(
      plano: plano,
      pessoaTitular: json['pessoatitular'] != null
          ? PessoaModel.fromJson(
              Map<String, dynamic>.from(json['pessoatitular']))
          : null,
      pessoaResponsavelFinanceiro: json['pessoaresponsavelfinanceiro'] != null
          ? PessoaModel.fromJson(
              Map<String, dynamic>.from(json['pessoaresponsavelfinanceiro']))
          : null,
      dependentes: (json['dependentes'] as List<dynamic>? ?? [])
          .map((e) =>
              PessoaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(
              Map<String, dynamic>.from(json['endereco']))
          : null,
      contatos: (json['contatos'] as List<dynamic>? ?? [])
          .map((e) =>
              ContatoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Mapeia o JSON de plano para [PlanModel] preenchendo valores padrão.
  PlanModel _mapPlan(Map<String, dynamic>? json) {
    if (json == null) {
      return PlanModel(
        id: 0,
        codigoPlano: '',
        nroContrato: 0,
        nomeContrato: '',
        values: [],
        vidasSelecionadas: 1,
      );
    }

    return PlanModel(
      id: json['id'] ?? 0,
      codigoPlano: json['codigo_plano'] ?? json['codigoPlano'] ?? '',
      nroContrato: json['nro_contrato'] ?? json['nroContrato'] ?? 0,
      nomeContrato: json['nome_contrato'] ?? json['nomeContrato'] ?? '',
      values: (json['values'] as List<dynamic>? ?? [])
          .map((e) => ValuesOfContractModel.fromMap(
              Map<String, dynamic>.from(e)))
          .toList(),
      vidasSelecionadas:
          json['vidas_selecionadas'] ?? json['vidasSelecionadas'] ?? 1,
    );
  }

  /// Salva a proposta completa na API
  Future<Response> salvarProposta(Map<String, dynamic> propostaData) async {
    try {
      const endpoint = '/database/propostas/full';
      final response = await _dio.post(endpoint, data: propostaData);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao salvar proposta'));
    } catch (e) {
      throw Exception('Erro inesperado ao salvar proposta: $e');
    }
  }

  /// Trata e formata erros do Dio
  String _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      return '$defaultMessage: ${e.response?.data['message'] ?? e.response?.statusMessage}';
    }
    return defaultMessage;
  }
}