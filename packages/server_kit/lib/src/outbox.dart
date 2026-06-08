import 'package:sorvete_core/sorvete_core.dart';

/// Persistence port for a service's `outbox` table. The relay reads unpublished
/// rows and marks them; the writer appends. Behind a port so it unit-tests in
/// memory; the Postgres-backed impl binds when a service wires it (issue #5).
abstract interface class OutboxRepo {
  /// Appends [event] (expected unpublished). In production this runs inside the
  /// same transaction as the domain write (ADR §7); the in-memory impl just adds.
  Future<void> append(OutboxEvent event);

  /// Oldest-first events that have not yet been published, capped at [limit].
  Future<List<OutboxEvent>> fetchUnpublished({int limit});

  /// Stamps the row with [id] as published at [publishedAt].
  Future<void> markPublished({
    required String id,
    required DateTime publishedAt,
  });
}

/// In-memory [OutboxRepo] for tests, preserving append order.
class InMemoryOutboxRepo implements OutboxRepo {
  final _events = <OutboxEvent>[];

  @override
  Future<void> append(OutboxEvent event) async => _events.add(event);

  @override
  Future<List<OutboxEvent>> fetchUnpublished({int limit = 100}) async => _events
      .where((e) => e.publishedAt == null)
      .take(limit)
      .toList(growable: false);

  @override
  Future<void> markPublished({
    required String id,
    required DateTime publishedAt,
  }) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _events[index] = _events[index].copyWith(publishedAt: publishedAt);
    }
  }
}

/// Appends domain events to the outbox. The atomic-with-the-domain-write
/// guarantee is provided by the (transactional) [OutboxRepo] implementation.
class OutboxWriter {
  OutboxWriter({required this.repo});

  final OutboxRepo repo;

  /// Enqueues [event] for later relay. The event must be unpublished.
  Future<void> enqueue({required OutboxEvent event}) async {
    if (event.publishedAt != null) {
      throw ArgumentError.value(
        event.publishedAt,
        'event.publishedAt',
        'cannot enqueue an already-published event',
      );
    }
    await repo.append(event);
  }
}
