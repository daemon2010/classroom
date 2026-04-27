import "package:flutter/material.dart";

import "../l10n/app_localizations.dart";
import "../models/classroom_models.dart";

class SummaryCards extends StatelessWidget {
  const SummaryCards({required this.summary, super.key});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.totalUngraded,
            value: summary.ungradedSubmissionCount.toString(),
            icon: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: l10n.classesWithUngraded,
            value: summary.classesWithUngradedCount.toString(),
            icon: Icons.school_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: l10n.lateSubmissions,
            value: summary.lateSubmissionCount.toString(),
            icon: Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
