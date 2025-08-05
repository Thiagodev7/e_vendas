import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _cpfKey = 'user_cpf';

  final Dio _dio = ApiClient().dio;

  // Login: salva token e CPF
  Future<bool> login(String cpf, String senha) async {
    try {
      final response = await _dio.post(
        '/oauth3/token',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({'cpf': cpf, 'senha': senha}),
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_cpfKey, cpf);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Busca dados do vendedor por CPF
  Future<Map<String, dynamic>?> getVendedorByCpf() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cpf = prefs.getString(_cpfKey);

      if (cpf == null) return null;

      final response = await _dio.get('/database/vendedor', queryParameters: {
        'cpf': cpf,
      });

      if (response.statusCode == 200) {
        return response.data; // retorna dados do vendedor
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_cpfKey);
  }
}