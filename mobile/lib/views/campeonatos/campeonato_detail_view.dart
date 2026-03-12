import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/campeonato_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/dialog.dart';
import 'package:fala_torcedor/core/snackbar.dart';
import 'package:fala_torcedor/models/campeonato.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:fala_torcedor/views/campeonatos/campeonato_form_view.dart';

class CampeonatoDetailView extends StatefulWidget {
  final Campeonato campeonato;

  const CampeonatoDetailView({super.key, required this.campeonato});

  @override
  State<CampeonatoDetailView> createState() => _CampeonatoDetailViewState();
}

class _CampeonatoDetailViewState extends State<CampeonatoDetailView> {
  final _api = ApiService();
  late Campeonato _campeonato;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _campeonato = widget.campeonato;
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    try {
      final completo = await _api.getCampeonatoById(_campeonato.id!);
      if (mounted) {
        setState(() {
          _campeonato = completo;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  builder: (_) => CampeonatoFormView(campeonato: _campeonato),
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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTemporada(),
            const SizedBox(height: 24),
            _buildEquipes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.campeonatos.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: AppColors.campeonatos,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _campeonato.nome,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemporada() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.campeonatos.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: AppColors.campeonatos,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Temporada',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              _campeonato.temporada,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.campeonatos,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shield_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Equipes participantes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${_campeonato.equipes.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        else if (_campeonato.equipes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nenhuma equipe vinculada',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ..._campeonato.equipes.asMap().entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
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
              ),
            ),
          ),
      ],
    );
  }

  void _confirmarExclusao(BuildContext context) async {
    final confirmou = await AppDialog.confirmar(
      context: context,
      titulo: 'Excluir campeonato',
      mensagem:
          'O campeonato "${_campeonato.nome}" será excluído. Deseja continuar?',
    );

    if (!confirmou || !context.mounted) return;

    final controller = CampeonatoController();
    final sucesso = await controller.excluirCampeonato(_campeonato.id!);

    if (context.mounted) {
      if (sucesso) {
        AppSnackBar.sucesso(context, 'Campeonato excluído');
        Navigator.pop(context, true);
      } else {
        AppSnackBar.erro(context, controller.erro ?? 'Erro ao excluir');
      }
    }
  }
}
