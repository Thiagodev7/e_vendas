import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

/// Chama o backend para enviar a proposta ao Datasys:
/// POST /datanext/pessoa-composicao
class DatanextService {
  final Dio _dio = ApiClient().dio;

  static const String _path = '/datanext/pessoa-composicao';

  /// Dispara o envio para o Datasys.
  /// - [nroProposta] vem do fluxo da venda
  /// - [cpfVendedor] precisa ser 11 dígitos
  ///
  /// Retorna o corpo de sucesso (Map) ou lança [DatanextHttpException] nos erros.
  Future<Map<String, dynamic>> enviarPessoaComposicao({
    required int nroProposta,
    required String cpfVendedor,
    Map<String, dynamic>? faturamento, // ⬅️ novo (opcional)
  }) async {
    try {
      final body = {
        'nro_proposta': nroProposta,
        'cpf_vendedor': cpfVendedor,
        if (faturamento != null) 'faturamento': faturamento, // ⬅️ envia se vier
      };

      final res = await _dio.post<Map<String, dynamic>>(
        _path,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: Duration(seconds: 30),
          sendTimeout: Duration(seconds: 30),
        ),
      );
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      print(e.response);
      final st = e.response?.statusCode;
      final data = e.response?.data;

      // Mensagem prioritária do backend (quando vem json)
      String backendMsg = '';
      if (data is Map) {
        backendMsg = (data['message'] ??
                      data['error_description'] ??
                      data['error'] ??
                      data['erro'] ??
                      data['detalhe'] ??
                      data['detail'] ??
                      '')
            .toString();
      }

      final msg = backendMsg.isNotEmpty
          ? backendMsg
          : (e.message ?? 'Falha ao comunicar com o servidor');

      throw DatanextHttpException(
        statusCode: st,
        message: '[HTTP ${st ?? '-'}] $msg',
        data: data,
      );
    } catch (e) {
      throw DatanextHttpException(message: 'Erro inesperado: $e');
    }
  }
}

/// Exceção semântica para falhas HTTP nessa integração.
class DatanextHttpException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  DatanextHttpException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'DatanextHttpException(${statusCode ?? '-'}) $message';
}