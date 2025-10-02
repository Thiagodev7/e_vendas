import 'package:mobx/mobx.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/contato_model.dart';

part 'totem_store.g.dart';

class TotemStore = _TotemStoreBase with _$TotemStore;

abstract class _TotemStoreBase with Store {
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
  }
}