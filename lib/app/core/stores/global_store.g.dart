// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GlobalStore on _GlobalStoreBase, Store {
  Computed<String>? _$vendedorNomeComputed;

  @override
  String get vendedorNome =>
      (_$vendedorNomeComputed ??= Computed<String>(() => super.vendedorNome,
              name: '_GlobalStoreBase.vendedorNome'))
          .value;
  Computed<String>? _$vendedorCpfComputed;

  @override
  String get vendedorCpf =>
      (_$vendedorCpfComputed ??= Computed<String>(() => super.vendedorCpf,
              name: '_GlobalStoreBase.vendedorCpf'))
          .value;

  late final _$vendedorAtom =
      Atom(name: '_GlobalStoreBase.vendedor', context: context);

  @override
  Map<String, dynamic>? get vendedor {
    _$vendedorAtom.reportRead();
    return super.vendedor;
  }

  @override
  set vendedor(Map<String, dynamic>? value) {
    _$vendedorAtom.reportWrite(value, super.vendedor, () {
      super.vendedor = value;
    });
  }

  late final _$vendasAbertasAtom =
      Atom(name: '_GlobalStoreBase.vendasAbertas', context: context);

  @override
  ObservableList<Map<String, dynamic>> get vendasAbertas {
    _$vendasAbertasAtom.reportRead();
    return super.vendasAbertas;
  }

  @override
  set vendasAbertas(ObservableList<Map<String, dynamic>> value) {
    _$vendasAbertasAtom.reportWrite(value, super.vendasAbertas, () {
      super.vendasAbertas = value;
    });
  }

  late final _$vendasFinalizadasAtom =
      Atom(name: '_GlobalStoreBase.vendasFinalizadas', context: context);

  @override
  ObservableList<Map<String, dynamic>> get vendasFinalizadas {
    _$vendasFinalizadasAtom.reportRead();
    return super.vendasFinalizadas;
  }

  @override
  set vendasFinalizadas(ObservableList<Map<String, dynamic>> value) {
    _$vendasFinalizadasAtom.reportWrite(value, super.vendasFinalizadas, () {
      super.vendasFinalizadas = value;
    });
  }

  late final _$_GlobalStoreBaseActionController =
      ActionController(name: '_GlobalStoreBase', context: context);

  @override
  void setVendedor(Map<String, dynamic> dados) {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.setVendedor');
    try {
      return super.setVendedor(dados);
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void adicionarVenda(Map<String, dynamic> venda) {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.adicionarVenda');
    try {
      return super.adicionarVenda(venda);
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void finalizarVenda(int index) {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.finalizarVenda');
    try {
      return super.finalizarVenda(index);
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparVendas() {
    final _$actionInfo = _$_GlobalStoreBaseActionController.startAction(
        name: '_GlobalStoreBase.limparVendas');
    try {
      return super.limparVendas();
    } finally {
      _$_GlobalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
vendedor: ${vendedor},
vendasAbertas: ${vendasAbertas},
vendasFinalizadas: ${vendasFinalizadas},
vendedorNome: ${vendedorNome},
vendedorCpf: ${vendedorCpf}
    ''';
  }
}
