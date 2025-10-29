// lib/app/modules/finish_sale/service/datanext_service.dart
import 'package:dio/dio.dart';
import 'package:e_vendas/app/core/config/api_client.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:intl/intl.dart';
// Importe os outros models
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';

class DatanextService {
  final Dio _dio = ApiClient().dio;

  static const String _pathPessoaComp = '/datanext/pessoa-composicao';
  static const String _pathInsertClient = '/datanext/insertClient';

  // ... (método enviarPessoaComposicao permanece igual) ...
  Future<Map<String, dynamic>> enviarPessoaComposicao({
    required int nroProposta,
    required String cpfVendedor,
    Map<String, dynamic>? faturamento,
  }) async {
    // ... (código existente)
        try {
      final body = {
        'nro_proposta': nroProposta,
        'cpf_vendedor': cpfVendedor,
        if (faturamento != null) 'faturamento': faturamento,
      };

      final res = await _dio.post<Map<String, dynamic>>(
        _pathPessoaComp, // <-- Rota antiga
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      print(e.response);
      final st = e.response?.statusCode;
      final data = e.response?.data;
      String backendMsg = '';
       if (data is Map) {
        backendMsg = (data['message'] ?? data['error_description'] ?? data['error'] ?? data['erro'] ?? data['detalhe'] ?? data['detail'] ?? '').toString();
      }
       final msg = backendMsg.isNotEmpty ? backendMsg : (e.message ?? 'Falha ao comunicar com o servidor');
       throw DatanextHttpException(statusCode: st, message: '[HTTP ${st ?? '-'}] $msg', data: data);
    } catch (e) {
      throw DatanextHttpException(message: 'Erro inesperado: $e');
    }
  }


  // --- MÉTODO ATUALIZADO (FORMATO EXATO DO EXEMPLO) ---
  Future<Map<String, dynamic>> enviarDadosCliente({
    required VendaModel venda,
    // cpfVendedor removido
  }) async {
    try {
      // --- Helper para formatar data DD-MM-YYYY ---
      String formatDateDMY(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return "";
        try {
          // Tenta parsear formatos comuns (DD/MM/YYYY, YYYY-MM-DD)
          DateTime parsedDate;
          if (dateStr.contains('/')) {
            parsedDate = DateFormat('dd/MM/yyyy').parseStrict(dateStr);
          } else if (dateStr.contains('-') && dateStr.length == 10) {
             parsedDate = DateFormat('yyyy-MM-dd').parseStrict(dateStr);
          } else {
             // Assume que já está no formato correto se não reconhecer
             // Ou lança erro/retorna vazio dependendo da necessidade
             print("Aviso: Formato de data não reconhecido '$dateStr'. Usando como está.");
             return dateStr; // Ou ""
          }
          return DateFormat('dd-MM-yyyy').format(parsedDate);
        } catch (e) {
          print("Erro ao formatar data '$dateStr': $e. Retornando vazio.");
          return "";
        }
      }
      String formatNowDMY() => DateFormat('dd-MM-yyyy').format(DateTime.now());

      // --- Helpers para extrair dados ---
      PessoaModel titular = venda.pessoaTitular! ;
      PessoaModel? resp = venda.pessoaResponsavelFinanceiro;
      EnderecoModel endereco = venda.endereco!;
      PlanModel plano = venda.plano!;
      List<ContatoModel> contatos = venda.contatos ?? [];

      // --- id_cidade (IBGE) - PONTO CRÍTICO ---
      int? idCidadeIbge = endereco.idCidade;
      if (idCidadeIbge == null || idCidadeIbge == 0) {
          print("ALERTA CRÍTICO: endereco.idCidade está nulo ou zero. Usando 5208707 (Goiânia) como fallback. A API DATANEXT REQUER O CÓDIGO IBGE CORRETO!");
          idCidadeIbge = 5208707; // Código IBGE de Goiânia como fallback
          // Descomente a linha abaixo para FORÇAR o erro se o ID não for válido
          // throw Exception("id_cidade (Código IBGE) é obrigatório e não foi fornecido no EnderecoModel.");
      }

      // --- Formata Contatos (Telefone e Email) ---
      List<Map<String, dynamic>> contatosPayload = [];
      // Email
      ContatoModel? emailContato = contatos.firstWhere(
            (c) => (c.idMeioComunicacao == 5 || c.descricao.contains('@')), orElse: () => ContatoModel(idMeioComunicacao: 5, descricao: "email@naoinformado.com", nomeContato: titular.nome));
      contatosPayload.add({
          "id_meio_comunicacao": 5, // Força tipo 5 para email
          "ddd": "", // Vazio para email
          "descricao": emailContato.descricao,
          "contato": emailContato.contato ?? "Email Principal", // Descrição
          "nome_contato": emailContato.nomeContato ?? titular.nome, // Nome
      });

      // Telefone
      ContatoModel? telefoneContato = contatos.firstWhere(
            (c) => (c.idMeioComunicacao != 5 && !c.descricao.contains('@') && c.descricao.replaceAll(RegExp(r'\D'), '').length >= 10), orElse: () => ContatoModel(idMeioComunicacao: 1, descricao: "62999999999", nomeContato: titular.nome)); // Fallback telefone
      if (telefoneContato != null) {
          String telDigits = telefoneContato.descricao.replaceAll(RegExp(r'\D'), '');
          String ddd = telDigits.length >= 2 ? telDigits.substring(0, 2) : "62";
          String numero = telDigits.length > 2 ? telDigits.substring(2) : telDigits;
          contatosPayload.add({
              "id_meio_comunicacao": 1, // Força tipo 1 para telefone? (Verifique com Datanext) ou use telefoneContato.idMeioComunicacao
              "ddd": ddd,
              "descricao": numero, // Apenas o número
              "nome_contato": numero,
          });
      }

      // --- Monta o Payload Final (seguindo o exemplo) ---
      final Map<String, dynamic> payload = {
        "pessoa_titular": {
          "id_sexo": titular.idSexo, // Envia null se for null no modelo
          "id_estado_civil": titular.idEstadoCivil == 0 ? null : titular.idEstadoCivil, // Converte 0 para null
          "nome": titular.nome,
          "data_nascimento": formatDateDMY(titular.dataNascimento), // Formato DD-MM-YYYY
          "nome_mae": titular.nomeMae ?? "",
          "nome_pai": titular.nomePai ?? "",
          "cpf": titular.cpf?.replaceAll(RegExp(r'\D'), '') ?? "",
          "rg": titular.rg ?? "",
          "rg_data_emissao": formatDateDMY(titular.rgDataEmissao), // Formato DD-MM-YYYY
          "rg_orgao_emissor": titular.rgOrgaoEmissor ?? "",
          "cns": titular.cns?.replaceAll(RegExp(r'\D'), '') ?? "",
          "naturalde": titular.naturalde ?? "",
          "observacao": titular.observacao ?? "", // Vazio se nulo
          "id_origem": "", // Default 5433?
          "carteirinha_origem": "" // Campo do exemplo, enviar vazio?
        },
        // Responsável Financeiro (opcional)
        if (resp != null) "pessoa_responsavel_financeiro": {
          "id_sexo": resp.idSexo,
          "id_estado_civil": resp.idEstadoCivil == 0 ? null : resp.idEstadoCivil,
          "nome": resp.nome,
          "data_nascimento": formatDateDMY(resp.dataNascimento),
          "nome_mae": resp.nomeMae ?? "",
          "nome_pai": resp.nomePai ?? "",
          "cpf": resp.cpf?.replaceAll(RegExp(r'\D'), '') ?? "",
          "rg": resp.rg ?? "",
          "rg_data_emissao": formatDateDMY(resp.rgDataEmissao),
          "rg_orgao_emissor": resp.rgOrgaoEmissor ?? "",
          "cns": resp.cns?.replaceAll(RegExp(r'\D'), '') ?? "",
          "naturalde": resp.naturalde ?? "",
          "observacao": resp.observacao ?? "",
          "id_origem": resp.idOrigem ?? 5433,
          "carteirinha_origem": ""
        } else "pessoa_responsavel_financeiro": { // Envia Titular como RF se não houver RF explícito
          "id_sexo": titular.idSexo,
          "id_estado_civil": 6,
          "nome": titular.nome,
          "data_nascimento": formatDateDMY(titular.dataNascimento),
          "nome_mae": titular.nomeMae ?? "",
          "nome_pai": titular.nomePai ?? "",
          "cpf": titular.cpf?.replaceAll(RegExp(r'\D'), '') ?? "",
          "rg": titular.rg ?? "",
          "rg_data_emissao": formatDateDMY(titular.rgDataEmissao),
          "rg_orgao_emissor": titular.rgOrgaoEmissor ?? "",
          "cns": titular.cns?.replaceAll(RegExp(r'\D'), '') ?? "",
          "naturalde": titular.naturalde ?? "",
          "observacao": titular.observacao ?? "Responsável Financeiro (Titular)",
          "id_origem": titular.idOrigem ?? 5433,
          "carteirinha_origem": ""
        },
        "dependentes": venda.dependentes?.map((d) => {
           "id_sexo": d.idSexo,
           "id_estado_civil": 6,
           "nome": d.nome,
           "data_nascimento": formatDateDMY(d.dataNascimento),
           "nome_mae": d.nomeMae ?? "",
           "nome_pai": d.nomePai ?? "",
           "cpf": d.cpf?.replaceAll(RegExp(r'\D'), '') ?? "",
           "rg": d.rg ?? "",
           "rg_data_emissao": formatDateDMY(d.rgDataEmissao),
           "rg_orgao_emissor": d.rgOrgaoEmissor ?? "",
           "cns": d.cns?.replaceAll(RegExp(r'\D'), '') ?? "",
           "naturalde": d.naturalde ?? "",
           "observacao": d.observacao ?? "",
           "id_origem": "",
           "id_grau_dependencia": d.idGrauDependencia ?? 3,
           "carteirinha_origem": d.carteirinhaOrigem ?? "" // Campo do exemplo
        }).toList() ?? [],
        "endereco": {
          "id_cidade": idCidadeIbge, // Código IBGE (CRÍTICO!)
          "id_tipo_logradouro": endereco.idTipoLogradouro ?? 1,
          "nome_cidade": endereco.nomeCidade ?? "",
          "sigla_uf": endereco.siglaUf ?? "",
          "cep": endereco.cep?.replaceAll(RegExp(r'\D'), '') ?? "",
          "bairro": endereco.bairro ?? "",
          "logradouro": endereco.logradouro ?? "",
          "numero": endereco.numero?.toString() ?? "", // Envia como string
          "complemento": endereco.complemento ?? ""
        },
        "contato": contatosPayload, // Array com telefone e/ou email formatados
        "contrato": {
          "id_contrato": plano.id, // Exemplo usa 56429
          "id_plano": plano.codigoPlano, // Exemplo usa 1699
          "id_tipo_cobranca": 8,
          "dia_vencimento": plano.dueDay ?? 5, // Exemplo usa 5
          "data_adesao_contratual": formatNowDMY(), // Formato DD-MM-YYYY
          "data_inicio_cobranca": formatNowDMY(),
          "data_adesao_plano": formatNowDMY(),
          "data_inicio_uso": formatNowDMY(),
          "observacao": "Inserção via ecommerce", // Igual ao exemplo
          "nro_proposta": "8" // Ou "" ? Exemplo tem "1233"
        }
        // cpf_vendedor removido
      };
      print('>>> Payload Datanext (Tentativa FORMATO EXATO): ${payload}'); // DEBUG

      final body = payload; // Envia direto

      final res = await _dio.post<Map<String, dynamic>>(
        _pathInsertClient,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );
      print('<<< Resposta de /datanext/insertClient: ${res.data}'); // DEBUG
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
       // ... (bloco catch DioException permanece igual) ...
              print('!!! Erro DioException em /datanext/insertClient: ${e.response?.statusCode} - ${e.response?.data}'); // DEBUG
      final st = e.response?.statusCode;
      final data = e.response?.data;
      String backendMsg = '';
       if (data is Map) {
        backendMsg = (data['message'] ?? data['error_description'] ?? data['error'] ?? data['erro'] ?? data['detalhe'] ?? data['detail'] ?? '').toString();
       }
       String datanextErrorMsg = '';
       if (data is Map && data['lista_erros'] is List && (data['lista_erros'] as List).isNotEmpty) {
           datanextErrorMsg = (data['lista_erros'] as List).first['msg']?.toString() ?? '';
       }
       final errorDesc = (data is Map ? (data['error_description'] ?? '') : '').toString();
       final finalMsg = (backendMsg.isNotEmpty ? backendMsg : (e.message ?? 'Falha ao comunicar com o servidor Datanext')) +
                        (datanextErrorMsg.isNotEmpty ? ': $datanextErrorMsg' : (errorDesc.isNotEmpty ? ': $errorDesc' : ''));
       throw DatanextHttpException(statusCode: st, message: '[HTTP ${st ?? '-'}] $finalMsg', data: data);
    } catch (e) {
       // ... (bloco catch genérico permanece igual) ...
        print('!!! Erro Genérico em /datanext/insertClient: $e'); // DEBUG
      throw DatanextHttpException(message: 'Erro inesperado ao enviar dados: $e');
    }
  }
  // --- FIM DO MÉTODO ATUALIZADO ---
}

/// Exceção semântica para falhas HTTP nessa integração.
class DatanextHttpException implements Exception {
 // ... (classe de exceção) ...
    final int? statusCode;
  final String message;
  final dynamic data;

  DatanextHttpException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'DatanextHttpException(${statusCode ?? '-'}) $message';
}