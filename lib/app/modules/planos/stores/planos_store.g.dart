// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planos_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlanosStore on _PlanosStoreBase, Store {
  late final _$planosAtom =
      Atom(name: '_PlanosStoreBase.planos', context: context);

  @override
  ObservableList<PlanoModel> get planos {
    _$planosAtom.reportRead();
    return super.planos;
  }

  @override
  set planos(ObservableList<PlanoModel> value) {
    _$planosAtom.reportWrite(value, super.planos, () {
      super.planos = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PlanosStoreBase.isLoading', context: context);

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
      Atom(name: '_PlanosStoreBase.errorMessage', context: context);

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

  late final _$getPlanosAsyncAction =
      AsyncAction('_PlanosStoreBase.getPlanos', context: context);

  @override
  Future<void> getPlanos() {
    return _$getPlanosAsyncAction.run(() => super.getPlanos());
  }

  @override
  String toString() {
    return '''
planos: ${planos},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
