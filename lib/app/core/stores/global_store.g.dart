// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GlobalStore on _GlobalStoreBase, Store {
  late final _$vendedorAtom =
      Atom(name: '_GlobalStoreBase.vendedor', context: context);

  @override
  VendedorModel? get vendedor {
    _$vendedorAtom.reportRead();
    return super.vendedor;
  }

  @override
  set vendedor(VendedorModel? value) {
    _$vendedorAtom.reportWrite(value, super.vendedor, () {
      super.vendedor = value;
    });
  }

  late final _$isLoggedInAtom =
      Atom(name: '_GlobalStoreBase.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$logoutAsyncAction =
      AsyncAction('_GlobalStoreBase.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$_GlobalStoreBaseActionController =
      ActionController(name: '_GlobalStoreBase', context: context);

  @override
  void setVendedor(VendedorModel data) {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.setVendedor');
    try {
      return super.setVendedor(data);
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
vendedor: ${vendedor},
isLoggedIn: ${isLoggedIn}
    ''';
  }
}
