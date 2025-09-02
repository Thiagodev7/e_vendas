import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/payment_service.dart';

part 'finish_sale_store.g.dart';

/// Método de pagamento atual selecionado na UI.
enum PayMethod { card, pix }

/// Estado consolidado do pagamento com base no gateway + servidor.
enum PaymentStatus { none, aguardando, pago, erro }

/// Store responsável por:
/// - Resumo de valores (mensal/adesão/pró-rata)
/// - Geração/consulta de pagamento (cartão/PIX)
/// - Reagir a flags do servidor (pagamento concluído)
class FinishSaleStore = _FinishSaleStoreBase with _$FinishSaleStore;

abstract class _FinishSaleStoreBase with Store {
  _FinishSaleStoreBase({
    PaymentService? paymentService,
    SalesService? salesService,
  })  : _payment = paymentService ?? Modular.get<PaymentService>(),
        _sales = salesService ?? Modular.get<SalesService>();

  final PaymentService _payment;
  final SalesService _sales;

  // =======================
  // Bindings / Estado base
  // =======================
  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  @observable
  bool loading = false;

  /// Método de pagamento selecionado na UI (Cartão / PIX).
  @observable
  PayMethod metodo = PayMethod.card;

  /// Se o backend já marcou pagamento_concluido, bloqueia novas cobranças.
  @observable
  bool pagamentoConcluidoServer = false;

  // ===========
  // Pagamento
  // ===========
  @observable
  String? cardUrl;

  @observable
  String? cardMyId;

  /// ID do gateway (quando disponível) para facilitar consultas de status.
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

  /// Quantidade de meses (usado no payload de cobrança parcelado).
  @observable
  int numMonths = 12;

  // =======================
  // Inicialização / Bind
  // =======================
  /// Use na página de finalização para “montar” a store com a venda atual.
  @action
  void init({required VendaModel v, int? nro}) {
    venda = v;
    nroProposta = nro ?? v.nroProposta;

    // Reset dos estados mutáveis
    loading = false;
    metodo = PayMethod.card;

    cardUrl = null;
    cardMyId = null;
    galaxPayId = null;

    pixEmv = null;
    pixImageBase64 = null;
    pixMyId = null;
    pixLink = null;

    paymentStatus = PaymentStatus.none;

    // Flags vindas do servidor, se disponíveis na venda
    pagamentoConcluidoServer = v.pagamentoConcluido == true;
    if (pagamentoConcluidoServer) {
      paymentStatus = PaymentStatus.pago;
    }
  }

  // =======================
  // Cálculos (Resumo)
  // =======================
  @computed
  ResumoValores? get resumo {
    if (venda == null) return null;
    return ResumoValores(
      vidas: vidas,
      adesaoIndividual: adesaoInd,
      mensalidadeIndividual: mensalInd,
      proRataIndividual: proRataInd,
      mensalidadeTotal: mensalTotal,
      proRataTotal: proRataTotal,
      totalPrimeiraCobranca: totalPrimeiraCobranca,
    );
  }

  @computed
  int get vidas => ((venda?.dependentes?.length ?? 0) + 1);

  /// Mensalidade individual (lendo da API de plano; aceita string/cents).
  @computed
  double get mensalInd => _parseMoney(
        venda?.plano?.getMensalidade() ?? venda?.plano?.getMensalidadeTotal(),
      );

  /// Mensalidade total considerando todas as vidas.
  @computed
  double get mensalTotal => (mensalInd * vidas);

  /// Adesão individual.
  @computed
  double get adesaoInd => _parseMoney(
        venda?.plano?.getTaxaAdesao() ?? venda?.plano?.getTaxaAdesaoTotal(),
      );

  /// Adesão total considerando todas as vidas.
  @computed
  double get adesaoTotal => (adesaoInd * vidas);

  /// Pró-rata individual (calculado no mês corrente).
  @computed
  double get proRataInd => calculateProrata(monthly: mensalInd);

  /// Pró-rata total considerando todas as vidas.
  @computed
  double get proRataTotal => (proRataInd * vidas);

  /// Total da 1ª cobrança (adesão + pró-rata + mensalidade).
  @computed
  double get totalPrimeiraCobranca => adesaoTotal + proRataTotal + mensalTotal;

  /// Pode finalizar a venda quando o pagamento está confirmado
  /// (o contrato agora vive na FinishContractStore).
  @computed
  bool get pagamentoOk => paymentStatus == PaymentStatus.pago;

  /// Alias para UI pré-existente.
  @computed
  bool get pagamentoConcluido => pagamentoConcluidoServer;

  /// Retorna o identificador “corrente” de cobrança conforme o método ativo.
  @computed
  String? get currentMyId => metodo == PayMethod.card ? cardMyId : pixMyId;

  // =======================
  // Ações: UI helpers
  // =======================
  @action
  void setMetodo(PayMethod m) => metodo = m;

  /// Pró-rata = dias restantes * (mensal / dias no mês).
  @action
  double calculateProrata({required double monthly}) {
    final today = DateTime.now();
    final totalDaysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final daysToPay = totalDaysInMonth - today.day;
    if (daysToPay <= 0) return 0.0;
    final valueByDay = monthly / totalDaysInMonth;
    final value = valueByDay * daysToPay;
    return double.parse(value.toStringAsFixed(2));
  }

  // =======================
  // Ações: Pagamento
  // =======================
  @action
  Future<void> gerarLinkCartao() async {
    if (pagamentoConcluidoServer) {
      throw Exception('Pagamento já concluído para esta proposta.');
    }
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');

    loading = true;
    try {
      final payload = _buildPaymentPayload();
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
  Future<void> gerarPix() async {
    if (pagamentoConcluidoServer) {
      throw Exception('Pagamento já concluído para esta proposta.');
    }
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');

    loading = true;
    try {
      final payload = _buildPaymentPayload();
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

      // Se confirmou pagamento, persistimos no backend.
      if (status == PaymentStatus.pago && nroProposta != null) {
        try {
          await _sales.atualizarStatusProposta(
            nroProposta: nroProposta!,
            pagamentoConcluido: true,
          );
          pagamentoConcluidoServer = true;
        } catch (_) {
          // não trava a UI caso a atualização falhe
        }
      }
      return status;
    } finally {
      loading = false;
    }
  }

  // =======================
  // Helpers internos
  // =======================
  Map<String, dynamic> _buildPaymentPayload() {
    final v = venda!;
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
    if (email == null) throw Exception('E-mail do titular é obrigatório.');
    if (phone == null) throw Exception('Telefone do titular é obrigatório.');

    final monthlyCents = _toCents(mensalInd);
    final enrollmentCents = _toCents(adesaoInd);
    final totalValue = ((monthlyCents * numMonths) + enrollmentCents) * vidas;

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
      'value': totalValue,
      'numMonths': numMonths,
      'numLives': vidas,
    };

    // Dependentes
    final deps = (v.dependentes ?? [])
        .where((d) => (d.cpf?.isNotEmpty ?? false))
        .map((d) => {
              'cpf': _digits(d.cpf ?? ''),
              'id_grau_dependencia': d.idGrauDependencia,
            })
        .toList();
    if (deps.isNotEmpty) payload['dependent'] = deps;

    // Responsável financeiro (se diferente do titular)
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
          (txs.isNotEmpty ? txs.first['status'] : res['status'])?.toString() ?? '';
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

  double _parseMoney(String? s) {
    if (s == null) return 0.0;
    final raw = s.trim();
    if (raw.isEmpty) return 0.0;

    // “1234” => cents
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      final cents = int.tryParse(raw) ?? 0;
      return (cents / 100).toDouble();
    }

    // “1.234,56” / “1234.56” -> double
    var cleaned = raw.replaceAll(RegExp(r'[^\d,\.]'), '');
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    if (lastComma > lastDot) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll(',', '');
    }

    var value = double.tryParse(cleaned) ?? 0.0;

    // Heurística anti “100x”
    if (value >= 1000) {
      final divided = value / 100.0;
      if (divided < 1000) value = divided;
    }
    return double.parse(value.toStringAsFixed(2));
  }

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

/// DTO simples para “Resumo de Valores” na UI.
class ResumoValores {
  final int vidas;
  final double adesaoIndividual;
  final double mensalidadeIndividual;
  final double proRataIndividual;
  final double mensalidadeTotal;
  final double proRataTotal;
  final double totalPrimeiraCobranca;

  const ResumoValores({
    required this.vidas,
    required this.adesaoIndividual,
    required this.mensalidadeIndividual,
    required this.proRataIndividual,
    required this.mensalidadeTotal,
    required this.proRataTotal,
    required this.totalPrimeiraCobranca,
  });
}