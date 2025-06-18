
import 'env.dart';

class ApiConfig {
  /// URL base da API
  static String get baseUrl => Env.apiUrl;

  /// Headers padrão para todas as requisições
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YXBwQXV0aERldjpqYW4yMDI0', // 🔐 Chave codificada
      };
}