import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

class ContractService {
  final Dio _dio = ApiClient().dio;

  static const String _sendPath = '/contracts/send';
  static String _statusPath(int nro) => '/contracts/$nro/status';
  static const String _dsStatusPath = '/contracts/docusign/status';

  Future<String?> enviarContratoDocuSign({ required Map<String, dynamic> body }) async {
    try {
      final res = await _dio.post(_sendPath, data: body);
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      if (!ok) throw Exception('Falha ao enviar contrato (HTTP ${res.statusCode})');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final raw = data['envelopeId'];
        if (raw != null) return '$raw';
      }
      return null;
    } on DioException catch (e) {
      final st = e.response?.statusCode;
      final data = e.response?.data;
      final msg = '[HTTP ${st ?? '-'}] '
          '${data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : (data?.toString() ?? e.message)}';
      throw Exception('Erro ao enviar contrato: $msg');
    }
  }

  Future<ContractFlags> buscarStatusContrato(int nroProposta) async {
    if (nroProposta <= 0) {
      throw Exception('nroProposta inválido no cliente: $nroProposta');
    }
    final path = _statusPath(nroProposta);
    // debug opcional:
    // print('GET $path');
    try {
      final res = await _dio.get(path);
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      return ContractFlags.fromJson(data);
    } on DioException catch (e) {
      final st = e.response?.statusCode;
      final data = e.response?.data;
      final msg = '[HTTP ${st ?? '-'}] '
          '${data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : (data?.toString() ?? e.message)}';
      throw Exception('Erro ao buscar status do contrato: $msg');
    }
  }

  Future<DocusignStatus> buscarStatusDocuSign(String envelopeId) async {
    try {
      final res = await _dio.get(_dsStatusPath, queryParameters: {'envelopeId': envelopeId});
      final map = (res.data is Map)
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};
      return DocusignStatus.fromJson(map);
    } on DioException catch (e) {
      final st = e.response?.statusCode;
      final data = e.response?.data;
      final msg = '[HTTP ${st ?? '-'}] '
          '${data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : (data?.toString() ?? e.message)}';
      throw Exception('Erro ao consultar DocuSign: $msg');
    }
  }
}

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

class DocusignStatus {
  final String envelopeId;
  final String status;
  final bool signed;
  final DateTime? statusChangedAt;

  DocusignStatus({
    required this.envelopeId,
    required this.status,
    required this.signed,
    required this.statusChangedAt,
  });

  factory DocusignStatus.fromJson(Map<String, dynamic> json) {
    final st = ('${json['status'] ?? ''}').toLowerCase();
    return DocusignStatus(
      envelopeId: '${json['envelopeId'] ?? ''}',
      status: st,
      signed: json['signed'] == true || st == 'completed',
      statusChangedAt: json['statusChangedDateTime'] != null
          ? DateTime.tryParse('${json['statusChangedDateTime']}')
          : null,
    );
  }
}