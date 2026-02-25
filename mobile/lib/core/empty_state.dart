import 'package:flutter/material.dart';
import 'package:fala_torcedor/core/colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final String? botaoTexto;
  final VoidCallback? onBotao;

  const EmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    this.subtitulo = '',
    this.botaoTexto,
    this.onBotao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (botaoTexto != null && onBotao != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onBotao,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(botaoTexto!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
