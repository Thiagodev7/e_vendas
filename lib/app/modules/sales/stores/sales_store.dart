import 'dart:convert';

import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sales_store.g.dart';

class SalesStore = _SalesStoreBase with _$SalesStore;

abstract class _SalesStoreBase with Store {
  _SalesStoreBase({
    SalesService? service,
    GlobalStore? global,
  })  : _service = service ?? Modular.get<SalesService>(),
        _global = global ?? Modular.get<GlobalStore>();

  final SalesService _service;
  final GlobalStore _global;

  static const _prefsKey = 'sales_drafts';
  static const _prefsKeyCloudOverrides = 'sales_cloud_overrides_v1';
  Map<int, VendaModel> _cloudOverrides = {};

  @observable
  ObservableList<VendaModel> vendas = ObservableList.of([]);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  VendaOrigin? originFilter;

  @computed
  List<VendaModel> get filteredVendas {
    if (originFilter == null) return vendas.toList();
    return vendas.where((v) => v.origin == originFilter).toList();
  }

  @computed
  int get cloudCount =>
      vendas.where((v) => v.origin == VendaOrigin.cloud).length;

  @computed
  int get localCount =>
      vendas.where((v) => v.origin == VendaOrigin.local).length;

  @computed
  int get totalCount => vendas.length;

  @action
  void setFilter(VendaOrigin? filter) {
    originFilter = filter;
  }

  // -------------------- Persistência Local --------------------

  Future<List<VendaModel>> _loadLocalVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];
    return raw
        .map((s) => VendaModel.fromLocalJson(jsonDecode(s)))
        .map((v) => v.copyWith(origin: VendaOrigin.local))
        .toList();
  }

  Future<void> _persistLocalsFromCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    final locals = vendas
        .where((v) => v.origin == VendaOrigin.local)
        .map((v) =>
            jsonEncode(v.copyWith(origin: VendaOrigin.local).toLocalJson()))
        .toList();
    await prefs.setStringList(_prefsKey, locals);
  }

  Future<void> _removeLocalVendaInstance(VendaModel target) async {
    await _persistLocalsFromCurrentState();
  }

  // -------------------- Overrides Cloud --------------------

  Future<void> _loadCloudOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyCloudOverrides);
    if (raw == null || raw.isEmpty) {
      _cloudOverrides = {};
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cloudOverrides = decoded.map((k, v) => MapEntry(
          int.parse(k),
          VendaModel.fromLocalJson(v as Map<String, dynamic>)
              .copyWith(origin: VendaOrigin.cloud),
        ));
  }

  Future<void> _saveCloudOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _cloudOverrides.map(
      (k, v) => MapEntry(k.toString(), v.toLocalJson()),
    );
    await prefs.setString(_prefsKeyCloudOverrides, jsonEncode(map));
  }

  VendaModel _mergeCloudWithOverride(VendaModel cloud, VendaModel override) {
    // Mantém sempre os flags de status vindos da nuvem (cloud),
    // e só sobrescreve dados de cadastro/endereço/contatos/plano.
    return cloud.copyWith(
      pessoaTitular: override.pessoaTitular ?? cloud.pessoaTitular,
      pessoaResponsavelFinanceiro: override.pessoaResponsavelFinanceiro ??
          cloud.pessoaResponsavelFinanceiro,
      dependentes: override.dependentes ?? cloud.dependentes,
      endereco: override.endereco ?? cloud.endereco,
      contatos: override.contatos ?? cloud.contatos,
      plano: override.plano ?? cloud.plano,
      nroProposta: cloud.nroProposta,
      origin: VendaOrigin.cloud,
    );
  }

  void _upsertCloudOverrideIfNeeded(int index) {
    if (!_indexIsValid(index)) return;
    final v = vendas[index];
    if (v.origin == VendaOrigin.cloud && v.nroProposta != null) {
      _cloudOverrides[v.nroProposta!] = v;
      _saveCloudOverrides();
    }
  }

  // -------------------- Helpers de hidratação --------------------

  /// Ajusta o plano da venda para refletir:
  /// - vidasSelecionadas = dependentes + 1
  /// - dueDay padrão quando mensal
  PlanModel? _hydratePlanInfo(VendaModel v) {
    final p = v.plano;
    if (p == null) return null;

    final vidas = (v.dependentes?.length ?? 0) + 1;
    final isAnnual = p.isAnnual == true;
    final due = isAnnual ? null : (p.dueDay ?? 10);

    return p.copyWith(
      vidasSelecionadas: vidas,
      isAnnual: isAnnual,
      dueDay: due,
    );
  }

  // -------------------- Sync --------------------

  @action
  Future<void> syncOpenProposals() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _loadCloudOverrides();
      final local = await _loadLocalVendas();

      // ajuste se tiver no GlobalStore (ex.: _global.userId)
      const vendedorId = 12;
      var cloud = await _service.fetchOpenProposals(vendedorId: vendedorId);

      // aplica overrides locais sobre o que veio da nuvem (apenas campos de cadastro/plano)
      cloud = cloud.map((c) {
        final id = c.nroProposta;
        if (id != null && _cloudOverrides.containsKey(id)) {
          return _mergeCloudWithOverride(c, _cloudOverrides[id]!);
        }
        return c;
      }).toList();

      // Junta e hidrata planos
      var combined = [...local, ...cloud];
      combined = combined.map((v) {
        final hydrated = _hydratePlanInfo(v);
        return hydrated != null ? v.copyWith(plano: hydrated) : v;
      }).toList();

      vendas = ObservableList.of(combined);
    } catch (e) {
      errorMessage = e.toString();
      try {
        final local = await _loadLocalVendas();
        // Hidrata locais também
        final hydrated = local.map((v) {
          final hp = _hydratePlanInfo(v);
          return hp != null ? v.copyWith(plano: hp) : v;
        }).toList();
        vendas = ObservableList.of(hydrated);
      } catch (_) {}
    } finally {
      isLoading = false;
    }
  }

  // -------------------- CRUD Local --------------------

  @action
  Future<void> novaVendaLocal(VendaModel v) async {
    // hidrata o plano (vidas e dueDay) antes de inserir
    final hp = _hydratePlanInfo(v);
    final nova = (hp != null ? v.copyWith(plano: hp) : v).copyWith(
      origin: VendaOrigin.local,
    );
    vendas.insert(0, nova);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<int> criarVendaComPlano(PlanModel? plano) async {
    var venda = VendaModel(plano: plano);
    // hidrata conforme dependentes (provavelmente 0 → vidas=1) e dueDay mensal
    final hp = _hydratePlanInfo(venda);
    if (hp != null) {
      venda = venda.copyWith(plano: hp);
    }
    vendas.add(venda);
    await _persistLocalsFromCurrentState();
    return vendas.length - 1;
  }

  @action
  Future<void> removerVenda(int index) async {
    if (!_indexIsValid(index)) return;
    final target = vendas[index];

    isLoading = true;
    errorMessage = null;
    try {
      if (target.origin == VendaOrigin.cloud && target.nroProposta != null) {
        await _service.excluirProposta(nroProposta: target.nroProposta!);
        _cloudOverrides.remove(target.nroProposta!);
        await _saveCloudOverrides();
      }

      vendas.removeAt(index);

      if (target.origin == VendaOrigin.local) {
        await _persistLocalsFromCurrentState();
      }
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  // -------------------- Fluxo Finalização --------------------

  /// Passo 1: criar/garantir a proposta e retornar o nro
  @action
  Future<int> finalizarVenda(int index) async {
    if (!_indexIsValid(index)) throw Exception('Índice inválido');
    final atual = vendas[index];

    if (atual.plano == null || atual.pessoaTitular == null) {
      throw Exception('Venda incompleta: plano e titular são obrigatórios.');
    }

    isLoading = true;
    errorMessage = null;
    try {
      // >>> SE JÁ EXISTE NA NUVEM, ATUALIZA OS DADOS ANTES DE FINALIZAR <<<
      if (atual.origin == VendaOrigin.cloud && atual.nroProposta != null) {
        await _service.atualizarProposta(
          nroProposta: atual.nroProposta!,
          v: atual,
        );
        // garante override local e persistência
        _upsertCloudOverrideIfNeeded(index);
        await _persistLocalsFromCurrentState();
        return atual.nroProposta!;
      }

      // Caso contrário, cria na nuvem
      const vendedorId = 12;
      final nro = await _service.criarProposta(atual, vendedorId: vendedorId);

      final atualizado = atual.copyWith(
        origin: VendaOrigin.cloud,
        nroProposta: nro,
      );
      vendas[index] = atualizado;

      await _persistLocalsFromCurrentState();
      _upsertCloudOverrideIfNeeded(index);

      return nro;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Passo 2: após pagamento e contrato ok, marca venda_finalizada = true e remove da lista
  @action
  Future<void> confirmarFinalizacao(int index) async {
    if (!_indexIsValid(index)) throw Exception('Índice inválido');
    final v = vendas[index];

    isLoading = true;
    errorMessage = null;
    try {
      // Garante proposta na nuvem
      if (v.origin == VendaOrigin.local || v.nroProposta == null) {
        await finalizarVenda(index);
      }
      final nro = vendas[index].nroProposta;
      if (nro == null) {
        throw Exception('Proposta sem nro_proposta após criação.');
      }

      await _service.atualizarStatusProposta(
        nroProposta: nro,
        vendaFinalizada: true,
      );

      _cloudOverrides.remove(nro);
      await _saveCloudOverrides();
      vendas.removeAt(index);

      await _persistLocalsFromCurrentState();
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  // -------------------- Updates --------------------

  bool _indexIsValid(int index) => index >= 0 && index < vendas.length;

  @action
  Future<void> atualizarPlano(int index, PlanModel plan) async {
    if (!_indexIsValid(index)) return;
    // garante dueDay quando mensal + vidas coerentes com dependentes atuais
    final atual = vendas[index];
    var fixed = plan;
    if ((fixed.isAnnual != true) && fixed.dueDay == null) {
      fixed = fixed.copyWith(dueDay: 10);
    }
    final v = atual.copyWith(plano: fixed);
    final hp = _hydratePlanInfo(v);
    vendas[index] = hp != null ? v.copyWith(plano: hp) : v;

    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<void> atualizarTitular(int index, PessoaModel titular) async {
    if (!_indexIsValid(index)) return;
    final v = vendas[index].copyWith(pessoaTitular: titular);
    vendas[index] = v;
    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<void> atualizarResponsavelFinanceiro(
      int index, PessoaModel resp) async {
    if (!_indexIsValid(index)) return;
    final v = vendas[index].copyWith(pessoaResponsavelFinanceiro: resp);
    vendas[index] = v;
    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<void> atualizarEndereco(int index, EnderecoModel end) async {
    if (!_indexIsValid(index)) return;
    final v = vendas[index].copyWith(endereco: end);
    vendas[index] = v;
    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<void> atualizarContatos(int index, List<ContatoModel> contatos) async {
    if (!_indexIsValid(index)) return;
    final v = vendas[index].copyWith(contatos: contatos);
    vendas[index] = v;
    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  @action
  Future<void> atualizarDependentes(int index, List<PessoaModel> deps) async {
    if (!_indexIsValid(index)) return;

    var v = vendas[index].copyWith(dependentes: deps);

    // re-hidrata com nova qtd. de vidas
    final hp = _hydratePlanInfo(v);
    if (hp != null) {
      v = v.copyWith(plano: hp);
    }

    vendas[index] = v;
    _upsertCloudOverrideIfNeeded(index);
    await _persistLocalsFromCurrentState();
  }

  bool vendaTemPlano(int index) =>
      _indexIsValid(index) && vendas[index].plano != null;

  bool vendaTemCliente(int index) =>
      _indexIsValid(index) && vendas[index].pessoaTitular != null;
}
