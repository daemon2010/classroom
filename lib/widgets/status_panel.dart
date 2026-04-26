import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../services/google_auth_service.dart";

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    required this.authStatus,
    required this.lastChecked,
    required this.ungradedCount,
    super.key,
  });

  final GoogleAuthStatus authStatus;
  final DateTime? lastChecked;
  final int ungradedCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSignedIn = authStatus.state == GoogleAuthState.signedIn;
    final name = authStatus.displayName;
    final email = authStatus.emailAddress;
    final accountText = isSignedIn
        ? _signedInText(name: name, email: email)
        : "Connect your Google account to check ungraded Classroom work.";

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
              label: "Account",
              value: accountText,
            ),
            _StatusItem(
              icon: Icons.update_outlined,
              label: "Last checked",
              value: _formatTime(lastChecked),
            ),
            _StatusItem(
              icon: Icons.pending_actions_outlined,
              label: "Ungraded works",
              value: ungradedCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  String _signedInText({required String? name, required String? email}) {
    final cleanName = name?.trim();
    final cleanEmail = email?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        return "Signed in as: $cleanName <$cleanEmail>";
      }
      return "Signed in as: $cleanName";
    }

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return "Signed in as: $cleanEmail";
    }

    return "Signed in";
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return "never";
    }
    return DateFormat("HH:mm").format(value.toLocal());
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text("$label: ", style: Theme.of(context).textTheme.labelLarge),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
