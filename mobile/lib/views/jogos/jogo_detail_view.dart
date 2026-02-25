import 'package:flutter/material.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/snackbar.dart';
import 'package:fala_torcedor/models/jogo.dart';
import 'package:fala_torcedor/views/jogos/jogo_form_view.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:intl/intl.dart';

class JogoDetailView extends StatefulWidget {
  final Jogo jogo;

  const JogoDetailView({super.key, required this.jogo});

  @override
  State<JogoDetailView> createState() => _JogoDetailViewState();
}

class _JogoDetailViewState extends State<JogoDetailView> {
  late Jogo _jogo;
  bool _alterou = false;

  @override
  void initState() {
    super.initState();
    _jogo = widget.jogo;
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir jogo?'),
        content: Text(
          '${_jogo.equipeANome} ${_jogo.placar} ${_jogo.equipeBNome}\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await ApiService().deleteJogo(_jogo.id!);
      if (mounted) {
        final jogoExcluido = _jogo;
        AppSnackBar.sucesso(
          context,
          'Jogo excluído',
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await ApiService().createJogo(jogoExcluido);
              } catch (_) {}
            },
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.erro(context, 'Erro ao excluir: $e');
      }
    }
  }

  Color get _corVencedor => switch (_jogo.vencedor) {
    'equipe_a' => AppColors.primary,
    'equipe_b' => AppColors.secondary,
    _ => AppColors.warning,
  };

  String get _textoResultado => switch (_jogo.vencedor) {
    'equipe_a' => 'Vitória ${_jogo.equipeANome}',
    'equipe_b' => 'Vitória ${_jogo.equipeBNome}',
    _ => 'Empate',
  };

  IconData get _iconeResultado => switch (_jogo.vencedor) {
    'empate' => Icons.handshake_rounded,
    _ => Icons.emoji_events_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _alterou) {
          Navigator.of(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Jogo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Editar',
              onPressed: () async {
                final editou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => JogoFormView(jogo: _jogo)),
                );
                if (editou == true) {
                  _alterou = true;
                  try {
                    final atualizado = await ApiService().getJogoById(
                      _jogo.id!,
                    );
                    setState(() => _jogo = atualizado);
                  } catch (_) {}
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Excluir',
              onPressed: _excluir,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPlacar(),
              const SizedBox(height: 20),
              _buildResultado(),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlacar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.jogos, AppColors.jogosLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.jogos.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _jogo.equipeANome ?? '—',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _jogo.placar,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _jogo.equipeBNome ?? '—',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _corVencedor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corVencedor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_iconeResultado, color: _corVencedor, size: 22),
          const SizedBox(width: 10),
          Text(
            _textoResultado,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _corVencedor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final formatadorData = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Data',
              value: formatadorData.format(_jogo.data),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Horário',
              value: _jogo.hora,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.shield_outlined,
              label: 'Mandante',
              value: _jogo.equipeANome ?? '—',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.shield_outlined,
              label: 'Visitante',
              value: _jogo.equipeBNome ?? '—',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
