import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'package:e_vendas/app/modules/finish_sale/widgets/billing_calculator.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:e_vendas/app/modules/finish_sale/service/datanext_service.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';

part 'finalizacao_store.g.dart';

enum FinalizacaoStatus { idle, loading, success, error }

class FinalizacaoStore = _FinalizacaoStoreBase with _$FinalizacaoStore;

abstract class _FinalizacaoStoreBase with Store {
  _FinalizacaoStoreBase(this._service);

  final DatanextService _service;

  // Stores p/ leitura do estado atual
  final FinishPaymentStore _paymentStore = Modular.get<FinishPaymentStore>();
  final FinishContractStore _contractStore = Modular.get<FinishContractStore>();
  final GlobalStore _globalStore = Modular.get<GlobalStore>();
  final FinishSaleStore _saleStore = Modular.get<FinishSaleStore>(); 

  // ======= STATE =======
  @observable
  FinalizacaoStatus status = FinalizacaoStatus.idle;

  @observable
  String? errorMessage;

  /// Guarda o payload de erro bruto do backend para detalhar na UI (ex.: erro.lista_erros)
  @observable
  Map<String, dynamic>? lastError;

  /// Guarda o retorno de sucesso
  @observable
  Map<String, dynamic>? lastSuccess;

  // ======= ACTIONS =======
  /// Regras:
  /// - Exige pagamento concluído e contrato assinado.
  /// - Se [cpfVendedor] vier vazio, usa o CPF do vendedor logado (GlobalStore).
  /// - CPF precisa ter 11 dígitos.
  @action
  Future<bool> finalizarVenda({
    required int nroProposta,
    String? cpfVendedor, // opcional (permite fallback)
  }) async {
    // 1) Bloqueios de negócio
    final pagamentoOk = _paymentStore.pagamentoConcluidoServer == true;
    final contratoOk = _contractStore.contratoAssinadoServer == true;

    if (!pagamentoOk || !contratoOk) {
      status = FinalizacaoStatus.error;
      lastError = null;
      errorMessage = [
        if (!pagamentoOk) 'Pagamento ainda não foi concluído.',
        if (!contratoOk) 'Contrato ainda não foi assinado.',
      ].join(' ');
      return false;
    }

    // 2) Resolve CPF do vendedor
    String resolvedCpf = (cpfVendedor ?? '').trim();
    if (resolvedCpf.isEmpty) {
      resolvedCpf = _globalStore.vendedorCpf.trim();
    }

    // 3) Sanitiza/valida CPF
    final cpfDigits = resolvedCpf.replaceAll(RegExp(r'\D'), '');
    if (cpfDigits.length != 11) {
      status = FinalizacaoStatus.error;
      lastError = null;
      errorMessage =
          'Informe um CPF de vendedor válido (11 dígitos). Verifique o campo ou o cadastro do vendedor.';
      return false;
    }

    // ===== calcula faturamento (centavos) a partir da venda atual =====
    Map<String, dynamic>? faturamento;
    final v = _saleStore.venda;
    if (v != null && v.plano != null) {
      final vidas = ((v.dependentes?.length ?? 0) + 1);
      final planSync = v.plano!.copyWith(vidasSelecionadas: vidas);
      final b = computeBilling(planSync);

      // --- Início da Lógica Modificada ---

      final bool isAnual = b.kind == BillingKind.anual;
      
      // Valores base
      final int adesaoCentavos = (b.adesao * 100).round();
      int mensalCentavos;
      int prorataCentavos;
      int totalPrimeiraCentavos;

      if (isAnual) {
        // 1. APLICA 10% DE DESCONTO NO MENSAL (conforme pedido)
        // (b.mensal * 0.9) * 100 
        mensalCentavos = (b.mensal * 90).round(); 

        // 2. APLICA 10% DE DESCONTO NO PRORATA (conforme pedido)
        // (b.prorata * 0.9) * 100
        prorataCentavos = (b.prorata * 90).round();

        // 3. O TOTAL É prorata(com desconto) + adesao (conforme pedido)
        totalPrimeiraCentavos = prorataCentavos + adesaoCentavos;

      } else {
        // Lógica original (se não for anual, usa os valores cheios)
        mensalCentavos = (b.mensal * 100).round();
        prorataCentavos = (b.prorata * 100).round();
        totalPrimeiraCentavos = b.valorAgoraCentavos; // Valor original do computeBilling
      }

      // Monta o mapa 'faturamento' com os valores corretos
      faturamento = {
        'vidas': vidas,
        'is_anual': isAnual,
        'num_meses': isAnual ? 12 : 1,
        'due_day': b.dueDay,
        'mensal_centavos': mensalCentavos,
        'adesao_centavos': adesaoCentavos,
        'prorata_centavos': prorataCentavos,
        'total_primeira_centavos': totalPrimeiraCentavos, // ESTE é o que cobra agora
      };
      // --- Fim da Lógica Modificada ---
    }

    status = FinalizacaoStatus.loading;
    try {
      final res = await _service.enviarPessoaComposicao(
        nroProposta: nroProposta,
        cpfVendedor: cpfDigits,
        faturamento: faturamento, // ⬅️ manda pro backend
      );
      status = FinalizacaoStatus.success;
      lastSuccess = res;
      return true;
    } on DatanextHttpException catch (e) {
      status = FinalizacaoStatus.error;
      // guarda bruto para o widget detalhar
      if (e.data is Map) {
        lastError = Map<String, dynamic>.from(e.data as Map);
      } else {
        lastError = null;
      }

      // tenta extrair mensagens amigáveis do Datasys
      errorMessage = _extractDatasysErrorMessage(e) ?? e.message;
      return false;
    } catch (e) {
      status = FinalizacaoStatus.error;
      lastError = null;
      errorMessage = 'Falha inesperada ao finalizar: $e';
      return false;
    }
  }

  /// Tenta encontrar mensagens específicas dentro do payload de erro do Datasys.
  /// Prioriza: data.erro.lista_erros[].msg (+ registro)
  String? _extractDatasysErrorMessage(DatanextHttpException e) {
    final data = e.data;
    if (data is Map) {
      // Padrão quando nosso backend devolve { message, erro: { lista_erros: [...] } }
      final erro = data['erro'];
      if (erro is Map) {
        final lista = erro['lista_erros'];
        if (lista is List && lista.isNotEmpty) {
          final msgs = <String>[];
          for (final it in lista) {
            if (it is Map) {
              final msg = (it['msg'] ?? '').toString().trim();
              final reg = (it['registro'] ?? '').toString().trim();
              if (msg.isNotEmpty && reg.isNotEmpty) {
                msgs.add('$msg ($reg)');
              } else if (msg.isNotEmpty) {
                msgs.add(msg);
              }
            }
          }
          if (msgs.isNotEmpty) return msgs.join(' | ');
        }
      }

      // fallback: usa 'message' se vier algo
      final m = (data['message'] ?? data['error_description'] ?? data['error'])
          ?.toString();
      if (m != null && m.trim().isNotEmpty) return m;
    }
    return null;
  }

  @action
  void reset() {
    status = FinalizacaoStatus.idle;
    errorMessage = null;
    lastError = null;
    lastSuccess = null;
  }
}