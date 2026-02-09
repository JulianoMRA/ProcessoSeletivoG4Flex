import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:intl/intl.dart';

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

  DateTime? _nascimento;
  Equipe? _equipeSelecionada;
  Plano? _planoSelecionado;
  bool _salvando = false;
  bool _carregando = true;

  bool get _editando => widget.torcedor != null;

  @override
  void initState() {
    super.initState();
    final t = widget.torcedor;

    _nomeCtrl = TextEditingController(text: t?.nome ?? '');
    _cpfCtrl = TextEditingController(text: t?.cpf ?? '');
    _nascimento = t?.nascimento;

    _controller.addListener(_onUpdate);
    _carregarDados();
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
      setState(() => _nascimento = data);
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

    final torcedor = Torcedor(
      nome: _nomeCtrl.text.trim(),
      cpf: _cpfCtrl.text.trim(),
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
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.erro ?? 'Erro desconhecido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        hintText: '00000000000',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o CPF';
                        if (v.trim().length != 11) return 'CPF deve ter 11 dígitos';
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
                        setState(() => _planoSelecionado = plano);
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
    );
  }
}
