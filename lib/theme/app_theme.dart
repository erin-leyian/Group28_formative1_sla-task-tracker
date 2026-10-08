import 'package:flutter/material.dart';

import '../services/sla_service.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E5AA8);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static Color slaColor(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return Colors.green.shade700;
      case SlaStatus.atRisk:
        return Colors.orange.shade700;
      case SlaStatus.overdue:
        return Colors.red.shade700;
      case SlaStatus.completed:
        return Colors.blueGrey;
    }
  }
}

class AppSpacing {
  static const double page = 16;
  static const double item = 8;
  static const double section = 24;
}
