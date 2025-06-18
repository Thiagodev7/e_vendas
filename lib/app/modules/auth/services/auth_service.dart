import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/service_response.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  /// 🔐 Login usando token JWT
  Future<ServiceResponse> loginReq(String token) async {
    final url = '${ApiConfig.baseUrl}/database/login';

    try {
      final response = await dio.post(
        url,
        data: json.encode({"token": token}),
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data["data"];
        return ServiceResponse.success(data: data);
      } else {
        final message = response.data?['message'] ?? 'Erro desconhecido.';
        return ServiceResponse.error(message: message);
      }
    } on DioException catch (e) {
      final message = _handleDioError(e);
      return ServiceResponse.error(message: message);
    } catch (e) {
      return ServiceResponse.error(message: 'Erro inesperado: $e');
    }
  }

  /// 🔥 Tratamento de erros de Dio
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

      return responseData?['message'] ??
          'Erro ${statusCode ?? ''}: Erro desconhecido.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Falha na conexão. Verifique sua internet.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Requisição cancelada.';
    } else {
      return 'Erro inesperado: ${e.message}';
    }
  }

  /// (Opcional) Se usar token salvo
  Future<void> clearSession() async {
    // Aqui você pode limpar cache, sharedPreferences ou qualquer persistência local
  }
}