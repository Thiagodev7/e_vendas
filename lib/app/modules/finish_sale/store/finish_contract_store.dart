import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/contract_service.dart';

part 'finish_contract_store.g.dart';

class FinishContractStore = _FinishContractStoreBase with _$FinishContractStore;

abstract class _FinishContractStoreBase with Store {
  _FinishContractStoreBase({
    ContractService? contractService,
    SalesService? salesService,
    int defaultVendedorId = 22,
  })  : _contract = contractService ?? Modular.get<ContractService>(),
        _sales = salesService ?? Modular.get<SalesService>(),
        _defaultVendedorId = defaultVendedorId;

  final ContractService _contract;
  final SalesService _sales;
  final int _defaultVendedorId;

  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  @observable
  bool loading = false;

  @observable
  bool checking = false;

  @observable
  DateTime? lastCheckedAt;

  @observable
  bool contratoGerado = false;

  @observable
  bool pagamentoConcluidoServer = false;

  @observable
  bool contratoAssinadoServer = false;

  @observable
  bool vendaFinalizadaServer = false;

  @observable
  String? contratoEnvelopeId;

  @computed
  bool get podeDispararContrato => !loading && !contratoAssinadoServer;

  @action
  void bindVenda(VendaModel v) => venda = v;

  @action
  void bindNroProposta(dynamic nro) => nroProposta = _coerceInt(nro);

  @action
  Future<ContractFlags?> syncFlags() async {
    final id = nroProposta;
    if (id == null) return null;
    checking = true;
    try {
      final flags = await _contract.buscarStatusContrato(id);
      pagamentoConcluidoServer = flags.pagamentoConcluido;
      contratoAssinadoServer   = flags.contratoAssinado;
      vendaFinalizadaServer    = flags.vendaFinalizada;
      lastCheckedAt            = DateTime.now();
      return flags;
    } finally {
      checking = false;
    }
  }

  @action
  Future<void> gerarContrato({
    required String enrollmentFmt,
    required String monthlyFmt,
  }) async {
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');

    // garante nroProposta
    // if (nroProposta == null) {
    //   final nroRaw = await _sales.criarProposta(v, vendedorId: _defaultVendedorId);
    //   final parsed = _coerceInt(nroRaw);
    //   if (parsed == null) {
    //     throw Exception('Retorno inválido ao criar proposta: $nroRaw');
    //   }
    //   nroProposta = parsed;
    // }

    if (contratoAssinadoServer) {
      throw Exception('Contrato já assinado. Não é possível reenviar.');
    }

    final titular = v.pessoaTitular; // PessoaModel
    final end = v.endereco;          // EnderecoModel

    // contato (busca email/telefone válidos)
    final email  = _pickEmail(v.contatos ?? const <ContatoModel>[]) ?? '';
    if (email.isEmpty) throw Exception('E-mail do titular é obrigatório.');
    final phone  = _pickPhone(v.contatos ?? const <ContatoModel>[]) ?? '';
    if (phone.isEmpty) throw Exception('Telefone do titular é obrigatório.');

    // titular
    final nome     = (titular?.nome ?? '').trim();
    final cpf      = _digits(titular?.cpf ?? '');
    final birth    = (titular?.dataNascimento ?? '').trim(); // "DD/MM/AAAA" no seu fluxo
    final sexo     = titular?.idSexo.toString();             // "1"/"2" (será normalizado no backend)
    final civilId  = titular?.idEstadoCivil ?? 0;
    final civilStr = _estadoCivilTexto(civilId);

    final nomeMae  = (titular?.nomeMae ?? '').trim();
    final nomePai  = (titular?.nomePai ?? '').trim();
    final rg       = (titular?.rg ?? '').trim();
    final rgData   = (titular?.rgDataEmissao ?? '').trim();       // "DD/MM/AAAA" (seu dado)
    final rgOrgao  = (titular?.rgOrgaoEmissor ?? '').trim();
    final cns      = (titular?.cns ?? '').trim();
    final natural  = (titular?.naturalde ?? '').trim();

    // endereço
    final address   = '${end?.logradouro ?? ''}, ${end?.numero ?? ''}'.trim();
    final complement= (end?.complemento ?? '').trim();
    final city      = (end?.nomeCidade ?? '').trim();
    final uf        = (end?.siglaUf ?? '').toString().trim();
    final cep       = _digits(end?.cep ?? '');

    // plano/vidas
    final plan  = v.plano?.nomeContrato ?? 'Plano';
    final deps  = v.dependentes ?? const [];
    final depsData = deps.map<Map<String, dynamic>>((d) {
      final nomeDep = (d.nome ?? (d as dynamic).nomeCompleto ?? '').toString().trim();
      final cpfDep  = _digits(d.cpf);
      final sexoDep = (d.idSexo).toString(); // "1"/"2" (ou texto)
      // se houver campo parentesco/idGrauDependencia no seu dependente, mapeie aqui:
      final parent  = (d.idGrauDependencia?.toString() ?? (d as dynamic).parentesco?.toString() ?? '').trim();
      return <String, dynamic>{
        'name': nomeDep,
        'cpf': cpfDep,
        'sex': sexoDep,
        'parent': parent,
      };
    }).toList();

    final body = <String, dynamic>{
      // proposta
      'nroProposta': nroProposta,

      // titular
      'email': email,
      'name': nome.isEmpty ? 'Cliente' : nome,
      'cpf': cpf,
      'phone': phone,
      'birth': birth,
      'sex': sexo,               // "1"/"2" ou "Masculino/Feminino" — normalizo no Node
      'civilStatus': civilStr,   // texto (também mando id abaixo se quiser usar)
      'civilStatusId': civilId,  // numérico cru (opcional)

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
      'plan': plan,
      'dependents': deps.length,
      'enrollment': enrollmentFmt,
      'monthly': monthlyFmt,

      // dependentes detalhados
      'dependentsData': depsData,
      // opcional: "Titular" no parentesco do próprio titular
      'signerParent': 'Titular',
    };

    loading = true;
    try {
      final envId = await _contract.enviarContratoDocuSign(body: body);
      contratoEnvelopeId = envId;
      contratoGerado = true;
    } finally {
      loading = false;
    }
  }

  @action
  Future<DocusignStatus?> conferirAssinaturaDocuSign() async {
    final id = contratoEnvelopeId;
    if (id == null || id.isEmpty) return null;
    checking = true;
    try {
      final ds = await _contract.buscarStatusDocuSign(id);
      if (ds.signed) contratoAssinadoServer = true;
      lastCheckedAt = DateTime.now();
      return ds;
    } finally {
      checking = false;
    }
  }

  // ===== Helpers =====
  int? _coerceInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    if (v is Map) {
      return _coerceInt(v['nroProposta'] ?? v['nro_proposta'] ?? v['propostaId'] ?? v['id']);
    }
    return null;
  }

  String _digits(String? s) => (s ?? '').replaceAll(RegExp(r'\D'), '');

  String? _pickEmail(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final s = c.descricao.trim();
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

  String _estadoCivilTexto(int id) {
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
  /// Gera URL de assinatura embutida (Recipient View) e retorna a URL.
  @action
  Future<String?> criarRecipientViewUrl({String? returnUrl}) async {
    final envId = contratoEnvelopeId;
    final v = venda;
    if (envId == null || envId.isEmpty || v == null) return null;

    final email = _pickEmail(v.contatos ?? const <ContatoModel>[]) ?? '';
    final name = (v.pessoaTitular?.nome ?? 'Cliente').trim();
    final cpf = _digits(v.pessoaTitular?.cpf ?? '');
    final clientUserId = cpf.isNotEmpty
        ? cpf
        : (nroProposta != null ? '${nroProposta!}' : 'cliente');

    final url = await _contract.getRecipientViewUrl(
      envelopeId: envId,
      email: email,
      name: name.isEmpty ? 'Cliente' : name,
      clientUserId: clientUserId,
      returnUrl: returnUrl,
    );
    return url;
  }

  /// Gera URL do Console DocuSign (Console View) e retorna a URL.
  @action
  Future<String?> criarConsoleViewUrl({String? returnUrl}) async {
    final envId = contratoEnvelopeId;
    if (envId == null || envId.isEmpty) return null;
    final url = await _contract.getConsoleViewUrl(
      envelopeId: envId,
      returnUrl: returnUrl,
    );
    return url;
  }

  /// Retorna URL absoluta para abrir o PDF combinado do envelope.
  String? getEnvelopePdfUrl() {
    final envId = contratoEnvelopeId;
    if (envId == null || envId.isEmpty) return null;
    return _contract.getEnvelopePdfUrl(envId);
  }
}