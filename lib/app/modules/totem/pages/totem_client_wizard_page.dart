// lib/app/modules/totem/modules/client/pages/totem_client_wizard_page.dart
import 'dart:math';
import 'dart:ui';
import 'package:e_vendas/app/core/model/contato_model.dart';
import 'package:e_vendas/app/core/model/endereco_model.dart';
import 'package:e_vendas/app/core/model/generic_state_model.dart';
import 'package:e_vendas/app/core/model/pessoa_model.dart';
import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/modules/client/services/client_service.dart';
import 'package:e_vendas/app/modules/totem/stores/totem_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum _Step { cep, numeroComp, cpf, contatos, dependentes, responsavel, resumo }

class TotemClientWizardPage extends StatefulWidget {
  const TotemClientWizardPage({super.key});

  @override
  State<TotemClientWizardPage> createState() => _TotemClientWizardPageState();
}

class _TotemClientWizardPageState extends State<TotemClientWizardPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  _Step _current = _Step.cep;

  late final AnimationController _titleAnimCtrl;
  late final AnimationController _pageAnimCtrl;

  @override
  void initState() {
    super.initState();
    _titleAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _pageAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _titleAnimCtrl.dispose();
    _pageAnimCtrl.dispose();
    super.dispose();
  }

  void _go(_Step s) {
    if (_current == s) return;

    // Animações de transição
    _titleAnimCtrl.reverse();
    _pageAnimCtrl.reverse().then((_) {
      setState(() => _current = s);
      _pageCtrl.jumpToPage(s.index); // Troca a página sem animação visual
      _titleAnimCtrl.forward();
      _pageAnimCtrl.forward();
    });
  }

  String _titleForStep(_Step s) {
    switch (s) {
      case _Step.cep: return 'Onde você mora?';
      case _Step.numeroComp: return 'Qual o número e complemento?';
      case _Step.cpf: return 'Dados do Titular';
      case _Step.contatos: return 'Seus Contatos';
      case _Step.dependentes: return 'Adicionar Dependentes';
      case _Step.responsavel: return 'Responsável Financeiro';
      case _Step.resumo: return 'Revise seus Dados';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AnimatedBlobBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _StepChips(
                    current: _current,
                    onTap: (_Step s) {
                      if (s.index <= _current.index) _go(s);
                    },
                  ),
                ),
                FadeTransition(
                  opacity: _titleAnimCtrl,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      _titleForStep(_current),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FadeTransition(
                    opacity: _pageAnimCtrl,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                        CurvedAnimation(parent: _pageAnimCtrl, curve: Curves.easeOutCubic),
                      ),
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _StepCep(onAvancar: () => _go(_Step.numeroComp)),
                          _StepNumeroCompl(onAvancar: () => _go(_Step.cpf), onVoltar: () => _go(_Step.cep)),
                          _StepCpf(onAvancar: () => _go(_Step.contatos), onVoltar: () => _go(_Step.numeroComp)),
                          _StepContatos(onAvancar: () => _go(_Step.dependentes), onVoltar: () => _go(_Step.cpf)),
                          _StepDependentes(onAvancar: () => _go(_Step.responsavel), onVoltar: () => _go(_Step.contatos)),
                          _StepResponsavel(onAvancar: () => _go(_Step.resumo), onVoltar: () => _go(_Step.dependentes)),
                          _StepResumo(
                            onVoltar: () => _go(_Step.responsavel),
                            onConfirm: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados confirmados! Próximo passo...')));
                              // Modular.to.pushNamed('/totem/checkout');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTES DE UI REUTILIZÁVEIS
// =============================================================================

class _WizardCard extends StatelessWidget {
  const _WizardCard({required this.child, this.maxWidth = 900});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WizardActions extends StatelessWidget {
  const _WizardActions({this.onVoltar, required this.onAvancar, this.labelAvancar = 'Continuar'});
  final VoidCallback? onVoltar;
  final VoidCallback onAvancar;
  final String labelAvancar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onVoltar != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onVoltar,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              label: const Text('Voltar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: onVoltar != null ? 2 : 1,
          child: FilledButton.icon(
            onPressed: onAvancar,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            label: Text(labelAvancar),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// WIDGETS DE CADA PASSO (STEP)
// =============================================================================

class _StepCep extends StatefulWidget {
  const _StepCep({required this.onAvancar});
  final VoidCallback onAvancar;

  @override
  State<_StepCep> createState() => _StepCepState();
}

class _StepCepState extends State<_StepCep> {
  final _service = ClientService();
  final _totem = Modular.get<TotemStore>();
  final _cepCtrl = TextEditingController();
  final _mask = MaskTextInputFormatter(mask: '#####-###');
  bool _loading = false;

  Future<void> _buscar() async {
    final cep = _mask.getUnmaskedText();
    if (cep.length != 8) {
      _snack('Informe um CEP válido');
      return;
    }
    setState(() => _loading = true);
    try {
      final e = await _service.buscarCep(cep);
      _totem.setEnderecoFromCep(e);
      widget.onAvancar();
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return _WizardCard(
      maxWidth: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Comece digitando seu CEP para encontrarmos seu endereço.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cepCtrl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _mask],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CEP', prefixIcon: Icon(Icons.location_pin)),
                  onFieldSubmitted: (_) => _loading ? null : _buscar(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _buscar,
                icon: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search),
                label: const Text('Buscar'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepNumeroCompl extends StatefulWidget {
  const _StepNumeroCompl({required this.onAvancar, required this.onVoltar});
  final VoidCallback onAvancar;
  final VoidCallback onVoltar;

  @override
  State<_StepNumeroCompl> createState() => _StepNumeroComplState();
}

class _StepNumeroComplState extends State<_StepNumeroCompl> {
  final _totem = Modular.get<TotemStore>();
  final _numeroCtrl = TextEditingController();
  final _complCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = _totem.endereco;
    if (e?.numero != null) _numeroCtrl.text = e!.numero!.toString();
    if (e?.complemento != null) _complCtrl.text = e!.complemento!;
  }

  void _salvar() {
    if (_numeroCtrl.text.isEmpty) {
      _snack('Por favor, informe o número.');
      return;
    }
    _totem.setEnderecoNumeroComplemento(numero: int.tryParse(_numeroCtrl.text), complemento: _complCtrl.text);
    widget.onAvancar();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final e = Modular.get<TotemStore>().endereco;
    return _WizardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (e != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${e.logradouro ?? ''}, ${e.bairro ?? ''}\n${e.nomeCidade ?? ''}/${e.siglaUf ?? ''}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: TextFormField(controller: _numeroCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Número')),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _complCtrl, decoration: const InputDecoration(labelText: 'Complemento (opcional)'))),
            ],
          ),
          const SizedBox(height: 32),
          _WizardActions(onVoltar: widget.onVoltar, onAvancar: _salvar),
        ],
      ),
    );
  }
}

class _StepCpf extends StatefulWidget {
  const _StepCpf({required this.onAvancar, required this.onVoltar});
  final VoidCallback onAvancar;
  final VoidCallback onVoltar;

  @override
  State<_StepCpf> createState() => _StepCpfState();
}

class _StepCpfState extends State<_StepCpf> {
  final _service = ClientService();
  final _totem = Modular.get<TotemStore>();
  final _cpfCtrl = TextEditingController();
  final _mask = MaskTextInputFormatter(mask: '###.###.###-##');
  bool _loading = false;
  PessoaModel? _pessoa;

  @override
  void initState() {
    super.initState();
    if (_totem.titular != null) {
      _pessoa = _totem.titular;
      _cpfCtrl.text = _mask.maskText(_totem.titular!.cpf ?? '');
    }
  }

  Future<void> _buscar() async {
    final cpf = _mask.getUnmaskedText();
    if (cpf.length != 11) {
      _snack('Informe um CPF válido');
      return;
    }
    setState(() { _loading = true; _pessoa = null; });
    try {
      final p = await _service.buscarPorCpf(cpf);
      _pessoa = p.copyWith(cpf: cpf);
      _totem.setTitular(_pessoa!);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continuar() {
    if (_totem.titular == null) {
      _snack('Busque e confirme os dados do titular pelo CPF.');
      return;
    }
    widget.onAvancar();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return _WizardCard(
      maxWidth: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cpfCtrl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _mask],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CPF do titular', prefixIcon: Icon(Icons.badge_outlined)),
                  onFieldSubmitted: (_) => _loading ? null : _buscar(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _buscar,
                icon: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search),
                label: const Text('Buscar'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              ),
            ],
          ),
          if (_pessoa != null) ...[
            const Divider(height: 32),
            _ResumoTile(title: 'Dados do Titular', lines: [
              'Nome: ${_pessoa!.nome}',
              'Data de Nascimento: ${_pessoa!.dataNascimento ?? '-'}',
              if ((_pessoa!.nomeMae ?? '').isNotEmpty) 'Nome da Mãe: ${_pessoa!.nomeMae}',
            ]),
          ],
          const SizedBox(height: 32),
          _WizardActions(onVoltar: widget.onVoltar, onAvancar: _continuar),
        ],
      ),
    );
  }
}

class _StepContatos extends StatefulWidget {
  const _StepContatos({required this.onAvancar, required this.onVoltar});
  final VoidCallback onAvancar;
  final VoidCallback onVoltar;

  @override
  State<_StepContatos> createState() => _StepContatosState();
}

class _StepContatosState extends State<_StepContatos> {
  final _totem = Modular.get<TotemStore>();
  final _celCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _celMask = MaskTextInputFormatter(mask: '(##) #####-####');

  @override
  void initState() {
    super.initState();
    final celular = _totem.contatos.firstWhere((c) => c.idMeioComunicacao == 1, orElse: () => ContatoModel(idMeioComunicacao: 1, descricao: '', nomeContato: ''));
    final email = _totem.contatos.firstWhere((c) => c.idMeioComunicacao == 5, orElse: () => ContatoModel(idMeioComunicacao: 5, descricao: '', nomeContato: ''));
    _celCtrl.text = celular.descricao;
    _emailCtrl.text = email.descricao;
  }

  bool _validEmail(String v) => RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);

  void _continuar() {
    final cel = _celMask.getUnmaskedText();
    final mail = _emailCtrl.text.trim();
    if (cel.length < 10) { _snack('Informe um número de celular válido.'); return; }
    if (!_validEmail(mail)) { _snack('Informe um e-mail válido.'); return; }
    
    _totem.setContatos(celular: _celCtrl.text, email: mail);
    widget.onAvancar();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return _WizardCard(
      maxWidth: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _celCtrl,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, _celMask],
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Celular com DDD', prefixIcon: Icon(Icons.phone_iphone)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 32),
          _WizardActions(onVoltar: widget.onVoltar, onAvancar: _continuar),
        ],
      ),
    );
  }
}

final List<GenericStateModel> _grauDependenciaList = [
  GenericStateModel(name: 'CÔNJUGE/COMPANHEIRO', id: 2),
  GenericStateModel(name: 'FILHO/FILHA', id: 3),
  GenericStateModel(name: 'PAI/MÃE/SOGRO/SOGRA', id: 5),
  GenericStateModel(name: 'AGREGADOS/OUTROS', id: 6),
  GenericStateModel(name: 'ENTEADO/MENOR SOB GUARDA', id: 7),
];

class _StepDependentes extends StatefulWidget {
  const _StepDependentes({required this.onAvancar, required this.onVoltar});
  final VoidCallback onAvancar;
  final VoidCallback onVoltar;

  @override
  State<_StepDependentes> createState() => _StepDependentesState();
}

class _StepDependentesState extends State<_StepDependentes> {
  final _totem = Modular.get<TotemStore>();
  final _service = ClientService();
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');
  final _cpfCtrl = TextEditingController();
  GenericStateModel? _grau;
  PessoaModel? _pessoa;
  bool _loading = false;

  void _resetForm() {
    _cpfCtrl.clear();
    _pessoa = null;
    _grau = null;
    setState(() {});
  }

  Future<void> _buscarCpf() async {
    final cpf = _cpfMask.getUnmaskedText();
    if (cpf.length != 11) { _snack('Informe um CPF válido'); return; }
    setState(() => _loading = true);
    try {
      final p = await _service.buscarPorCpf(cpf);
      _pessoa = p.copyWith(cpf: cpf);
      setState(() {});
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _adicionar() {
    if (_pessoa == null || _grau == null) { _snack('Busque o CPF e selecione o grau de dependência.'); return; }
    _totem.addDependente(_pessoa!.copyWith(idGrauDependencia: _grau!.id));
    _resetForm();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return _WizardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LISTA DE DEPENDENTES ADICIONADOS
          if (_totem.dependentes.isNotEmpty) ...[
            Align(alignment: Alignment.centerLeft, child: Text('Dependentes adicionados', style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 8),
            ...List.generate(_totem.dependentes.length, (i) {
              final d = _totem.dependentes[i];
              final grau = _grauDependenciaList.firstWhere((g) => g.id == d.idGrauDependencia, orElse: () => GenericStateModel(name: 'Não informado', id: 0));
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(d.nome),
                subtitle: Text('CPF: ${d.cpf ?? ''} • ${grau.name}'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _totem.removeDependenteAt(i))),
              );
            }),
            const Divider(height: 32),
          ],
          
          // FORMULÁRIO DE ADIÇÃO
          _StepIndicator(step: 1, text: 'Busque o CPF do dependente'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _cpfCtrl, inputFormatters: [FilteringTextInputFormatter.digitsOnly, _cpfMask], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'CPF', enabled: _pessoa == null), readOnly: _pessoa != null)),
              const SizedBox(width: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : OutlinedButton.icon(
                      onPressed: _pessoa == null ? _buscarCpf : _resetForm,
                      icon: Icon(_pessoa == null ? Icons.search : Icons.clear),
                      label: Text(_pessoa == null ? 'Buscar' : 'Limpar'),
                       style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                    ),
            ],
          ),
          
          if (_pessoa != null) ...[
            const SizedBox(height: 24),
            _StepIndicator(step: 2, text: 'Selecione o grau de parentesco'),
            const SizedBox(height: 12),
            DropdownButtonFormField<GenericStateModel>(
              value: _grau,
              isExpanded: true,
              items: _grauDependenciaList.map((e) => DropdownMenuItem(value: e, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
              decoration: const InputDecoration(labelText: 'Grau de Parentesco'),
              onChanged: (v) => setState(() => _grau = v),
            ),
            const SizedBox(height: 8),
            Text('Dependente encontrado: ${_pessoa!.nome}'),
          ],
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_pessoa != null && _grau != null) ? _adicionar : null, // Habilita/desabilita
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Adicionar Dependente'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          const SizedBox(height: 32),
          _WizardActions(onVoltar: widget.onVoltar, onAvancar: widget.onAvancar),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.text});
  final int step;
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      CircleAvatar(radius: 14, backgroundColor: cs.primary, child: Text('$step', style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold))),
      const SizedBox(width: 12),
      Text(text, style: Theme.of(context).textTheme.titleMedium),
    ]);
  }
}

class _StepResponsavel extends StatefulWidget {
  const _StepResponsavel({required this.onAvancar, required this.onVoltar});
  final VoidCallback onAvancar;
  final VoidCallback onVoltar;

  @override
  State<_StepResponsavel> createState() => _StepResponsavelState();
}

class _StepResponsavelState extends State<_StepResponsavel> {
  final _totem = Modular.get<TotemStore>();
  final _service = ClientService();
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');
  final _cpfCtrl = TextEditingController();
  bool _souTitular = true;
  PessoaModel? _pessoa;
  bool _loading = false;

  Future<void> _buscarCpf() async {
    final cpf = _cpfMask.getUnmaskedText();
    if (cpf.length != 11) { _snack('Informe um CPF válido'); return; }
    setState(() { _loading = true; _pessoa = null; });
    try {
      final p = await _service.buscarPorCpf(cpf);
      _pessoa = p.copyWith(cpf: cpf);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continuar() {
    if (_souTitular) {
      if (_totem.titular == null) { _snack('Titular não encontrado.'); return; }
      _totem.setResponsavelFinanceiro(_totem.titular);
    } else {
      if (_pessoa == null) { _snack('Busque o CPF do responsável.'); return; }
      _totem.setResponsavelFinanceiro(_pessoa);
    }
    widget.onAvancar();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _WizardCard(
      maxWidth: 700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleButtons(
            isSelected: [_souTitular, !_souTitular],
            borderRadius: BorderRadius.circular(100),
            selectedColor: cs.onPrimary,
            fillColor: cs.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            constraints: const BoxConstraints(minWidth: 150, minHeight: 40),
            children: const [Text('O titular'), Text('Outra pessoa')],
            onPressed: (i) => setState(() => _souTitular = (i == 0)),
          ),
          const SizedBox(height: 24),
          if (!_souTitular) ...[
            Row(
              children: [
                Expanded(child: TextFormField(controller: _cpfCtrl, inputFormatters: [FilteringTextInputFormatter.digitsOnly, _cpfMask], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CPF do responsável', prefixIcon: Icon(Icons.badge_outlined)), onFieldSubmitted: (_) => _loading ? null : _buscarCpf())),
                const SizedBox(width: 12),
                FilledButton.icon(onPressed: _loading ? null : _buscarCpf, icon: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search), label: const Text('Buscar'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24))),
              ],
            ),
            if (_pessoa != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Encontrado: ${_pessoa!.nome}')),
          ],
          if (_souTitular) Text('O titular, ${_totem.titular?.nome ?? ''}, será o responsável financeiro.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 32),
          _WizardActions(onVoltar: widget.onVoltar, onAvancar: _continuar),
        ],
      ),
    );
  }
}

class _StepResumo extends StatelessWidget {
  const _StepResumo({required this.onConfirm, required this.onVoltar});
  final VoidCallback onConfirm;
  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    final totem = Modular.get<TotemStore>();
    return _WizardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (totem.selectedPlan != null) ...[_ResumoTile(title: 'Plano', lines: [totem.selectedPlan!.nomeContrato, 'Mensalidade: R\$ ${totem.selectedPlan!.getMensalidade()}', 'Adesão: R\$ ${totem.selectedPlan!.getTaxaAdesao()}']), const Divider(height: 28)],
          _ResumoTile(title: 'Endereço', lines: [if (totem.endereco != null) '${totem.endereco!.logradouro ?? ''}, ${totem.endereco!.numero ?? ''} ${totem.endereco!.complemento?.isNotEmpty == true ? ' - ${totem.endereco!.complemento}' : ''}', if (totem.endereco != null) '${totem.endereco!.bairro ?? ''} - ${totem.endereco!.nomeCidade ?? ''}/${totem.endereco!.siglaUf ?? ''}']),
          const SizedBox(height: 16),
          _ResumoTile(title: 'Titular', lines: ['Nome: ${totem.titular?.nome ?? '-'}', 'CPF: ${totem.titular?.cpf ?? '-'}', 'Nascimento: ${totem.titular?.dataNascimento ?? '-'}' ]),
          const SizedBox(height: 16),
          _ResumoTile(title: 'Contatos', lines: totem.contatos.isEmpty ? ['Nenhum informado'] : totem.contatos.map((c) => c.idMeioComunicacao == 1 ? 'Celular: ${c.descricao}' : 'E-mail: ${c.descricao}').toList()),
          const SizedBox(height: 16),
          _ResumoTile(title: 'Responsável Financeiro', lines: [if (totem.titular != null && totem.responsavelFinanceiro != null && (totem.titular!.cpf ?? '') == (totem.responsavelFinanceiro!.cpf ?? '')) 'O titular' else 'Nome: ${totem.responsavelFinanceiro?.nome ?? '-'}\nCPF: ${totem.responsavelFinanceiro?.cpf ?? '-'}' ]),
          const SizedBox(height: 16),
          _ResumoTile(title: 'Dependentes', lines: totem.dependentes.isEmpty ? ['Nenhum'] : totem.dependentes.map((d) { final grau = _grauDependenciaList.firstWhere((g) => g.id == d.idGrauDependencia, orElse: () => GenericStateModel(name: '', id: 0)).name; return '${d.nome} ($grau)'; }).toList()),
          const SizedBox(height: 32),
          _WizardActions(onVoltar: onVoltar, onAvancar: onConfirm, labelAvancar: 'Confirmar Dados'),
        ],
      ),
    );
  }
}

class _ResumoTile extends StatelessWidget {
  const _ResumoTile({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...lines.where((l) => l.trim().isNotEmpty).map((l) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(l, style: t.bodyLarge))),
        ],
      ),
    );
  }
}


// =============================================================================
// COMPONENTES DE ESTILO
// =============================================================================

class _StepChips extends StatelessWidget {
  const _StepChips({required this.current, required this.onTap});
  final _Step current;
  final void Function(_Step) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(String text, _Step step, IconData icon) {
      final isCurrent = current == step;
      final isDone = current.index > step.index;
      
      final color = isCurrent ? cs.primary : (isDone ? cs.secondary.withOpacity(0.7) : cs.surfaceVariant.withOpacity(0.5));
      final onColor = isCurrent ? cs.onPrimary : (isDone ? cs.onSecondary : cs.onSurfaceVariant);

      return InkWell(
        onTap: () => onTap(step),
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Icon(isDone ? Icons.check_circle : icon, color: onColor, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: onColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          chip('Endereço', _Step.cep, Icons.location_on_outlined),
          chip('CPF', _Step.cpf, Icons.person_outline),
          chip('Contatos', _Step.contatos, Icons.phone_outlined),
          chip('Dependentes', _Step.dependentes, Icons.people_outline),
          chip('Responsável', _Step.responsavel, Icons.account_balance_wallet_outlined),
          chip('Resumo', _Step.resumo, Icons.playlist_add_check_rounded),
        ],
      ),
    );
  }
}

class _AnimatedBlobBackground extends StatefulWidget {
  const _AnimatedBlobBackground();

  @override
  State<_AnimatedBlobBackground> createState() => _AnimatedBlobBackgroundState();
}

class _AnimatedBlobBackgroundState extends State<_AnimatedBlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 26), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CustomPaint(
      painter: _BlobPainter(animation: _controller, color: color),
      size: Size.infinite,
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.animation, required this.color}) : super(repaint: animation);
  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.18);
    final t = animation.value;

    final pos1 = Offset(size.width * (0.2 + 0.2 * sin(t * pi * 2 + 0.5)), size.height * (0.3 - 0.2 * cos(t * pi * 2 + 0.5)));
    final r1 = size.width * (0.35 + 0.1 * sin(t * pi * 2));
    canvas.drawCircle(pos1, r1, paint);

    final pos2 = Offset(size.width * (0.8 - 0.15 * sin(t * pi * 1.5 + 1.0)), size.height * (0.7 + 0.15 * cos(t * pi * 1.5 + 1.0)));
    final r2 = size.width * (0.3 + 0.08 * cos(t * pi * 2.5));
    canvas.drawCircle(pos2, r2, paint);

    final pos3 = Offset(size.width * (0.6 + 0.2 * cos(t * pi * 2.2 + 2.0)), size.height * (0.1 + 0.1 * sin(t * pi * 2.2 + 2.0)));
    final r3 = size.width * (0.25 + 0.05 * sin(t * pi * 1.8));
    canvas.drawCircle(pos3, r3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}