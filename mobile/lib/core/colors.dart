import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const primary = Color(0xFF2D5BFF);
  static const primaryLight = Color(0xFF6B8AFF);
  static const primaryDark = Color(0xFF0039CB);

  // Secondary/Accent
  static const secondary = Color(0xFF00D9A5);
  static const secondaryLight = Color(0xFF5FFFD7);
  static const secondaryDark = Color(0xFF00A676);

  // Accent (Planos)
  static const accent = Color(0xFFFF6B35);
  static const accentLight = Color(0xFFFFA07A);

  // Surfaces
  static const surface = Color(0xFFFAFBFC);
  static const surfaceVariant = Color(0xFFF0F2F5);
  static const card = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF1A1D29);
  static const textSecondary = Color(0xFF5A6178);
  static const textHint = Color(0xFF9CA3AF);

  // Borders
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Series colors (divisões)
  static const serieA = Color(0xFF22C55E);
  static const serieB = Color(0xFF3B82F6);
  static const serieC = Color(0xFFF59E0B);
  static const serieD = Color(0xFFEF4444);

  // Status
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static Color corSerie(String serie) {
    return switch (serie) {
      'Série A' => serieA,
      'Série B' => serieB,
      'Série C' => serieC,
      'Série D' => serieD,
      _ => textSecondary,
    };
  }
}
