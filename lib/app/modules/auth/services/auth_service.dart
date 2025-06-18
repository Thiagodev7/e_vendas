import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/service_response.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<ServiceResponse> loginReq(String token) async {
  final url = '${ApiConfig.baseUrl}/database/login';

  try {
    final result = await dio.post(
      url,
      data: json.encode({"token": token}),
      options: Options(headers: ApiConfig.defaultHeaders),
    );

    if (result.statusCode == 202) {
      final data = result.data["data"];
      print('Dados do usuário: $data');
      return ServiceResponse.success(data: data);
    } else {
      final message = 'Usuário não encontrado.';
      return ServiceResponse.error(message: message);
    }
  } on DioException catch (e) {
    final message = _handleDioError(e);
    return ServiceResponse.error(message: message);
  } catch (e) {
    return ServiceResponse.error(message: 'Erro inesperado: $e');
  }
}

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'A resposta da API demorou demais.';
    } else if (e.type == DioExceptionType.sendTimeout) {
      return 'Falha ao enviar dados para a API.';
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (statusCode == 203) {
        return responseData?['message'] ?? 'Usuário não encontrado.';
      } else if (statusCode == 400) {
        return responseData?['message'] ?? 'Requisição inválida (400).';
      } else if (statusCode == 401) {
        return responseData?['message'] ?? 'Não autorizado (401).';
      } else if (statusCode == 403) {
        return responseData?['message'] ?? 'Acesso negado (403).';
      } else if (statusCode == 404) {
        return responseData?['message'] ?? 'Endpoint não encontrado (404).';
      } else if (statusCode == 500) {
        return 'Erro interno no servidor (500).';
      } else {
        return 'Erro ${statusCode ?? ''}: ${responseData?['message'] ?? 'Erro desconhecido.'}';
      }
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Falha na conexão. Verifique sua internet.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Requisição cancelada.';
    } else {
      return 'Erro inesperado: ${e.message}';
    }
  }
}
