// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_payment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinishPaymentStore on _FinishPaymentStoreBase, Store {
  Computed<int>? _$numMonthsComputed;

  @override
  int get numMonths =>
      (_$numMonthsComputed ??= Computed<int>(() => super.numMonths,
              name: '_FinishPaymentStoreBase.numMonths'))
          .value;
  Computed<int?>? _$dueDayComputed;

  @override
  int? get dueDay => (_$dueDayComputed ??= Computed<int?>(() => super.dueDay,
          name: '_FinishPaymentStoreBase.dueDay'))
      .value;
  Computed<String?>? _$currentMyIdComputed;

  @override
  String? get currentMyId =>
      (_$currentMyIdComputed ??= Computed<String?>(() => super.currentMyId,
              name: '_FinishPaymentStoreBase.currentMyId'))
          .value;
  Computed<int>? _$valorCelcoinCentavosComputed;

  @override
  int get valorCelcoinCentavos => (_$valorCelcoinCentavosComputed ??=
          Computed<int>(() => super.valorCelcoinCentavos,
              name: '_FinishPaymentStoreBase.valorCelcoinCentavos'))
      .value;
  Computed<String>? _$valorCelcoinFmtComputed;

  @override
  String get valorCelcoinFmt => (_$valorCelcoinFmtComputed ??= Computed<String>(
          () => super.valorCelcoinFmt,
          name: '_FinishPaymentStoreBase.valorCelcoinFmt'))
      .value;

  late final _$vendaAtom =
      Atom(name: '_FinishPaymentStoreBase.venda', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.nroProposta', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.loading', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.metodo', context: context);

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

  late final _$cardUrlAtom =
      Atom(name: '_FinishPaymentStoreBase.cardUrl', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.cardMyId', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.galaxPayId', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.pixEmv', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.pixImageBase64', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.pixMyId', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.pixLink', context: context);

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
      Atom(name: '_FinishPaymentStoreBase.paymentStatus', context: context);

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

  late final _$pagamentoConcluidoServerAtom = Atom(
      name: '_FinishPaymentStoreBase.pagamentoConcluidoServer',
      context: context);

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

  late final _$gerarLinkCartaoAsyncAction =
      AsyncAction('_FinishPaymentStoreBase.gerarLinkCartao', context: context);

  @override
  Future<void> gerarLinkCartao() {
    return _$gerarLinkCartaoAsyncAction.run(() => super.gerarLinkCartao());
  }

  late final _$gerarPixAsyncAction =
      AsyncAction('_FinishPaymentStoreBase.gerarPix', context: context);

  @override
  Future<void> gerarPix() {
    return _$gerarPixAsyncAction.run(() => super.gerarPix());
  }

  late final _$consultarStatusPagamentoAsyncAction = AsyncAction(
      '_FinishPaymentStoreBase.consultarStatusPagamento',
      context: context);

  @override
  Future<PaymentStatus> consultarStatusPagamento() {
    return _$consultarStatusPagamentoAsyncAction
        .run(() => super.consultarStatusPagamento());
  }

  late final _$_FinishPaymentStoreBaseActionController =
      ActionController(name: '_FinishPaymentStoreBase', context: context);

  @override
  void bindVenda(VendaModel v) {
    final _$actionInfo = _$_FinishPaymentStoreBaseActionController.startAction(
        name: '_FinishPaymentStoreBase.bindVenda');
    try {
      return super.bindVenda(v);
    } finally {
      _$_FinishPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void bindNroProposta(int? nro) {
    final _$actionInfo = _$_FinishPaymentStoreBaseActionController.startAction(
        name: '_FinishPaymentStoreBase.bindNroProposta');
    try {
      return super.bindNroProposta(nro);
    } finally {
      _$_FinishPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMetodo(PayMethod m) {
    final _$actionInfo = _$_FinishPaymentStoreBaseActionController.startAction(
        name: '_FinishPaymentStoreBase.setMetodo');
    try {
      return super.setMetodo(m);
    } finally {
      _$_FinishPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
venda: ${venda},
nroProposta: ${nroProposta},
loading: ${loading},
metodo: ${metodo},
cardUrl: ${cardUrl},
cardMyId: ${cardMyId},
galaxPayId: ${galaxPayId},
pixEmv: ${pixEmv},
pixImageBase64: ${pixImageBase64},
pixMyId: ${pixMyId},
pixLink: ${pixLink},
paymentStatus: ${paymentStatus},
pagamentoConcluidoServer: ${pagamentoConcluidoServer},
numMonths: ${numMonths},
dueDay: ${dueDay},
currentMyId: ${currentMyId},
valorCelcoinCentavos: ${valorCelcoinCentavos},
valorCelcoinFmt: ${valorCelcoinFmt}
    ''';
  }
}
