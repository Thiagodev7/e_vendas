// lib/app/modules/totem/stores/totem_payment_store.dart
import 'dart:async';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
import 'package:mobx/mobx.dart';

// Imports corretos baseados nos seus arquivos
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart'; 
// Fim imports

import 'package:e_vendas/app/modules/finish_sale/service/payment_service.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_types.dart'; 

part 'totem_payment_store.g.dart';

class TotemPaymentStore = _TotemPaymentStoreBase with _$TotemPaymentStore;

abstract class _TotemPaymentStoreBase with Store {
  final PaymentService _paymentService;
  _TotemPaymentStoreBase(this._paymentService);

  // Venda/Proposta atual que está sendo paga
  @observable
  VendaModel? vendaAtual; 

  @observable
  PayMethod metodo = PayMethod.pix;

  @observable
  bool loading = false;

  @observable
  String? pixEmv;

  @observable
  String? pixImageBase64;

  @observable
  String? cardUrl;

  @observable
  int? galaxPayId;

  @observable
  String? currentMyId;

  @observable
  PaymentStatus paymentStatus = PaymentStatus.none;

  @observable
  String? errorMessage;

  Timer? _statusTimer;

  @action
  void setMetodo(PayMethod m) {
    metodo = m;
  }

  @action
  void setVenda(VendaModel venda) {
    vendaAtual = venda;
    // Reseta o estado de pagamento ao trocar a venda
    resetPaymentState();
  }

  @action
  void resetPaymentState() {
    loading = false;
    pixEmv = null;
    pixImageBase64 = null;
    cardUrl = null;
    // IMPORTANTE: Não zere os IDs se a venda for a mesma
    // e já tiver flags do backend
    if (vendaAtual != null) {
      galaxPayId = null; // Zera o galaxPayId se for nova cobrança
      currentMyId = vendaAtual!.gatewayPagamentoId; // Mantém o myId da proposta
    } else {
      galaxPayId = null;
      currentMyId = null;
    }
    
    paymentStatus = PaymentStatus.none;
    errorMessage = null;
    _statusTimer?.cancel();
  }

  // ===================================================================
  // MÉTODO _buildPaymentPayload (TOTALMENTE REFEITO)
  // ===================================================================
  Map<String, dynamic> _buildPaymentPayload(BillingBreakdown billing) {
    if (vendaAtual == null) {
      throw Exception('Venda atual não definida na store do totem.');
    }

    final PessoaModel? titular = vendaAtual!.pessoaTitular;
    final List<ContatoModel> contatos = vendaAtual!.contatos ?? [];
    final EnderecoModel? endereco = vendaAtual!.endereco;
    final PlanModel? plano = vendaAtual!.plano;

    // --- Lógica de busca de Contatos (Ajustada) ---
    final emailContato = contatos.firstWhere(
      (c) => c.descricao.contains('@'), // <-- Prioriza o formato
      orElse: () => contatos.firstWhere(
        (c) => c.idMeioComunicacao == 1, // <-- Tenta pelo ID
        orElse: () => ContatoModel(idMeioComunicacao: 0, descricao: 'na@informado.com', nomeContato: 'N/A'),
      ),
    );

    final celularContato = contatos.firstWhere(
      (c) => c.idMeioComunicacao == 2, // <-- Prioriza o ID
      orElse: () => contatos.firstWhere(
        (c) => c.descricao != emailContato.descricao && c.descricao.replaceAll(RegExp(r'\D'), '').length >= 10,
        orElse: () => ContatoModel(idMeioComunicacao: 0, descricao: '9999999999', nomeContato: 'N/A'),
      ),
    );
    
    // Formata os campos como no payload do finish
    final celularDigits = celularContato.descricao.replaceAll(RegExp(r'\D'), '');
    final cepDigits = (endereco?.cep ?? '00000000').replaceAll(RegExp(r'\D'), '');

    // --- Valores (em CENTAVOS) ---
    // Usamos os valores do BillingBreakdown
    final int valorCentavos = (billing.valorAgora * 100).toInt();
    final int adesaoCentavos = (billing.adesao * 100).toInt();
    final int mensalCentavos = (billing.mensal * 100).toInt();

    // --- Montar Payload (NOVO FORMATO) ---
    return {
      'username': 'somosuni', // <-- Fixo, igual ao do Finish
      'customer': {
        'name': titular?.nome,
        'cpf': titular?.cpf, // (confirme se no PessoaModel é 'cpf' ou 'cpfCnpj')
        'email': emailContato.descricao,
        'cep': cepDigits,
        'phone': celularDigits, // <-- 'phone' (string) e não 'phones' (array)
      },
      'plan': plano?.nomeContrato,
      'enrollment': adesaoCentavos,
      'monthly': mensalCentavos,
      'value': valorCentavos, // <-- O valor da primeira cobrança
      'numMonths': 1, // <-- Fixo, igual ao do Finish
      'numLives': vendaAtual!.vidasSelecionadas,
      'nro_proposta': vendaAtual!.nroProposta, // <-- snake_case
    };
  }
  // ===================================================================
  // FIM DO MÉTODO CORRIGIDO
  // ===================================================================

  @action
  Future<void> gerarPix({required BillingBreakdown billing}) async { // <-- Recebe Billing
    loading = true;
    errorMessage = null;
    _statusTimer?.cancel();
    try {
      final payload = _buildPaymentPayload(billing); // <-- Passa Billing
      final result = await _paymentService.gerarPix(payload: payload);
      pixEmv = result.emv;
      pixImageBase64 = result.imageBase64;
      galaxPayId = result.galaxPayId;
      currentMyId = result.myId;
      paymentStatus = PaymentStatus.aguardando;
      _startStatusPolling();
    } catch (e) {
      errorMessage = 'Erro ao gerar PIX: $e';
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> gerarLinkCartao({required BillingBreakdown billing}) async { // <-- Recebe Billing
    loading = true;
    errorMessage = null;
    _statusTimer?.cancel();
    try {
      final payload = _buildPaymentPayload(billing); // <-- Passa Billing
      final result = await _paymentService.gerarCartao(payload: payload);
      cardUrl = result.url;
      galaxPayId = result.galaxPayId;
      currentMyId = result.myId;
      paymentStatus = PaymentStatus.aguardando;
      _startStatusPolling();
    } catch (e) {
      errorMessage = 'Erro ao gerar link do Cartão: $e';
    } finally {
      loading = false;
    }
  }
  
  // Função de auto-verificação
  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (paymentStatus == PaymentStatus.pago || loading) {
        timer.cancel();
        return;
      }
      consultarStatusPagamento();
    });
  }

  @action
  Future<PaymentStatus> consultarStatusPagamento() async {
    // Agora também verificamos o 'gatewayPagamentoId' que vem da VendaModel
    final idParaConsulta = currentMyId ?? vendaAtual?.gatewayPagamentoId;
    
    if (galaxPayId == null && (idParaConsulta == null || idParaConsulta.isEmpty)) {
      return PaymentStatus.none;
    }
    
    // Evita consultas paralelas
    if(loading && paymentStatus == PaymentStatus.aguardando) return paymentStatus;

    loading = true;
    try {
      final data = await _paymentService.consultarStatus(
        galaxPayId: galaxPayId,
        myId: idParaConsulta,
      );

      print(data); // DEBUG

      // ================== INÍCIO DA CORREÇÃO ==================
      
      // 1. Pega a LISTA de transações
      final transactionsList = data['Transactions'] as List?;
      String? statusApi;

      // 2. Verifica se a lista não está vazia
      if (transactionsList != null && transactionsList.isNotEmpty) {
        // 3. Pega o status do PRIMEIRO item da lista
        statusApi = transactionsList.first?['status']?.toString().toLowerCase();
      }
      
      // ================== FIM DA CORREÇÃO ==================

      if (statusApi == 'payed' || statusApi == 'completed' || statusApi == 'payexternal') { // Adicionei 'payexternal' por segurança
        paymentStatus = PaymentStatus.pago;
        _statusTimer?.cancel();
        
        // TODO: Notificar o backend que o pagamento foi concluído
        // (Similar ao que a FinishPaymentStore faz com o SalesService)
        // await Modular.get<SalesService>().atualizarStatusProposta(
        //   vendaAtual!.nroProposta!, 'pago',
        // );

      } else {
        // Se o status for "pendingPix" (como no seu print) ou qualquer outro,
        // ele cairá aqui e continuará aguardando.
        paymentStatus = PaymentStatus.aguardando;
      }
    } catch (e) {
      errorMessage = 'Erro ao consultar status: $e';
    } finally {
      loading = false;
    }
    return paymentStatus;
  }
  
  // Lembre-se de cancelar o timer ao sair da tela
  void dispose() {
    _statusTimer?.cancel();
  }
}