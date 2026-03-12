import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/campeonato_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/snackbar.dart';
import 'package:fala_torcedor/models/campeonato.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/services/api_service.dart';

class CampeonatoFormView extends StatefulWidget {
  final Campeonato? campeonato;

  const CampeonatoFormView({super.key, this.campeonato});

  @override
  State<CampeonatoFormView> createState() => _CampeonatoFormViewState();
}

class _CampeonatoFormViewState extends State<CampeonatoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = CampeonatoController();
  final _api = ApiService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _temporadaCtrl;
  bool _salvando = false;
  bool _carregando = true;
  bool _modificado = false;

  List<Equipe> _todasEquipes = [];
  final Set<String> _equipesSelecionadas = {};

  bool get _editando => widget.campeonato != null;

  @override
  void initState() {
    super.initState();
    final c = widget.campeonato;
    _nomeCtrl = TextEditingController(text: c?.nome ?? '');
    _temporadaCtrl = TextEditingController(
      text: c?.temporada ?? DateTime.now().year.toString(),
    );

    _nomeCtrl.addListener(_marcarModificado);
    _temporadaCtrl.addListener(_marcarModificado);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      _todasEquipes = await _api.getEquipes();

      if (_editando) {
        final completo = await _api.getCampeonatoById(widget.campeonato!.id!);
        for (final eq in completo.equipes) {
          _equipesSelecionadas.add(eq.id!);
        }
      }
    } catch (e) {
      // silently handle
    }

    if (mounted) setState(() => _carregando = false);
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _temporadaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_equipesSelecionadas.length < 2) {
      AppSnackBar.info(context, 'Selecione pelo menos duas equipes');
      return;
    }

    setState(() => _salvando = true);

    final campeonato = Campeonato(
      nome: _nomeCtrl.text.trim(),
      temporada: _temporadaCtrl.text.trim(),
    );

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarCampeonato(
        widget.campeonato!.id!,
        campeonato,
        _equipesSelecionadas.toList(),
      );
    } else {
      sucesso = await _controller.criarCampeonato(
        campeonato,
        _equipesSelecionadas.toList(),
      );
    }

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      AppSnackBar.sucesso(
        context,
        _editando ? 'Campeonato atualizado!' : 'Campeonato criado!',
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      AppSnackBar.erro(context, _controller.erro ?? 'Erro desconhecido');
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
        appBar: AppBar(
          title: Text(_editando ? 'Editar Campeonato' : 'Novo Campeonato'),
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Informações'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome do campeonato',
                          prefixIcon: Icon(Icons.emoji_events_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _temporadaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Temporada',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe a temporada'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Equipes participantes'),
                      const SizedBox(height: 4),
                      Text(
                        'Selecione pelo menos 2 equipes',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEquipesSelection(),
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
                                    : 'Criar campeonato',
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

  Widget _buildEquipesSelection() {
    if (_todasEquipes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhuma equipe cadastrada.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _todasEquipes.map((equipe) {
        final selecionada = _equipesSelecionadas.contains(equipe.id);
        return FilterChip(
          label: Text(equipe.nome),
          selected: selecionada,
          showCheckmark: true,
          selectedColor: AppColors.campeonatos.withValues(alpha: 0.15),
          checkmarkColor: AppColors.campeonatos,
          labelStyle: TextStyle(
            fontWeight: selecionada ? FontWeight.w600 : FontWeight.w400,
            color: selecionada
                ? AppColors.campeonatos
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _equipesSelecionadas.add(equipe.id!);
              } else {
                _equipesSelecionadas.remove(equipe.id!);
              }
              _modificado = true;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.campeonatos,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
