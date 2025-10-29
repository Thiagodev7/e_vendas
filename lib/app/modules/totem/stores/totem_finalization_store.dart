// lib/app/modules/totem/stores/totem_finalization_store.dart
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/finish_sale/service/datanext_service.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';

part 'totem_finalization_store.g.dart';

enum TotemFinalizationStatus { idle, loading, success, error }

class TotemFinalizationStore = _TotemFinalizationStoreBase with _$TotemFinalizationStore;

abstract class _TotemFinalizationStoreBase with Store {

  final DatanextService _service = Modular.get<DatanextService>();
  final GlobalStore _globalStore = Modular.get<GlobalStore>();

  @observable
  TotemFinalizationStatus status = TotemFinalizationStatus.idle;

  @observable
  String? errorMessage;

  @observable
  Map<String, dynamic>? lastSuccessData;

  @action
  Future<bool> finalizarVendaTotem({ required VendaModel venda }) async {
    status = TotemFinalizationStatus.loading;
    errorMessage = null;
    lastSuccessData = null;

    try {
      // Pega o CPF do vendedor (se necessário pelo service)
      final cpfVendedor = _globalStore.vendedorCpf.replaceAll(RegExp(r'\D'), '');
      // Descomente a validação se o CPF for obrigatório no DatanextService
      // if (cpfVendedor.length != 11) {
      //    throw Exception('CPF do vendedor não encontrado ou inválido.');
      // }

      final result = await _service.enviarDadosCliente(
        venda: venda,// Passe se o DatanextService exigir
      );

      print('Resultado da finalização Totem: $result'); // Mantenha para debug

      // ================== INÍCIO DA CORREÇÃO ==================
      // Nova lógica de verificação de sucesso:
      // Verifica se 'lista_erros' existe e é uma lista vazia.
      final bool sucesso;
      if (result['lista_erros'] is List && (result['lista_erros'] as List).isEmpty) {
          sucesso = true;
      } else {
          sucesso = false;
          // Tenta pegar a mensagem de erro da lista, se houver
          errorMessage = (result['lista_erros'] is List && (result['lista_erros'] as List).isNotEmpty)
              ? (result['lista_erros'] as List).first['msg']?.toString() ?? 'Datanext retornou um erro na lista_erros.'
              : 'Formato de resposta inesperado da Datanext.';
      }
      // ================== FIM DA CORREÇÃO ==================


      if (sucesso) {
        status = TotemFinalizationStatus.success;
        lastSuccessData = result; // Guarda a resposta completa
        print('>>> Finalização Totem: SUCESSO!'); // Log de sucesso
        return true;
      } else {
        // errorMessage já foi definido na lógica acima
        status = TotemFinalizationStatus.error;
        print('>>> Finalização Totem: ERRO - $errorMessage'); // Log de erro
        return false;
      }
    } on DatanextHttpException catch (e) {
      status = TotemFinalizationStatus.error;
      errorMessage = e.message; // Mensagem formatada pelo service
      print('>>> Finalização Totem: ERRO HTTP - $errorMessage'); // Log de erro HTTP
      return false;
    } catch (e) {
      status = TotemFinalizationStatus.error;
      errorMessage = 'Erro inesperado ao finalizar: $e';
      print('>>> Finalização Totem: ERRO INESPERADO - $errorMessage'); // Log de erro genérico
      return false;
    }
  }

  @action
  void reset() {
    status = TotemFinalizationStatus.idle;
    errorMessage = null;
    lastSuccessData = null;
  }
}