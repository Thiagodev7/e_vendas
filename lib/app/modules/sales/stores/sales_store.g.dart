// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SalesStore on _SalesStoreBase, Store {
  Computed<List<VendaModel>>? _$filteredVendasComputed;

  @override
  List<VendaModel> get filteredVendas => (_$filteredVendasComputed ??=
          Computed<List<VendaModel>>(() => super.filteredVendas,
              name: '_SalesStoreBase.filteredVendas'))
      .value;
  Computed<int>? _$cloudCountComputed;

  @override
  int get cloudCount =>
      (_$cloudCountComputed ??= Computed<int>(() => super.cloudCount,
              name: '_SalesStoreBase.cloudCount'))
          .value;
  Computed<int>? _$localCountComputed;

  @override
  int get localCount =>
      (_$localCountComputed ??= Computed<int>(() => super.localCount,
              name: '_SalesStoreBase.localCount'))
          .value;
  Computed<int>? _$totalCountComputed;

  @override
  int get totalCount =>
      (_$totalCountComputed ??= Computed<int>(() => super.totalCount,
              name: '_SalesStoreBase.totalCount'))
          .value;

  late final _$vendasAtom =
      Atom(name: '_SalesStoreBase.vendas', context: context);

  @override
  ObservableList<VendaModel> get vendas {
    _$vendasAtom.reportRead();
    return super.vendas;
  }

  @override
  set vendas(ObservableList<VendaModel> value) {
    _$vendasAtom.reportWrite(value, super.vendas, () {
      super.vendas = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_SalesStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_SalesStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$originFilterAtom =
      Atom(name: '_SalesStoreBase.originFilter', context: context);

  @override
  VendaOrigin? get originFilter {
    _$originFilterAtom.reportRead();
    return super.originFilter;
  }

  @override
  set originFilter(VendaOrigin? value) {
    _$originFilterAtom.reportWrite(value, super.originFilter, () {
      super.originFilter = value;
    });
  }

  late final _$syncOpenProposalsAsyncAction =
      AsyncAction('_SalesStoreBase.syncOpenProposals', context: context);

  @override
  Future<void> syncOpenProposals() {
    return _$syncOpenProposalsAsyncAction.run(() => super.syncOpenProposals());
  }

  late final _$novaVendaLocalAsyncAction =
      AsyncAction('_SalesStoreBase.novaVendaLocal', context: context);

  @override
  Future<void> novaVendaLocal(VendaModel v) {
    return _$novaVendaLocalAsyncAction.run(() => super.novaVendaLocal(v));
  }

  late final _$criarVendaComPlanoAsyncAction =
      AsyncAction('_SalesStoreBase.criarVendaComPlano', context: context);

  @override
  Future<int> criarVendaComPlano(PlanModel? plano) {
    return _$criarVendaComPlanoAsyncAction
        .run(() => super.criarVendaComPlano(plano));
  }

  late final _$removerVendaAsyncAction =
      AsyncAction('_SalesStoreBase.removerVenda', context: context);

  @override
  Future<void> removerVenda(int index) {
    return _$removerVendaAsyncAction.run(() => super.removerVenda(index));
  }

  late final _$finalizarVendaAsyncAction =
      AsyncAction('_SalesStoreBase.finalizarVenda', context: context);

  @override
  Future<int> finalizarVenda(int index) {
    return _$finalizarVendaAsyncAction.run(() => super.finalizarVenda(index));
  }

  late final _$confirmarFinalizacaoAsyncAction =
      AsyncAction('_SalesStoreBase.confirmarFinalizacao', context: context);

  @override
  Future<void> confirmarFinalizacao(int index) {
    return _$confirmarFinalizacaoAsyncAction
        .run(() => super.confirmarFinalizacao(index));
  }

  late final _$atualizarPlanoAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarPlano', context: context);

  @override
  Future<void> atualizarPlano(int index, PlanModel plan) {
    return _$atualizarPlanoAsyncAction
        .run(() => super.atualizarPlano(index, plan));
  }

  late final _$atualizarTitularAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarTitular', context: context);

  @override
  Future<void> atualizarTitular(int index, PessoaModel titular) {
    return _$atualizarTitularAsyncAction
        .run(() => super.atualizarTitular(index, titular));
  }

  late final _$atualizarResponsavelFinanceiroAsyncAction = AsyncAction(
      '_SalesStoreBase.atualizarResponsavelFinanceiro',
      context: context);

  @override
  Future<void> atualizarResponsavelFinanceiro(int index, PessoaModel resp) {
    return _$atualizarResponsavelFinanceiroAsyncAction
        .run(() => super.atualizarResponsavelFinanceiro(index, resp));
  }

  late final _$atualizarEnderecoAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarEndereco', context: context);

  @override
  Future<void> atualizarEndereco(int index, EnderecoModel end) {
    return _$atualizarEnderecoAsyncAction
        .run(() => super.atualizarEndereco(index, end));
  }

  late final _$atualizarContatosAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarContatos', context: context);

  @override
  Future<void> atualizarContatos(int index, List<ContatoModel> contatos) {
    return _$atualizarContatosAsyncAction
        .run(() => super.atualizarContatos(index, contatos));
  }

  late final _$atualizarDependentesAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarDependentes', context: context);

  @override
  Future<void> atualizarDependentes(int index, List<PessoaModel> deps) {
    return _$atualizarDependentesAsyncAction
        .run(() => super.atualizarDependentes(index, deps));
  }

  late final _$_SalesStoreBaseActionController =
      ActionController(name: '_SalesStoreBase', context: context);

  @override
  void setFilter(VendaOrigin? filter) {
    final _$actionInfo = _$_SalesStoreBaseActionController.startAction(
        name: '_SalesStoreBase.setFilter');
    try {
      return super.setFilter(filter);
    } finally {
      _$_SalesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
vendas: ${vendas},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
originFilter: ${originFilter},
filteredVendas: ${filteredVendas},
cloudCount: ${cloudCount},
localCount: ${localCount},
totalCount: ${totalCount}
    ''';
  }
}
