import 'package:e_vendas/app/core/model/generic_state_model.dart';
import 'package:mobx/mobx.dart';
import '../../../core/model/endereco_model.dart';
import '../../../core/model/pessoa_model.dart';
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
  ObservableList<Map<String, dynamic>> contatos = ObservableList<Map<String, dynamic>>();

  // ------------------------
  // Funções auxiliares
  // ------------------------

  @action
  Future<void> buscarCep(String cep) async {
    try {
      errorMessage = null;
      isLoading = true;
      endereco = await _service.buscarCep(cep);
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
  }

  @action
  void removerDependente(int index) {
    dependentes.removeAt(index);
  }

  @action
  void adicionarContato(Map<String, dynamic> contato) {
    contatos.add(contato);
  }

  @action
  void removerContato(int index) {
    contatos.removeAt(index);
  }

  @action
  void setResponsavelFinanceiro(PessoaModel responsavel) {
    responsavelFinanceiro = responsavel;
  }

  @action
  Future<bool> salvarCliente({
    required PessoaModel titular,
    PessoaModel? responsavelFinanceiro,
    List<PessoaModel>? dependentes,
    required EnderecoModel endereco,
    required Map<String, dynamic> contrato,
    required List<Map<String, dynamic>> contatos,
  }) async {
    try {
      errorMessage = null;
      isLoading = true;

      final dados = {
        "pessoa_titular": titular.toJson(),
        if (responsavelFinanceiro != null)
          "pessoa_responsavel_financeiro": responsavelFinanceiro.toJson(),
        if (dependentes != null && dependentes.isNotEmpty)
          "dependentes": dependentes.map((d) => d.toJson()).toList(),
        "endereco": endereco.toJson(),
        "contato": contatos,
        "contrato": contrato,
      };

      await _service.cadastrarCliente(dados);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
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