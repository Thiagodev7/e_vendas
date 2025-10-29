// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totem_finalization_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TotemFinalizationStore on _TotemFinalizationStoreBase, Store {
  late final _$statusAtom =
      Atom(name: '_TotemFinalizationStoreBase.status', context: context);

  @override
  TotemFinalizationStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(TotemFinalizationStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_TotemFinalizationStoreBase.errorMessage', context: context);

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

  late final _$lastSuccessDataAtom = Atom(
      name: '_TotemFinalizationStoreBase.lastSuccessData', context: context);

  @override
  Map<String, dynamic>? get lastSuccessData {
    _$lastSuccessDataAtom.reportRead();
    return super.lastSuccessData;
  }

  @override
  set lastSuccessData(Map<String, dynamic>? value) {
    _$lastSuccessDataAtom.reportWrite(value, super.lastSuccessData, () {
      super.lastSuccessData = value;
    });
  }

  late final _$finalizarVendaTotemAsyncAction = AsyncAction(
      '_TotemFinalizationStoreBase.finalizarVendaTotem',
      context: context);

  @override
  Future<bool> finalizarVendaTotem({required VendaModel venda}) {
    return _$finalizarVendaTotemAsyncAction
        .run(() => super.finalizarVendaTotem(venda: venda));
  }

  late final _$_TotemFinalizationStoreBaseActionController =
      ActionController(name: '_TotemFinalizationStoreBase', context: context);

  @override
  void reset() {
    final _$actionInfo = _$_TotemFinalizationStoreBaseActionController
        .startAction(name: '_TotemFinalizationStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_TotemFinalizationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
errorMessage: ${errorMessage},
lastSuccessData: ${lastSuccessData}
    ''';
  }
}
