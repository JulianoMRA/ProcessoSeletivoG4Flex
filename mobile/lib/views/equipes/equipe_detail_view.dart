import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fala_torcedor/controllers/equipe_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/dialog.dart';
import 'package:fala_torcedor/core/snackbar.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:fala_torcedor/views/equipes/equipe_form_view.dart';

class EquipeDetailView extends StatefulWidget {
  final Equipe equipe;

  const EquipeDetailView({super.key, required this.equipe});

  @override
  State<EquipeDetailView> createState() => _EquipeDetailViewState();
}

class _EquipeDetailViewState extends State<EquipeDetailView> {
  final _api = ApiService();
  late Equipe _equipe;
  bool _carregando = true;

  int _vitorias = 0;
  int _empates = 0;
  int _derrotas = 0;
  int _totalJogos = 0;

  @override
  void initState() {
    super.initState();
    _equipe = widget.equipe;
    _carregarDetalhes();
    _carregarEstatisticas();
  }

  Future<void> _carregarDetalhes() async {
    try {
      final equipeCompleta = await _api.getEquipeById(_equipe.id!);
      if (mounted) {
        setState(() {
          _equipe = equipeCompleta;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarEstatisticas() async {
    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/jogos?equipe_id=${_equipe.id}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jogos = json.decode(response.body) as List;
        int v = 0, e = 0, d = 0;
        for (final jogo in jogos) {
          final vencedor = jogo['vencedor'];
          if (vencedor == 'empate') {
            e++;
          } else if ((vencedor == 'equipe_a' &&
                  jogo['equipe_a_id'] == _equipe.id) ||
              (vencedor == 'equipe_b' && jogo['equipe_b_id'] == _equipe.id)) {
            v++;
          } else {
            d++;
          }
        }
        if (mounted) {
          setState(() {
            _vitorias = v;
            _empates = e;
            _derrotas = d;
            _totalJogos = jogos.length;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () async {
              final editou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipeFormView(equipe: _equipe),
                ),
              );
              if (editou == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cor),
            const SizedBox(height: 16),
            _buildStats(context),
            const SizedBox(height: 16),
            _buildJogosStats(),
            const SizedBox(height: 24),
            _buildPlanos(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.shield_rounded, color: cor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _equipe.nome,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Sócios-torcedores',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              _equipe.qtdSocios.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJogosStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.jogos.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.sports_score_rounded,
                    color: AppColors.jogos,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Desempenho',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '$_totalJogos jogos',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (_totalJogos > 0) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.emoji_events_rounded,
                    label: 'Vitórias',
                    value: _vitorias,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    icon: Icons.handshake_rounded,
                    label: 'Empates',
                    value: _empates,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    icon: Icons.trending_down_rounded,
                    label: 'Derrotas',
                    value: _derrotas,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.card_membership_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Planos de sócio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_carregando)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_equipe.planos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nenhum plano cadastrado',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ..._equipe.planos.asMap().entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.8),
                        AppColors.secondaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  entry.value.nome,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: Text(
                  'R\$ ${entry.value.valor.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmarExclusao(BuildContext context) async {
    final confirmou = await AppDialog.confirmar(
      context: context,
      titulo: 'Excluir equipe',
      mensagem:
          'Todos os torcedores e planos de "${_equipe.nome}" serão excluídos. Deseja continuar?',
    );

    if (!confirmou || !context.mounted) return;

    final controller = EquipeController();
    final equipeExcluida = _equipe;
    final planoIds = _equipe.planos.map((p) => p.id!).toList();
    final sucesso = await controller.excluirEquipe(_equipe.id!);

    if (context.mounted) {
      if (sucesso) {
        AppSnackBar.sucesso(
          context,
          'Equipe excluída',
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await controller.criarEquipe(equipeExcluida, planoIds);
              } catch (_) {}
            },
          ),
        );
        Navigator.pop(context, true);
      } else {
        AppSnackBar.erro(context, controller.erro ?? 'Erro ao excluir');
      }
    }
  }
}
