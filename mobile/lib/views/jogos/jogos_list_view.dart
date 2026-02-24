import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/jogo_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/jogo.dart';
import 'package:fala_torcedor/views/jogos/jogo_detail_view.dart';
import 'package:fala_torcedor/views/jogos/jogo_form_view.dart';
import 'package:intl/intl.dart';

class JogosListView extends StatefulWidget {
  const JogosListView({super.key});

  @override
  State<JogosListView> createState() => _JogosListViewState();
}

class _JogosListViewState extends State<JogosListView> {
  final _controller = JogoController();
  final _buscaCtrl = TextEditingController();
  final _formatadorData = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _buscaCtrl.addListener(_onUpdate);
    _controller.carregarJogos();
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

  List<Jogo> get _jogosFiltrados {
    var lista = _controller.jogos.toList();

    final busca = _buscaCtrl.text.toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista
          .where(
            (j) =>
                (j.equipeANome?.toLowerCase().contains(busca) ?? false) ||
                (j.equipeBNome?.toLowerCase().contains(busca) ?? false),
          )
          .toList();
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jogos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const JogoFormView()),
          );
          if (criou == true) _controller.carregarJogos();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _buscaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por equipe...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _buscaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => _buscaCtrl.clear(),
                      )
                    : null,
              ),
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _controller.erro!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _controller.carregarJogos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final jogos = _jogosFiltrados;

    if (jogos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.sports_score_rounded,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _controller.jogos.isEmpty
                  ? 'Nenhum jogo cadastrado'
                  : 'Nenhum jogo encontrado',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarJogos(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: jogos.length,
        itemBuilder: (context, index) => _JogoCard(
          jogo: jogos[index],
          formatarData: _formatadorData.format,
          onTap: () async {
            final alterou = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => JogoDetailView(jogo: jogos[index]),
              ),
            );
            if (alterou == true) _controller.carregarJogos();
          },
        ),
      ),
    );
  }
}

class _JogoCard extends StatelessWidget {
  final Jogo jogo;
  final String Function(DateTime) formatarData;
  final VoidCallback onTap;

  const _JogoCard({
    required this.jogo,
    required this.formatarData,
    required this.onTap,
  });

  Color get _corVencedor => switch (jogo.vencedor) {
    'equipe_a' => AppColors.primary,
    'equipe_b' => AppColors.secondary,
    _ => AppColors.warning,
  };

  String get _textoVencedor => switch (jogo.vencedor) {
    'equipe_a' => jogo.equipeANome ?? 'Equipe A',
    'equipe_b' => jogo.equipeBNome ?? 'Equipe B',
    _ => 'Empate',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${formatarData(jogo.data)} • ${jogo.hora}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _corVencedor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _textoVencedor,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _corVencedor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        jogo.equipeANome ?? '—',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: jogo.vencedor == 'equipe_a'
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.jogos, AppColors.jogosLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          jogo.placar,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        jogo.equipeBNome ?? '—',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: jogo.vencedor == 'equipe_b'
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
