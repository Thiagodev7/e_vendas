import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

import '../../../core/model/endereco_model.dart';
import '../../../core/model/pessoa_model.dart';

/// Service responsável por comunicação com a API para dados de cliente
class ClientService {
  final Dio _dio = ApiClient().dio;

  /// Busca endereço pelo CEP e retorna [EnderecoModel]
/// Busca endereço pelo CEP e retorna [EnderecoModel]
Future<EnderecoModel> buscarCep(String cep) async {
  try {
    final response = await _dio.post('/database/postCep', data: {"cep": cep});
    final data = response.data;

    // Se vier o campo "erro" = "true", lança exceção amigável
    if (data is Map<String, dynamic> && data['erro'] == 'true') {
      throw Exception('CEP não encontrado');
    }

    return EnderecoModel.fromJson(data);
  } on DioException catch (e) {
    throw Exception(_handleDioError(e, 'Erro ao buscar CEP'));
  } catch (e) {
    throw Exception('Erro inesperado ao buscar CEP: $e');
  }
}

  /// Busca dados da pessoa pelo CPF via API CadSUS e retorna [PessoaModel]
Future<PessoaModel> buscarPorCpf(String cpf) async {
  try {
    final response = await _dio.post('/datanext/postcadSus', data: {"cpf": cpf});
    final data = response.data;

    // Verifica se o JSON contém a chave 'data' e se não está vazio
    if (data['data'] != null && data['data'].isNotEmpty) {
      final registro = data['data'][0];

      // Caso o retorno indique que não encontrou o CPF
      if (registro['resultado'] == 0) {
        throw Exception('CPF não encontrado na base de dados');
      }

      return PessoaModel.fromCpfJson(registro);
    } else {
      throw Exception('CPF não encontrado na base de dados');
    }
  } on DioException catch (e) {
    throw Exception(_handleDioError(e, 'Erro ao buscar CPF'));
  } catch (e) {
    throw Exception('Erro inesperado ao buscar CPF: $e');
  }
}

  /// Envia o JSON completo do cliente para cadastro no backend
  Future<void> cadastrarCliente(Map<String, dynamic> dados) async {
    try {
      await _dio.post('/datanext/insertClient', data: {"info": dados});
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Erro ao cadastrar cliente'));
    } catch (e) {
      throw Exception('Erro inesperado ao cadastrar cliente: $e');
    }
  }

  /// Trata mensagens de erro de Dio
  String _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null) {
      return '$defaultMessage: ${e.response?.data['message'] ?? e.response?.statusMessage}';
    }
    return defaultMessage;
  }
}