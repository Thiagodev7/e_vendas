import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

/// Service das rotas de contrato:
/// - POST /contracts/send
/// - GET  /contracts/:nroProposta/status
class ContractService {
  final Dio _dio = ApiClient().dio;

  static const String _sendPath = '/contracts/send';
  static String _statusPath(int nro) => '/contracts/$nro/status';

  /// Dispara a criação/envio do envelope (DocuSign).
  Future<void> enviarContratoDocuSign({
    required Map<String, dynamic> body,
  }) async {
    try {
      final res = await _dio.post(_sendPath, data: body);
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      if (!ok) {
        throw Exception('Falha ao enviar contrato (HTTP ${res.statusCode})');
      }
    } on DioException catch (e) {
      final st = e.response?.statusCode;
      final data = e.response?.data;
      final msg = '[HTTP ${st ?? '-'}] '
          '${data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : (data?.toString() ?? e.message)}';
      throw Exception('Erro ao enviar contrato: $msg');
    }
  }

  /// Consulta as flags atuais no servidor para uma proposta.
  Future<ContractFlags> buscarStatusContrato(int nroProposta) async {
    try {
      final res = await _dio.get(_statusPath(nroProposta));
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return ContractFlags.fromJson(data);
    } on DioException catch (e) {
      final st = e.response?.statusCode;
      final data = e.response?.data;
      final msg = '[HTTP ${st ?? '-'}] '
          '${data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : (data?.toString() ?? e.message)}';
      throw Exception('Erro ao consultar status do contrato: $msg');
    }
  }
}

/// DTO das flags da proposta no backend.
class ContractFlags {
  final int? nroProposta;
  final bool vendaFinalizada;
  final bool pagamentoConcluido;
  final bool contratoAssinado;

  ContractFlags({
    required this.nroProposta,
    required this.vendaFinalizada,
    required this.pagamentoConcluido,
    required this.contratoAssinado,
  });

  factory ContractFlags.fromJson(Map<String, dynamic> json) {
    return ContractFlags(
      nroProposta: json['nroProposta'] is int
          ? json['nroProposta'] as int
          : int.tryParse('${json['nroProposta'] ?? ''}'),
      vendaFinalizada: json['vendaFinalizada'] == true,
      pagamentoConcluido: json['pagamentoConcluido'] == true,
      contratoAssinado: json['contratoAssinado'] == true,
    );
  }
}