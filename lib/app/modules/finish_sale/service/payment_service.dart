import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

Future<PixChargeResult> gerarPix({required Map<String, dynamic> payload}) async {
  print(payload);
  final res = await _dio.post('/celcoin/generatePix', data: payload);
  final charge = Map<String, dynamic>.from(res.data['Charge'] ?? {});
  print('Charge: $charge');

  final myId = charge['myId']?.toString() ?? '';
  final link = (charge['paymentLink'] ?? charge['PaymentLink'])?.toString();

  final txs = (charge['Transactions'] is List) ? List.from(charge['Transactions']) : const [];
  final dynamic gTop = charge['galaxPayId'];
  final dynamic gTx  = txs.isNotEmpty ? txs.first['galaxPayId'] : null;
  final int? galaxId = _asInt(gTop) ?? _asInt(gTx);

  // PaymentMethodPix (alguns formatos)
  final pmPix  = Map<String, dynamic>.from(charge['PaymentMethodPix'] ?? charge['PaymentMethod'] ?? {});
  final qrBlk  = Map<String, dynamic>.from(pmPix['QrCode'] ?? {});
  String? emv  = (qrBlk['emv'] ?? qrBlk['Emv'] ?? qrBlk['payload'])?.toString();
  String? img  = (qrBlk['image'] ?? qrBlk['ImageBase64'])?.toString();

  // Transactions[0].Pix (se não veio no bloco anterior)
  if ((emv == null || emv.isEmpty) && txs.isNotEmpty) {
    final t0  = Map<String, dynamic>.from(txs.first);
    final pix = Map<String, dynamic>.from(t0['Pix'] ?? {});
    emv ??= (pix['qrCode'] ?? pix['emv'] ?? pix['payload'])?.toString();
    img ??= (pix['image'] ?? pix['ImageBase64'])?.toString();
  }

  // Decide para onde vai a imagem
  String? imageUrl;
  String? imageBase64;
  if (img != null && img.isNotEmpty) {
    if (img.startsWith('http')) {
      imageUrl = img;
    } else {
      imageBase64 = img;
    }
  }

  return PixChargeResult(
    myId: myId,
    galaxPayId: galaxId,
    emv: emv,
    imageBase64: imageBase64,
    imageUrl: imageUrl,
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
  final String? imageBase64; // quando vier base64
  final String? imageUrl;    // quando vier URL
  final String? link;
  final Map<String, dynamic> rawCharge;

  const PixChargeResult({
    required this.myId,
    required this.galaxPayId,
    required this.emv,
    this.imageBase64,
    this.imageUrl,
    required this.link,
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