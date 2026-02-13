import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/plano_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/views/planos/plano_detail_view.dart';
import 'package:fala_torcedor/views/planos/plano_form_view.dart';
import 'package:intl/intl.dart';

class PlanosListView extends StatefulWidget {
  const PlanosListView({super.key});

  @override
  State<PlanosListView> createState() => _PlanosListViewState();
}

class _PlanosListViewState extends State<PlanosListView> {
  final _controller = PlanoController();
  final _buscaCtrl = TextEditingController();
  String _filtroEquipe = 'Todas';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _controller.carregarPlanos();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  List<Plano> get _planosFiltrados {
    var lista = _controller.planos;
    final busca = _buscaCtrl.text.toLowerCase();

    if (busca.isNotEmpty) {
      lista = lista
          .where(
            (p) =>
                p.nome.toLowerCase().contains(busca) ||
                (p.equipeNome?.toLowerCase().contains(busca) ?? false),
          )
          .toList();
    }

    if (_filtroEquipe != 'Todas') {
      lista = lista.where((p) => p.equipeNome == _filtroEquipe).toList();
    }

    return lista;
  }

  List<String> get _equipes {
    final nomes = _controller.planos
        .where((p) => p.equipeNome != null)
        .map((p) => p.equipeNome!)
        .toSet()
        .toList();
    nomes.sort();
    return ['Todas', ...nomes];
  }

  String _formatarValor(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PlanoFormView()),
          );
          if (criou == true) _controller.carregarPlanos();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _buscaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou equipe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _buscaCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _equipes
                  .map(
                    (equipe) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(equipe),
                        selected: _filtroEquipe == equipe,
                        onSelected: (_) =>
                            setState(() => _filtroEquipe = equipe),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_controller.erro!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _controller.carregarPlanos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final planos = _planosFiltrados;

    if (planos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum plano encontrado',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: planos.length,
      itemBuilder: (context, index) => _PlanoCard(
        plano: planos[index],
        formatarValor: _formatarValor,
        onTap: () async {
          final alterou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PlanoDetailView(plano: planos[index]),
            ),
          );
          if (alterou == true) _controller.carregarPlanos();
        },
      ),
    );
  }
}

class _PlanoCard extends StatelessWidget {
  final Plano plano;
  final String Function(double) formatarValor;
  final VoidCallback onTap;

  const _PlanoCard({
    required this.plano,
    required this.formatarValor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.card_membership_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          plano.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          plano.equipeNome ?? '',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: Text(
          formatarValor(plano.valor),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
