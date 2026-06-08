import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:sorvete_server_kit/sorvete_server_kit.dart';
import 'package:test/test.dart';

void main() {
  final faker = Faker(seed: 271);

  OutboxEvent event() => OutboxEvent(
    id: Ids.newId(),
    type: faker.lorem.word(),
    aggregateId: Ids.newId(),
    occurredAt: DateTime.utc(2026, 6, 8),
    payload: const {},
  );

  group('EventConsumer.deliver', () {
    late IdempotencyStore store;

    setUp(() {
      store = IdempotencyStore(
        repo: InMemoryIdempotencyCacheRepo(),
        window: const Duration(days: 30),
      );
    });

    EventConsumer consumer(String name, Future<void> Function(OutboxEvent) h) =>
        EventConsumer(name: name, store: store, handle: h);

    test('runs the handler once even if the event is redelivered', () async {
      var calls = 0;
      final c = consumer('audit-from-identity', (_) async => calls++);
      final e = event();

      await c.deliver(e);
      await c.deliver(e); // redelivery of same event_id

      expect(calls, 1);
    });

    test('processes distinct events', () async {
      var calls = 0;
      final c = consumer('audit-from-identity', (_) async => calls++);

      await c.deliver(event());
      await c.deliver(event());

      expect(calls, 2);
    });

    test('two consumers each process the same event exactly once', () async {
      var auditCalls = 0;
      var inventoryCalls = 0;
      final e = event();
      final audit = consumer('audit-from-identity', (_) async => auditCalls++);
      final inventory = consumer(
        'inventory-from-identity',
        (_) async => inventoryCalls++,
      );

      await audit.deliver(e);
      await audit.deliver(e);
      await inventory.deliver(e);

      expect(auditCalls, 1);
      expect(inventoryCalls, 1);
    });
  });
}
