import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../l10n/app_localizations.dart";
import "../services/google_auth_service.dart";

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    required this.authStatus,
    required this.lastChecked,
    required this.currentTime,
    required this.ungradedCount,
    super.key,
  });

  final GoogleAuthStatus authStatus;
  final DateTime? lastChecked;
  final DateTime currentTime;
  final int ungradedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final isSignedIn = authStatus.state == GoogleAuthState.signedIn;
    final name = authStatus.displayName;
    final email = authStatus.emailAddress;
    final accountText = isSignedIn
        ? _signedInText(l10n: l10n, name: name, email: email)
        : l10n.connectAccountPrompt;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 22,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusItem(
              icon: Icons.account_circle_outlined,
              label: l10n.account,
              value: accountText,
              maxWidth: 520,
            ),
            _StatusItem(
              icon: Icons.update_outlined,
              label: l10n.lastChecked,
              value: _formatLastChecked(l10n, lastChecked, currentTime),
              maxWidth: 280,
            ),
            _StatusItem(
              icon: Icons.schedule_outlined,
              label: l10n.now,
              value: _formatClock(l10n, currentTime),
              maxWidth: 180,
            ),
            _StatusItem(
              icon: Icons.pending_actions_outlined,
              label: l10n.ungradedWorks,
              value: ungradedCount.toString(),
              maxWidth: 260,
            ),
          ],
        ),
      ),
    );
  }

  String _signedInText({
    required AppLocalizations l10n,
    required String? name,
    required String? email,
  }) {
    final cleanName = name?.trim();
    final cleanEmail = email?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        return l10n.signedInAsNameEmail(cleanName, cleanEmail);
      }
      return l10n.signedInAsName(cleanName);
    }

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return l10n.signedInAsEmail(cleanEmail);
    }

    return l10n.signedIn;
  }

  String _formatLastChecked(
    AppLocalizations l10n,
    DateTime? value,
    DateTime now,
  ) {
    if (value == null) {
      return l10n.never;
    }

    final localValue = value.toLocal();
    final localNow = now.toLocal();
    final elapsed = localNow.difference(localValue);
    final checkedAt = DateFormat("HH:mm", l10n.localeName).format(localValue);
    if (elapsed.isNegative) {
      return checkedAt;
    }
    if (elapsed.inSeconds < 60) {
      return "$checkedAt (${l10n.checkedNow})";
    }
    if (elapsed.inMinutes < 60) {
      return "$checkedAt (${l10n.minutesAgo(elapsed.inMinutes)})";
    }
    if (elapsed.inHours < 24) {
      return "$checkedAt (${l10n.hoursAgo(elapsed.inHours)})";
    }

    return DateFormat("yyyy-MM-dd HH:mm", l10n.localeName).format(localValue);
  }

  String _formatClock(AppLocalizations l10n, DateTime value) {
    return DateFormat("HH:mm:ss", l10n.localeName).format(value.toLocal());
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.maxWidth,
  });

  final IconData icon;
  final String label;
  final String value;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final valueStyle = DefaultTextStyle.of(context).style;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "$label: ", style: labelStyle),
                  TextSpan(text: value, style: valueStyle),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
