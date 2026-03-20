import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/empty_state.dart';
import 'package:fala_torcedor/core/shimmer_loading.dart';
import 'package:fala_torcedor/core/staggered_list_item.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/views/equipes/equipe_form_view.dart';
import 'package:fala_torcedor/views/equipes/equipe_detail_view.dart';

enum OrdenacaoEquipe { nome, socios }

class EquipesListView extends StatefulWidget {
  const EquipesListView({super.key});

  @override
  State<EquipesListView> createState() => _EquipesListViewState();
}

class _EquipesListViewState extends State<EquipesListView> {
  final _controller = EquipeController();
  final _buscaCtrl = TextEditingController();

  OrdenacaoEquipe _ordenacao = OrdenacaoEquipe.nome;
  bool _ordemCrescente = true;

  List<Equipe> get _equipesFiltradas {
    var lista = _controller.equipes.toList();

    // Filtro por busca
    final busca = _buscaCtrl.text.toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista.where((e) => e.nome.toLowerCase().contains(busca)).toList();
    }

    // Ordenação
    lista.sort((a, b) {
      int resultado;
      switch (_ordenacao) {
        case OrdenacaoEquipe.nome:
          resultado = a.nome.compareTo(b.nome);
        case OrdenacaoEquipe.socios:
          resultado = a.qtdSocios.compareTo(b.qtdSocios);
      }
      return _ordemCrescente ? resultado : -resultado;
    });

    return lista;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _buscaCtrl.addListener(_onUpdate);
    _controller.carregarEquipes();
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

  void _mostrarOpcoesFiltro() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Filtros e ordenação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _ordenacao = OrdenacaoEquipe.nome;
                        _ordemCrescente = true;
                      });
                      setState(() {});
                    },
                    child: const Text('Limpar'),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Ordenação
              Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortOption(
                    label: 'Nome',
                    icon: Icons.sort_by_alpha_rounded,
                    selected: _ordenacao == OrdenacaoEquipe.nome,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoEquipe.nome);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    label: 'Sócios',
                    icon: Icons.people_rounded,
                    selected: _ordenacao == OrdenacaoEquipe.socios,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoEquipe.socios);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Direção
              Row(
                children: [
                  Text(
                    'Direção',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.arrow_upward_rounded, size: 18),
                        label: Text('Crescente'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.arrow_downward_rounded, size: 18),
                        label: Text('Decrescente'),
                      ),
                    ],
                    selected: {_ordemCrescente},
                    onSelectionChanged: (v) {
                      setModalState(() => _ordemCrescente = v.first);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _temFiltrosAtivos =>
      _ordenacao != OrdenacaoEquipe.nome ||
      !_ordemCrescente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipes'),
        actions: [
          Badge(
            isLabelVisible: _temFiltrosAtivos,
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Filtros e ordenação',
              onPressed: _mostrarOpcoesFiltro,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const EquipeFormView()),
          );
          if (criou == true) _controller.carregarEquipes();
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
                hintText: 'Buscar equipe...',
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
          if (_temFiltrosAtivos) _buildActiveFilters(),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _descricaoFiltros(),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _ordenacao = OrdenacaoEquipe.nome;
              _ordemCrescente = true;
            }),
            child: const Text(
              'Limpar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _descricaoFiltros() {
    final ordenacaoTexto = switch (_ordenacao) {
      OrdenacaoEquipe.nome => 'Nome',
      OrdenacaoEquipe.socios => 'Sócios',
    };
    final direcao = _ordemCrescente ? '↑' : '↓';
    return '$ordenacaoTexto $direcao';
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
                onPressed: _controller.carregarEquipes,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final lista = _equipesFiltradas;

    if (lista.isEmpty) {
      return EmptyState(
        icon: Icons.shield_outlined,
        titulo: _controller.equipes.isEmpty
            ? 'Nenhuma equipe cadastrada'
            : 'Nenhuma equipe encontrada',
        subtitulo: _controller.equipes.isEmpty
            ? 'Cadastre a primeira equipe para começar'
            : 'Tente ajustar os filtros de busca',
        botaoTexto: _controller.equipes.isEmpty ? 'Cadastrar equipe' : null,
        onBotao: _controller.equipes.isEmpty
            ? () async {
                final criou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const EquipeFormView()),
                );
                if (criou == true) _controller.carregarEquipes();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarEquipes(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final equipe = lista[index];
          return StaggeredListItem(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EquipeCard(
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EquipeCard extends StatelessWidget {
  final Equipe equipe;
  final VoidCallback onTap;

  const _EquipeCard({required this.equipe, required this.onTap});

  String _initials(String nome) {
    final words = nome.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _colorFromName(String nome) {
    const palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.jogos,
      AppColors.campeonatos,
      AppColors.relatorios,
    ];
    final hash = nome.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarColor = _colorFromName(equipe.nome);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: avatarColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(equipe.nome),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: avatarColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipe.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${equipe.qtdSocios} sócios',
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
