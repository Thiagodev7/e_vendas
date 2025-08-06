import 'dart:convert';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sales_store.g.dart';

class SalesStore = _SalesStoreBase with _$SalesStore;

abstract class _SalesStoreBase with Store {
  final String _storageKey = "vendas_abertas";

  @observable
  ObservableList<VendaModel> vendas = ObservableList<VendaModel>();

  _SalesStoreBase() {
    _loadVendas();
  }

  /// Cria nova venda apenas com o plano selecionado
  @action
  Future<int> criarVendaComPlano(PlanModel? plano) async {
    final venda = VendaModel(plano: plano);
    vendas.add(venda);
    await _saveVendas();
    return vendas.length - 1;
  }

  /// Atualiza titular da venda
  @action
  Future<void> atualizarTitular(int index, PessoaModel titular) async {
    vendas[index] = vendas[index].copyWith(pessoaTitular: titular);
    await _saveVendas();
  }

  /// Atualiza endereço
  @action
  Future<void> atualizarEndereco(int index, EnderecoModel endereco) async {
    vendas[index] = vendas[index].copyWith(endereco: endereco);
    await _saveVendas();
  }

  /// Atualiza responsável financeiro
  @action
  Future<void> atualizarResponsavelFinanceiro(int index, PessoaModel resp) async {
    vendas[index] = vendas[index].copyWith(pessoaResponsavelFinanceiro: resp);
    await _saveVendas();
  }

  /// Atualiza dependentes
  @action
  Future<void> atualizarDependentes(int index, List<PessoaModel> dependentes) async {
    vendas[index] = vendas[index].copyWith(dependentes: dependentes);
    await _saveVendas();
  }

  /// Atualiza contatos
  @action
  Future<void> atualizarContatos(int index, List<ContatoModel> contatos) async {
    vendas[index] = vendas[index].copyWith(contatos: contatos);
    await _saveVendas();
  }

  /// Remove venda
  @action
  Future<void> removerVenda(int index) async {
    vendas.removeAt(index);
    await _saveVendas();
  }

  /// Salvar local
  @action
  Future<void> _saveVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(vendas.map((v) => v.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  @action
Future<void> atualizarPlano(int index, PlanModel plano) async {
  final venda = vendas[index].copyWith(plano: plano);
  vendas[index] = venda;
  await _saveVendas();
}

  /// Carregar vendas do local
  Future<void> _loadVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      vendas = ObservableList.of(
        decoded.map((e) => VendaModel.fromJson(e)).toList(),
      );
    }
  }
}