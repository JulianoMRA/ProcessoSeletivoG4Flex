import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/plano_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/plano.dart';

class PlanoFormView extends StatefulWidget {
  final Plano? plano;

  const PlanoFormView({super.key, this.plano});

  @override
  State<PlanoFormView> createState() => _PlanoFormViewState();
}

class _PlanoFormViewState extends State<PlanoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = PlanoController();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _valorCtrl;
  bool _salvando = false;
  bool _modificado = false;

  bool get _editando => widget.plano != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plano;

    _nomeCtrl = TextEditingController(text: p?.nome ?? '');
    _valorCtrl = TextEditingController(
      text: p != null ? p.valor.toStringAsFixed(2) : '',
    );

    _nomeCtrl.addListener(_marcarModificado);
    _valorCtrl.addListener(_marcarModificado);
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final plano = Plano(
      nome: _nomeCtrl.text.trim(),
      valor: double.parse(_valorCtrl.text.trim()),
    );

    bool sucesso;
    if (_editando) {
      sucesso = await _controller.atualizarPlano(widget.plano!.id!, plano);
    } else {
      sucesso = await _controller.criarPlano(plano);
    }

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando ? 'Plano atualizado!' : 'Plano criado!'),
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
        appBar: AppBar(title: Text(_editando ? 'Editar Plano' : 'Novo Plano')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Informações do plano'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do plano',
                    prefixIcon: Icon(Icons.card_membership_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Valor mensal (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o valor';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
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
                          _editando ? 'Salvar alterações' : 'Criar plano',
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
            color: AppColors.accent,
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
