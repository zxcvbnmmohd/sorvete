@Tags(['integration'])
library;

import 'dart:convert';

import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:sorvete_server_kit/sorvete_server_kit.dart';
import 'package:test/test.dart';

/// Requires a live NATS server. Excluded from the default unit gate; run with:
///   docker run -d --rm -p 4222:4222 nats:2.10-alpine -js
///   dart test --tags integration
void main() {
  final uri = Uri.parse(
    const String.fromEnvironment(
      'NATS_URL',
      defaultValue: 'nats://localhost:4222',
    ),
  );
  final faker = Faker(seed: 8);

  test('publishes an OutboxEvent and receives it on a subscription', () async {
    final subscriber = await NatsBus.connect(uri, name: 'subscriber');
    final publisher = await NatsBus.connect(uri, name: 'publisher');
    addTearDown(() async {
      await subscriber.close();
      await publisher.close();
    });

    const subject = 'outbox.identity';
    final received = subscriber.subscribe(subject).first;
    await subscriber.flush();
    // Give the server a moment to register the SUB before publishing.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final event = OutboxEvent(
      id: Ids.newId(),
      type: 'TestEvent',
      aggregateId: Ids.newId(),
      occurredAt: DateTime.utc(2026, 6, 8),
      payload: {'note': faker.lorem.word()},
    );
    await NatsEventPublisher(publisher).publish(subject: subject, event: event);

    final msg = await received.timeout(const Duration(seconds: 5));
    final decoded = OutboxEvent.fromJson(
      jsonDecode(utf8.decode(msg.payload)) as Map<String, dynamic>,
    );

    expect(msg.subject, subject);
    expect(decoded, event);
  });
}
