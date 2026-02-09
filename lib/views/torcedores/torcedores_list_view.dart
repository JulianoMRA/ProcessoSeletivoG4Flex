import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_form_view.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_detail_view.dart';

class TorcedoresListView extends StatefulWidget {
  const TorcedoresListView({super.key});

  @override
  State<TorcedoresListView> createState() => _TorcedoresListViewState();
}

class _TorcedoresListViewState extends State<TorcedoresListView> {
  final _controller = TorcedorController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _controller.carregarTorcedores();
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
        title: const Text('Torcedores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TorcedorFormView()),
          );
          if (criou == true) _controller.carregarTorcedores();
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
              onPressed: _controller.carregarTorcedores,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_controller.torcedores.isEmpty) {
      return const Center(
        child: Text('Nenhum torcedor cadastrado.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.torcedores.length,
      itemBuilder: (context, index) {
        final torcedor = _controller.torcedores[index];
        return _TorcedorCard(
          torcedor: torcedor,
          onTap: () async {
            final atualizou = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => TorcedorDetailView(torcedor: torcedor),
              ),
            );
            if (atualizou == true) _controller.carregarTorcedores();
          },
        );
      },
    );
  }
}

class _TorcedorCard extends StatelessWidget {
  final Torcedor torcedor;
  final VoidCallback onTap;

  const _TorcedorCard({required this.torcedor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nomeEquipe = torcedor.equipe?.nome ?? 'Sem equipe';
    final nomePlano = torcedor.plano?.nome ?? 'Sem plano';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(torcedor.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$nomeEquipe • $nomePlano'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
