// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_sale_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinishSaleStore on _FinishSaleStoreBase, Store {
  Computed<ResumoValores?>? _$resumoComputed;

  @override
  ResumoValores? get resumo =>
      (_$resumoComputed ??= Computed<ResumoValores?>(() => super.resumo,
              name: '_FinishSaleStoreBase.resumo'))
          .value;
  Computed<int>? _$vidasComputed;

  @override
  int get vidas => (_$vidasComputed ??=
          Computed<int>(() => super.vidas, name: '_FinishSaleStoreBase.vidas'))
      .value;
  Computed<double>? _$mensalIndComputed;

  @override
  double get mensalInd =>
      (_$mensalIndComputed ??= Computed<double>(() => super.mensalInd,
              name: '_FinishSaleStoreBase.mensalInd'))
          .value;
  Computed<double>? _$mensalTotalComputed;

  @override
  double get mensalTotal =>
      (_$mensalTotalComputed ??= Computed<double>(() => super.mensalTotal,
              name: '_FinishSaleStoreBase.mensalTotal'))
          .value;
  Computed<double>? _$adesaoIndComputed;

  @override
  double get adesaoInd =>
      (_$adesaoIndComputed ??= Computed<double>(() => super.adesaoInd,
              name: '_FinishSaleStoreBase.adesaoInd'))
          .value;
  Computed<double>? _$adesaoTotalComputed;

  @override
  double get adesaoTotal =>
      (_$adesaoTotalComputed ??= Computed<double>(() => super.adesaoTotal,
              name: '_FinishSaleStoreBase.adesaoTotal'))
          .value;
  Computed<double>? _$proRataIndComputed;

  @override
  double get proRataInd =>
      (_$proRataIndComputed ??= Computed<double>(() => super.proRataInd,
              name: '_FinishSaleStoreBase.proRataInd'))
          .value;
  Computed<double>? _$proRataTotalComputed;

  @override
  double get proRataTotal =>
      (_$proRataTotalComputed ??= Computed<double>(() => super.proRataTotal,
              name: '_FinishSaleStoreBase.proRataTotal'))
          .value;
  Computed<double>? _$totalPrimeiraCobrancaComputed;

  @override
  double get totalPrimeiraCobranca => (_$totalPrimeiraCobrancaComputed ??=
          Computed<double>(() => super.totalPrimeiraCobranca,
              name: '_FinishSaleStoreBase.totalPrimeiraCobranca'))
      .value;
  Computed<bool>? _$pagamentoOkComputed;

  @override
  bool get pagamentoOk =>
      (_$pagamentoOkComputed ??= Computed<bool>(() => super.pagamentoOk,
              name: '_FinishSaleStoreBase.pagamentoOk'))
          .value;
  Computed<bool>? _$pagamentoConcluidoComputed;

  @override
  bool get pagamentoConcluido => (_$pagamentoConcluidoComputed ??=
          Computed<bool>(() => super.pagamentoConcluido,
              name: '_FinishSaleStoreBase.pagamentoConcluido'))
      .value;
  Computed<String?>? _$currentMyIdComputed;

  @override
  String? get currentMyId =>
      (_$currentMyIdComputed ??= Computed<String?>(() => super.currentMyId,
              name: '_FinishSaleStoreBase.currentMyId'))
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

  late final _$loadingAtom =
      Atom(name: '_FinishSaleStoreBase.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$metodoAtom =
      Atom(name: '_FinishSaleStoreBase.metodo', context: context);

  @override
  PayMethod get metodo {
    _$metodoAtom.reportRead();
    return super.metodo;
  }

  @override
  set metodo(PayMethod value) {
    _$metodoAtom.reportWrite(value, super.metodo, () {
      super.metodo = value;
    });
  }

  late final _$pagamentoConcluidoServerAtom = Atom(
      name: '_FinishSaleStoreBase.pagamentoConcluidoServer', context: context);

  @override
  bool get pagamentoConcluidoServer {
    _$pagamentoConcluidoServerAtom.reportRead();
    return super.pagamentoConcluidoServer;
  }

  @override
  set pagamentoConcluidoServer(bool value) {
    _$pagamentoConcluidoServerAtom
        .reportWrite(value, super.pagamentoConcluidoServer, () {
      super.pagamentoConcluidoServer = value;
    });
  }

  late final _$cardUrlAtom =
      Atom(name: '_FinishSaleStoreBase.cardUrl', context: context);

  @override
  String? get cardUrl {
    _$cardUrlAtom.reportRead();
    return super.cardUrl;
  }

  @override
  set cardUrl(String? value) {
    _$cardUrlAtom.reportWrite(value, super.cardUrl, () {
      super.cardUrl = value;
    });
  }

  late final _$cardMyIdAtom =
      Atom(name: '_FinishSaleStoreBase.cardMyId', context: context);

  @override
  String? get cardMyId {
    _$cardMyIdAtom.reportRead();
    return super.cardMyId;
  }

  @override
  set cardMyId(String? value) {
    _$cardMyIdAtom.reportWrite(value, super.cardMyId, () {
      super.cardMyId = value;
    });
  }

  late final _$galaxPayIdAtom =
      Atom(name: '_FinishSaleStoreBase.galaxPayId', context: context);

  @override
  int? get galaxPayId {
    _$galaxPayIdAtom.reportRead();
    return super.galaxPayId;
  }

  @override
  set galaxPayId(int? value) {
    _$galaxPayIdAtom.reportWrite(value, super.galaxPayId, () {
      super.galaxPayId = value;
    });
  }

  late final _$pixEmvAtom =
      Atom(name: '_FinishSaleStoreBase.pixEmv', context: context);

  @override
  String? get pixEmv {
    _$pixEmvAtom.reportRead();
    return super.pixEmv;
  }

  @override
  set pixEmv(String? value) {
    _$pixEmvAtom.reportWrite(value, super.pixEmv, () {
      super.pixEmv = value;
    });
  }

  late final _$pixImageBase64Atom =
      Atom(name: '_FinishSaleStoreBase.pixImageBase64', context: context);

  @override
  String? get pixImageBase64 {
    _$pixImageBase64Atom.reportRead();
    return super.pixImageBase64;
  }

  @override
  set pixImageBase64(String? value) {
    _$pixImageBase64Atom.reportWrite(value, super.pixImageBase64, () {
      super.pixImageBase64 = value;
    });
  }

  late final _$pixMyIdAtom =
      Atom(name: '_FinishSaleStoreBase.pixMyId', context: context);

  @override
  String? get pixMyId {
    _$pixMyIdAtom.reportRead();
    return super.pixMyId;
  }

  @override
  set pixMyId(String? value) {
    _$pixMyIdAtom.reportWrite(value, super.pixMyId, () {
      super.pixMyId = value;
    });
  }

  late final _$pixLinkAtom =
      Atom(name: '_FinishSaleStoreBase.pixLink', context: context);

  @override
  String? get pixLink {
    _$pixLinkAtom.reportRead();
    return super.pixLink;
  }

  @override
  set pixLink(String? value) {
    _$pixLinkAtom.reportWrite(value, super.pixLink, () {
      super.pixLink = value;
    });
  }

  late final _$paymentStatusAtom =
      Atom(name: '_FinishSaleStoreBase.paymentStatus', context: context);

  @override
  PaymentStatus get paymentStatus {
    _$paymentStatusAtom.reportRead();
    return super.paymentStatus;
  }

  @override
  set paymentStatus(PaymentStatus value) {
    _$paymentStatusAtom.reportWrite(value, super.paymentStatus, () {
      super.paymentStatus = value;
    });
  }

  late final _$numMonthsAtom =
      Atom(name: '_FinishSaleStoreBase.numMonths', context: context);

  @override
  int get numMonths {
    _$numMonthsAtom.reportRead();
    return super.numMonths;
  }

  @override
  set numMonths(int value) {
    _$numMonthsAtom.reportWrite(value, super.numMonths, () {
      super.numMonths = value;
    });
  }

  late final _$gerarLinkCartaoAsyncAction =
      AsyncAction('_FinishSaleStoreBase.gerarLinkCartao', context: context);

  @override
  Future<void> gerarLinkCartao() {
    return _$gerarLinkCartaoAsyncAction.run(() => super.gerarLinkCartao());
  }

  late final _$gerarPixAsyncAction =
      AsyncAction('_FinishSaleStoreBase.gerarPix', context: context);

  @override
  Future<void> gerarPix() {
    return _$gerarPixAsyncAction.run(() => super.gerarPix());
  }

  late final _$consultarStatusPagamentoAsyncAction = AsyncAction(
      '_FinishSaleStoreBase.consultarStatusPagamento',
      context: context);

  @override
  Future<PaymentStatus> consultarStatusPagamento() {
    return _$consultarStatusPagamentoAsyncAction
        .run(() => super.consultarStatusPagamento());
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
  void setMetodo(PayMethod m) {
    final _$actionInfo = _$_FinishSaleStoreBaseActionController.startAction(
        name: '_FinishSaleStoreBase.setMetodo');
    try {
      return super.setMetodo(m);
    } finally {
      _$_FinishSaleStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  double calculateProrata({required double monthly}) {
    final _$actionInfo = _$_FinishSaleStoreBaseActionController.startAction(
        name: '_FinishSaleStoreBase.calculateProrata');
    try {
      return super.calculateProrata(monthly: monthly);
    } finally {
      _$_FinishSaleStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
venda: ${venda},
nroProposta: ${nroProposta},
loading: ${loading},
metodo: ${metodo},
pagamentoConcluidoServer: ${pagamentoConcluidoServer},
cardUrl: ${cardUrl},
cardMyId: ${cardMyId},
galaxPayId: ${galaxPayId},
pixEmv: ${pixEmv},
pixImageBase64: ${pixImageBase64},
pixMyId: ${pixMyId},
pixLink: ${pixLink},
paymentStatus: ${paymentStatus},
numMonths: ${numMonths},
resumo: ${resumo},
vidas: ${vidas},
mensalInd: ${mensalInd},
mensalTotal: ${mensalTotal},
adesaoInd: ${adesaoInd},
adesaoTotal: ${adesaoTotal},
proRataInd: ${proRataInd},
proRataTotal: ${proRataTotal},
totalPrimeiraCobranca: ${totalPrimeiraCobranca},
pagamentoOk: ${pagamentoOk},
pagamentoConcluido: ${pagamentoConcluido},
currentMyId: ${currentMyId}
    ''';
  }
}
