// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finalizacao_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinalizacaoStore on _FinalizacaoStoreBase, Store {
  late final _$statusAtom =
      Atom(name: '_FinalizacaoStoreBase.status', context: context);

  @override
  FinalizacaoStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(FinalizacaoStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_FinalizacaoStoreBase.errorMessage', context: context);

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

  late final _$lastSuccessAtom =
      Atom(name: '_FinalizacaoStoreBase.lastSuccess', context: context);

  @override
  Map<String, dynamic>? get lastSuccess {
    _$lastSuccessAtom.reportRead();
    return super.lastSuccess;
  }

  @override
  set lastSuccess(Map<String, dynamic>? value) {
    _$lastSuccessAtom.reportWrite(value, super.lastSuccess, () {
      super.lastSuccess = value;
    });
  }

  late final _$finalizarVendaAsyncAction =
      AsyncAction('_FinalizacaoStoreBase.finalizarVenda', context: context);

  @override
  Future<bool> finalizarVenda({required int nroProposta, String? cpfVendedor}) {
    return _$finalizarVendaAsyncAction.run(() => super
        .finalizarVenda(nroProposta: nroProposta, cpfVendedor: cpfVendedor));
  }

  late final _$_FinalizacaoStoreBaseActionController =
      ActionController(name: '_FinalizacaoStoreBase', context: context);

  @override
  void reset() {
    final _$actionInfo = _$_FinalizacaoStoreBaseActionController.startAction(
        name: '_FinalizacaoStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_FinalizacaoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
errorMessage: ${errorMessage},
lastSuccess: ${lastSuccess}
    ''';
  }
}
