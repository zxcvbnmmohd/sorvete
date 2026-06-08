/// Resolves the base URL for a given Sorvete service.
///
/// Flavor is read from `--dart-define=FLAVOR=<dev|staging|prod>`.
/// - `dev` returns `http://localhost:8080/` for every service (single-service
///   local dev — only one server runs at a time, see ports policy).
/// - `staging` / `prod` return per-service hostnames under the Sorvete domain.
class ServerpodConfig {
  static const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static String urlFor(String service) {
    return switch (_flavor) {
      'staging' => 'https://$service.staging.sorvete.app/',
      'prod' => 'https://$service.sorvete.app/',
      _ => 'http://localhost:8080/',
    };
  }

  static String get flavor => _flavor;
}
