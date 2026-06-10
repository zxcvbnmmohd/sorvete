import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:sorvete_core/sorvete_core.dart';

import '../adapters/serverpod_idempotency_cache_repo.dart';
import '../adapters/serverpod_outbox_repo.dart';
import '../event_consumer.dart';
import '../idempotency_store.dart';
import '../nats_bus.dart';
import '../outbox_relay.dart';

/// NATS endpoint from the `NATS_URL` env var (defaults to local dev).
Uri natsUriFromEnv() =>
    Uri.parse(Platform.environment['NATS_URL'] ?? 'nats://localhost:4222');

/// Starts a periodic outbox relay for [sourceService]: every [interval] it
/// ships that service's unpublished events to `outbox.<sourceService>` on NATS.
/// At-least-once — a failed tick simply retries next time. Returns the [NatsBus]
/// (keep it for shutdown). Call once, after `pod.start()`.
Future<NatsBus> startOutboxRelay({
  required Serverpod pod,
  required String sourceService,
  Uri? natsUri,
  Duration interval = const Duration(seconds: 1),
}) async {
  final bus = await NatsBus.connect(
    natsUri ?? natsUriFromEnv(),
    name: '$sourceService-relay',
  );
  final publisher = NatsEventPublisher(bus);
  Timer.periodic(interval, (_) async {
    final session = await pod.createSession();
    try {
      await OutboxRelay(
        repo: ServerpodOutboxRepo(session),
        publisher: publisher,
        sourceService: sourceService,
      ).pump();
    } catch (_) {
      // Best-effort; unpublished rows are retried on the next tick.
    } finally {
      await session.close();
    }
  });
  return bus;
}

/// Starts a durable consumer named [consumerName] that applies [handle] exactly
/// once per (consumer, event id) to events arriving on [sourceSubject]
/// (e.g. `outbox.identity`). Returns the [NatsBus]. Call once, after
/// `pod.start()`.
Future<NatsBus> startEventConsumer({
  required Serverpod pod,
  required String consumerName,
  required String sourceSubject,
  required Future<void> Function(Session session, OutboxEvent event) handle,
  Uri? natsUri,
}) async {
  final bus = await NatsBus.connect(
    natsUri ?? natsUriFromEnv(),
    name: consumerName,
  );
  bus.subscribe(sourceSubject).listen((msg) async {
    final event = OutboxEvent.fromJson(
      jsonDecode(utf8.decode(msg.payload)) as Map<String, dynamic>,
    );
    final session = await pod.createSession();
    try {
      final consumer = EventConsumer(
        name: consumerName,
        store: IdempotencyStore(
          repo: ServerpodIdempotencyCacheRepo(session),
          window: const Duration(days: 30),
        ),
        handle: (e) => handle(session, e),
      );
      await consumer.deliver(event);
    } catch (_) {
      // Best-effort; redelivery + idempotency keep this safe.
    } finally {
      await session.close();
    }
  });
  return bus;
}
