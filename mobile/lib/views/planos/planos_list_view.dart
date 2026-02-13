import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/plano_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/views/planos/plano_detail_view.dart';
import 'package:fala_torcedor/views/planos/plano_form_view.dart';
import 'package:intl/intl.dart';

enum OrdenacaoPlano { nome, valor, equipe }

class PlanosListView extends StatefulWidget {
  const PlanosListView({super.key});

  @override
  State<PlanosListView> createState() => _PlanosListViewState();
}

class _PlanosListViewState extends State<PlanosListView> {
  final _controller = PlanoController();
  final _buscaCtrl = TextEditingController();

  String? _filtroEquipe;
  OrdenacaoPlano _ordenacao = OrdenacaoPlano.nome;
  bool _ordemCrescente = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _buscaCtrl.addListener(_onUpdate);
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
    var lista = _controller.planos.toList();

    // Filtro por equipe
    if (_filtroEquipe != null) {
      lista = lista.where((p) => p.equipeNome == _filtroEquipe).toList();
    }

    // Filtro por busca
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

    // Ordenação
    lista.sort((a, b) {
      int resultado;
      switch (_ordenacao) {
        case OrdenacaoPlano.nome:
          resultado = a.nome.compareTo(b.nome);
        case OrdenacaoPlano.valor:
          resultado = a.valor.compareTo(b.valor);
        case OrdenacaoPlano.equipe:
          resultado = (a.equipeNome ?? '').compareTo(b.equipeNome ?? '');
      }
      return _ordemCrescente ? resultado : -resultado;
    });

    return lista;
  }

  List<String> get _equipes {
    final nomes = _controller.planos
        .where((p) => p.equipeNome != null)
        .map((p) => p.equipeNome!)
        .toSet()
        .toList();
    nomes.sort();
    return nomes;
  }

  String _formatarValor(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }

  bool get _temFiltrosAtivos =>
      _filtroEquipe != null ||
      _ordenacao != OrdenacaoPlano.nome ||
      !_ordemCrescente;

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
                  const Text(
                    'Filtros e ordenação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _filtroEquipe = null;
                        _ordenacao = OrdenacaoPlano.nome;
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
              const Text(
                'Filtrar por equipe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'Todas',
                    selected: _filtroEquipe == null,
                    onTap: () {
                      setModalState(() => _filtroEquipe = null);
                      setState(() {});
                    },
                  ),
                  ..._equipes.map(
                    (equipe) => _buildFilterChip(
                      label: equipe,
                      selected: _filtroEquipe == equipe,
                      onTap: () {
                        setModalState(() => _filtroEquipe = equipe);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ordenação
              const Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip(
                    label: 'Nome',
                    icon: Icons.sort_by_alpha_rounded,
                    selected: _ordenacao == OrdenacaoPlano.nome,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoPlano.nome);
                      setState(() {});
                    },
                  ),
                  _buildSortChip(
                    label: 'Valor',
                    icon: Icons.attach_money,
                    selected: _ordenacao == OrdenacaoPlano.valor,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoPlano.valor);
                      setState(() {});
                    },
                  ),
                  _buildSortChip(
                    label: 'Equipe',
                    icon: Icons.shield_rounded,
                    selected: _ordenacao == OrdenacaoPlano.equipe,
                    onTap: () {
                      setModalState(() => _ordenacao = OrdenacaoPlano.equipe);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Direção
              Row(
                children: [
                  const Text(
                    'Direção',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip({
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
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _descricaoFiltros() {
    final partes = <String>[];
    if (_filtroEquipe != null) partes.add(_filtroEquipe!);
    final ordenacaoTexto = switch (_ordenacao) {
      OrdenacaoPlano.nome => 'Nome',
      OrdenacaoPlano.valor => 'Valor',
      OrdenacaoPlano.equipe => 'Equipe',
    };
    final direcao = _ordemCrescente ? '↑' : '↓';
    partes.add('$ordenacaoTexto $direcao');
    return partes.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos'),
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
            MaterialPageRoute(builder: (_) => const PlanoFormView()),
          );
          if (criou == true) _controller.carregarPlanos();
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
          const Icon(
            Icons.filter_list_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _descricaoFiltros(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _filtroEquipe = null;
              _ordenacao = OrdenacaoPlano.nome;
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
                onPressed: _controller.carregarPlanos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final planos = _planosFiltrados;

    if (planos.isEmpty) {
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
                Icons.card_membership_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _controller.planos.isEmpty
                  ? 'Nenhum plano cadastrado'
                  : 'Nenhum plano encontrado',
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
      onRefresh: () => _controller.carregarPlanos(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plano.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formatarValor(plano.valor),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            plano.equipeNome ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
