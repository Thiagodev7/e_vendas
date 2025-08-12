// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlansStore on _PlansStoreBase, Store {
  late final _$isLoadingAtom =
      Atom(name: '_PlansStoreBase.isLoading', context: context);

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

  late final _$plansAtom =
      Atom(name: '_PlansStoreBase.plans', context: context);

  @override
  ObservableList<PlanModel> get plans {
    _$plansAtom.reportRead();
    return super.plans;
  }

  @override
  set plans(ObservableList<PlanModel> value) {
    _$plansAtom.reportWrite(value, super.plans, () {
      super.plans = value;
    });
  }

  late final _$selectedLivesAtom =
      Atom(name: '_PlansStoreBase.selectedLives', context: context);

  @override
  ObservableMap<int, int> get selectedLives {
    _$selectedLivesAtom.reportRead();
    return super.selectedLives;
  }

  @override
  set selectedLives(ObservableMap<int, int> value) {
    _$selectedLivesAtom.reportWrite(value, super.selectedLives, () {
      super.selectedLives = value;
    });
  }

  late final _$loadPlansAsyncAction =
      AsyncAction('_PlansStoreBase.loadPlans', context: context);

  @override
  Future<void> loadPlans() {
    return _$loadPlansAsyncAction.run(() => super.loadPlans());
  }

  late final _$_PlansStoreBaseActionController =
      ActionController(name: '_PlansStoreBase', context: context);

  @override
  void setLives(int planId, int lives) {
    final _$actionInfo = _$_PlansStoreBaseActionController.startAction(
        name: '_PlansStoreBase.setLives');
    try {
      return super.setLives(planId, lives);
    } finally {
      _$_PlansStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
plans: ${plans},
selectedLives: ${selectedLives}
    ''';
  }
}
