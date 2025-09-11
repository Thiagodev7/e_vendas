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

    // 4) Chamada
    status = FinalizacaoStatus.loading;
    errorMessage = null;
    lastError = null;
    lastSuccess = null;

    try {
      final res = await _service.enviarPessoaComposicao(
        nroProposta: nroProposta,
        cpfVendedor: cpfDigits,
      );

      status = FinalizacaoStatus.success;
      lastSuccess = res;
      lastError = null;
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