import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TorcedorFormView extends StatefulWidget {
  final Torcedor? torcedor;

  const TorcedorFormView({super.key, this.torcedor});

  @override
  State<TorcedorFormView> createState() => _TorcedorFormViewState();
}

class _TorcedorFormViewState extends State<TorcedorFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TorcedorController();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _cpfCtrl;
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  DateTime? _nascimento;
  Equipe? _equipeSelecionada;
  Plano? _planoSelecionado;
  bool _salvando = false;
  bool _carregando = true;
  bool _modificado = false;

  bool get _editando => widget.torcedor != null;

  @override
  void initState() {
    super.initState();
    final t = widget.torcedor;

    _nomeCtrl = TextEditingController(text: t?.nome ?? '');
    _cpfCtrl = TextEditingController();
    _nascimento = t?.nascimento;

    if (t != null) {
      _cpfMask.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: t.cpf),
      );
      _cpfCtrl.text = _cpfMask.getMaskedText();
    }

    _nomeCtrl.addListener(_marcarModificado);
    _cpfCtrl.addListener(_marcarModificado);

    _controller.addListener(_onUpdate);
    _carregarDados();
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  Future<void> _carregarDados() async {
    await _controller.carregarEquipes();

    if (_editando) {
      _equipeSelecionada = _controller.equipes
          .where((e) => e.id == widget.torcedor!.equipeId)
          .firstOrNull;

      if (_equipeSelecionada != null) {
        await _controller.carregarPlanos(_equipeSelecionada!.id!);
        _planoSelecionado = _controller.planosDisponiveis
            .where((p) => p.id == widget.torcedor!.planoId)
            .firstOrNull;
      }
    }

    setState(() => _carregando = false);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) {
      setState(() {
        _nascimento = data;
        _modificado = true;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }

    setState(() => _salvando = true);

    final cpfLimpo = _cpfMask.getUnmaskedText();

    final cpfDuplicado = await _controller.cpfJaExiste(
      cpfLimpo,
      ignorarId: _editando ? widget.torcedor!.id : null,
    );

    if (cpfDuplicado) {
      setState(() => _salvando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe um torcedor com este CPF')),
        );
      }
      return;
    }

    final torcedor = Torcedor(
      nome: _nomeCtrl.text.trim(),
      cpf: cpfLimpo,
      nascimento: _nascimento!,
      equipeId: _equipeSelecionada!.id!,
      planoId: _planoSelecionado!.id!,
    );

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarTorcedor(
        widget.torcedor!.id!,
        torcedor,
      );
    } else {
      sucesso = await _controller.criarTorcedor(torcedor);
    }

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando ? 'Torcedor atualizado!' : 'Torcedor criado!'),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.erro ?? 'Erro desconhecido')),
      );
    }
  }

  Future<bool> _confirmarSaida() async {
    if (!_modificado) return true;

    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('Você tem alterações não salvas. Deseja descartá-las?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return sair ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_modificado,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final sair = await _confirmarSaida();
        if (sair && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editando ? 'Editar Torcedor' : 'Novo Torcedor'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cpfCtrl,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          border: OutlineInputBorder(),
                          hintText: '000.000.000-00',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cpfMask],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe o CPF';
                          if (_cpfMask.getUnmaskedText().length != 11) {
                            return 'CPF deve ter 11 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _selecionarData,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _nascimento != null
                              ? DateFormat('dd/MM/yyyy').format(_nascimento!)
                              : 'Selecionar data de nascimento',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Equipe>(
                        initialValue: _equipeSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Equipe',
                          border: OutlineInputBorder(),
                        ),
                        items: _controller.equipes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.nome),
                                ))
                            .toList(),
                        onChanged: (equipe) {
                          setState(() {
                            _equipeSelecionada = equipe;
                            _planoSelecionado = null;
                            _controller.planosDisponiveis = [];
                            _modificado = true;
                          });
                          if (equipe != null) {
                            _controller.carregarPlanos(equipe.id!);
                          }
                        },
                        validator: (v) => v == null ? 'Selecione uma equipe' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Plano>(
                        initialValue: _planoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Plano de sócio',
                          border: OutlineInputBorder(),
                        ),
                        items: _controller.planosDisponiveis
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.nome),
                                ))
                            .toList(),
                        onChanged: (plano) {
                          setState(() {
                            _planoSelecionado = plano;
                            _modificado = true;
                          });
                        },
                        validator: (v) => v == null ? 'Selecione um plano' : null,
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _salvando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_editando ? 'Salvar alterações' : 'Criar torcedor'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
