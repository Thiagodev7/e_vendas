// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_contract_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FinishContractStore on _FinishContractStoreBase, Store {
  Computed<bool>? _$podeDispararContratoComputed;

  @override
  bool get podeDispararContrato => (_$podeDispararContratoComputed ??=
          Computed<bool>(() => super.podeDispararContrato,
              name: '_FinishContractStoreBase.podeDispararContrato'))
      .value;
  Computed<bool>? _$hasEnvelopeComputed;

  @override
  bool get hasEnvelope =>
      (_$hasEnvelopeComputed ??= Computed<bool>(() => super.hasEnvelope,
              name: '_FinishContractStoreBase.hasEnvelope'))
          .value;

  late final _$vendaAtom =
      Atom(name: '_FinishContractStoreBase.venda', context: context);

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
      Atom(name: '_FinishContractStoreBase.nroProposta', context: context);

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
      Atom(name: '_FinishContractStoreBase.loading', context: context);

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

  late final _$checkingAtom =
      Atom(name: '_FinishContractStoreBase.checking', context: context);

  @override
  bool get checking {
    _$checkingAtom.reportRead();
    return super.checking;
  }

  @override
  set checking(bool value) {
    _$checkingAtom.reportWrite(value, super.checking, () {
      super.checking = value;
    });
  }

  late final _$lastCheckedAtAtom =
      Atom(name: '_FinishContractStoreBase.lastCheckedAt', context: context);

  @override
  DateTime? get lastCheckedAt {
    _$lastCheckedAtAtom.reportRead();
    return super.lastCheckedAt;
  }

  @override
  set lastCheckedAt(DateTime? value) {
    _$lastCheckedAtAtom.reportWrite(value, super.lastCheckedAt, () {
      super.lastCheckedAt = value;
    });
  }

  late final _$contratoGeradoAtom =
      Atom(name: '_FinishContractStoreBase.contratoGerado', context: context);

  @override
  bool get contratoGerado {
    _$contratoGeradoAtom.reportRead();
    return super.contratoGerado;
  }

  @override
  set contratoGerado(bool value) {
    _$contratoGeradoAtom.reportWrite(value, super.contratoGerado, () {
      super.contratoGerado = value;
    });
  }

  late final _$pagamentoConcluidoServerAtom = Atom(
      name: '_FinishContractStoreBase.pagamentoConcluidoServer',
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

  late final _$contratoAssinadoServerAtom = Atom(
      name: '_FinishContractStoreBase.contratoAssinadoServer',
      context: context);

  @override
  bool get contratoAssinadoServer {
    _$contratoAssinadoServerAtom.reportRead();
    return super.contratoAssinadoServer;
  }

  @override
  set contratoAssinadoServer(bool value) {
    _$contratoAssinadoServerAtom
        .reportWrite(value, super.contratoAssinadoServer, () {
      super.contratoAssinadoServer = value;
    });
  }

  late final _$vendaFinalizadaServerAtom = Atom(
      name: '_FinishContractStoreBase.vendaFinalizadaServer', context: context);

  @override
  bool get vendaFinalizadaServer {
    _$vendaFinalizadaServerAtom.reportRead();
    return super.vendaFinalizadaServer;
  }

  @override
  set vendaFinalizadaServer(bool value) {
    _$vendaFinalizadaServerAtom.reportWrite(value, super.vendaFinalizadaServer,
        () {
      super.vendaFinalizadaServer = value;
    });
  }

  late final _$contratoEnvelopeIdAtom = Atom(
      name: '_FinishContractStoreBase.contratoEnvelopeId', context: context);

  @override
  String? get contratoEnvelopeId {
    _$contratoEnvelopeIdAtom.reportRead();
    return super.contratoEnvelopeId;
  }

  @override
  set contratoEnvelopeId(String? value) {
    _$contratoEnvelopeIdAtom.reportWrite(value, super.contratoEnvelopeId, () {
      super.contratoEnvelopeId = value;
    });
  }

  late final _$syncFlagsAsyncAction =
      AsyncAction('_FinishContractStoreBase.syncFlags', context: context);

  @override
  Future<ContractFlags?> syncFlags() {
    return _$syncFlagsAsyncAction.run(() => super.syncFlags());
  }

  late final _$gerarContratoAsyncAction =
      AsyncAction('_FinishContractStoreBase.gerarContrato', context: context);

  @override
  Future<void> gerarContrato(
      {required String enrollmentFmt,
      required String monthlyFmt,
      required String dueDay}) {
    return _$gerarContratoAsyncAction.run(() => super.gerarContrato(
        enrollmentFmt: enrollmentFmt, monthlyFmt: monthlyFmt, dueDay: dueDay));
  }

  late final _$conferirAssinaturaDocuSignAsyncAction = AsyncAction(
      '_FinishContractStoreBase.conferirAssinaturaDocuSign',
      context: context);

  @override
  Future<DocusignStatus?> conferirAssinaturaDocuSign() {
    return _$conferirAssinaturaDocuSignAsyncAction
        .run(() => super.conferirAssinaturaDocuSign());
  }

  late final _$criarRecipientViewUrlAsyncAction = AsyncAction(
      '_FinishContractStoreBase.criarRecipientViewUrl',
      context: context);

  @override
  Future<String?> criarRecipientViewUrl({String? returnUrl}) {
    return _$criarRecipientViewUrlAsyncAction
        .run(() => super.criarRecipientViewUrl(returnUrl: returnUrl));
  }

  late final _$criarConsoleViewUrlAsyncAction = AsyncAction(
      '_FinishContractStoreBase.criarConsoleViewUrl',
      context: context);

  @override
  Future<String?> criarConsoleViewUrl({String? returnUrl}) {
    return _$criarConsoleViewUrlAsyncAction
        .run(() => super.criarConsoleViewUrl(returnUrl: returnUrl));
  }

  late final _$_FinishContractStoreBaseActionController =
      ActionController(name: '_FinishContractStoreBase', context: context);

  @override
  void bindVenda(VendaModel v) {
    final _$actionInfo = _$_FinishContractStoreBaseActionController.startAction(
        name: '_FinishContractStoreBase.bindVenda');
    try {
      return super.bindVenda(v);
    } finally {
      _$_FinishContractStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void bindNroProposta(dynamic nro) {
    final _$actionInfo = _$_FinishContractStoreBaseActionController.startAction(
        name: '_FinishContractStoreBase.bindNroProposta');
    try {
      return super.bindNroProposta(nro);
    } finally {
      _$_FinishContractStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
venda: ${venda},
nroProposta: ${nroProposta},
loading: ${loading},
checking: ${checking},
lastCheckedAt: ${lastCheckedAt},
contratoGerado: ${contratoGerado},
pagamentoConcluidoServer: ${pagamentoConcluidoServer},
contratoAssinadoServer: ${contratoAssinadoServer},
vendaFinalizadaServer: ${vendaFinalizadaServer},
contratoEnvelopeId: ${contratoEnvelopeId},
podeDispararContrato: ${podeDispararContrato},
hasEnvelope: ${hasEnvelope}
    ''';
  }
}
