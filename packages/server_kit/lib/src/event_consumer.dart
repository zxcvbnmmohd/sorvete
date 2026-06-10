import 'package:sorvete_core/sorvete_core.dart';

import 'idempotency_store.dart';

/// Consumes events idempotently. Each durable consumer has a [name]
/// (e.g. `audit-from-identity`); the handler runs at most once per
/// (consumer, event id), so NATS redelivery never double-applies an effect.
class EventConsumer {
  EventConsumer({
    required this.name,
    required this.store,
    required this.handle,
  });

  final String name;
  final IdempotencyStore store;
  final Future<void> Function(OutboxEvent event) handle;

  /// Applies [handle] to [event] unless this consumer has already processed
  /// that event id.
  Future<void> deliver(OutboxEvent event) async {
    await store.runOnce<void>(
      key: '$name:${event.id}',
      action: () async => handle(event),
    );
  }
}
