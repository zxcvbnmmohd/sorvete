/// Server-side shared engine for Sorvete's Serverpod services.
///
/// The outbox writer/relay, idempotency store, and event-consumer primitives,
/// all behind ports so they unit-test with no Postgres and no NATS. Pure Dart;
/// the Serverpod and NATS adapters bind in later slices.
library;

export 'src/event_consumer.dart';
export 'src/idempotency_store.dart';
export 'src/nats_bus.dart';
export 'src/nats_protocol.dart';
export 'src/outbox.dart';
export 'src/outbox_relay.dart';
