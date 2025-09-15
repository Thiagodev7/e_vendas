// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_sales_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RecentSalesStore on _RecentSalesStoreBase, Store {
  late final _$vendasAtom =
      Atom(name: '_RecentSalesStoreBase.vendas', context: context);

  @override
  ObservableList<RecentSaleModel> get vendas {
    _$vendasAtom.reportRead();
    return super.vendas;
  }

  @override
  set vendas(ObservableList<RecentSaleModel> value) {
    _$vendasAtom.reportWrite(value, super.vendas, () {
      super.vendas = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_RecentSalesStoreBase.isLoading', context: context);

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

  late final _$loadAsyncAction =
      AsyncAction('_RecentSalesStoreBase.load', context: context);

  @override
  Future<void> load({required int vendedorId, int limit = 10}) {
    return _$loadAsyncAction
        .run(() => super.load(vendedorId: vendedorId, limit: limit));
  }

  @override
  String toString() {
    return '''
vendas: ${vendas},
isLoading: ${isLoading}
    ''';
  }
}
