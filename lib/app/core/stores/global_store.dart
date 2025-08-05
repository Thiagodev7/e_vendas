import 'package:mobx/mobx.dart';

part 'global_store.g.dart';

class GlobalStore = _GlobalStoreBase with _$GlobalStore;

abstract class _GlobalStoreBase with Store {
  // -------------------------------
  // INFORMAÇÕES DO VENDEDOR LOGADO
  // -------------------------------
  @observable
  Map<String, dynamic>? vendedor;

  @computed
  String get vendedorNome => vendedor?['nome_completo'] ?? 'Carregando...';

  @action
  void setVendedor(Map<String, dynamic> dados) {
    vendedor = dados;
  }

  // -------------------------------
  // GERENCIAMENTO DE VENDAS
  // -------------------------------
  @observable
  ObservableList<Map<String, dynamic>> vendasAbertas =
      ObservableList<Map<String, dynamic>>();

  @observable
  ObservableList<Map<String, dynamic>> vendasFinalizadas =
      ObservableList<Map<String, dynamic>>();

  /// Adiciona nova venda aberta
  @action
  void adicionarVenda(Map<String, dynamic> venda) {
    vendasAbertas.add(venda);
  }

  /// Finaliza uma venda e move para lista finalizada
  @action
  void finalizarVenda(int index) {
    final venda = vendasAbertas.removeAt(index);
    vendasFinalizadas.add(venda);
  }

  /// Limpa todas as vendas (ex: logout)
  @action
  void limparVendas() {
    vendasAbertas.clear();
    vendasFinalizadas.clear();
  }
}