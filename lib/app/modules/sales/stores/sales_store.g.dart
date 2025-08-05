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

  late final _$criarVendaAsyncAction =
      AsyncAction('_SalesStoreBase.criarVenda', context: context);

  @override
  Future<void> criarVenda(
      {PessoaModel? titular,
      PessoaModel? responsavelFinanceiro,
      List<PessoaModel>? dependentes,
      EnderecoModel? endereco,
      List<ContatoModel>? contatos,
      PlanModel? plano}) {
    return _$criarVendaAsyncAction.run(() => super.criarVenda(
        titular: titular,
        responsavelFinanceiro: responsavelFinanceiro,
        dependentes: dependentes,
        endereco: endereco,
        contatos: contatos,
        plano: plano));
  }

  late final _$removerVendaAsyncAction =
      AsyncAction('_SalesStoreBase.removerVenda', context: context);

  @override
  Future<void> removerVenda(int index) {
    return _$removerVendaAsyncAction.run(() => super.removerVenda(index));
  }

  @override
  String toString() {
    return '''
vendas: ${vendas}
    ''';
  }
}
