import 'package:flutter/material.dart';

import '../health_status.dart';

/// One service's status card. Color + icon by state, latency + last-checked
/// in subtitle. Pure presentational — fed by [HealthDashboard].
class HealthTile extends StatelessWidget {
  const HealthTile({super.key, required this.status});

  final HealthStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon, label) = switch (status.state) {
      HealthState.healthy => (Colors.green.shade600, Icons.check_circle, 'up'),
      HealthState.unhealthy => (Colors.red.shade600, Icons.error, 'down'),
      HealthState.unknown => (Colors.grey.shade500, Icons.help_outline, '…'),
    };

    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    status.serviceName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              status.baseUrl
                  .replaceFirst('http://', '')
                  .replaceFirst('https://', ''),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (status.latency != null)
              Text(
                '${status.latency!.inMilliseconds} ms',
                style: theme.textTheme.bodySmall,
              ),
            if (status.error != null)
              Text(
                status.error!,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
