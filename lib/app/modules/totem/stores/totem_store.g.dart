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

  late final _$enderecoAtom =
      Atom(name: '_TotemStoreBase.endereco', context: context);

  @override
  EnderecoModel? get endereco {
    _$enderecoAtom.reportRead();
    return super.endereco;
  }

  @override
  set endereco(EnderecoModel? value) {
    _$enderecoAtom.reportWrite(value, super.endereco, () {
      super.endereco = value;
    });
  }

  late final _$titularAtom =
      Atom(name: '_TotemStoreBase.titular', context: context);

  @override
  PessoaModel? get titular {
    _$titularAtom.reportRead();
    return super.titular;
  }

  @override
  set titular(PessoaModel? value) {
    _$titularAtom.reportWrite(value, super.titular, () {
      super.titular = value;
    });
  }

  late final _$responsavelFinanceiroAtom =
      Atom(name: '_TotemStoreBase.responsavelFinanceiro', context: context);

  @override
  PessoaModel? get responsavelFinanceiro {
    _$responsavelFinanceiroAtom.reportRead();
    return super.responsavelFinanceiro;
  }

  @override
  set responsavelFinanceiro(PessoaModel? value) {
    _$responsavelFinanceiroAtom.reportWrite(value, super.responsavelFinanceiro,
        () {
      super.responsavelFinanceiro = value;
    });
  }

  late final _$dependentesAtom =
      Atom(name: '_TotemStoreBase.dependentes', context: context);

  @override
  ObservableList<PessoaModel> get dependentes {
    _$dependentesAtom.reportRead();
    return super.dependentes;
  }

  @override
  set dependentes(ObservableList<PessoaModel> value) {
    _$dependentesAtom.reportWrite(value, super.dependentes, () {
      super.dependentes = value;
    });
  }

  late final _$contatosAtom =
      Atom(name: '_TotemStoreBase.contatos', context: context);

  @override
  ObservableList<ContatoModel> get contatos {
    _$contatosAtom.reportRead();
    return super.contatos;
  }

  @override
  set contatos(ObservableList<ContatoModel> value) {
    _$contatosAtom.reportWrite(value, super.contatos, () {
      super.contatos = value;
    });
  }

  late final _$sendingContractAtom =
      Atom(name: '_TotemStoreBase.sendingContract', context: context);

  @override
  bool get sendingContract {
    _$sendingContractAtom.reportRead();
    return super.sendingContract;
  }

  @override
  set sendingContract(bool value) {
    _$sendingContractAtom.reportWrite(value, super.sendingContract, () {
      super.sendingContract = value;
    });
  }

  late final _$checkingAtom =
      Atom(name: '_TotemStoreBase.checking', context: context);

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

  late final _$contratoEnvelopeIdAtom =
      Atom(name: '_TotemStoreBase.contratoEnvelopeId', context: context);

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

  late final _$contratoGeradoAtom =
      Atom(name: '_TotemStoreBase.contratoGerado', context: context);

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

  late final _$contratoAssinadoServerAtom =
      Atom(name: '_TotemStoreBase.contratoAssinadoServer', context: context);

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

  late final _$lastCheckedAtAtom =
      Atom(name: '_TotemStoreBase.lastCheckedAt', context: context);

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

  late final _$gerarContratoAsyncAction =
      AsyncAction('_TotemStoreBase.gerarContrato', context: context);

  @override
  Future<String?> gerarContrato() {
    return _$gerarContratoAsyncAction.run(() => super.gerarContrato());
  }

  late final _$gerarContratoEObterUrlAssinaturaAsyncAction = AsyncAction(
      '_TotemStoreBase.gerarContratoEObterUrlAssinatura',
      context: context);

  @override
  Future<String?> gerarContratoEObterUrlAssinatura({String? returnUrl}) {
    return _$gerarContratoEObterUrlAssinaturaAsyncAction.run(
        () => super.gerarContratoEObterUrlAssinatura(returnUrl: returnUrl));
  }

  late final _$criarRecipientViewUrlAsyncAction =
      AsyncAction('_TotemStoreBase.criarRecipientViewUrl', context: context);

  @override
  Future<String?> criarRecipientViewUrl({String? returnUrl}) {
    return _$criarRecipientViewUrlAsyncAction
        .run(() => super.criarRecipientViewUrl(returnUrl: returnUrl));
  }

  late final _$conferirAssinaturaDocuSignAsyncAction = AsyncAction(
      '_TotemStoreBase.conferirAssinaturaDocuSign',
      context: context);

  @override
  Future<DocusignStatus?> conferirAssinaturaDocuSign() {
    return _$conferirAssinaturaDocuSignAsyncAction
        .run(() => super.conferirAssinaturaDocuSign());
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
  void setEnderecoFromCep(EnderecoModel e) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setEnderecoFromCep');
    try {
      return super.setEnderecoFromCep(e);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnderecoNumeroComplemento({int? numero, String? complemento}) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setEnderecoNumeroComplemento');
    try {
      return super.setEnderecoNumeroComplemento(
          numero: numero, complemento: complemento);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTitular(PessoaModel p) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setTitular');
    try {
      return super.setTitular(p);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResponsavelFinanceiro(PessoaModel? p) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setResponsavelFinanceiro');
    try {
      return super.setResponsavelFinanceiro(p);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addDependente(PessoaModel d) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.addDependente');
    try {
      return super.addDependente(d);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeDependenteAt(int index) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.removeDependenteAt');
    try {
      return super.removeDependenteAt(index);
    } finally {
      _$_TotemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setContatos({String? celular, String? email}) {
    final _$actionInfo = _$_TotemStoreBaseActionController.startAction(
        name: '_TotemStoreBase.setContatos');
    try {
      return super.setContatos(celular: celular, email: email);
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
selectedPlan: ${selectedPlan},
endereco: ${endereco},
titular: ${titular},
responsavelFinanceiro: ${responsavelFinanceiro},
dependentes: ${dependentes},
contatos: ${contatos},
sendingContract: ${sendingContract},
checking: ${checking},
contratoEnvelopeId: ${contratoEnvelopeId},
contratoGerado: ${contratoGerado},
contratoAssinadoServer: ${contratoAssinadoServer},
lastCheckedAt: ${lastCheckedAt}
    ''';
  }
}
