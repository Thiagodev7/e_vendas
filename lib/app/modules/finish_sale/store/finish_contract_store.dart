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

  @observable
  String? contratoUrl;

  @computed
  bool get podeDispararContrato => !loading && !contratoAssinadoServer;

  @action
  void bindVenda(VendaModel v) => venda = v;

  /// aceita qualquer tipo e tenta converter para int
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

  /// Dispara o DocuSign via backend (`POST /contracts/send`).
  @action
  Future<void> gerarContrato({
    required String enrollmentFmt,
    required String monthlyFmt,
  }) async {
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');

    // Garante nro_proposta válido
    if (nroProposta == null) {
      final nroRaw = await _sales.criarProposta(v, vendedorId: _defaultVendedorId);
      final parsed = _coerceInt(nroRaw);
      if (parsed == null) {
        throw Exception('Retorno inválido ao criar proposta: $nroRaw');
      }
      nroProposta = parsed;
    }

    if (contratoAssinadoServer) {
      throw Exception('Contrato já assinado. Não é possível reenviar.');
    }

    final titular = v.pessoaTitular;
    final end = v.endereco;

    final nome = (titular?.nome ?? '').trim();

    // e-mail e telefone vindos de ContatoModel
    final email = _pickEmail(v.contatos ?? const <ContatoModel>[]) ?? '';
    if (email.isEmpty) throw Exception('E-mail do titular é obrigatório.');
    final phone = _pickPhone(v.contatos ?? const <ContatoModel>[]) ?? '';
    if (phone.isEmpty) throw Exception('Telefone do titular é obrigatório.');

    final cpf = _digits(titular?.cpf ?? '');
    final address = '${end?.logradouro ?? ''}, ${end?.numero ?? ''} ${end?.complemento ?? ''}'.trim();
    final city = (end?.nomeCidade ?? '').trim();
    final uf = (end?.siglaUf ?? '').toString().trim();
    final cep = _digits(end?.cep ?? '');

    final plan = v.plano?.nomeContrato ?? 'Plano';
    final deps = (v.dependentes ?? []).length;

    final body = <String, dynamic>{
      'nroProposta': nroProposta, // já garantido int
      'email': email,
      'name': nome.isEmpty ? 'Cliente' : nome,
      'cpf': cpf,
      'phone': phone,
      'birth': titular?.dataNascimento ?? '',
      'sex': titular?.idSexo?.toString() ?? '',
      'address': address,
      'city': city,
      'uf': uf,
      'cep': cep,
      'plan': plan,
      'dependents': deps,
      'enrollment': enrollmentFmt,
      'monthly': monthlyFmt,
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
      return _coerceInt(
        v['nroProposta'] ?? v['nro_proposta'] ?? v['propostaId'] ?? v['id'],
      );
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