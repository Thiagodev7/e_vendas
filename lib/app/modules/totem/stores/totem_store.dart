// lib/app/modules/totem/stores/totem_store.dart
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/modules/finish_sale/service/contract_service.dart';

part 'totem_store.g.dart';

class TotemStore = _TotemStoreBase with _$TotemStore;

abstract class _TotemStoreBase with Store {
  // =========================
  // INJETÁVEIS
  // =========================
  ContractService get _contract => Modular.get<ContractService>();

  // =========================
  // DADOS DO FLUXO
  // =========================

  // Plano
  @observable
  PlanModel? selectedPlan;

  @action
  void setSelectedPlan(PlanModel? plan) => selectedPlan = plan;

  // Cliente
  @observable
  EnderecoModel? endereco;

  @observable
  PessoaModel? titular;

  @observable
  PessoaModel? responsavelFinanceiro;

  @observable
  ObservableList<PessoaModel> dependentes = ObservableList<PessoaModel>();

  @observable
  ObservableList<ContatoModel> contatos = ObservableList<ContatoModel>();

  // Endereço
  @action
  void setEnderecoFromCep(EnderecoModel e) => endereco = e;

  @action
  void setEnderecoNumeroComplemento({int? numero, String? complemento}) {
    if (endereco == null) return;
    endereco = endereco!.copyWith(numero: numero, complemento: complemento);
  }

  // Titular
  @action
  void setTitular(PessoaModel p) => titular = p;

  // Responsável
  @action
  void setResponsavelFinanceiro(PessoaModel? p) => responsavelFinanceiro = p;

  // Dependentes
  @action
  void addDependente(PessoaModel d) => dependentes.add(d);

  @action
  void removeDependenteAt(int index) => dependentes.removeAt(index);

  // Contatos
  @action
  void setContatos({String? celular, String? email}) {
    contatos.clear();
    if (celular != null && celular.isNotEmpty) {
      contatos.add(ContatoModel(idMeioComunicacao: 1, descricao: celular, nomeContato: ''));
    }
    if (email != null && email.isNotEmpty) {
      contatos.add(ContatoModel(idMeioComunicacao: 5, descricao: email, nomeContato: ''));
    }
  }

  @action
  void clear() {
    selectedPlan = null;
    endereco = null;
    titular = null;
    responsavelFinanceiro = null;
    dependentes.clear();
    contatos.clear();
    // flags de contrato
    contratoEnvelopeId = null;
    contratoGerado = false;
    contratoAssinadoServer = false;
    lastCheckedAt = null;
  }

  // =========================
  // ESTADO DE CONTRATO/ASSINATURA
  // =========================
  @observable
  bool sendingContract = false;

  @observable
  bool checking = false;

  @observable
  String? contratoEnvelopeId;

  @observable
  bool contratoGerado = false;

  @observable
  bool contratoAssinadoServer = false;

  @observable
  DateTime? lastCheckedAt;

  // =========================
  // CONTRATO: GERAÇÃO E ASSINATURA
  // =========================

  /// Gera o contrato no backend e retorna o `envelopeId` do DocuSign.
  /// Usa SOMENTE os dados mantidos no TotemStore.
  @action
  Future<String?> gerarContrato() async {
    // ---- validações mínimas
    final plan = _planComVidas();
    if (plan == null) {
      throw Exception('Plano não selecionado.');
    }
    if (titular == null) {
      throw Exception('Dados do titular ausentes.');
    }
    if (endereco == null) {
      throw Exception('Endereço não informado.');
    }
    final email = _pickEmail(contatos.toList()) ?? '';
    if (email.isEmpty) {
      throw Exception('E-mail do titular é obrigatório.');
    }
    final phone = _pickPhone(contatos.toList()) ?? '';
    if (phone.isEmpty) {
      throw Exception('Telefone do titular é obrigatório.');
    }

    // ---- formatações de valores (seguindo a lógica usada no app)
    final monthlyRaw    = plan.getMensalidade() ?? plan.getMensalidadeTotal();
    final enrollmentRaw = plan.getTaxaAdesao()  ?? plan.getTaxaAdesaoTotal();

    final monthlyFmt    = _fmtCurrency(monthlyRaw);
    final enrollmentFmt = _fmtCurrency(enrollmentRaw);

    // ---- titular
    final t = titular!;
    final nome     = (t.nome ?? '').trim().isEmpty ? 'Cliente' : (t.nome ?? '').trim();
    final cpf      = _digits(t.cpf);
    final birth    = (t.dataNascimento ?? '').trim(); // "DD/MM/AAAA" (conforme seu fluxo)
    final sexo     = (t.idSexo?.toString() ?? '').trim(); // "1"/"2" ou vazio
    final civilId  = t.idEstadoCivil ?? 0;
    final civilStr = _estadoCivilTexto(civilId);

    // ---- docs/saúde
    final nomeMae  = (t.nomeMae ?? '').trim();
    final nomePai  = (t.nomePai ?? '').trim();
    final rg       = (t.rg ?? '').trim();
    final rgData   = (t.rgDataEmissao ?? '').trim();    // "DD/MM/AAAA"
    final rgOrgao  = (t.rgOrgaoEmissor ?? '').trim();
    final cns      = (t.cns ?? '').trim();
    final natural  = (t.naturalde ?? '').trim();

    // ---- endereço
    final e = endereco!;
    final address    = '${e.logradouro ?? ''}, ${e.numero ?? ''}'.trim();
    final complement = (e.complemento ?? '').trim();
    final city       = (e.nomeCidade ?? '').trim();
    final uf         = (e.siglaUf ?? '').trim();
    final cep        = _digits(e.cep);

    // ---- dependentes
    final deps = dependentes.toList();
    final depsData = deps.map<Map<String, dynamic>>((d) {
      final nomeDep = (d.nome ?? '').trim();
      final cpfDep  = _digits(d.cpf);
      final sexoDep = (d.idSexo?.toString() ?? '').trim();
      final parent  = (d.idGrauDependencia?.toString() ?? '').trim();
      return <String, dynamic>{
        'name': nomeDep,
        'cpf': cpfDep,
        'sex': sexoDep,
        'parent': parent,
      };
    }).toList();

    // ---- corpo da requisição (compatível com seu ContractService)
    final body = <String, dynamic>{
      // titular/assinante
      'email': email,
      'name': nome,
      'cpf': cpf,
      'phone': phone,
      'birth': birth,
      'sex': sexo,
      'civilStatus': civilStr,
      'civilStatusId': civilId,

      // docs/saúde
      'rg': rg,
      'rgIssuer': rgOrgao,
      'rgIssueDate': rgData,
      'cns': cns,
      'naturalDe': natural,
      'motherName': nomeMae,
      'fatherName': nomePai,

      // endereço
      'address': address,
      'signerComplement': complement,
      'city': city,
      'uf': uf,
      'cep': cep,

      // plano/valores
      'plan': plan.nomeContrato,
      'dependents': deps.length,
      'enrollment': enrollmentFmt,
      'monthly': monthlyFmt,

      // detalhamento de dependentes
      'dependentsData': depsData,

      // opcional: parentesco do signatário principal
      'signerParent': 'Titular',
    };

    sendingContract = true;
    try {
      final envId = await _contract.enviarContratoDocuSign(body: body);
      contratoEnvelopeId = envId;
      contratoGerado = envId != null && envId.isNotEmpty;
      return contratoEnvelopeId;
    } finally {
      sendingContract = false;
    }
  }

  /// Atalho: gera contrato (se preciso) e já retorna a URL de assinatura embutida.
  /// Use essa URL para abrir no WebView.
  @action
  Future<String?> gerarContratoEObterUrlAssinatura({String? returnUrl}) async {
    // Gera caso ainda não exista
    if (contratoEnvelopeId == null || contratoEnvelopeId!.isEmpty) {
      final id = await gerarContrato();
      if (id == null || id.isEmpty) return null;
    }
    return await criarRecipientViewUrl(returnUrl: returnUrl);
  }

  /// Cria a URL de assinatura embutida (Recipient View) para o envelope atual.
  @action
  Future<String?> criarRecipientViewUrl({String? returnUrl}) async {
    final envId = contratoEnvelopeId;
    final t = titular;
    if (envId == null || envId.isEmpty || t == null) return null;

    final email = _pickEmail(contatos.toList()) ?? '';
    final name  = (t.nome ?? 'Cliente').trim().isEmpty ? 'Cliente' : (t.nome ?? 'Cliente').trim();
    final cpf   = _digits(t.cpf);

    final clientUserId = cpf.isNotEmpty ? cpf : 'cliente';

    final url = await _contract.getRecipientViewUrl(
      envelopeId: envId,
      email: email,
      name: name,
      clientUserId: clientUserId,
      returnUrl: returnUrl,
    );
    return url;
  }

  /// Atualiza o status do envelope no DocuSign.
  @action
  Future<DocusignStatus?> conferirAssinaturaDocuSign() async {
    final envId = contratoEnvelopeId;
    if (envId == null || envId.isEmpty) return null;
    checking = true;
    try {
      final ds = await _contract.buscarStatusDocuSign(envId);
      if (ds.signed) contratoAssinadoServer = true;
      lastCheckedAt = DateTime.now();
      return ds;
    } finally {
      checking = false;
    }
  }

  // =========================
  // HELPERS
  // =========================

  PlanModel? _planComVidas() {
    if (selectedPlan == null) return null;
    final vidas = (dependentes.length) + 1;
    // se seu PlanModel já calcula total pelas "vidasSelecionadas",
    // garantimos que isso esteja setado aqui:
    return selectedPlan!.copyWith(vidasSelecionadas: vidas);
  }

  String? _pickEmail(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final s = (c.descricao).trim();
      if (s.contains('@')) return s;
    }
    for (final c in contatos) {
      final s = (c.contato ?? '').trim();
      if (s.contains('@')) return s;
    }
    return null;
  }

  String? _pickPhone(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final digits = _digits(c.descricao);
      if (digits.length >= 10) return digits;
    }
    for (final c in contatos) {
      final digits = _digits(c.contato ?? '');
      if (digits.length >= 10) return digits;
    }
    return null;
  }

  String _digits(String? s) => (s ?? '').replaceAll(RegExp(r'\D'), '');

  // Mesma ideia do card já usado no seu app: aceita num/str e devolve "R$ x,xx"
  String _fmtCurrency(dynamic v) {
    if (v == null) return 'R\$ 0,00';
    if (v is num) return _toCurrency(v);
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return 'R\$ 0,00';
      if (s.contains('R\$')) return s;
      final numeric = double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
      if (numeric != null) return _toCurrency(numeric);
      return s;
    }
    return 'R\$ 0,00';
  }

  String _toCurrency(num? v) {
    final n = (v ?? 0) * 100;
    final cents = n.round();
    final s = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  String _estadoCivilTexto(int id) {
    // mapeamento simples (ajuste conforme seus IDs)
    switch (id) {
      case 1: return 'Solteiro(a)';
      case 2: return 'Casado(a)';
      case 3: return 'Divorciado(a)';
      case 4: return 'Viúvo(a)';
      case 5: return 'Separado(a)';
      case 6: return 'União Estável';
      default: return '';
    }
  }
}