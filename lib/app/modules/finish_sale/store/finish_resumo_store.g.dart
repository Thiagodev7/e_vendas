// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_resumo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinishResumoStore on _FinishResumoStoreBase, Store {
  Computed<int>? _$vidasComputed;

  @override
  int get vidas => (_$vidasComputed ??= Computed<int>(() => super.vidas,
          name: '_FinishResumoStoreBase.vidas'))
      .value;
  Computed<double>? _$mensalIndComputed;

  @override
  double get mensalInd =>
      (_$mensalIndComputed ??= Computed<double>(() => super.mensalInd,
              name: '_FinishResumoStoreBase.mensalInd'))
          .value;
  Computed<double>? _$mensalTotalComputed;

  @override
  double get mensalTotal =>
      (_$mensalTotalComputed ??= Computed<double>(() => super.mensalTotal,
              name: '_FinishResumoStoreBase.mensalTotal'))
          .value;
  Computed<double>? _$adesaoIndComputed;

  @override
  double get adesaoInd =>
      (_$adesaoIndComputed ??= Computed<double>(() => super.adesaoInd,
              name: '_FinishResumoStoreBase.adesaoInd'))
          .value;
  Computed<double>? _$adesaoTotalComputed;

  @override
  double get adesaoTotal =>
      (_$adesaoTotalComputed ??= Computed<double>(() => super.adesaoTotal,
              name: '_FinishResumoStoreBase.adesaoTotal'))
          .value;
  Computed<double>? _$proRataIndComputed;

  @override
  double get proRataInd =>
      (_$proRataIndComputed ??= Computed<double>(() => super.proRataInd,
              name: '_FinishResumoStoreBase.proRataInd'))
          .value;
  Computed<double>? _$proRataTotalComputed;

  @override
  double get proRataTotal =>
      (_$proRataTotalComputed ??= Computed<double>(() => super.proRataTotal,
              name: '_FinishResumoStoreBase.proRataTotal'))
          .value;
  Computed<double>? _$totalPrimeiraCobrancaComputed;

  @override
  double get totalPrimeiraCobranca => (_$totalPrimeiraCobrancaComputed ??=
          Computed<double>(() => super.totalPrimeiraCobranca,
              name: '_FinishResumoStoreBase.totalPrimeiraCobranca'))
      .value;
  Computed<ResumoValores?>? _$resumoComputed;

  @override
  ResumoValores? get resumo =>
      (_$resumoComputed ??= Computed<ResumoValores?>(() => super.resumo,
              name: '_FinishResumoStoreBase.resumo'))
          .value;

  late final _$vendaAtom =
      Atom(name: '_FinishResumoStoreBase.venda', context: context);

  @override
  VendaModel? get venda {
    _$vendaAtom.reportRead();
    return super.venda;
  }

  @override
  set venda(VendaModel? value) {
    _$vendaAtom.reportWrite(value, super.venda, () {
      super.venda = value;
    });
  }

  late final _$_FinishResumoStoreBaseActionController =
      ActionController(name: '_FinishResumoStoreBase', context: context);

  @override
  void bindVenda(VendaModel v) {
    final _$actionInfo = _$_FinishResumoStoreBaseActionController.startAction(
        name: '_FinishResumoStoreBase.bindVenda');
    try {
      return super.bindVenda(v);
    } finally {
      _$_FinishResumoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  double calculateProrata({required double monthly}) {
    final _$actionInfo = _$_FinishResumoStoreBaseActionController.startAction(
        name: '_FinishResumoStoreBase.calculateProrata');
    try {
      return super.calculateProrata(monthly: monthly);
    } finally {
      _$_FinishResumoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
venda: ${venda},
vidas: ${vidas},
mensalInd: ${mensalInd},
mensalTotal: ${mensalTotal},
adesaoInd: ${adesaoInd},
adesaoTotal: ${adesaoTotal},
proRataInd: ${proRataInd},
proRataTotal: ${proRataTotal},
totalPrimeiraCobranca: ${totalPrimeiraCobranca},
resumo: ${resumo}
    ''';
  }
}
