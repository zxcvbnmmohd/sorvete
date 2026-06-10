import 'package:sorvete_core/sorvete_core.dart';

import 'outbox.dart';

/// Port for shipping an [OutboxEvent] onto the message bus. The real
/// NATS-backed impl binds in issue #4; [FakeEventPublisher] stands in for tests.
abstract interface class EventPublisher {
  Future<void> publish({required String subject, required OutboxEvent event});
}

/// Records published events; can be told to fail its first [failFirst] calls
/// to exercise the relay's at-least-once re-attempt behavior.
class FakeEventPublisher implements EventPublisher {
  FakeEventPublisher({this.failFirst = 0});

  final int failFirst;
  final published = <({String subject, OutboxEvent event})>[];
  int _attempts = 0;

  @override
  Future<void> publish({
    required String subject,
    required OutboxEvent event,
  }) async {
    _attempts++;
    if (_attempts <= failFirst) {
      throw StateError('publish failed (attempt $_attempts)');
    }
    published.add((subject: subject, event: event));
  }
}

/// Polls a service's outbox and ships unpublished events, oldest-first, onto
/// `outbox.<sourceService>`, marking each published. One relay per service.
///
/// At-least-once: a publish failure propagates out of [pump] with the event
/// still unpublished, so the periodic driver (issues #4/#5) retries it. A
/// published row is never shipped twice.
class OutboxRelay {
  OutboxRelay({
    required this.repo,
    required this.publisher,
    required this.sourceService,
    int batchSize = 100,
    DateTime Function()? clock,
  }) : _batchSize = batchSize,
       _clock = clock ?? DateTime.now;

  final OutboxRepo repo;
  final EventPublisher publisher;
  final String sourceService;
  final int _batchSize;
  final DateTime Function() _clock;

  String get subject => 'outbox.$sourceService';

  /// Publishes the current unpublished batch, returning how many were shipped.
  Future<int> pump() async {
    final batch = await repo.fetchUnpublished(limit: _batchSize);
    var count = 0;
    for (final event in batch) {
      await publisher.publish(subject: subject, event: event);
      await repo.markPublished(id: event.id, publishedAt: _clock());
      count++;
    }
    return count;
  }
}
