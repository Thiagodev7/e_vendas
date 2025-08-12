// lib/app/modules/sales/stores/sales_store.dart

import 'dart:convert';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
<<<<<<< HEAD
=======
import 'package:flutter_modular/flutter_modular.dart';
>>>>>>> f47e3e3 (atualização 12/08)
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sales_store.g.dart';

class SalesStore = _SalesStoreBase with _$SalesStore;

abstract class _SalesStoreBase with Store {
  final String _storageKey = "vendas_abertas";
<<<<<<< HEAD
  final SalesService _service;
  final GlobalStore _globalStore;
=======
  final SalesService _service = SalesService();
  final GlobalStore _globalStore = Modular.get<GlobalStore>();
>>>>>>> f47e3e3 (atualização 12/08)

  @observable
  ObservableList<VendaModel> vendas = ObservableList<VendaModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

<<<<<<< HEAD
  _SalesStoreBase(this._service, this._globalStore);

  /// Busca as vendas abertas do backend e atualiza o estado da store.
  @action
  Future<void> fetchVendas() async {
    isLoading = true;
    errorMessage = null;
    try {
      final vendedorId = _globalStore.vendedor?['id'];
      if (vendedorId == null) {
        throw Exception("Vendedor não identificado. Faça login novamente.");
      }

      final lista = await _service.fetchOpenSales(vendedorId);
      vendas = ObservableList.of(lista);
      await _saveVendas();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }

  /// Carrega as vendas salvas localmente no SharedPreferences.
  @action
  // ignore: unused_element
=======
  _SalesStoreBase() {
    // Inicia a store carregando os dados locais (para UI rápida)
    // e imediatamente busca os dados mais recentes do servidor.
    _loadVendasFromLocal();
  }

  /// Busca as propostas abertas do backend e atualiza o estado da store.
  /// Este método é chamado pela SalesPage ao ser iniciada.
  @action
  Future<void> syncOpenProposals() async {
    
    errorMessage = null;
    try {
      // Pega o ID do vendedor logado a partir do GlobalStore.
      //final vendedorId = _globalStore.vendedor?['id'];
      final vendedorId = 22;
      if (vendedorId == null) {
        throw Exception("Vendedor não identificado. Faça login novamente.");
      }

      final propostasJson = await _service.getOpenProposals(vendedorId);
      
      // Usa o construtor factory `fromProposalJson` para converter os dados da API
      // em uma lista de VendaModel.
      final propostasConvertidas = propostasJson
          .map((json) => VendaModel.fromJson(json))
          .toList();

      // Substitui a lista de vendas atual pelos dados frescos do servidor.
      vendas = ObservableList.of(propostasConvertidas);

      // Salva a nova lista no armazenamento local para acesso offline.
      await _saveVendas();

    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }

  /// Carrega as vendas salvas localmente no SharedPreferences.
  @action
>>>>>>> f47e3e3 (atualização 12/08)
  Future<void> _loadVendasFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      vendas = ObservableList.of(
        decoded.map((e) => VendaModel.fromJson(e)).toList(),
      );
    }
  }

  /// Salva a lista atual de vendas no SharedPreferences.
  @action
  Future<void> _saveVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(vendas.map((v) => v.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // --- Métodos existentes para manipulação de vendas ---

  /// Cria nova venda
  @action
  Future<int> criarVendaComPlano(PlanModel? plano) async {
    final venda = VendaModel(plano: plano);
    vendas.add(venda);
    await _saveVendas();
    return vendas.length - 1;
  }

  /// Atualiza titular
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
    final vendaAtual = vendas[index];
    final novo = vendaAtual.copyWith(dependentes: dependentes);

    if (vendaAtual.plano != null) {
      final vidas = (dependentes.length) + 1;
      final novoPlano = vendaAtual.plano!.copyWith(vidasSelecionadas: vidas);
      vendas[index] = novo.copyWith(plano: novoPlano);
    } else {
      vendas[index] = novo;
    }
    await _saveVendas();
  }

  /// Atualiza contatos
  @action
  Future<void> atualizarContatos(int index, List<ContatoModel> contatos) async {
    vendas[index] = vendas[index].copyWith(contatos: contatos);
    await _saveVendas();
  }

  /// Atualiza plano
  @action
  Future<void> atualizarPlano(int index, PlanModel plano) async {
    final vendaAtual = vendas[index];
    final vidas = (vendaAtual.dependentes?.length ?? 0) + 1;
    final planoComVidas = plano.copyWith(vidasSelecionadas: vidas);
    vendas[index] = vendaAtual.copyWith(plano: planoComVidas);
    await _saveVendas();
  }

  /// Remove venda
  @action
  Future<void> removerVenda(int index) async {
    vendas.removeAt(index);
    await _saveVendas();
  }

  /// Finaliza venda (apenas remove da lista local)
  @action
  Future<void> finalizarVenda(int index) async {
    vendas.removeAt(index);
    await _saveVendas();
  }

  /// Helpers de validação
  bool vendaTemPlano(int index) => vendas[index].plano != null;
  bool vendaTemCliente(int index) => vendas[index].pessoaTitular != null;
}