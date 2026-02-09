import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_form_view.dart';
import 'package:intl/intl.dart';

class TorcedorDetailView extends StatelessWidget {
  final Torcedor torcedor;

  const TorcedorDetailView({super.key, required this.torcedor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(torcedor.nome),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final editou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => TorcedorFormView(torcedor: torcedor),
                ),
              );
              if (editou == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('Nome', torcedor.nome),
            const SizedBox(height: 16),
            _buildInfo('CPF', _formatarCpf(torcedor.cpf)),
            const SizedBox(height: 16),
            _buildInfo(
              'Data de nascimento',
              DateFormat('dd/MM/yyyy').format(torcedor.nascimento),
            ),
            const SizedBox(height: 16),
            _buildInfo('Equipe', torcedor.equipe?.nome ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfo('Plano de sócio', torcedor.plano?.nome ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  String _formatarCpf(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir torcedor'),
        content: Text('Deseja excluir "${torcedor.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final controller = TorcedorController();
              final sucesso = await controller.excluirTorcedor(torcedor.id!);

              if (context.mounted) {
                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Torcedor excluído!')),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(controller.erro ?? 'Erro ao excluir')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
