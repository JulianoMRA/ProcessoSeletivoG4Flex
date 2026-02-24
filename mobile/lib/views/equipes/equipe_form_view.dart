import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:intl/intl.dart';

class EquipeFormView extends StatefulWidget {
  final Equipe? equipe;

  const EquipeFormView({super.key, this.equipe});

  @override
  State<EquipeFormView> createState() => _EquipeFormViewState();
}

class _EquipeFormViewState extends State<EquipeFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = EquipeController();
  final _api = ApiService();
  final _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  late final TextEditingController _nomeCtrl;
  String _serieSelecionada = 'Série A';
  bool _salvando = false;
  bool _carregando = true;
  bool _modificado = false;

  List<Plano> _todosPlanos = [];
  final Set<String> _planosSelecionados = {};

  bool get _editando => widget.equipe != null;

  static const _series = ['Série A', 'Série B', 'Série C', 'Série D'];

  @override
  void initState() {
    super.initState();
    final eq = widget.equipe;

    _nomeCtrl = TextEditingController(text: eq?.nome ?? '');
    _serieSelecionada = eq?.serie ?? 'Série A';

    _nomeCtrl.addListener(_marcarModificado);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      _todosPlanos = await _api.getPlanos();

      if (_editando) {
        final equipeCompleta = await _api.getEquipeById(widget.equipe!.id!);
        for (final plano in equipeCompleta.planos) {
          _planosSelecionados.add(plano.id!);
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
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_planosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um plano')),
      );
      return;
    }

    setState(() => _salvando = true);

    final equipe = Equipe(
      nome: _nomeCtrl.text.trim(),
      serie: _serieSelecionada,
      qtdSocios: widget.equipe?.qtdSocios ?? 0,
    );

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarEquipe(
        widget.equipe!.id!,
        equipe,
        _planosSelecionados.toList(),
      );
    } else {
      sucesso = await _controller.criarEquipe(
        equipe,
        _planosSelecionados.toList(),
      );
    }

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando ? 'Equipe atualizada!' : 'Equipe criada!'),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.erro ?? 'Erro desconhecido')),
      );
    }
  }

  Future<void> _criarPlanoInline() async {
    final nomeCtrl = TextEditingController();
    final valorCtrl = TextEditingController();

    final criou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo plano'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome do plano',
                prefixIcon: Icon(Icons.card_membership_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valorCtrl,
              decoration: const InputDecoration(
                labelText: 'Valor mensal (R\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (nomeCtrl.text.trim().isEmpty ||
                  valorCtrl.text.trim().isEmpty ||
                  double.tryParse(valorCtrl.text.trim()) == null) {
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (criou == true) {
      final plano = Plano(
        nome: nomeCtrl.text.trim(),
        valor: double.parse(valorCtrl.text.trim()),
      );
      try {
        final novo = await _api.createPlano(plano);
        setState(() {
          _todosPlanos.add(novo);
          _planosSelecionados.add(novo.id!);
          _modificado = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Erro ao criar plano')));
        }
      }
    }

    nomeCtrl.dispose();
    valorCtrl.dispose();
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
          title: Text(_editando ? 'Editar Equipe' : 'Nova Equipe'),
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
                          labelText: 'Nome da equipe',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _serieSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Série',
                          prefixIcon: Icon(Icons.emoji_events_outlined),
                        ),
                        items: _series
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.corSerie(s),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    Text(s),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _serieSelecionada = v!;
                          _modificado = true;
                        }),
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Planos de sócio'),
                      const SizedBox(height: 4),
                      Text(
                        'Selecione os planos disponíveis para esta equipe',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPlanosSelection(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _criarPlanoInline,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Criar novo plano'),
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
                                    : 'Criar equipe',
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

  Widget _buildPlanosSelection() {
    if (_todosPlanos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhum plano cadastrado. Crie um abaixo.',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _todosPlanos.map((plano) {
        final selecionado = _planosSelecionados.contains(plano.id);
        return FilterChip(
          label: Text('${plano.nome} — ${_formatador.format(plano.valor)}'),
          selected: selecionado,
          showCheckmark: true,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
            color: selecionado ? AppColors.primary : AppColors.textSecondary,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _planosSelecionados.add(plano.id!);
              } else {
                _planosSelecionados.remove(plano.id!);
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
            color: AppColors.primary,
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
