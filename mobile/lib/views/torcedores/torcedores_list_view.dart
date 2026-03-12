import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/empty_state.dart';
import 'package:fala_torcedor/core/shimmer_loading.dart';
import 'package:fala_torcedor/core/staggered_list_item.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_form_view.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_detail_view.dart';

enum OrdenacaoTorcedor { nome, nascimento, equipe }

class TorcedoresListView extends StatefulWidget {
  const TorcedoresListView({super.key});

  @override
  State<TorcedoresListView> createState() => _TorcedoresListViewState();
}

class _TorcedoresListViewState extends State<TorcedoresListView> {
  final _controller = TorcedorController();
  final _buscaCtrl = TextEditingController();

  Equipe? _filtroEquipe;
  String? _filtroPlano;
  OrdenacaoTorcedor _ordenacao = OrdenacaoTorcedor.nome;
  bool _ordemCrescente = true;

  List<Torcedor> get _torcedoresFiltrados {
    var lista = _controller.torcedores.toList();

    // Filtro por equipe
    if (_filtroEquipe != null) {
      lista = lista.where((t) => t.equipeId == _filtroEquipe!.id).toList();
    }

    // Filtro por plano
    if (_filtroPlano != null) {
      lista = lista.where((t) => t.plano?.nome == _filtroPlano).toList();
    }

    // Filtro por busca
    final busca = _buscaCtrl.text.toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista
          .where(
            (t) =>
                t.nome.toLowerCase().contains(busca) ||
                (t.equipe?.nome.toLowerCase().contains(busca) ?? false),
          )
          .toList();
    }

    // Ordenação
    lista.sort((a, b) {
      int resultado;
      switch (_ordenacao) {
        case OrdenacaoTorcedor.nome:
          resultado = a.nome.compareTo(b.nome);
        case OrdenacaoTorcedor.nascimento:
          resultado = a.nascimento.compareTo(b.nascimento);
        case OrdenacaoTorcedor.equipe:
          resultado = (a.equipe?.nome ?? '').compareTo(b.equipe?.nome ?? '');
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
    _controller.carregarTorcedores();
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
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
                          _filtroEquipe = null;
                          _filtroPlano = null;
                          _ordenacao = OrdenacaoTorcedor.nome;
                          _ordemCrescente = true;
                        });
                        setState(() {});
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filtro por equipe
                Text(
                  'Filtrar por equipe',
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
                    _buildFilterOption(
                      label: 'Todas',
                      selected: _filtroEquipe == null,
                      onTap: () {
                        setModalState(() => _filtroEquipe = null);
                        setState(() {});
                      },
                    ),
                    ..._controller.equipes.map(
                      (eq) => _buildFilterOption(
                        label: eq.nome,
                        selected: _filtroEquipe?.id == eq.id,
                        color: AppColors.primary,
                        onTap: () {
                          setModalState(() => _filtroEquipe = eq);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Filtro por plano
                Text(
                  'Filtrar por plano',
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
                    _buildFilterOption(
                      label: 'Todos',
                      selected: _filtroPlano == null,
                      onTap: () {
                        setModalState(() => _filtroPlano = null);
                        setState(() {});
                      },
                    ),
                    ..._controller.torcedores
                        .where((t) => t.plano != null)
                        .map((t) => t.plano!.nome)
                        .toSet()
                        .map(
                          (nome) => _buildFilterOption(
                            label: nome,
                            selected: _filtroPlano == nome,
                            color: AppColors.secondary,
                            onTap: () {
                              setModalState(() => _filtroPlano = nome);
                              setState(() {});
                            },
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 24),

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
                      selected: _ordenacao == OrdenacaoTorcedor.nome,
                      onTap: () {
                        setModalState(
                          () => _ordenacao = OrdenacaoTorcedor.nome,
                        );
                        setState(() {});
                      },
                    ),
                    _buildSortOption(
                      label: 'Idade',
                      icon: Icons.cake_rounded,
                      selected: _ordenacao == OrdenacaoTorcedor.nascimento,
                      onTap: () {
                        setModalState(
                          () => _ordenacao = OrdenacaoTorcedor.nascimento,
                        );
                        setState(() {});
                      },
                    ),
                    _buildSortOption(
                      label: 'Equipe',
                      icon: Icons.shield_rounded,
                      selected: _ordenacao == OrdenacaoTorcedor.equipe,
                      onTap: () {
                        setModalState(
                          () => _ordenacao = OrdenacaoTorcedor.equipe,
                        );
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
                          label: Text('A-Z'),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.arrow_downward_rounded, size: 18),
                          label: Text('Z-A'),
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
      ),
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool selected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? chipColor
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
      _filtroEquipe != null ||
      _ordenacao != OrdenacaoTorcedor.nome ||
      !_ordemCrescente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torcedores'),
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
            MaterialPageRoute(builder: (_) => const TorcedorFormView()),
          );
          if (criou == true) _controller.carregarTorcedores();
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
                hintText: 'Buscar por nome ou equipe...',
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _filtroEquipe = null;
              _ordenacao = OrdenacaoTorcedor.nome;
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
    final partes = <String>[];

    if (_filtroEquipe != null) {
      partes.add(_filtroEquipe!.nome);
    }

    final ordenacaoTexto = switch (_ordenacao) {
      OrdenacaoTorcedor.nome => 'Nome',
      OrdenacaoTorcedor.nascimento => 'Idade',
      OrdenacaoTorcedor.equipe => 'Equipe',
    };
    final direcao = _ordemCrescente ? '↑' : '↓';
    partes.add('$ordenacaoTexto $direcao');

    return partes.join(' • ');
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
                onPressed: _controller.carregarTorcedores,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final lista = _torcedoresFiltrados;

    if (lista.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline_rounded,
        titulo: _controller.torcedores.isEmpty
            ? 'Nenhum torcedor cadastrado'
            : 'Nenhum torcedor encontrado',
        subtitulo: _controller.torcedores.isEmpty
            ? 'Cadastre o primeiro torcedor para começar'
            : 'Tente ajustar os filtros de busca',
        botaoTexto: _controller.torcedores.isEmpty
            ? 'Cadastrar torcedor'
            : null,
        onBotao: _controller.torcedores.isEmpty
            ? () async {
                final criou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const TorcedorFormView()),
                );
                if (criou == true) _controller.carregarTorcedores();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarTorcedores(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final torcedor = lista[index];
          return StaggeredListItem(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TorcedorCard(
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TorcedorCard extends StatelessWidget {
  final Torcedor torcedor;
  final VoidCallback onTap;

  const _TorcedorCard({required this.torcedor, required this.onTap});

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return nome[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final nomeEquipe = torcedor.equipe?.nome ?? 'Sem equipe';
    final nomePlano = torcedor.plano?.nome ?? 'Sem plano';

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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _iniciais(torcedor.nome),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                      torcedor.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$nomeEquipe  •  $nomePlano',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
