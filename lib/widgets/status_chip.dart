import 'package:flutter/material.dart';

import '../services/sla_service.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final SlaStatus status;
  const StatusChip({super.key, required this.status});

  String get _label {
    switch (status) {
      case SlaStatus.onTrack:
        return 'On Track';
      case SlaStatus.atRisk:
        return 'At Risk';
      case SlaStatus.overdue:
        return 'Overdue';
      case SlaStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.slaColor(status),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
