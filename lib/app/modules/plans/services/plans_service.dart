// lib/app/modules/plans/services/plans_service.dart
import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

class PlansService {
  final Dio _dio = ApiClient().dio;

  Future<List<PlanModel>> fetchPlans() async {
    try {
      final response = await _dio.get('/database/valoresContrato');

      if (response.statusCode == 200 && response.data['result'] != null) {
        final result = response.data['result'] as List<dynamic>;
        return result.map((e) => PlanModel.fromMap(e)).toList();
      }

      throw Exception('Erro ao carregar planos');
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}