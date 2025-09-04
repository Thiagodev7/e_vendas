// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_sale_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinishSaleStore on _FinishSaleStoreBase, Store {
  Computed<int>? _$vidasComputed;

  @override
  int get vidas => (_$vidasComputed ??=
          Computed<int>(() => super.vidas, name: '_FinishSaleStoreBase.vidas'))
      .value;
  Computed<BillingBreakdown?>? _$billingComputed;

  @override
  BillingBreakdown? get billing =>
      (_$billingComputed ??= Computed<BillingBreakdown?>(() => super.billing,
              name: '_FinishSaleStoreBase.billing'))
          .value;
  Computed<double>? _$mensalTotalComputed;

  @override
  double get mensalTotal =>
      (_$mensalTotalComputed ??= Computed<double>(() => super.mensalTotal,
              name: '_FinishSaleStoreBase.mensalTotal'))
          .value;
  Computed<double>? _$adesaoTotalComputed;

  @override
  double get adesaoTotal =>
      (_$adesaoTotalComputed ??= Computed<double>(() => super.adesaoTotal,
              name: '_FinishSaleStoreBase.adesaoTotal'))
          .value;
  Computed<double>? _$proRataTotalComputed;

  @override
  double get proRataTotal =>
      (_$proRataTotalComputed ??= Computed<double>(() => super.proRataTotal,
              name: '_FinishSaleStoreBase.proRataTotal'))
          .value;
  Computed<double>? _$mensalIndComputed;

  @override
  double get mensalInd =>
      (_$mensalIndComputed ??= Computed<double>(() => super.mensalInd,
              name: '_FinishSaleStoreBase.mensalInd'))
          .value;
  Computed<double>? _$adesaoIndComputed;

  @override
  double get adesaoInd =>
      (_$adesaoIndComputed ??= Computed<double>(() => super.adesaoInd,
              name: '_FinishSaleStoreBase.adesaoInd'))
          .value;
  Computed<double>? _$proRataIndComputed;

  @override
  double get proRataInd =>
      (_$proRataIndComputed ??= Computed<double>(() => super.proRataInd,
              name: '_FinishSaleStoreBase.proRataInd'))
          .value;
  Computed<double>? _$totalPrimeiraCobrancaComputed;

  @override
  double get totalPrimeiraCobranca => (_$totalPrimeiraCobrancaComputed ??=
          Computed<double>(() => super.totalPrimeiraCobranca,
              name: '_FinishSaleStoreBase.totalPrimeiraCobranca'))
      .value;
  Computed<int>? _$valorAgoraCentavosComputed;

  @override
  int get valorAgoraCentavos => (_$valorAgoraCentavosComputed ??= Computed<int>(
          () => super.valorAgoraCentavos,
          name: '_FinishSaleStoreBase.valorAgoraCentavos'))
      .value;

  late final _$vendaAtom =
      Atom(name: '_FinishSaleStoreBase.venda', context: context);

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

  late final _$nroPropostaAtom =
      Atom(name: '_FinishSaleStoreBase.nroProposta', context: context);

  @override
  int? get nroProposta {
    _$nroPropostaAtom.reportRead();
    return super.nroProposta;
  }

  @override
  set nroProposta(int? value) {
    _$nroPropostaAtom.reportWrite(value, super.nroProposta, () {
      super.nroProposta = value;
    });
  }

  late final _$_FinishSaleStoreBaseActionController =
      ActionController(name: '_FinishSaleStoreBase', context: context);

  @override
  void init({required VendaModel v, int? nro}) {
    final _$actionInfo = _$_FinishSaleStoreBaseActionController.startAction(
        name: '_FinishSaleStoreBase.init');
    try {
      return super.init(v: v, nro: nro);
    } finally {
      _$_FinishSaleStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  double calculateProrataIndividual() {
    final _$actionInfo = _$_FinishSaleStoreBaseActionController.startAction(
        name: '_FinishSaleStoreBase.calculateProrataIndividual');
    try {
      return super.calculateProrataIndividual();
    } finally {
      _$_FinishSaleStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
venda: ${venda},
nroProposta: ${nroProposta},
vidas: ${vidas},
billing: ${billing},
mensalTotal: ${mensalTotal},
adesaoTotal: ${adesaoTotal},
proRataTotal: ${proRataTotal},
mensalInd: ${mensalInd},
adesaoInd: ${adesaoInd},
proRataInd: ${proRataInd},
totalPrimeiraCobranca: ${totalPrimeiraCobranca},
valorAgoraCentavos: ${valorAgoraCentavos}
    ''';
  }
}
