// lib/app/modules/finish_sale/repository/proposta_repository.dart

import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

// O nome da classe foi mantido como SalesService para consistência com o exemplo
class SalesService {
  final Dio _dio = ApiClient().dio;

  /// Salva a proposta completa na API
  Future<Response> salvarProposta(Map<String, dynamic> propostaData) async {
    try {
      const endpoint = '/database/propostas/full';
      final response = await _dio.post(endpoint, data: propostaData);
      return response;
    } on DioException catch (e) {
      // PADRÃO APLICADO: Lança uma Exception genérica com a mensagem formatada
      throw Exception(_handleDioError(e, 'Erro ao salvar proposta'));
    } catch (e) {
      // PADRÃO APLICADO: Trata outros erros inesperados
      throw Exception('Erro inesperado ao salvar proposta: $e');
    }
  }

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
    return defaultMessage;
  }
}