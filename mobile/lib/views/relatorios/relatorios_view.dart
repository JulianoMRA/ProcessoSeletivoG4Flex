import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/services/api_service.dart';

enum TipoVisualizacao { pizza, barras, lista }

class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<RelatoriosView> {
  final _api = ApiService();
  bool _carregando = true;
  String? _erro;
  TipoVisualizacao _tipo = TipoVisualizacao.pizza;

  // KPIs
  int _totalTorcedores = 0;
  int _mediaIdade = 0;
  int _totalGols = 0;
  int _totalJogos = 0;

  // Relatórios
  Map<String, int> _etaria = {};
  List<Map<String, dynamic>> _equipesCamp = [];
  List<Map<String, dynamic>> _jogosCamp = [];
  List<Map<String, dynamic>> _desempenho = [];

  final _coresEtaria = [
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
  ];

  final _coresCampeonato = [
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFEC4899),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
    const Color(0xFF6366F1),
    const Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final data = await _api.getRelatorios();

      // KPIs
      final kpis = data['kpis'] as Map<String, dynamic>;
      _totalTorcedores = (kpis['total_torcedores'] as num?)?.toInt() ?? 0;
      _mediaIdade = (kpis['media_idade'] as num?)?.toInt() ?? 0;
      _totalGols = (kpis['total_gols'] as num?)?.toInt() ?? 0;
      _totalJogos = (kpis['total_jogos'] as num?)?.toInt() ?? 0;

      // Distribuição etária
      final etariaRaw = data['distribuicao_etaria'] as Map<String, dynamic>;
      _etaria = {
        'Jovens (<20)': (etariaRaw['jovens'] as num).toInt(),
        'Adultos (20-59)': (etariaRaw['adultos'] as num).toInt(),
        'Idosos (60+)': (etariaRaw['idosos'] as num).toInt(),
      };

      // Equipes por campeonato (com nomes)
      _equipesCamp = (data['equipes_por_campeonato'] as List)
          .map((e) => {
                'label': e['campeonato'] as String,
                'total': (e['total'] as num).toInt(),
                'equipes': (e['equipes'] as List).cast<String>(),
              })
          .toList();

      // Jogos por campeonato
      _jogosCamp = (data['jogos_por_campeonato'] as List)
          .map((e) => {
                'label': e['campeonato'] as String,
                'total': (e['total'] as num).toInt(),
                'total_gols': (e['total_gols'] as num).toInt(),
              })
          .toList();

      // Desempenho
      _desempenho = (data['desempenho_equipes'] as List)
          .map((e) => {
                'equipe': e['equipe'] as String,
                'jogos': (e['jogos'] as num).toInt(),
                'vitorias': (e['vitorias'] as num).toInt(),
                'empates': (e['empates'] as num).toInt(),
                'derrotas': (e['derrotas'] as num).toInt(),
                'gols_pro': (e['gols_pro'] as num).toInt(),
                'gols_contra': (e['gols_contra'] as num).toInt(),
              })
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar relatórios';
    }

    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 12),
                      Text(_erro!),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _carregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildKpis(),
                        const SizedBox(height: 20),
                        _buildToggle(),
                        const SizedBox(height: 24),
                        _buildRelatorio(
                          titulo: 'Distribuição Etária',
                          icone: Icons.people_rounded,
                          cor: AppColors.secondary,
                          dados: _etaria.entries
                              .map((e) =>
                                  {'label': e.key, 'total': e.value})
                              .toList(),
                          cores: _coresEtaria,
                        ),
                        const SizedBox(height: 20),
                        _buildRelatorio(
                          titulo: 'Equipes por Campeonato',
                          icone: Icons.shield_rounded,
                          cor: AppColors.primary,
                          dados: _equipesCamp,
                          cores: _coresCampeonato,
                        ),
                        const SizedBox(height: 20),
                        _buildRelatorio(
                          titulo: 'Jogos por Campeonato',
                          icone: Icons.sports_score_rounded,
                          cor: AppColors.jogos,
                          dados: _jogosCamp,
                          cores: _coresCampeonato,
                        ),
                        const SizedBox(height: 20),
                        _buildDesempenho(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ======================== KPI CARDS ========================

  Widget _buildKpis() {
    return Row(
      children: [
        _buildKpiCard(
          icone: Icons.people_rounded,
          label: 'Torcedores',
          valor: '$_totalTorcedores',
          cor: AppColors.secondary,
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          icone: Icons.cake_rounded,
          label: 'Média Idade',
          valor: '$_mediaIdade anos',
          cor: AppColors.campeonatos,
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          icone: Icons.sports_soccer_rounded,
          label: 'Gols',
          valor: '$_totalGols',
          cor: AppColors.accent,
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          icone: Icons.stadium_rounded,
          label: 'Jogos',
          valor: '$_totalJogos',
          cor: AppColors.jogos,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icone,
    required String label,
    required String valor,
    required Color cor,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== TOGGLE ========================

  Widget _buildToggle() {
    return SegmentedButton<TipoVisualizacao>(
      segments: const [
        ButtonSegment(
          value: TipoVisualizacao.pizza,
          icon: Icon(Icons.pie_chart_rounded, size: 18),
          label: Text('Pizza'),
        ),
        ButtonSegment(
          value: TipoVisualizacao.barras,
          icon: Icon(Icons.bar_chart_rounded, size: 18),
          label: Text('Barras'),
        ),
        ButtonSegment(
          value: TipoVisualizacao.lista,
          icon: Icon(Icons.list_rounded, size: 18),
          label: Text('Lista'),
        ),
      ],
      selected: {_tipo},
      onSelectionChanged: (s) => setState(() => _tipo = s.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ======================== RELATÓRIO GENÉRICO ========================

  Widget _buildRelatorio({
    required String titulo,
    required IconData icone,
    required Color cor,
    required List<Map<String, dynamic>> dados,
    required List<Color> cores,
  }) {
    final total = dados.fold<int>(0, (s, d) => s + (d['total'] as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: cor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: $total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (total == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insert_chart_outlined_rounded,
                        size: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum dado disponível',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildVisualizacao(dados, cores, total),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizacao(
    List<Map<String, dynamic>> dados,
    List<Color> cores,
    int total,
  ) {
    Widget child;
    switch (_tipo) {
      case TipoVisualizacao.pizza:
        child = _buildPieChart(dados, cores, total);
      case TipoVisualizacao.barras:
        child = _buildBarChart(dados, cores);
      case TipoVisualizacao.lista:
        child = _buildListView(dados, cores, total);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey(_tipo),
        child: child,
      ),
    );
  }

  // ======================== PIE CHART ========================

  Widget _buildPieChart(
    List<Map<String, dynamic>> dados,
    List<Color> cores,
    int total,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: dados.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final value = (d['total'] as int).toDouble();
                final pct = total > 0 ? (value / total * 100) : 0;
                return PieChartSectionData(
                  value: value,
                  title: '${pct.toStringAsFixed(0)}%',
                  color: cores[i % cores.length],
                  radius: 55,
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {},
                enabled: true,
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 35,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegenda(dados, cores),
      ],
    );
  }

  // ======================== BAR CHART ========================

  Widget _buildBarChart(
    List<Map<String, dynamic>> dados,
    List<Color> cores,
  ) {
    final maxVal = dados.fold<int>(0, (m, d) {
      final v = d['total'] as int;
      return v > m ? v : m;
    });

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxVal + 1).toDouble(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = dados[group.x.toInt()];
                    final label = d['label'] as String;
                    final equipes = d['equipes'] as List<String>?;
                    final totalGols = d['total_gols'] as int?;

                    String text = '$label\n${rod.toY.toInt()}';
                    if (equipes != null && equipes.isNotEmpty) {
                      text += '\n${equipes.join(', ')}';
                    }
                    if (totalGols != null && totalGols > 0) {
                      text += '\n⚽ $totalGols gols';
                    }
                    return BarTooltipItem(
                      text,
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == value.roundToDouble()) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < dados.length) {
                        final label = dados[idx]['label'] as String;
                        final words = label.split(' ');
                        String short;
                        if (label.length <= 10) {
                          short = label;
                        } else if (words.length >= 2) {
                          short = words.first;
                        } else {
                          short = '${label.substring(0, 9)}…';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            short,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: dados.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (d['total'] as int).toDouble(),
                      color: cores[i % cores.length],
                      width: dados.length <= 3 ? 28 : 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegenda(dados, cores),
      ],
    );
  }

  // ======================== LIST VIEW (com barras de progresso) ========================

  Widget _buildListView(
    List<Map<String, dynamic>> dados,
    List<Color> cores,
    int total,
  ) {
    final maxVal = dados.fold<int>(0, (m, d) {
      final v = d['total'] as int;
      return v > m ? v : m;
    });

    return Column(
      children: dados.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        final valor = d['total'] as int;
        final pct = total > 0 ? (valor / total * 100) : 0.0;
        final barFraction = maxVal > 0 ? valor / maxVal : 0.0;
        final cor = cores[i % cores.length];
        final equipes = d['equipes'] as List<String>?;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$valor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: barFraction,
                  minHeight: 6,
                  backgroundColor: cor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(cor),
                ),
              ),
              if (equipes != null && equipes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  equipes.join(', '),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ======================== LEGENDA ========================

  Widget _buildLegenda(
    List<Map<String, dynamic>> dados,
    List<Color> cores,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: dados.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cores[i % cores.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${d['label']} (${d['total']})',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ======================== DESEMPENHO POR EQUIPE ========================

  Widget _buildDesempenho() {
    if (_desempenho.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.campeonatos.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.leaderboard_rounded,
                      color: AppColors.campeonatos, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Desempenho por Equipe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._desempenho.map((d) => _buildDesempenhoItem(d)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesempenhoItem(Map<String, dynamic> d) {
    final equipe = d['equipe'] as String;
    final jogos = d['jogos'] as int;
    final v = d['vitorias'] as int;
    final e = d['empates'] as int;
    final derrota = d['derrotas'] as int;
    final gp = d['gols_pro'] as int;
    final gc = d['gols_contra'] as int;
    final saldo = gp - gc;
    final pontos = v * 3 + e;

    // Barra de aproveitamento
    final aproveitamento = jogos > 0 ? (pontos / (jogos * 3) * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  equipe,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$pontos pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip('$v', 'V', AppColors.success),
              const SizedBox(width: 6),
              _buildStatChip('$e', 'E', AppColors.warning),
              const SizedBox(width: 6),
              _buildStatChip('$derrota', 'D', AppColors.error),
              const SizedBox(width: 12),
              Text(
                '$gp:$gc',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${saldo >= 0 ? '+' : ''}$saldo)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: saldo > 0
                      ? AppColors.success
                      : saldo < 0
                          ? AppColors.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${aproveitamento.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: aproveitamento / 100,
              minHeight: 4,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                aproveitamento >= 60
                    ? AppColors.success
                    : aproveitamento >= 40
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: cor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
