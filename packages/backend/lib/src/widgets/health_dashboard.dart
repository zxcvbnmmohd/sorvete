import 'package:flutter/material.dart';

import '../health_check_service.dart';
import '../health_status.dart';
import '../service_registry.dart';
import 'health_tile.dart';

/// Drop-in widget that polls every service in the [registry] and renders a
/// responsive grid of [HealthTile]s.
///
/// Owns its own [HealthCheckService] lifecycle (disposes on widget dispose).
class HealthDashboard extends StatefulWidget {
  const HealthDashboard({
    super.key,
    required this.registry,
    this.pollInterval = const Duration(seconds: 5),
    this.title = 'Service health',
  });

  final ServiceRegistry registry;
  final Duration pollInterval;
  final String title;

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  late final HealthCheckService _service;

  @override
  void initState() {
    super.initState();
    _service = HealthCheckService(
      registry: widget.registry,
      pollInterval: widget.pollInterval,
    )..start();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<Map<String, HealthStatus>>(
        stream: _service.stream,
        initialData: _service.current,
        builder: (context, snap) {
          final statuses = snap.data ?? const <String, HealthStatus>{};
          final ordered = widget.registry.services
              .map((s) => statuses[s.name])
              .whereType<HealthStatus>()
              .toList();
          final up = ordered
              .where((s) => s.state == HealthState.healthy)
              .length;
          final down = ordered
              .where((s) => s.state == HealthState.unhealthy)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _Summary(
                      label: 'up',
                      count: up,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 12),
                    _Summary(
                      label: 'down',
                      count: down,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 12),
                    _Summary(
                      label: 'total',
                      count: ordered.length,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    childAspectRatio: 2.1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: ordered.length,
                  itemBuilder: (_, i) => HealthTile(status: ordered[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
