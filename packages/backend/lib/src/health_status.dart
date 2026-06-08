/// State of a single backend service from the dashboard's point of view.
enum HealthState {
  /// HTTP 2xx came back within the timeout — backend is reachable.
  healthy,

  /// HTTP non-2xx, connection refused, or timeout — backend is down or unreachable.
  unhealthy,

  /// No check has run yet for this service.
  unknown,
}

/// One health-check result for one backend.
class HealthStatus {
  const HealthStatus({
    required this.serviceName,
    required this.baseUrl,
    required this.state,
    this.latency,
    this.lastChecked,
    this.responseBody,
    this.error,
  });

  /// Service identifier (e.g., `identity`, `ordering`).
  final String serviceName;

  /// Where it lives (e.g., `http://localhost:8110`).
  final String baseUrl;

  final HealthState state;

  /// Round-trip time of the last successful probe. Null until first success.
  final Duration? latency;

  /// When the last probe ran (regardless of outcome). Null until first probe.
  final DateTime? lastChecked;

  /// Raw response body from the last successful probe — typically Serverpod's
  /// `"OK <ISO-8601 timestamp>"` from the built-in `/` endpoint.
  final String? responseBody;

  /// Error message from the last failed probe.
  final String? error;

  /// Initial / pre-probe placeholder for a known service.
  factory HealthStatus.unknown({
    required String serviceName,
    required String baseUrl,
  }) => HealthStatus(
    serviceName: serviceName,
    baseUrl: baseUrl,
    state: HealthState.unknown,
  );

  HealthStatus copyWith({
    HealthState? state,
    Duration? latency,
    DateTime? lastChecked,
    String? responseBody,
    String? error,
  }) => HealthStatus(
    serviceName: serviceName,
    baseUrl: baseUrl,
    state: state ?? this.state,
    latency: latency ?? this.latency,
    lastChecked: lastChecked ?? this.lastChecked,
    responseBody: responseBody ?? this.responseBody,
    error: error,
  );
}
