// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ClientStore on _ClientStoreBase, Store {
  late final _$isLoadingAtom =
      Atom(name: '_ClientStoreBase.isLoading', context: context);

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
      Atom(name: '_ClientStoreBase.errorMessage', context: context);

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

  late final _$enderecoAtom =
      Atom(name: '_ClientStoreBase.endereco', context: context);

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

  late final _$pessoaAtom =
      Atom(name: '_ClientStoreBase.pessoa', context: context);

  @override
  PessoaModel? get pessoa {
    _$pessoaAtom.reportRead();
    return super.pessoa;
  }

  @override
  set pessoa(PessoaModel? value) {
    _$pessoaAtom.reportWrite(value, super.pessoa, () {
      super.pessoa = value;
    });
  }

  late final _$titularAtom =
      Atom(name: '_ClientStoreBase.titular', context: context);

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
      Atom(name: '_ClientStoreBase.responsavelFinanceiro', context: context);

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
      Atom(name: '_ClientStoreBase.dependentes', context: context);

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
      Atom(name: '_ClientStoreBase.contatos', context: context);

  @override
  ObservableList<Map<String, dynamic>> get contatos {
    _$contatosAtom.reportRead();
    return super.contatos;
  }

  @override
  set contatos(ObservableList<Map<String, dynamic>> value) {
    _$contatosAtom.reportWrite(value, super.contatos, () {
      super.contatos = value;
    });
  }

  late final _$estadoCivilListAtom =
      Atom(name: '_ClientStoreBase.estadoCivilList', context: context);

  @override
  List<GenericStateModel> get estadoCivilList {
    _$estadoCivilListAtom.reportRead();
    return super.estadoCivilList;
  }

  @override
  set estadoCivilList(List<GenericStateModel> value) {
    _$estadoCivilListAtom.reportWrite(value, super.estadoCivilList, () {
      super.estadoCivilList = value;
    });
  }

  late final _$bondDependentListAtom =
      Atom(name: '_ClientStoreBase.bondDependentList', context: context);

  @override
  List<GenericStateModel> get bondDependentList {
    _$bondDependentListAtom.reportRead();
    return super.bondDependentList;
  }

  @override
  set bondDependentList(List<GenericStateModel> value) {
    _$bondDependentListAtom.reportWrite(value, super.bondDependentList, () {
      super.bondDependentList = value;
    });
  }

  late final _$contactTypesAtom =
      Atom(name: '_ClientStoreBase.contactTypes', context: context);

  @override
  List<GenericStateModel> get contactTypes {
    _$contactTypesAtom.reportRead();
    return super.contactTypes;
  }

  @override
  set contactTypes(List<GenericStateModel> value) {
    _$contactTypesAtom.reportWrite(value, super.contactTypes, () {
      super.contactTypes = value;
    });
  }

  late final _$buscarCepAsyncAction =
      AsyncAction('_ClientStoreBase.buscarCep', context: context);

  @override
  Future<void> buscarCep(String cep) {
    return _$buscarCepAsyncAction.run(() => super.buscarCep(cep));
  }

  late final _$buscarCpfAsyncAction =
      AsyncAction('_ClientStoreBase.buscarCpf', context: context);

  @override
  Future<void> buscarCpf(String cpf) {
    return _$buscarCpfAsyncAction.run(() => super.buscarCpf(cpf));
  }

  late final _$salvarClienteAsyncAction =
      AsyncAction('_ClientStoreBase.salvarCliente', context: context);

  @override
  Future<bool> salvarCliente(
      {required PessoaModel titular,
      PessoaModel? responsavelFinanceiro,
      List<PessoaModel>? dependentes,
      required EnderecoModel endereco,
      required Map<String, dynamic> contrato,
      required List<Map<String, dynamic>> contatos}) {
    return _$salvarClienteAsyncAction.run(() => super.salvarCliente(
        titular: titular,
        responsavelFinanceiro: responsavelFinanceiro,
        dependentes: dependentes,
        endereco: endereco,
        contrato: contrato,
        contatos: contatos));
  }

  late final _$_ClientStoreBaseActionController =
      ActionController(name: '_ClientStoreBase', context: context);

  @override
  void adicionarDependente(PessoaModel dependente) {
    final _$actionInfo = _$_ClientStoreBaseActionController.startAction(
        name: '_ClientStoreBase.adicionarDependente');
    try {
      return super.adicionarDependente(dependente);
    } finally {
      _$_ClientStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerDependente(int index) {
    final _$actionInfo = _$_ClientStoreBaseActionController.startAction(
        name: '_ClientStoreBase.removerDependente');
    try {
      return super.removerDependente(index);
    } finally {
      _$_ClientStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void adicionarContato(Map<String, dynamic> contato) {
    final _$actionInfo = _$_ClientStoreBaseActionController.startAction(
        name: '_ClientStoreBase.adicionarContato');
    try {
      return super.adicionarContato(contato);
    } finally {
      _$_ClientStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerContato(int index) {
    final _$actionInfo = _$_ClientStoreBaseActionController.startAction(
        name: '_ClientStoreBase.removerContato');
    try {
      return super.removerContato(index);
    } finally {
      _$_ClientStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResponsavelFinanceiro(PessoaModel responsavel) {
    final _$actionInfo = _$_ClientStoreBaseActionController.startAction(
        name: '_ClientStoreBase.setResponsavelFinanceiro');
    try {
      return super.setResponsavelFinanceiro(responsavel);
    } finally {
      _$_ClientStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
endereco: ${endereco},
pessoa: ${pessoa},
titular: ${titular},
responsavelFinanceiro: ${responsavelFinanceiro},
dependentes: ${dependentes},
contatos: ${contatos},
estadoCivilList: ${estadoCivilList},
bondDependentList: ${bondDependentList},
contactTypes: ${contactTypes}
    ''';
  }
}
