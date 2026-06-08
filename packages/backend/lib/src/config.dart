import 'service_registry.dart';

/// Resolves the base URL for a given Sorvete service.
///
/// Flavor is read from `--dart-define=FLAVOR=<dev|staging|prod>`.
/// - `dev` maps each service to `http://localhost:${devPortBase + index}/`,
///   where `index` is its alphabetical slot in [ServiceRegistry.serviceNames].
///   This matches `docker-compose.dev.yml` (all services run concurrently) and
///   [ServiceRegistry]. The earlier single-service `:8080` scheme was retired
///   when the Wave 0 happy-path E2E began running services together.
/// - `staging` / `prod` return per-service hostnames under the Sorvete domain.
class ServerpodConfig {
  static const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static String urlFor(String service) {
    return switch (_flavor) {
      'staging' => 'https://$service.staging.sorvete.app/',
      'prod' => 'https://$service.sorvete.app/',
      _ =>
        'http://localhost:${ServiceRegistry.devPortBase + _devIndexOf(service)}/',
    };
  }

  /// Alphabetical slot of [service] in the canonical registry — the dev-mode
  /// port offset. Throws on an unknown service rather than silently mapping it
  /// to a wrong port.
  static int _devIndexOf(String service) {
    final index = ServiceRegistry.serviceNames.indexOf(service);
    if (index < 0) {
      throw ArgumentError.value(
        service,
        'service',
        'Unknown Sorvete service — not in ServiceRegistry.serviceNames',
      );
    }
    return index;
  }

  static String get flavor => _flavor;
}
