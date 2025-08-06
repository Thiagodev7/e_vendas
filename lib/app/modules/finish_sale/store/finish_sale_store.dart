import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:mobx/mobx.dart';

part 'finish_sale_store.g.dart';

class FinishSaleStore = _FinishSaleStoreBase with _$FinishSaleStore;

abstract class _FinishSaleStoreBase with Store {

  @action
  Future<void> gerarPagamento(VendaModel venda) async {
    // Aqui você pode chamar API ou abrir tela de pagamento
    print("Gerando pagamento para: ${venda.pessoaTitular?.nome}");
    // Exemplo: Modular.to.pushNamed('/pagamento', arguments: {...});
  }

  @action
  Future<void> gerarContrato(VendaModel venda) async {
    // Aqui você pode chamar API para gerar PDF contrato
    print("Gerando contrato para: ${venda.plano?.nomeContrato}");
    // Exemplo: Modular.to.pushNamed('/contrato', arguments: {...});
  }
}