import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  Future<PixChargeResult> gerarPix({required Map<String, dynamic> payload}) async {
    final res = await _dio.post('/celcoin/generatePix', data: payload);
    final charge = Map<String, dynamic>.from(res.data['Charge'] ?? {});

    final myId = charge['myId']?.toString() ?? '';

    final pmPix  = Map<String, dynamic>.from(charge['PaymentMethodPix'] ?? charge['PaymentMethod'] ?? {});
    final qr     = Map<String, dynamic>.from(pmPix['QrCode'] ?? {});
    final emv    = (qr['emv'] ?? qr['Emv'] ?? qr['payload'])?.toString();
    final img    = (qr['image'] ?? qr['ImageBase64'])?.toString();

    final link   = charge['paymentLink']?.toString();

    final txs = (charge['Transactions'] is List) ? List.from(charge['Transactions']) : const [];
    final dynamic gTop = charge['galaxPayId'];
    final dynamic gTx  = txs.isNotEmpty ? txs.first['galaxPayId'] : null;
    final int? galaxId = _asInt(gTop) ?? _asInt(gTx);

    return PixChargeResult(
      myId: myId,
      galaxPayId: galaxId,
      emv: emv,
      imageBase64: img,
      link: link,
      rawCharge: charge,
    );
  }

  Future<CardLinkResult> gerarCartao({required Map<String, dynamic> payload}) async {
    final res = await _dio.post('/celcoin/generateOneOffChargeLink', data: payload);
    final charge = Map<String, dynamic>.from(res.data['Charge'] ?? {});

    final myId = charge['myId']?.toString() ?? '';

    String? link = charge['paymentLink']?.toString();
    if (link == null || link.isEmpty) {
      final pmCC = Map<String, dynamic>.from(charge['PaymentMethodCreditCard'] ?? charge['PaymentMethod'] ?? {});
      link = (pmCC['Link'] is Map && pmCC['Link']['url'] != null)
          ? pmCC['Link']['url'].toString()
          : (pmCC['payLink'] is Map && pmCC['payLink']['url'] != null)
              ? pmCC['payLink']['url'].toString()
              : pmCC['url']?.toString();
    }

    final txs = (charge['Transactions'] is List) ? List.from(charge['Transactions']) : const [];
    final dynamic gTop = charge['galaxPayId'];
    final dynamic gTx  = txs.isNotEmpty ? txs.first['galaxPayId'] : null;
    final int? galaxId = _asInt(gTop) ?? _asInt(gTx);

    return CardLinkResult(
      myId: myId,
      galaxPayId: galaxId,
      url: link ?? '',
      rawCharge: charge,
    );
  }

  Future<Map<String, dynamic>> consultarStatus({String? myId, int? galaxPayId}) async {
    if (galaxPayId == null && (myId == null || myId.isEmpty)) {
      throw Exception('Informe galaxPayId ou myId para consultar status.');
    }
    final body = <String, dynamic>{
      if (galaxPayId != null) 'galaxPayId': galaxPayId,
      if (myId != null && myId.isNotEmpty) 'myId': myId,
    };
    final res = await _dio.post('/celcoin/postTransactionStatus', data: body);
    return Map<String, dynamic>.from(res.data ?? {});
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class PixChargeResult {
  final String myId;
  final int? galaxPayId;
  final String? emv;
  final String? imageBase64;
  final String? link;
  final Map<String, dynamic> rawCharge;
  PixChargeResult({
    required this.myId,
    required this.galaxPayId,
    this.emv,
    this.imageBase64,
    this.link,
    required this.rawCharge,
  });
}

class CardLinkResult {
  final String myId;
  final int? galaxPayId;
  final String url;
  final Map<String, dynamic> rawCharge;
  CardLinkResult({
    required this.myId,
    required this.galaxPayId,
    required this.url,
    required this.rawCharge,
  });
}