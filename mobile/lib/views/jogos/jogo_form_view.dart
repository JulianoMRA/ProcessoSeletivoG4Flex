import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/jogo_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/jogo.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:intl/intl.dart';

class JogoFormView extends StatefulWidget {
  final Jogo? jogo;

  const JogoFormView({super.key, this.jogo});

  @override
  State<JogoFormView> createState() => _JogoFormViewState();
}

class _JogoFormViewState extends State<JogoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = JogoController();
  final _golsACtrl = TextEditingController();
  final _golsBCtrl = TextEditingController();

  DateTime? _data;
  TimeOfDay? _hora;
  Equipe? _equipeA;
  Equipe? _equipeB;
  bool _salvando = false;
  bool _carregando = true;
  bool _modificado = false;

  bool get _editando => widget.jogo != null;

  @override
  void initState() {
    super.initState();
    final j = widget.jogo;

    if (j != null) {
      _data = j.data;
      final partes = j.hora.split(':');
      _hora = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
      _golsACtrl.text = j.golsEquipeA.toString();
      _golsBCtrl.text = j.golsEquipeB.toString();
    }

    _golsACtrl.addListener(_marcarModificado);
    _golsBCtrl.addListener(_marcarModificado);
    _controller.addListener(_onUpdate);
    _carregarDados();
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  Future<void> _carregarDados() async {
    await _controller.carregarEquipes();

    if (_editando) {
      _equipeA = _controller.equipes
          .where((e) => e.id == widget.jogo!.equipeAId)
          .firstOrNull;
      _equipeB = _controller.equipes
          .where((e) => e.id == widget.jogo!.equipeBId)
          .firstOrNull;
    }

    setState(() => _carregando = false);
  }

  @override
  void dispose() {
    _golsACtrl.dispose();
    _golsBCtrl.dispose();
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
      initialDate: _data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) {
      setState(() {
        _data = data;
        _modificado = true;
      });
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _hora = hora;
        _modificado = true;
      });
    }
  }

  String _formatarHora(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_data == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione a data do jogo')));
      return;
    }
    if (_hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o horário do jogo')),
      );
      return;
    }

    setState(() => _salvando = true);

    final jogo = Jogo(
      data: _data!,
      hora: _formatarHora(_hora!),
      equipeAId: _equipeA!.id!,
      equipeBId: _equipeB!.id!,
      golsEquipeA: int.parse(_golsACtrl.text.trim()),
      golsEquipeB: int.parse(_golsBCtrl.text.trim()),
    );

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarJogo(widget.jogo!.id!, jogo);
    } else {
      sucesso = await _controller.criarJogo(jogo);
    }

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando ? 'Jogo atualizado!' : 'Jogo criado!'),
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
        content: const Text(
          'Você tem alterações não salvas. Deseja descartá-las?',
        ),
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
        appBar: AppBar(title: Text(_editando ? 'Editar Jogo' : 'Novo Jogo')),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Data e horário'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selecionarData,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_rounded,
                                  ),
                                ),
                                child: Text(
                                  _data != null
                                      ? DateFormat('dd/MM/yyyy').format(_data!)
                                      : 'Selecionar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _data != null
                                        ? AppColors.textPrimary
                                        : AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selecionarHora,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Horário',
                                  prefixIcon: Icon(Icons.access_time_rounded),
                                ),
                                child: Text(
                                  _hora != null
                                      ? _formatarHora(_hora!)
                                      : 'Selecionar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _hora != null
                                        ? AppColors.textPrimary
                                        : AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Equipes'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Equipe>(
                        value: _equipeA,
                        decoration: const InputDecoration(
                          labelText: 'Mandante (Equipe A)',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        items: _controller.equipes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (equipe) {
                          setState(() {
                            _equipeA = equipe;
                            _modificado = true;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Selecione o mandante' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Equipe>(
                        value: _equipeB,
                        decoration: const InputDecoration(
                          labelText: 'Visitante (Equipe B)',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        items: _controller.equipes
                            .where((e) => e.id != _equipeA?.id)
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (equipe) {
                          setState(() {
                            _equipeB = equipe;
                            _modificado = true;
                          });
                        },
                        validator: (v) {
                          if (v == null) return 'Selecione o visitante';
                          if (v.id == _equipeA?.id) {
                            return 'Deve ser diferente do mandante';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Placar'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _golsACtrl,
                              decoration: InputDecoration(
                                labelText:
                                    'Gols ${_equipeA?.nome ?? 'Mandante'}',
                                prefixIcon: const Icon(
                                  Icons.sports_soccer_rounded,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Informe';
                                }
                                if (int.tryParse(v.trim()) == null ||
                                    int.parse(v.trim()) < 0) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'x',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.jogos,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _golsBCtrl,
                              decoration: InputDecoration(
                                labelText:
                                    'Gols ${_equipeB?.nome ?? 'Visitante'}',
                                prefixIcon: const Icon(
                                  Icons.sports_soccer_rounded,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Informe';
                                }
                                if (int.tryParse(v.trim()) == null ||
                                    int.parse(v.trim()) < 0) {
                                  return 'Inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
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
                            : Text(
                                _editando
                                    ? 'Salvar alterações'
                                    : 'Registrar jogo',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.jogos,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
