import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/plano_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/empty_state.dart';
import 'package:fala_torcedor/core/staggered_list_item.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/views/planos/plano_detail_view.dart';
import 'package:fala_torcedor/views/planos/plano_form_view.dart';
import 'package:intl/intl.dart';

enum OrdenacaoPlano { nome, valor }

class PlanosListView extends StatefulWidget {
  const PlanosListView({super.key});

  @override
  State<PlanosListView> createState() => _PlanosListViewState();
}

class _PlanosListViewState extends State<PlanosListView> {
  final _controller = PlanoController();
  final _buscaCtrl = TextEditingController();
  final _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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

    final busca = _buscaCtrl.text.toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista.where((p) => p.nome.toLowerCase().contains(busca)).toList();
    }

    lista.sort((a, b) {
      int resultado;
      switch (_ordenacao) {
        case OrdenacaoPlano.nome:
          resultado = a.nome.compareTo(b.nome);
        case OrdenacaoPlano.valor:
          resultado = a.valor.compareTo(b.valor);
      }
      return _ordemCrescente ? resultado : -resultado;
    });

    return lista;
  }

  bool get _temFiltrosAtivos =>
      _ordenacao != OrdenacaoPlano.nome || !_ordemCrescente;

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
                    'Ordenação',
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
                ],
              ),
              const SizedBox(height: 16),
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
              tooltip: 'Ordenação',
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
                hintText: 'Buscar por nome...',
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
      return EmptyState(
        icon: Icons.card_membership_outlined,
        titulo: _controller.planos.isEmpty
            ? 'Nenhum plano cadastrado'
            : 'Nenhum plano encontrado',
        subtitulo: _controller.planos.isEmpty
            ? 'Cadastre o primeiro plano para começar'
            : 'Tente ajustar os filtros de busca',
        botaoTexto: _controller.planos.isEmpty ? 'Cadastrar plano' : null,
        onBotao: _controller.planos.isEmpty
            ? () async {
                final criou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanoFormView()),
                );
                if (criou == true) _controller.carregarPlanos();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.carregarPlanos(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: planos.length,
        itemBuilder: (context, index) => StaggeredListItem(
          index: index,
          child: _PlanoCard(
            plano: planos[index],
            formatarValor: _formatador.format,
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
      ),
    );
  }
}

class _PlanoCard extends StatelessWidget {
  final Plano plano;
  final String Function(num) formatarValor;
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
