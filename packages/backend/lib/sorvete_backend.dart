/// Sorvete backend SDK — single package that bundles every backend concern an
/// app needs:
///   • 32 typed Serverpod clients (`SorveteClients.bootstrap()`)
///   • Cross-cutting infrastructure (auth, idempotency keys, error mapping,
///     base-URL config, past-dated timestamps)
///   • Platform observability (`HealthDashboard`, `ServiceRegistry`)
///
/// Apps depend on this ONE package and get everything. Type access for a
/// specific service uses the prefixed shim:
///   import 'package:sorvete_backend/ordering.dart' as ordering;
///   final cart = ordering.Cart(...);
library;

// RPC surface (32 typed clients aggregator).
export 'src/clients.dart';

// Cross-cutting infrastructure.
export 'src/auth_key_manager.dart';
export 'src/config.dart';
export 'src/errors.dart';
export 'src/idempotency_key.dart';
export 'src/past_dated_timestamp.dart';

// Platform observability (HTTP-polled health dashboard).
export 'src/health_status.dart';
export 'src/service_registry.dart';
export 'src/health_check_service.dart';
export 'src/widgets/health_dashboard.dart';
export 'src/widgets/health_tile.dart';
