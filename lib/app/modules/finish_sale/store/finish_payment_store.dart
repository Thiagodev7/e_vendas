import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/finish_sale/service/payment_service.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';

import 'finish_types.dart';

part 'finish_payment_store.g.dart';

class FinishPaymentStore = _FinishPaymentStoreBase with _$FinishPaymentStore;

abstract class _FinishPaymentStoreBase with Store {
  _FinishPaymentStoreBase({
    PaymentService? paymentService,
    SalesService? salesService,
  })  : _payment = paymentService ?? Modular.get<PaymentService>(),
        _sales = salesService ?? Modular.get<SalesService>();

  final PaymentService _payment;
  final SalesService _sales;

  // bindings
  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  /// Num. de meses para compor payload anual
  @observable
  int numMonths = 12;

  // estado base
  @observable
  bool loading = false;

  // método UI
  @observable
  PayMethod metodo = PayMethod.card;

  // cobrança
  @observable
  String? cardUrl;

  @observable
  String? cardMyId;

  @observable
  int? galaxPayId;

  @observable
  String? pixEmv;

  @observable
  String? pixImageBase64;

  @observable
  String? pixMyId;

  @observable
  String? pixLink;

  @observable
  PaymentStatus paymentStatus = PaymentStatus.none;

  /// backend já marcou pagamento_concluido
  @observable
  bool pagamentoConcluidoServer = false;

  // -------- binds --------
  @action
  void bindVenda(VendaModel v) {
    venda = v;
  }

  @action
  void bindNroProposta(int? nro) {
    nroProposta = nro;
  }

  // -------- UI helpers --------
  @action
  void setMetodo(PayMethod m) => metodo = m;

  @computed
  String? get currentMyId => (metodo == PayMethod.card) ? cardMyId : pixMyId;

  // -------- ações --------
  @action
  Future<void> gerarLinkCartao({
    required int vidas,
    required double mensalInd,
    required double adesaoInd,
  }) async {
    if (pagamentoConcluidoServer) {
      throw Exception('Pagamento já concluído para esta proposta.');
    }
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');
    loading = true;
    try {
      final payload = _buildPaymentPayload(v, vidas, mensalInd, adesaoInd);
      final result = await _payment.gerarCartao(payload: payload);
      cardUrl = result.url;
      cardMyId = result.myId;
      galaxPayId = result.galaxPayId;
      paymentStatus = PaymentStatus.aguardando;
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> gerarPix({
    required int vidas,
    required double mensalInd,
    required double adesaoInd,
  }) async {
    if (pagamentoConcluidoServer) {
      throw Exception('Pagamento já concluído para esta proposta.');
    }
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');
    loading = true;
    try {
      final payload = _buildPaymentPayload(v, vidas, mensalInd, adesaoInd);
      final result = await _payment.gerarPix(payload: payload);
      pixEmv = result.emv;
      pixImageBase64 = result.imageBase64;
      pixLink = result.link;
      pixMyId = result.myId;
      galaxPayId = result.galaxPayId;
      paymentStatus = PaymentStatus.aguardando;
    } finally {
      loading = false;
    }
  }

  @action
  Future<PaymentStatus> consultarStatusPagamento() async {
    if (galaxPayId == null && cardMyId == null && pixMyId == null) {
      throw Exception('Nenhuma cobrança gerada.');
    }
    loading = true;
    try {
      final res = await _payment.consultarStatus(
        galaxPayId: galaxPayId,
        myId: cardMyId ?? pixMyId,
      );
      final status = _mapStatus(res);
      paymentStatus = status;

      if (status == PaymentStatus.pago && nroProposta != null) {
        try {
          await _sales.atualizarStatusProposta(
            nroProposta: nroProposta!,
            pagamentoConcluido: true,
          );
          pagamentoConcluidoServer = true;
        } catch (_) {
          // não interrompe se falhar
        }
      }
      return status;
    } finally {
      loading = false;
    }
  }

  // -------- helpers --------

  Map<String, dynamic> _buildPaymentPayload(
    VendaModel v,
    int vidas,
    double mensalInd,
    double adesaoInd,
  ) {
    final titular = v.pessoaTitular;
    final end = v.endereco;

    if (titular?.cpf == null || titular!.cpf!.trim().isEmpty) {
      throw Exception('CPF do titular é obrigatório para pagamento.');
    }
    if (end?.cep == null || end!.cep!.trim().isEmpty) {
      throw Exception('CEP é obrigatório para pagamento.');
    }

    final email = _pickEmail(v.contatos ?? const []);
    final phone = _pickPhone(v.contatos ?? const []);
    if (email == null) {
      throw Exception('Contato de e-mail do titular é obrigatório.');
    }
    if (phone == null) {
      throw Exception('Contato de telefone do titular é obrigatório.');
    }

    final monthlyCents = _toCents(mensalInd);
    final enrollmentCents = _toCents(adesaoInd);
    final valueTotal = ((monthlyCents * numMonths) + enrollmentCents) * vidas;

    final Map<String, dynamic> payload = {
      'username': 'somosuni',
      'customer': {
        'name': titular.nome ?? '',
        'cpf': _digits(titular.cpf ?? ''),
        'email': email,
        'cep': _digits(end.cep ?? ''),
        'phone': phone,
      },
      'plan': v.plano?.nomeContrato ?? 'Plano',
      'enrollment': enrollmentCents,
      'monthly': monthlyCents,
      'value': valueTotal,
      'numMonths': numMonths,
      'numLives': vidas,
    };

    final deps = (v.dependentes ?? [])
        .where((d) => (d.cpf?.isNotEmpty ?? false))
        .map((d) => {
              'cpf': _digits(d.cpf ?? ''),
              'id_grau_dependencia': d.idGrauDependencia,
            })
        .toList();
    if (deps.isNotEmpty) payload['dependent'] = deps;

    final rf = v.pessoaResponsavelFinanceiro;
    if (rf?.cpf != null &&
        rf!.cpf!.isNotEmpty &&
        _digits(rf.cpf!) != _digits(titular.cpf!)) {
      payload['financialManager'] = {'cpf': _digits(rf.cpf!)};
    }

    return payload;
  }

  PaymentStatus _mapStatus(Map<String, dynamic> res) {
    try {
      final txs = (res['Transactions'] as List?) ?? const [];
      final status =
          (txs.isNotEmpty ? txs.first['status'] : res['status'])?.toString() ??
              '';
      final normalized = status.toLowerCase();

      const paid = {
        'closed',
        'payedpix',
        'captured',
        'payexternal',
        'payed',
        'payedboleto',
        'approved',
        'confirmed',
        'settled'
      };
      const waiting = {
        'notsend',
        'waitingpayment',
        'processing',
        'open',
        'pendingpix',
        'pending',
        'authorized',
        'active'
      };

      if (paid.contains(normalized)) return PaymentStatus.pago;
      if (waiting.contains(normalized)) return PaymentStatus.aguardando;
      return PaymentStatus.erro;
    } catch (_) {
      return PaymentStatus.erro;
    }
  }

  String _digits(String v) => v.replaceAll(RegExp(r'\D'), '');
  int _toCents(double v) => (v * 100).round();

  String? _pickEmail(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final s = c.descricao.trim();
      if (s.contains('@')) return s;
    }
    return null;
  }

  String? _pickPhone(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final digits = _digits(c.descricao);
      if (digits.length >= 10) return digits;
    }
    return null;
  }
}