/// The catalog of Sorvete backend services and how to reach each one.
///
/// Single source of truth for "which 32 services exist" — used by the health
/// dashboard and any future feature that needs to fan out across all services.
class ServiceRegistry {
  const ServiceRegistry({required this.services});

  /// Each entry is `(name, baseUrl)`.
  final List<({String name, String baseUrl})> services;

  /// Default Sorvete registry — built from the 32 services in ADR-0003 §4,
  /// with URLs picked by `flavor` (matches `ServerpodConfig` in
  /// `packages/backend`).
  ///
  /// In `dev` flavor, each service runs in its own Docker container exposed
  /// on host port `8100 + alphabeticalIndex`. In `staging`/`prod`, each lives
  /// at `https://<service>.[staging.]sorvete.app/`.
  factory ServiceRegistry.sorvete({String flavor = 'dev'}) {
    return ServiceRegistry(
      services: [
        for (var i = 0; i < _serviceNames.length; i++)
          (
            name: _serviceNames[i],
            baseUrl: _urlFor(_serviceNames[i], i, flavor),
          ),
      ],
    );
  }

  static String _urlFor(String service, int index, String flavor) {
    return switch (flavor) {
      'staging' => 'https://$service.staging.sorvete.app',
      'prod' => 'https://$service.sorvete.app',
      _ => 'http://localhost:${8100 + index}',
    };
  }

  /// The 32 services from ADR-0003 — alphabetical so the dev-mode port slot
  /// stays stable across the codebase.
  static const _serviceNames = <String>[
    'ads',
    'analytics',
    'audit',
    'catalog',
    'config',
    'device',
    'disputes',
    'fulfillment',
    'geo',
    'gift_cards',
    'identity',
    'inventory',
    'kitchen',
    'kyc',
    'loyalty',
    'marketing',
    'media',
    'merchant',
    'notifications',
    'ordering',
    'payments',
    'payouts',
    'pricing',
    'promotions',
    'recommendations',
    'reservations',
    'reviews',
    'risk',
    'search',
    'support',
    'wallet',
    'webhooks',
  ];
}
