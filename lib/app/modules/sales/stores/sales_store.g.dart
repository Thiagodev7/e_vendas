// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SalesStore on _SalesStoreBase, Store {
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

  late final _$criarVendaComPlanoAsyncAction =
      AsyncAction('_SalesStoreBase.criarVendaComPlano', context: context);

  @override
  Future<int> criarVendaComPlano(PlanModel? plano) {
    return _$criarVendaComPlanoAsyncAction
        .run(() => super.criarVendaComPlano(plano));
  }

  late final _$atualizarTitularAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarTitular', context: context);

  @override
  Future<void> atualizarTitular(int index, PessoaModel titular) {
    return _$atualizarTitularAsyncAction
        .run(() => super.atualizarTitular(index, titular));
  }

  late final _$atualizarEnderecoAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarEndereco', context: context);

  @override
  Future<void> atualizarEndereco(int index, EnderecoModel endereco) {
    return _$atualizarEnderecoAsyncAction
        .run(() => super.atualizarEndereco(index, endereco));
  }

  late final _$atualizarResponsavelFinanceiroAsyncAction = AsyncAction(
      '_SalesStoreBase.atualizarResponsavelFinanceiro',
      context: context);

  @override
  Future<void> atualizarResponsavelFinanceiro(int index, PessoaModel resp) {
    return _$atualizarResponsavelFinanceiroAsyncAction
        .run(() => super.atualizarResponsavelFinanceiro(index, resp));
  }

  late final _$atualizarDependentesAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarDependentes', context: context);

  @override
  Future<void> atualizarDependentes(int index, List<PessoaModel> dependentes) {
    return _$atualizarDependentesAsyncAction
        .run(() => super.atualizarDependentes(index, dependentes));
  }

  late final _$atualizarContatosAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarContatos', context: context);

  @override
  Future<void> atualizarContatos(int index, List<ContatoModel> contatos) {
    return _$atualizarContatosAsyncAction
        .run(() => super.atualizarContatos(index, contatos));
  }

  late final _$atualizarPlanoAsyncAction =
      AsyncAction('_SalesStoreBase.atualizarPlano', context: context);

  @override
  Future<void> atualizarPlano(int index, PlanModel plano) {
    return _$atualizarPlanoAsyncAction
        .run(() => super.atualizarPlano(index, plano));
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
  Future<void> finalizarVenda(int index) {
    return _$finalizarVendaAsyncAction.run(() => super.finalizarVenda(index));
  }

  late final _$_saveVendasAsyncAction =
      AsyncAction('_SalesStoreBase._saveVendas', context: context);

  @override
  Future<void> _saveVendas() {
    return _$_saveVendasAsyncAction.run(() => super._saveVendas());
  }

  @override
  String toString() {
    return '''
vendas: ${vendas}
    ''';
  }
}
