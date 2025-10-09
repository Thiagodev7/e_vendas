import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/generic_state_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/dashboard_layout.dart';
import '../../../core/utils/responsive_helper.dart';
import '../stores/client_store.dart';

class ClientFormPage extends StatefulWidget {
  final PlanModel? selectedPlan;
  final int? vendaIndex;

  const ClientFormPage({super.key, this.selectedPlan, this.vendaIndex});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final store = Modular.get<ClientStore>();
  final salesStore = Modular.get<SalesStore>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final cpfController = TextEditingController();
  final cepController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();

  // Máscaras
  final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');
  final cepMask = MaskTextInputFormatter(mask: '#####-###');

  GenericStateModel? estadoCivilTitular;

  @override
  void initState() {
    super.initState();
    carregarVendaExistente();
  }

  @override
  void dispose() {
    cpfController.dispose();
    cepController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    super.dispose();
  }

  void carregarVendaExistente() {
    if (widget.selectedPlan == null) return;
    if (widget.vendaIndex == null) return;

    final venda = salesStore.vendas[widget.vendaIndex!];

    // Titular
    if (venda.pessoaTitular != null) {
      store.titular = venda.pessoaTitular;
      cpfController.text = venda.pessoaTitular!.cpf ?? '';
      estadoCivilTitular = store.estadoCivilList.firstWhere(
        (e) => e.id == venda.pessoaTitular!.idEstadoCivil,
        orElse: () => store.estadoCivilList.first,
      );
    }

    // Endereço
    if (venda.endereco != null) {
      store.endereco = venda.endereco;
      cepController.text = venda.endereco!.cep ?? '';
      numeroController.text = venda.endereco!.numero.toString() ?? '';
      complementoController.text = venda.endereco!.complemento ?? '';
    }

    // Responsável Financeiro
    if (venda.pessoaResponsavelFinanceiro != null) {
      store.responsavelFinanceiro = venda.pessoaResponsavelFinanceiro;
    }

    // Dependentes
    if (venda.dependentes != null && venda.dependentes!.isNotEmpty) {
      store.dependentes.clear();
      store.dependentes.addAll(venda.dependentes!);
    }

    // Contatos
    if (venda.contatos != null && venda.contatos!.isNotEmpty) {
      store.contatos.clear();
      store.contatos.addAll(venda.contatos!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardLayout(
      title: 'Cadastrar Cliente',
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth;
          if (ResponsiveHelper.isDesktop(context)) {
            maxWidth = constraints.maxWidth * 1;
          } else if (ResponsiveHelper.isTablet(context)) {
            maxWidth = 600;
          } else {
            maxWidth = double.infinity;
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Observer(
                builder: (_) => Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.selectedPlan != null)
                              _buildSelectedPlan(widget.selectedPlan!, isDark),
                            const SizedBox(height: 20),

                            // Responsivo
                            if (ResponsiveHelper.isDesktop(context)) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _buildCardDadosPessoais(isDark)),
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildCardEndereco(isDark)),
                                ],
                              ),
                            ] else ...[
                              _buildCardDadosPessoais(isDark),
                              const SizedBox(height: 20),
                              _buildCardEndereco(isDark),
                            ],

                            const SizedBox(height: 20),

                            if (ResponsiveHelper.isDesktop(context)) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _buildCardResponsavelFinanceiro(
                                          isDark)),
                                  const SizedBox(width: 24),
                                  Expanded(
                                      child: _buildCardDependentes(isDark)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildCardContatos(isDark),
                            ] else ...[
                              _buildCardResponsavelFinanceiro(isDark),
                              const SizedBox(height: 20),
                              _buildCardDependentes(isDark),
                              const SizedBox(height: 20),
                              _buildCardContatos(isDark),
                            ],
                            const SizedBox(height: 24),

                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),
                    if (store.errorMessage != null && !store.isLoading)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Material(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              store.errorMessage!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _digits(String? s) => (s ?? '').replaceAll(RegExp(r'\D'), '');

  bool _isPhoneType(GenericStateModel? t) {
    final n = (t?.name ?? '').toLowerCase();
    return n.contains('telefone') ||
        n.contains('celular') ||
        n.contains('whats') ||
        n.contains('phone');
  }

  String? _formatBrPhone(String digits) {
    // 10 dígitos: (DD) XXXX-XXXX | 11 dígitos: (DD) XXXXX-XXXX
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    return null;
  }

  // Plano Selecionado
  Widget _buildSelectedPlan(PlanModel plan, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lilac.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lilac),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plano Selecionado: ${plan.nomeContrato}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          Text('Vidas: ${plan.vidasSelecionadas}'),
          Text('Mensalidade: R\$ ${plan.getMensalidade()}'),
          Text('Mensalidade total: R\$ ${plan.getMensalidadeTotal()}'),
          Text('Adesão: R\$ ${plan.getTaxaAdesao()}'),
          Text('Adesão total: R\$ ${plan.getTaxaAdesaoTotal()}'),
        ],
      ),
    );
  }

  // =====================
  // CARDS DE FORM
  // =====================

  Widget _buildCardDadosPessoais(bool isDark) {
    final pessoa = store.titular;

    return _buildCardContainer(
      title: 'Dados Pessoais',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCpfField(),
          if (pessoa != null) ...[
            const SizedBox(height: 8),
            _buildInfoText('Nome', pessoa.nome),
            _buildInfoText('Data Nascimento', pessoa.dataNascimento),
            _buildInfoText('Nome da Mãe', pessoa.nomeMae),
            _buildInfoText('Nome do Pai', pessoa.nomePai),
            _buildInfoText('CNS', pessoa.cns),
          ],
          const SizedBox(height: 12),
          _buildEstadoCivilSelector(),
        ],
      ),
    );
  }

  Widget _buildCardEndereco(bool isDark) {
    final endereco = store.endereco;

    return _buildCardContainer(
      title: 'Endereço',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCepField(),
          if (endereco != null) ...[
            const SizedBox(height: 8),
            _buildInfoText('Cidade', endereco.nomeCidade),
            _buildInfoText('UF', endereco.siglaUf),
            _buildInfoText('Bairro', endereco.bairro),
            _buildInfoText('Logradouro', endereco.logradouro),
          ],
          const SizedBox(height: 8),
          _buildTextField('Número', numeroController,
              keyboardType: TextInputType.number),
          _buildTextField('Complemento', complementoController),
        ],
      ),
    );
  }

  Widget _buildCardResponsavelFinanceiro(bool isDark) {
    return _buildCardContainer(
      title: 'Responsável Financeiro',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _openModalPessoa(isDark, isResponsavel: true),
            icon: const Icon(Icons.person_add),
            label: const Text('Adicionar Responsável'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Observer(builder: (_) {
            final resp = store.responsavelFinanceiro;
            if (resp == null)
              return const Text('Nenhum responsável adicionado');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoText('Nome', resp.nome),
                _buildInfoText('CPF', resp.cpf),
                _buildInfoText('Data Nascimento', resp.dataNascimento),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardDependentes(bool isDark) {
    return _buildCardContainer(
      title: 'Dependentes',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _openModalPessoa(isDark, isResponsavel: false),
            icon: const Icon(Icons.group_add),
            label: const Text('Adicionar Dependente'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Observer(builder: (_) {
            if (store.dependentes.isEmpty) {
              return const Text('Nenhum dependente adicionado');
            }
            return Column(
              children: List.generate(store.dependentes.length, (index) {
                final dep = store.dependentes[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dep.nome),
                  subtitle: Text(dep.idGrauDependencia != null
                      ? 'Grau: ${store.bondDependentList.firstWhere((e) => e.id == dep.idGrauDependencia).name}'
                      : ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => store.removerDependente(index),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardContatos(bool isDark) {
    return _buildCardContainer(
      title: 'Contatos',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _openModalContato(),
            icon: const Icon(Icons.add_call),
            label: const Text('Adicionar Contato'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Observer(builder: (_) {
            if (store.contatos.isEmpty) {
              return const Text('Nenhum contato adicionado');
            }
            return Column(
              children: List.generate(store.contatos.length, (index) {
                final contato = store.contatos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(contato.descricao),
                  subtitle: Text(contato.nomeContato ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => store.removerContato(index),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // =====================
  // BOTÃO SALVAR
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: store.isLoading
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) return;

                if (!store.validarContatosObrigatorios()) {
                  _showSnackBar(
                      'Informe ao menos um celular e um e-mail', Colors.red);
                  return;
                }

                if (store.titular == null || store.endereco == null) {
                  _showSnackBar(
                      'Preencha os dados do titular e endereço', Colors.red);
                  return;
                }

                // Pega o plano (se existir)
                PlanModel? plan = widget.selectedPlan;

                if (widget.vendaIndex == null) {
                  // Nova venda
                  final index = await salesStore.criarVendaComPlano(plan);
                  await _salvarDadosVenda(index);
                } else {
                  // Atualiza venda existente
                  await _salvarDadosVenda(widget.vendaIndex!);
                }

                await store.clearLocalStorage();

                _showSnackBar('Venda salva com sucesso', Colors.green);
                Modular.to.navigate('/sales');
              },
        child: store.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Salvar Cliente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _salvarDadosVenda(int index) async {
    // Atualiza os campos alterados manualmente
    store.titular = store.titular!.copyWith(
      idEstadoCivil: estadoCivilTitular?.id,
    );

    store.endereco = store.endereco!.copyWith(
      numero: numeroController.text.isNotEmpty
          ? int.tryParse(numeroController.text)
          : null,
      complemento: complementoController.text,
    );

    // Salva
    await salesStore.atualizarTitular(index, store.titular!);
    await salesStore.atualizarEndereco(index, store.endereco!);
    await salesStore.atualizarDependentes(index, store.dependentes.toList());
    await salesStore.atualizarContatos(index, store.contatos.toList());

    if (store.responsavelFinanceiro != null) {
      await salesStore.atualizarResponsavelFinanceiro(
          index, store.responsavelFinanceiro!);
    }
  }

  // Campos e cards
  Widget _buildCpfField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            'CPF',
            cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: [cpfMask],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            await store.buscarCpf(cpfMask.getUnmaskedText());
            store.titular = store.pessoa;
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Buscar'),
        ),
      ],
    );
  }

  Widget _buildCepField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            'CEP',
            cepController,
            keyboardType: TextInputType.number,
            inputFormatters: [cepMask],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            await store.buscarCep(cepMask.getUnmaskedText());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Buscar'),
        ),
      ],
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildEstadoCivilSelector() {
    return Observer(builder: (_) {
      return DropdownButtonFormField<GenericStateModel>(
        value: estadoCivilTitular,
        decoration: InputDecoration(
          labelText: 'Estado Civil',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: store.estadoCivilList.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: (val) => setState(() => estadoCivilTitular = val),
        validator: (value) =>
            value == null || value.id == 0 ? 'Selecione o estado civil' : null,
      );
    });
  }

  // Containers
  Widget _buildCardContainer({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.6)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: (value) =>
            value == null || value.isEmpty ? 'Preencha o campo $label' : null,
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
// =====================
  // MODAIS
  // =====================

  void _openModalPessoa(bool isDark, {required bool isResponsavel}) {
    final cpfModalController = TextEditingController();
    GenericStateModel? estadoCivilSelecionado;
    GenericStateModel? grauDependenciaSelecionado;
    PessoaModel? pessoaEncontrada; // dados temporários no modal
    final cpfMaskModal = MaskTextInputFormatter(mask: '###.###.###-##');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: isDark
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
              title: Text(
                isResponsavel
                    ? 'Adicionar Responsável Financeiro'
                    : 'Adicionar Dependente',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: cpfModalController,
                    decoration: const InputDecoration(labelText: 'CPF'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfMaskModal],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await store.buscarCpf(cpfMaskModal.getUnmaskedText());
                      setModalState(() {
                        pessoaEncontrada = store.pessoa;
                        pessoaEncontrada?.cpf = cpfMaskModal.getUnmaskedText();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Buscar'),
                  ),
                  const SizedBox(height: 12),
                  if (pessoaEncontrada != null) ...[
                    _buildInfoText('Nome', pessoaEncontrada!.nome),
                    _buildInfoText(
                        'Nascimento', pessoaEncontrada!.dataNascimento),
                    _buildInfoText('Mãe', pessoaEncontrada!.nomeMae),
                    _buildInfoText('Pai', pessoaEncontrada!.nomePai),
                  ],
                  const SizedBox(height: 12),
                  Observer(builder: (_) {
                    return DropdownButtonFormField<GenericStateModel>(
                      value: estadoCivilSelecionado,
                      decoration:
                          const InputDecoration(labelText: 'Estado Civil'),
                      items: store.estadoCivilList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.name));
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => estadoCivilSelecionado = val),
                      validator: (value) => value == null || value.id == 0
                          ? 'Selecione o estado civil'
                          : null,
                    );
                  }),
                  if (!isResponsavel) ...[
                    const SizedBox(height: 12),
                    Observer(builder: (_) {
                      return DropdownButtonFormField<GenericStateModel>(
                        value: grauDependenciaSelecionado,
                        decoration: const InputDecoration(
                            labelText: 'Grau de Dependência'),
                        items: store.bondDependentList.map((e) {
                          return DropdownMenuItem(
                              value: e, child: Text(e.name));
                        }).toList(),
                        onChanged: (val) => setModalState(
                            () => grauDependenciaSelecionado = val),
                        validator: (value) => value == null || value.id == 0
                            ? 'Selecione o grau de dependência'
                            : null,
                      );
                    }),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: (pessoaEncontrada != null &&
                          estadoCivilSelecionado != null &&
                          estadoCivilSelecionado!.id != 0 &&
                          (isResponsavel ||
                              (grauDependenciaSelecionado != null &&
                                  grauDependenciaSelecionado?.id != 0)))
                      ? () {
                          final pessoa = pessoaEncontrada!.copyWith(
                            idEstadoCivil: estadoCivilSelecionado!.id,
                            idGrauDependencia: !isResponsavel
                                ? grauDependenciaSelecionado!.id
                                : null,
                          );
                          if (isResponsavel) {
                            store.responsavelFinanceiro = pessoa;
                          } else {
                            store.adicionarDependente(pessoa);
                          }
                          Navigator.pop(ctx);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openModalContato() {
    final descricaoController = TextEditingController();
    final nomeController = TextEditingController();
    GenericStateModel? tipoContatoSelecionado;

    // máscaras para telefone (fixo e celular)
    final phoneMask11 = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {'#': RegExp(r'\d')},
    );
    final phoneMask10 = MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {'#': RegExp(r'\d')},
    );

    // máscara atual aplicada no campo de descrição (vai mudar conforme o tipo)
    MaskTextInputFormatter? currentMask;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // atualiza máscara quando o tipo muda
            void _updateMask() {
              if (_isPhoneType(tipoContatoSelecionado)) {
                // começa com celular (11). Se o usuário digitar 10, a gente revalida
                currentMask = phoneMask11;
              } else {
                currentMask = null; // sem máscara para email/outros
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Adicionar Contato'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Observer(builder: (_) {
                    return DropdownButtonFormField<GenericStateModel>(
                      value: tipoContatoSelecionado,
                      decoration:
                          const InputDecoration(labelText: 'Tipo de Contato'),
                      items: store.contactTypes.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.name));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          tipoContatoSelecionado = val;
                          _updateMask();
                          // limpa formatações anteriores quando troca tipo
                          descricaoController.clear();
                          phoneMask10.clear();
                          phoneMask11.clear();
                        });
                      },
                      validator: (value) => value == null || value.id == 0
                          ? 'Selecione o tipo'
                          : null,
                    );
                  }),
                  const SizedBox(height: 12),

                  // Campo descrição com máscara dinâmica quando for telefone
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: _isPhoneType(tipoContatoSelecionado)
                          ? TextInputType.phone
                          : TextInputType.text,
                      inputFormatters: _isPhoneType(tipoContatoSelecionado)
                          ? [currentMask!]
                          : null,
                      onChanged: (val) {
                        if (_isPhoneType(tipoContatoSelecionado)) {
                          // troca de máscara conforme 10/11 dígitos
                          final d = _digits(val);
                          final wants11 = d.length >= 11;
                          final is11Applied =
                              identical(currentMask, phoneMask11);
                          if (wants11 && !is11Applied) {
                            // migra para 11 dígitos
                            final raw = _digits(descricaoController.text);
                            setModalState(() {
                              currentMask = phoneMask11;
                              phoneMask11.clear();
                              descricaoController.text =
                                  phoneMask11.maskText(raw);
                              descricaoController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: descricaoController.text.length),
                              );
                            });
                          } else if (!wants11 && is11Applied) {
                            // volta para 10 dígitos
                            final raw = _digits(descricaoController.text);
                            setModalState(() {
                              currentMask = phoneMask10;
                              phoneMask10.clear();
                              descricaoController.text =
                                  phoneMask10.maskText(raw);
                              descricaoController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: descricaoController.text.length),
                              );
                            });
                          }
                        }
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Contato',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (tipoContatoSelecionado == null ||
                        tipoContatoSelecionado!.id == 0) {
                      _showSnackBar('Selecione o tipo de contato', Colors.red);
                      return;
                    }

                    // ✅ Regra: se for telefone, exigir DDD (10 ou 11 dígitos)
                    if (_isPhoneType(tipoContatoSelecionado)) {
                      final digits = _digits(descricaoController.text);

                      if (digits.length < 10 || digits.length > 11) {
                        _showSnackBar(
                          'Telefone inválido. Inclua DDD. Ex: (62) 98158-0544',
                          Colors.red,
                        );
                        return;
                      }

                      // formata bonitinho antes de salvar
                      final formatted =
                          _formatBrPhone(digits) ?? descricaoController.text;
                      descricaoController.text = formatted;
                    }

                    store.adicionarContato(
                      ContatoModel(
                        idMeioComunicacao: tipoContatoSelecionado!.id,
                        descricao: descricaoController.text,
                        nomeContato: nomeController.text,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
