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

  /// Cria nova venda (campos opcionais)
  @action
  Future<void> criarVenda({
    PessoaModel? titular,
    PessoaModel? responsavelFinanceiro,
    List<PessoaModel>? dependentes,
    EnderecoModel? endereco,
    List<ContatoModel>? contatos,
    PlanModel? plano, // substituindo contrato
  }) async {
    final novaVenda = VendaModel(
      pessoaTitular: titular,
      pessoaResponsavelFinanceiro: responsavelFinanceiro,
      dependentes: dependentes ?? [],
      endereco: endereco,
      contato: contatos ?? [],
      plano: plano,
    );

    vendas.add(novaVenda);
    await _saveVendas();
  }

  /// Remove venda pelo índice
  @action
  Future<void> removerVenda(int index) async {
    vendas.removeAt(index);
    await _saveVendas();
  }

  /// Persiste as vendas
  Future<void> _saveVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(vendas.map((v) => v.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Carrega vendas
  Future<void> _loadVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      vendas = ObservableList.of(
        decoded.map((e) => VendaModel.fromJson(e)).toList(),
      );
    }
  }
}