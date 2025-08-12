<<<<<<< HEAD
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

=======
// lib/app/modules/finish_sale/repository/proposta_repository.dart

import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

// O nome da classe foi mantido como SalesService para consistência com o exemplo
class SalesService {
  final Dio _dio = ApiClient().dio;

>>>>>>> f47e3e3 (atualização 12/08)
  /// Salva a proposta completa na API
  Future<Response> salvarProposta(Map<String, dynamic> propostaData) async {
    try {
      const endpoint = '/database/propostas/full';
      final response = await _dio.post(endpoint, data: propostaData);
      return response;
    } on DioException catch (e) {
<<<<<<< HEAD
      throw Exception(_handleDioError(e, 'Erro ao salvar proposta'));
    } catch (e) {
=======
      // PADRÃO APLICADO: Lança uma Exception genérica com a mensagem formatada
      throw Exception(_handleDioError(e, 'Erro ao salvar proposta'));
    } catch (e) {
      // PADRÃO APLICADO: Trata outros erros inesperados
>>>>>>> f47e3e3 (atualização 12/08)
      throw Exception('Erro inesperado ao salvar proposta: $e');
    }
  }

<<<<<<< HEAD
  /// Trata e formata erros do Dio
  String _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      return '$defaultMessage: ${e.response?.data['message'] ?? e.response?.statusMessage}';
    }
=======
   /// Busca as propostas em aberto de um vendedor no backend.
  Future<List<dynamic>> getOpenProposals(int vendedorId) async {
    try {
      // Usamos o endpoint que criamos no backend
      final response = await _dio.get(
        '/database/propostas/abertas',
        queryParameters: {'vendedorId': 22},
      );
      // A API retorna uma lista de JSONs
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao buscar propostas abertas'));
    } catch (e) {
      throw Exception('Erro inesperado ao buscar propostas: $e');
    }
  }


  /// PADRÃO APLICADO: Helper para tratar e formatar erros do Dio.
  /// Este método é idêntico ao do seu ClientService.
  String _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      // Tenta extrair a mensagem específica retornada pela API
      return '$defaultMessage: ${e.response?.data['message'] ?? e.response?.statusMessage}';
    }
    // Se não houver uma resposta ou mensagem específica, retorna a mensagem padrão.
>>>>>>> f47e3e3 (atualização 12/08)
    return defaultMessage;
  }
}