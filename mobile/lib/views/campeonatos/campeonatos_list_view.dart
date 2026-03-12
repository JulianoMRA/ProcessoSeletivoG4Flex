import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/campeonato_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/empty_state.dart';
import 'package:fala_torcedor/core/shimmer_loading.dart';
import 'package:fala_torcedor/core/staggered_list_item.dart';
import 'package:fala_torcedor/models/campeonato.dart';
import 'package:fala_torcedor/views/campeonatos/campeonato_form_view.dart';
import 'package:fala_torcedor/views/campeonatos/campeonato_detail_view.dart';

class CampeonatosListView extends StatefulWidget {
  const CampeonatosListView({super.key});

  @override
  State<CampeonatosListView> createState() => _CampeonatosListViewState();
}

class _CampeonatosListViewState extends State<CampeonatosListView> {
  final _controller = CampeonatoController();
  final _buscaCtrl = TextEditingController();

  List<Campeonato> get _campeonatosFiltrados {
    var lista = _controller.campeonatos.toList();
    final busca = _buscaCtrl.text.toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista
          .where(
            (c) =>
                c.nome.toLowerCase().contains(busca) ||
                c.temporada.toLowerCase().contains(busca),
          )
          .toList();
    }
    return lista;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _buscaCtrl.addListener(_onUpdate);
    _controller.carregarCampeonatos();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _buscaCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campeonatos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CampeonatoFormView()),
          );
          if (criou == true) _controller.carregarCampeonatos();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _buscaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar campeonato...',
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
      return ShimmerLoading.cards();
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
                onPressed: _controller.carregarCampeonatos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final lista = _campeonatosFiltrados;

    if (lista.isEmpty) {
      return EmptyState(
        icon: Icons.emoji_events_outlined,
        titulo: _controller.campeonatos.isEmpty
            ? 'Nenhum campeonato cadastrado'
            : 'Nenhum campeonato encontrado',
        subtitulo: _controller.campeonatos.isEmpty
            ? 'Cadastre o primeiro campeonato para começar'
            : 'Tente ajustar a busca',
        botaoTexto:
            _controller.campeonatos.isEmpty ? 'Cadastrar campeonato' : null,
        onBotao: _controller.campeonatos.isEmpty
            ? () async {
                final criou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CampeonatoFormView(),
                  ),
                );
                if (criou == true) _controller.carregarCampeonatos();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarCampeonatos(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final campeonato = lista[index];
          return StaggeredListItem(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CampeonatoCard(
                campeonato: campeonato,
                onTap: () async {
                  final atualizou = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CampeonatoDetailView(campeonato: campeonato),
                    ),
                  );
                  if (atualizou == true) _controller.carregarCampeonatos();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CampeonatoCard extends StatelessWidget {
  final Campeonato campeonato;
  final VoidCallback onTap;

  const _CampeonatoCard({required this.campeonato, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.campeonatos.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.campeonatos,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campeonato.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Temporada ${campeonato.temporada}',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
