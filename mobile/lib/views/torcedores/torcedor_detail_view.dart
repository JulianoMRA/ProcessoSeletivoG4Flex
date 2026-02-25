import 'package:flutter/material.dart';
import 'package:fala_torcedor/controllers/torcedor_controller.dart';
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/core/dialog.dart';
import 'package:fala_torcedor/core/snackbar.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/views/torcedores/torcedor_form_view.dart';
import 'package:intl/intl.dart';

class TorcedorDetailView extends StatelessWidget {
  final Torcedor torcedor;

  const TorcedorDetailView({super.key, required this.torcedor});

  String _formatarCpf(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return nome[0].toUpperCase();
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
                  builder: (_) => TorcedorFormView(torcedor: torcedor),
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
            _buildInfoCard(),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _iniciais(torcedor.nome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    torcedor.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatarCpf(torcedor.cpf),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
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

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _InfoTile(
              icon: Icons.cake_rounded,
              label: 'Data de nascimento',
              valor: DateFormat('dd/MM/yyyy').format(torcedor.nascimento),
            ),
            const Divider(height: 1, indent: 56),
            _InfoTile(
              icon: Icons.shield_rounded,
              label: 'Equipe',
              valor: torcedor.equipe?.nome ?? 'N/A',
            ),
            const Divider(height: 1, indent: 56),
            _InfoTile(
              icon: Icons.card_membership_rounded,
              label: 'Plano de sócio',
              valor: torcedor.plano?.nome ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) async {
    final confirmou = await AppDialog.confirmar(
      context: context,
      titulo: 'Excluir torcedor',
      mensagem: 'Deseja excluir "${torcedor.nome}"?',
    );

    if (!confirmou || !context.mounted) return;

    final controller = TorcedorController();
    final torcedorExcluido = torcedor;
    final sucesso = await controller.excluirTorcedor(torcedor.id!);

    if (context.mounted) {
      if (sucesso) {
        AppSnackBar.sucesso(
          context,
          'Torcedor excluído',
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await controller.criarTorcedor(torcedorExcluido);
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
