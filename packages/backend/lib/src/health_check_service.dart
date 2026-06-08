import 'dart:async';

import 'package:http/http.dart' as http;

import 'health_status.dart';
import 'service_registry.dart';

/// Polls every service in a [ServiceRegistry] on a fixed interval, emitting
/// updated status maps via [stream].
///
/// Probes the built-in Serverpod `GET /` endpoint that every backend serves
/// — no per-service health endpoint needed; Serverpod returns `"OK <ts>"`
/// with HTTP 200 when the process is alive.
class HealthCheckService {
  HealthCheckService({
    required this.registry,
    this.pollInterval = const Duration(seconds: 5),
    this.requestTimeout = const Duration(seconds: 3),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ServiceRegistry registry;
  final Duration pollInterval;
  final Duration requestTimeout;
  final http.Client _httpClient;

  final _controller = StreamController<Map<String, HealthStatus>>.broadcast();
  Timer? _timer;
  Map<String, HealthStatus> _current = const {};

  /// Latest snapshot for every service. Updates each time [_poll] completes.
  Stream<Map<String, HealthStatus>> get stream => _controller.stream;

  /// Synchronous snapshot — useful for the initial render before the first
  /// stream event lands.
  Map<String, HealthStatus> get current => _current;

  /// Start polling. Emits an initial all-`unknown` snapshot immediately, then
  /// fires a probe round every [pollInterval].
  void start() {
    _current = {
      for (final s in registry.services)
        s.name: HealthStatus.unknown(serviceName: s.name, baseUrl: s.baseUrl),
    };
    _controller.add(_current);
    _poll();
    _timer = Timer.periodic(pollInterval, (_) => _poll());
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
    _httpClient.close();
  }

  Future<void> _poll() async {
    // Fan out concurrently — 32 small HTTP GETs in parallel is fine.
    final futures = registry.services.map(_probe).toList();
    final results = await Future.wait(futures);
    _current = {for (final r in results) r.serviceName: r};
    if (!_controller.isClosed) _controller.add(_current);
  }

  Future<HealthStatus> _probe(({String name, String baseUrl}) entry) async {
    final start = DateTime.now();
    final url = Uri.parse('${entry.baseUrl}/');
    try {
      final res = await _httpClient.get(url).timeout(requestTimeout);
      final elapsed = DateTime.now().difference(start);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return HealthStatus(
          serviceName: entry.name,
          baseUrl: entry.baseUrl,
          state: HealthState.healthy,
          latency: elapsed,
          lastChecked: DateTime.now(),
          responseBody: res.body,
        );
      }
      return HealthStatus(
        serviceName: entry.name,
        baseUrl: entry.baseUrl,
        state: HealthState.unhealthy,
        latency: elapsed,
        lastChecked: DateTime.now(),
        error: 'HTTP ${res.statusCode}',
      );
    } on TimeoutException {
      return HealthStatus(
        serviceName: entry.name,
        baseUrl: entry.baseUrl,
        state: HealthState.unhealthy,
        lastChecked: DateTime.now(),
        error: 'timeout',
      );
    } catch (e) {
      return HealthStatus(
        serviceName: entry.name,
        baseUrl: entry.baseUrl,
        state: HealthState.unhealthy,
        lastChecked: DateTime.now(),
        error: e.toString(),
      );
    }
  }
}
