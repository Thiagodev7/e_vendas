// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totem_payment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TotemPaymentStore on _TotemPaymentStoreBase, Store {
  late final _$vendaAtualAtom =
      Atom(name: '_TotemPaymentStoreBase.vendaAtual', context: context);

  @override
  VendaModel? get vendaAtual {
    _$vendaAtualAtom.reportRead();
    return super.vendaAtual;
  }

  @override
  set vendaAtual(VendaModel? value) {
    _$vendaAtualAtom.reportWrite(value, super.vendaAtual, () {
      super.vendaAtual = value;
    });
  }

  late final _$metodoAtom =
      Atom(name: '_TotemPaymentStoreBase.metodo', context: context);

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

  late final _$loadingAtom =
      Atom(name: '_TotemPaymentStoreBase.loading', context: context);

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

  late final _$pixEmvAtom =
      Atom(name: '_TotemPaymentStoreBase.pixEmv', context: context);

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
      Atom(name: '_TotemPaymentStoreBase.pixImageBase64', context: context);

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

  late final _$cardUrlAtom =
      Atom(name: '_TotemPaymentStoreBase.cardUrl', context: context);

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

  late final _$galaxPayIdAtom =
      Atom(name: '_TotemPaymentStoreBase.galaxPayId', context: context);

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

  late final _$currentMyIdAtom =
      Atom(name: '_TotemPaymentStoreBase.currentMyId', context: context);

  @override
  String? get currentMyId {
    _$currentMyIdAtom.reportRead();
    return super.currentMyId;
  }

  @override
  set currentMyId(String? value) {
    _$currentMyIdAtom.reportWrite(value, super.currentMyId, () {
      super.currentMyId = value;
    });
  }

  late final _$paymentStatusAtom =
      Atom(name: '_TotemPaymentStoreBase.paymentStatus', context: context);

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

  late final _$errorMessageAtom =
      Atom(name: '_TotemPaymentStoreBase.errorMessage', context: context);

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

  late final _$gerarPixAsyncAction =
      AsyncAction('_TotemPaymentStoreBase.gerarPix', context: context);

  @override
  Future<void> gerarPix({required BillingBreakdown billing}) {
    return _$gerarPixAsyncAction.run(() => super.gerarPix(billing: billing));
  }

  late final _$gerarLinkCartaoAsyncAction =
      AsyncAction('_TotemPaymentStoreBase.gerarLinkCartao', context: context);

  @override
  Future<void> gerarLinkCartao({required BillingBreakdown billing}) {
    return _$gerarLinkCartaoAsyncAction
        .run(() => super.gerarLinkCartao(billing: billing));
  }

  late final _$consultarStatusPagamentoAsyncAction = AsyncAction(
      '_TotemPaymentStoreBase.consultarStatusPagamento',
      context: context);

  @override
  Future<PaymentStatus> consultarStatusPagamento() {
    return _$consultarStatusPagamentoAsyncAction
        .run(() => super.consultarStatusPagamento());
  }

  late final _$_TotemPaymentStoreBaseActionController =
      ActionController(name: '_TotemPaymentStoreBase', context: context);

  @override
  void setMetodo(PayMethod m) {
    final _$actionInfo = _$_TotemPaymentStoreBaseActionController.startAction(
        name: '_TotemPaymentStoreBase.setMetodo');
    try {
      return super.setMetodo(m);
    } finally {
      _$_TotemPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVenda(VendaModel venda) {
    final _$actionInfo = _$_TotemPaymentStoreBaseActionController.startAction(
        name: '_TotemPaymentStoreBase.setVenda');
    try {
      return super.setVenda(venda);
    } finally {
      _$_TotemPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetPaymentState() {
    final _$actionInfo = _$_TotemPaymentStoreBaseActionController.startAction(
        name: '_TotemPaymentStoreBase.resetPaymentState');
    try {
      return super.resetPaymentState();
    } finally {
      _$_TotemPaymentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
vendaAtual: ${vendaAtual},
metodo: ${metodo},
loading: ${loading},
pixEmv: ${pixEmv},
pixImageBase64: ${pixImageBase64},
cardUrl: ${cardUrl},
galaxPayId: ${galaxPayId},
currentMyId: ${currentMyId},
paymentStatus: ${paymentStatus},
errorMessage: ${errorMessage}
    ''';
  }
}
