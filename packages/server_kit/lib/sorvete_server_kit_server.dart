/// Server-side shared engine for Sorvete's Serverpod services (Serverpod module).
///
/// The outbox writer/relay, idempotency store, and event-consumer primitives
/// (pure logic behind ports, unit-tested with no Postgres/NATS), the
/// Serverpod-backed table models + adapters, the relay bootstrap, and the
/// dev/test-only emitTestEvent endpoint.
library;

// Serverpod-generated protocol + endpoints for this module.
export 'src/generated/protocol.dart';
export 'src/generated/endpoints.dart';

// Pure logic + ports.
export 'src/event_consumer.dart';
export 'src/idempotency_store.dart';
export 'src/nats_bus.dart';
export 'src/nats_protocol.dart';
export 'src/outbox.dart';
export 'src/outbox_relay.dart';
