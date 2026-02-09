import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/views/equipes/equipe_form_view.dart';

class EquipeDetailView extends StatelessWidget {
  final Equipe equipe;

  const EquipeDetailView({super.key, required this.equipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipe.nome),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final editou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipeFormView(equipe: equipe),
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
            _buildInfo('Nome', equipe.nome),
            const SizedBox(height: 16),
            _buildInfo('Série', equipe.serie),
            const SizedBox(height: 16),
            _buildInfo('Sócios-torcedores', equipe.qtdSocios.toString()),
            const SizedBox(height: 24),
            Text(
              'Planos de sócio',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...equipe.planos.map(
              (plano) => Card(
                child: ListTile(
                  leading: const Icon(Icons.card_membership),
                  title: Text(plano.nome),
                ),
              ),
            ),
            if (equipe.planos.isEmpty)
              const Text('Nenhum plano cadastrado.',
                  style: TextStyle(color: Colors.grey)),
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

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir equipe'),
        content: Text(
          'Todos os torcedores e planos de "${equipe.nome}" serão excluídos. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final controller = EquipeController();
              final sucesso = await controller.excluirEquipe(equipe.id!);

              if (context.mounted) {
                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipe excluída!')),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(controller.erro ?? 'Erro ao excluir')),
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
