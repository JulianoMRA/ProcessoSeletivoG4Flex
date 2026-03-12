import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/jogo_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/empty_state.dart';
import 'package:fala_torcedor/core/shimmer_loading.dart';
import 'package:fala_torcedor/core/staggered_list_item.dart';
import 'package:fala_torcedor/models/jogo.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/views/jogos/jogo_detail_view.dart';
import 'package:fala_torcedor/views/jogos/jogo_form_view.dart';
import 'package:intl/intl.dart';

enum OrdenacaoJogo { data, placar }

class JogosListView extends StatefulWidget {
  const JogosListView({super.key});

  @override
  State<JogosListView> createState() => _JogosListViewState();
}

class _JogosListViewState extends State<JogosListView> {
  final _controller = JogoController();
  final _buscaCtrl = TextEditingController();
  final _formatadorData = DateFormat('dd/MM/yyyy');

  String? _filtroEquipeId;
  String? _filtroResultado; // 'vitoria', 'empate', null
  OrdenacaoJogo _ordenacao = OrdenacaoJogo.data;
  bool _ordemCrescente = false;

  List<Equipe> _equipes = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _buscaCtrl.addListener(_onUpdate);
    _controller.carregarJogos();
    _controller.carregarEquipes().then((_) {
      setState(() => _equipes = _controller.equipes);
    });
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

  bool get _temFiltrosAtivos =>
      _filtroEquipeId != null ||
      _filtroResultado != null ||
      _ordenacao != OrdenacaoJogo.data ||
      _ordemCrescente;

  List<Jogo> get _jogosFiltrados {
    var lista = _controller.jogos.toList();

    // Filtro por busca
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

    // Filtro por equipe
    if (_filtroEquipeId != null) {
      lista = lista
          .where(
            (j) =>
                j.equipeAId == _filtroEquipeId ||
                j.equipeBId == _filtroEquipeId,
          )
          .toList();
    }

    // Filtro por resultado
    if (_filtroResultado == 'vitoria') {
      lista = lista
          .where((j) => j.vencedor == 'equipe_a' || j.vencedor == 'equipe_b')
          .toList();
    } else if (_filtroResultado == 'empate') {
      lista = lista.where((j) => j.vencedor == 'empate').toList();
    }

    // Ordenação
    lista.sort((a, b) {
      int resultado;
      switch (_ordenacao) {
        case OrdenacaoJogo.data:
          resultado = a.data.compareTo(b.data);
        case OrdenacaoJogo.placar:
          final totalA = a.golsEquipeA + a.golsEquipeB;
          final totalB = b.golsEquipeA + b.golsEquipeB;
          resultado = totalA.compareTo(totalB);
      }
      return _ordemCrescente ? resultado : -resultado;
    });

    return lista;
  }

  void _mostrarOpcoesFiltro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  const Icon(Icons.tune_rounded, color: AppColors.jogos),
                  const SizedBox(width: 10),
                  Text(
                    'Filtros e Ordenação',
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
                        _filtroEquipeId = null;
                        _filtroResultado = null;
                        _ordenacao = OrdenacaoJogo.data;
                        _ordemCrescente = false;
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
                'Equipe',
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
                  _buildFilterChip(
                    label: 'Todas',
                    icon: Icons.sports_score_rounded,
                    selected: _filtroEquipeId == null,
                    onTap: () {
                      setModalState(() => _filtroEquipeId = null);
                      setState(() {});
                    },
                  ),
                  ..._equipes.map(
                    (e) => _buildFilterChip(
                      label: e.nome,
                      icon: Icons.shield_rounded,
                      selected: _filtroEquipeId == e.id,
                      onTap: () {
                        setModalState(() => _filtroEquipeId = e.id);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filtro por resultado
              Text(
                'Resultado',
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
                  _buildFilterChip(
                    label: 'Todos',
                    icon: Icons.sports_score_rounded,
                    selected: _filtroResultado == null,
                    onTap: () {
                      setModalState(() => _filtroResultado = null);
                      setState(() {});
                    },
                  ),
                  _buildFilterChip(
                    label: 'Vitórias',
                    icon: Icons.emoji_events_rounded,
                    selected: _filtroResultado == 'vitoria',
                    onTap: () {
                      setModalState(() => _filtroResultado = 'vitoria');
                      setState(() {});
                    },
                  ),
                  _buildFilterChip(
                    label: 'Empates',
                    icon: Icons.handshake_rounded,
                    selected: _filtroResultado == 'empate',
                    onTap: () {
                      setModalState(() => _filtroResultado = 'empate');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                  _buildFilterChip(
                    label: 'Data',
                    icon: Icons.calendar_today_rounded,
                    selected: _ordenacao == OrdenacaoJogo.data,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoJogo.data);
                      setState(() {});
                    },
                  ),
                  _buildFilterChip(
                    label: 'Placar',
                    icon: Icons.sports_soccer_rounded,
                    selected: _ordenacao == OrdenacaoJogo.placar,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoJogo.placar);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
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

  Widget _buildFilterChip({
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
              ? AppColors.jogos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogos'),
        actions: [
          Badge(
            isLabelVisible: _temFiltrosAtivos,
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Filtros',
              onPressed: _mostrarOpcoesFiltro,
            ),
          ),
        ],
      ),
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
      return EmptyState(
        icon: Icons.sports_score_rounded,
        titulo: _controller.jogos.isEmpty
            ? 'Nenhum jogo cadastrado'
            : 'Nenhum jogo encontrado',
        subtitulo: _controller.jogos.isEmpty
            ? 'Registre o primeiro jogo para começar'
            : 'Tente ajustar os filtros de busca',
        botaoTexto: _controller.jogos.isEmpty ? 'Registrar jogo' : null,
        onBotao: _controller.jogos.isEmpty
            ? () async {
                final criou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const JogoFormView()),
                );
                if (criou == true) _controller.carregarJogos();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarJogos(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: jogos.length,
        itemBuilder: (context, index) => StaggeredListItem(
          index: index,
          child: _JogoCard(
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
    final cs = Theme.of(context).colorScheme;
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
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${formatarData(jogo.data)} • ${jogo.hora}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (jogo.campeonatoNome != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '• ${jogo.campeonatoNome}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.campeonatos,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                          color: cs.onSurface,
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
                          color: cs.onSurface,
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
