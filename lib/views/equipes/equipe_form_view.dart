import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/equipe.dart';

class EquipeFormView extends StatefulWidget {
  final Equipe? equipe;

  const EquipeFormView({super.key, this.equipe});

  @override
  State<EquipeFormView> createState() => _EquipeFormViewState();
}

class _EquipeFormViewState extends State<EquipeFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = EquipeController();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _qtdSociosCtrl;
  late final TextEditingController _plano1Ctrl;
  late final TextEditingController _plano2Ctrl;
  late final TextEditingController _plano3Ctrl;

  String _serieSelecionada = 'Série A';
  bool _salvando = false;
  bool _modificado = false;

  bool get _editando => widget.equipe != null;

  static const _series = ['Série A', 'Série B', 'Série C', 'Série D'];

  @override
  void initState() {
    super.initState();
    final eq = widget.equipe;

    _nomeCtrl = TextEditingController(text: eq?.nome ?? '');
    _qtdSociosCtrl = TextEditingController(
      text: eq != null ? eq.qtdSocios.toString() : '',
    );
    _serieSelecionada = eq?.serie ?? 'Série A';

    _plano1Ctrl = TextEditingController(
      text: eq != null && eq.planos.isNotEmpty ? eq.planos[0].nome : '',
    );
    _plano2Ctrl = TextEditingController(
      text: eq != null && eq.planos.length > 1 ? eq.planos[1].nome : '',
    );
    _plano3Ctrl = TextEditingController(
      text: eq != null && eq.planos.length > 2 ? eq.planos[2].nome : '',
    );

    _nomeCtrl.addListener(_marcarModificado);
    _qtdSociosCtrl.addListener(_marcarModificado);
    _plano1Ctrl.addListener(_marcarModificado);
    _plano2Ctrl.addListener(_marcarModificado);
    _plano3Ctrl.addListener(_marcarModificado);
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _qtdSociosCtrl.dispose();
    _plano1Ctrl.dispose();
    _plano2Ctrl.dispose();
    _plano3Ctrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final equipe = Equipe(
      nome: _nomeCtrl.text.trim(),
      serie: _serieSelecionada,
      qtdSocios: int.parse(_qtdSociosCtrl.text.trim()),
    );

    final planos = [
      _plano1Ctrl.text.trim(),
      _plano2Ctrl.text.trim(),
      _plano3Ctrl.text.trim(),
    ];

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarEquipe(
        widget.equipe!.id!,
        equipe,
        planos,
      );
    } else {
      sucesso = await _controller.criarEquipe(equipe, planos);
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
        body: SingleChildScrollView(
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
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qtdSociosCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de sócios',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe a quantidade';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Número inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                _buildSectionTitle('Planos de sócio'),
                const SizedBox(height: 12),
                _buildPlanoField(_plano1Ctrl, 'Plano 1'),
                const SizedBox(height: 12),
                _buildPlanoField(_plano2Ctrl, 'Plano 2'),
                const SizedBox(height: 12),
                _buildPlanoField(_plano3Ctrl, 'Plano 3'),
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
                          _editando ? 'Salvar alterações' : 'Criar equipe',
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

  Widget _buildPlanoField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.card_membership_outlined),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Informe o nome do plano' : null,
    );
  }
}
