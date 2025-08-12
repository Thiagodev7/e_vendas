import 'dart:convert';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/model/contato_model.dart';
import '../../../core/model/endereco_model.dart';
import '../../../core/model/pessoa_model.dart';
import '../../../core/model/generic_state_model.dart';
import '../services/client_service.dart';

part 'client_store.g.dart';

class ClientStore = _ClientStoreBase with _$ClientStore;

abstract class _ClientStoreBase with Store {
  final ClientService _service = ClientService();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  EnderecoModel? endereco;

  @observable
  PessoaModel? pessoa;

  @observable
  PessoaModel? titular;

  @observable
  PessoaModel? responsavelFinanceiro;

  @observable
  ObservableList<PessoaModel> dependentes = ObservableList<PessoaModel>();

  @observable
  ObservableList<ContatoModel> contatos = ObservableList<ContatoModel>();

  static const String storageKey = "client_form_data";

  // =======================
  // Persistência Local
  // =======================

  @action
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
  "titular": titular?.toJson(),
      "endereco": endereco?.toJson(),
      "responsavelFinanceiro": responsavelFinanceiro?.toJson(),
      "dependentes": dependentes.map((d) => d.toJson()).toList(),
      "contatos": contatos.map((c) => c.toJson()).toList(),
    };
    prefs.setString(storageKey, jsonEncode(data));
  }

  @action
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);
    if (jsonString == null) return;

    final data = jsonDecode(jsonString);

    titular = data["titular"] != null ? PessoaModel.fromJson(data["titular"]) : null;
    endereco = data["endereco"] != null ? EnderecoModel.fromJson(data["endereco"]) : null;
    responsavelFinanceiro = data["responsavelFinanceiro"] != null
        ? PessoaModel.fromJson(data["responsavelFinanceiro"])
        : null;
    dependentes = ObservableList.of((data["dependentes"] as List)
        .map((e) => PessoaModel.fromJson(e))
        .toList());
    contatos = ObservableList.of(
        (data["contatos"] as List).map((e) => ContatoModel.fromJson(e)).toList());
  }

  @action
  Future<void> clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }

  // =======================
  // Validação de contatos
  // =======================

  bool validarContatosObrigatorios() {
    final temCelular = contatos.any(
        (c) => c.idMeioComunicacao == 1 && (c.descricao.isNotEmpty));
    final temEmail = contatos.any(
        (c) => c.idMeioComunicacao == 5 && (c.descricao.isNotEmpty));
    return temCelular && temEmail;
  }

  // =======================
  // Ações
  // =======================

  @action
  Future<void> buscarCep(String cep) async {
    try {
      errorMessage = null;
      isLoading = true;
      endereco = await _service.buscarCep(cep);
      await saveToLocalStorage();
    } catch (e) {
      errorMessage = e.toString();
      endereco = null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> buscarCpf(String cpf) async {
    try {
      errorMessage = null;
      isLoading = true;
      pessoa = await _service.buscarPorCpf(cpf);
      pessoa?.cpf = cpf;
      await saveToLocalStorage();
    } catch (e) {
      errorMessage = e.toString();
      pessoa = null;
    } finally {
      isLoading = false;
    }
  }

  @action
  void adicionarDependente(PessoaModel dependente) {
    dependentes.add(dependente);
    saveToLocalStorage();
  }

  @action
  void removerDependente(int index) {
    dependentes.removeAt(index);
    saveToLocalStorage();
  }

  @action
  void adicionarContato(ContatoModel contato) {
    contatos.add(contato);
    saveToLocalStorage();
  }

  @action
  void removerContato(int index) {
    contatos.removeAt(index);
    saveToLocalStorage();
  }

  @action
  void setResponsavelFinanceiro(PessoaModel responsavel) {
    responsavelFinanceiro = responsavel;
    saveToLocalStorage();
  }

  @observable
  List<GenericStateModel> estadoCivilList = [
    GenericStateModel(name: 'ESTADO CIVIL', id: 0),
    GenericStateModel(name: 'UNIÃO ESTÁVEL', id: 1),
    GenericStateModel(name: 'CASADO(A)', id: 2),
    GenericStateModel(name: 'DIVORCIADO(A)', id: 3),
    GenericStateModel(name: 'SEPARADO(A)', id: 5),
    GenericStateModel(name: 'SOLTEIRO(A)', id: 6),
    GenericStateModel(name: 'VIÚVO(A)', id: 7),
    GenericStateModel(name: 'OUTROS', id: 8),
  ];

  @observable
  List<GenericStateModel> bondDependentList = [
    GenericStateModel(name: 'Grau Dependência', id: 0),
    GenericStateModel(name: 'BENEFICIÁRIO', id: 1),
    GenericStateModel(name: 'CÔNJUGE/COMPANHEIRO', id: 2),
    GenericStateModel(name: 'FILHO/FILHA', id: 3),
    GenericStateModel(name: 'PAI/MÃE/SOGRO/SOGRA', id: 5),
    GenericStateModel(name: 'AGREGADOS/OUTROS', id: 6),
    GenericStateModel(name: 'ENTEADO/MENOR SOB GUARDA', id: 7),
  ];

  @observable
  List<GenericStateModel> contactTypes = [
    GenericStateModel(name: 'Tipo de Meio de Contato', id: 0),
    GenericStateModel(name: 'CELULAR', id: 1),
    GenericStateModel(name: 'TELEFONE FIXO', id: 2),
    GenericStateModel(name: 'EMAIL', id: 5),
  ];
}