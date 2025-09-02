import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/contract_service.dart';

part 'finish_contract_store.g.dart';

/// Store do fluxo de contrato (DocuSign) + flags de status no servidor.
/// - Dispara envelope
/// - Consulta /contracts/:nroProposta/status
/// - Finaliza a venda quando tudo ok
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

  // ===========
  // Bindings
  // ===========
  @observable
  VendaModel? venda;

  @observable
  int? nroProposta;

  // ===========
  // Estado
  // ===========
  @observable
  bool loading = false;      // ações longas (gerar contrato / finalizar)

  @observable
  bool checking = false;     // checando flags no backend

  @observable
  DateTime? lastCheckedAt;   // última checagem

  @observable
  bool contratoGerado = false;

  /// Flags do servidor
  @observable
  bool pagamentoConcluidoServer = false;

  @observable
  bool contratoAssinadoServer = false;

  @observable
  bool vendaFinalizadaServer = false;

  @observable
  String? contratoEnvelopeId; // futuro

  @observable
  String? contratoUrl;        // futuro

  // ===========
  // Getters
  // ===========
  /// Evita reenvio se já assinado no servidor.
  @computed
  bool get podeDispararContrato => !loading && !contratoAssinadoServer;

  // ===========
  // Binds
  // ===========
  @action
  void bindVenda(VendaModel v) => venda = v;

  @action
  void bindNroProposta(int? nro) => nroProposta = nro;

  // ===========
  // Ações
  // ===========
  /// Consulta flags no servidor e atualiza estado local.
  @action
  Future<ContractFlags?> syncFlags() async {
    final nro = nroProposta;
    if (nro == null) return null;

    checking = true;
    try {
      final flags = await _contract.buscarStatusContrato(nro);

      pagamentoConcluidoServer = flags.pagamentoConcluido;
      contratoAssinadoServer   = flags.contratoAssinado;
      vendaFinalizadaServer    = flags.vendaFinalizada;
      lastCheckedAt            = DateTime.now();

      return flags;
    } catch (_) {
      return null; // silencioso p/ UI
    } finally {
      checking = false;
    }
  }

  /// Dispara o DocuSign via backend (`POST /contracts/send`).
  /// `enrollmentFmt` e `monthlyFmt` devem vir formatados ("R$ 43,20").
  @action
  Future<void> gerarContrato({
    required String enrollmentFmt,
    required String monthlyFmt,
  }) async {
    final v = venda;
    if (v == null) throw Exception('Venda não carregada.');

    // Garante nro_proposta
    if (nroProposta == null) {
      final nro = await _sales.criarProposta(v, vendedorId: _defaultVendedorId);
      nroProposta = nro;
    }

    if (contratoAssinadoServer) {
      throw Exception('Contrato já assinado. Não é possível reenviar.');
    }

    // Dados do titular
    final titular = v.pessoaTitular;
    if (titular == null) throw Exception('Titular ausente.');
    final nome = (titular.nome ?? '').trim();
    final cpf = _digits(titular.cpf ?? '');
    if (cpf.isEmpty) throw Exception('CPF do titular é obrigatório.');

    final email = _pickEmail(v.contatos ?? const []);
    final phone = _pickPhone(v.contatos ?? const []);
    if (email == null) throw Exception('E-mail do titular é obrigatório.');
    if (phone == null) throw Exception('Telefone do titular é obrigatório.');

    final end = v.endereco;
    final address = [
      end?.logradouro,
      end?.numero?.toString(),
      end?.bairro,
    ].where((s) => (s ?? '').toString().trim().isNotEmpty).join(', ');
    final city = (end?.nomeCidade ?? '').trim();
    final uf = (end?.siglaUf ?? '').toString().trim();
    final cep = _digits(end?.cep ?? '');

    final plan = v.plano?.nomeContrato ?? 'Plano';
    final deps = (v.dependentes ?? []).length;

    final body = <String, dynamic>{
      'nroProposta': nroProposta, // usado pelo webhook/status
      'email': email,
      'name': nome.isEmpty ? 'Cliente' : nome,
      'cpf': cpf,
      'phone': phone,
      'birth': titular.dataNascimento ?? '',
      'sex': titular.idSexo?.toString() ?? '',
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
      await _contract.enviarContratoDocuSign(body: body);
      contratoGerado = true; // assinatura confirmará via webhook/status
    } finally {
      loading = false;
    }
  }

  /// Finaliza a venda no backend quando pagamento/contrato estiverem ok.
  @action
  Future<void> finalizarVenda() async {
    final nro = nroProposta;
    if (nro == null) throw Exception('nroProposta ausente.');

    loading = true;
    try {
      await _sales.atualizarStatusProposta(
        nroProposta: nro,
        vendaFinalizada: true,
        pagamentoConcluido: true, // seguro/idempotente
        // contratoAssinado: true  // marque via webhook quando assinado
      );
      vendaFinalizadaServer = true;
    } finally {
      loading = false;
    }
  }

  // ===========
  // Helpers
  // ===========
  String _digits(String v) => v.replaceAll(RegExp(r'\D'), '');

  String? _pickEmail(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final s = c.descricao.trim();
      if (s.contains('@')) return s;
    }
    return null;
  }

  String? _pickPhone(List<ContatoModel> contatos) {
    for (final c in contatos) {
      final digits = _digits(c.descricao);
      if (digits.length >= 10) return digits;
    }
    return null;
  }
}