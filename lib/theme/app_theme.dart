import 'package:flutter/material.dart';

import '../services/sla_service.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E5AA8);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      appBarTheme: const AppBarTheme(centerTitle: true),
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
