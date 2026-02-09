import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/views/equipes/equipe_form_view.dart';
import 'package:fala_torcedor/views/equipes/equipe_detail_view.dart';

class EquipesListView extends StatefulWidget {
  const EquipesListView({super.key});

  @override
  State<EquipesListView> createState() => _EquipesListViewState();
}

class _EquipesListViewState extends State<EquipesListView> {
  final _controller = EquipeController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _controller.carregarEquipes();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const EquipeFormView()),
          );
          if (criou == true) _controller.carregarEquipes();
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_controller.erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.carregarEquipes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_controller.equipes.isEmpty) {
      return const Center(
        child: Text('Nenhuma equipe cadastrada.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.equipes.length,
      itemBuilder: (context, index) {
        final equipe = _controller.equipes[index];
        return _EquipeCard(
          equipe: equipe,
          onTap: () async {
            final atualizou = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => EquipeDetailView(equipe: equipe),
              ),
            );
            if (atualizou == true) _controller.carregarEquipes();
          },
        );
      },
    );
  }
}

class _EquipeCard extends StatelessWidget {
  final Equipe equipe;
  final VoidCallback onTap;

  const _EquipeCard({required this.equipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.shield)),
        title: Text(equipe.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${equipe.serie} • ${equipe.qtdSocios} sócios'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
