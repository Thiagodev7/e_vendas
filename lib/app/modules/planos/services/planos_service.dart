import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/plano_model.dart';

class PlanosService {
  final Dio dio;

  PlanosService(this.dio);

  Future<List<PlanoModel>> fetchPlanos() async {
    try {
      final response = await dio.get(
        '${ApiConfig.baseUrl}/SEU_ENDPOINT_AQUI', // 🔗 coloque aqui seu endpoint correto
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final list = response.data['result'] as List;
        return list.map((e) => PlanoModel.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao buscar os planos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}