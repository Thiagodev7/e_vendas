// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totem_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TotemStore on _TotemStoreBase, Store {
  late final _$selectedPlanAtom =
      Atom(name: '_TotemStoreBase.selectedPlan', context: context);

  @override
  PlanModel? get selectedPlan {
    _$selectedPlanAtom.reportRead();
    return super.selectedPlan;
  }

  @override
  set selectedPlan(PlanModel? value) {
    _$selectedPlanAtom.reportWrite(value, super.selectedPlan, () {
      super.selectedPlan = value;
    });
  }

  late final _$_TotemStoreBaseActionController =
      ActionController(name: '_TotemStoreBase', context: context);

  @override
  void setSelectedPlan(PlanModel? plan) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setSelectedPlan');
    try {
      return super.setSelectedPlan(plan);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.clear');
    try {
      return super.clear();
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedPlan: ${selectedPlan}
    ''';
  }
}
