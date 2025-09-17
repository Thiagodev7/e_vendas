import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
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

  // ===== Bindings / estado base =====
  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  @observable
  bool loading = false;

  @observable
  PayMethod metodo = PayMethod.card;

  // ===== Cobrança (IDs/links) =====
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

  /// Backend já marcou pagamento_concluido
  @observable
  bool pagamentoConcluidoServer = false;

  // ===== Binds =====
  @action
void bindVenda(VendaModel v) {
  venda = v;

  // Se já veio myId salvo no back, usa para permitir "Atualizar status"
  final ref = v.gatewayPagamentoId; // agora é o myId
  if ((ref != null && ref.isNotEmpty) && (cardMyId == null || cardMyId!.isEmpty)) {
    cardMyId = ref;
  }

  if (!pagamentoConcluidoServer && v.pagamentoConcluido != true && canCheckStatus) {
    paymentStatus = PaymentStatus.aguardando;
  }
}

  @action
  void bindNroProposta(int? nro) => nroProposta = nro;

  // ===== Derivados do plano (única fonte de verdade) =====
  @computed
  int get numMonths => (venda?.plano?.isAnnual ?? false) ? 12 : 1;

  @computed
  int? get dueDay => venda?.plano?.dueDay;

  // ===== Helpers UI =====
  @action
  void setMetodo(PayMethod m) => metodo = m;

  @computed
  String? get currentMyId => (metodo == PayMethod.card) ? cardMyId : pixMyId;

  @computed
bool get canCheckStatus {
  final hasMyId = (cardMyId != null && cardMyId!.isNotEmpty) ||
                  (pixMyId  != null && pixMyId!.isNotEmpty) ||
                  ((venda?.gatewayPagamentoId ?? '').isNotEmpty);
  final hasLegacyNum = galaxPayId != null; // fallback antigo, se sobrar algo local
  return hasMyId || hasLegacyNum;
}

  /// Valor que DEVE ser cobrado AGORA (centavos) — mesmo cálculo do resumo.
  @computed
  int get valorCelcoinCentavos {
    final v = venda;
    if (v == null || v.plano == null) return 0;
    final vidas = (v.dependentes?.length ?? 0) + 1;
    final planSync = v.plano!.copyWith(vidasSelecionadas: vidas);
    final b = computeBilling(planSync);
    return b.valorAgoraCentavos;
  }

  @computed
  String get valorCelcoinFmt {
    final cents = valorCelcoinCentavos;
    final val = cents / 100.0;
    return 'R\$ ${val.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  

  // ===== Ações: gerar cobranças =====
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
  // Prioriza myId: local (card/pix) -> vindo da proposta (gatewayPagamentoId)
  final String? myIdEffective =
      (cardMyId ?? pixMyId) ?? venda?.gatewayPagamentoId;

  // Suporte legado: galaxPayId numérico gerado nesta sessão
  final int? galaxIdEffective = galaxPayId;

  if (galaxIdEffective == null && (myIdEffective == null || myIdEffective.isEmpty)) {
    throw Exception('Nenhuma cobrança gerada.');
  }

  loading = true;
  try {
    final res = await _payment.consultarStatus(
      galaxPayId: galaxIdEffective,
      myId: myIdEffective,
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

  // ===== Helpers internos =====
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
    if (email == null) {
      throw Exception('Contato de e-mail do titular é obrigatório.');
    }
    if (phone == null) {
      throw Exception('Contato de telefone do titular é obrigatório.');
    }

    // === Valor a cobrar (centavos) — fonte única
    final valueCents = valorCelcoinCentavos;

    // Infos auxiliares (mensal/adesão) para logs/auditoria:
    final vidas = (v.dependentes?.length ?? 0) + 1;
    final planSync = v.plano!.copyWith(vidasSelecionadas: vidas);
    final b = computeBilling(planSync);
    final monthlyCents = (b.mensal * 100).round();
    final enrollmentCents = (b.adesao * 100).round();

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
    'value': valueCents,               // valor cobrado AGORA (centavos)
    'numMonths': numMonths,            // 12 se anual, 1 se mensal
    'numLives': vidas,
    if (nroProposta != null) 'nro_proposta': nroProposta, // <<< ADICIONE ISTO
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
