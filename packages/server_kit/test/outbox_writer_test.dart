import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:sorvete_server_kit/sorvete_server_kit.dart';
import 'package:test/test.dart';

void main() {
  final faker = Faker(seed: 99);

  OutboxEvent event({DateTime? publishedAt}) => OutboxEvent(
    id: Ids.newId(),
    type: faker.lorem.word(),
    aggregateId: Ids.newId(),
    occurredAt: DateTime.utc(2026, 6, 8),
    payload: const {},
    publishedAt: publishedAt,
  );

  group('OutboxWriter.enqueue', () {
    late InMemoryOutboxRepo repo;
    late OutboxWriter writer;

    setUp(() {
      repo = InMemoryOutboxRepo();
      writer = OutboxWriter(repo: repo);
    });

    test('appends the event to the outbox as unpublished', () async {
      final e = event();
      await writer.enqueue(event: e);
      expect(await repo.fetchUnpublished(limit: 10), contains(e));
    });

    test('appends multiple events in order', () async {
      final a = event();
      final b = event();
      await writer.enqueue(event: a);
      await writer.enqueue(event: b);
      expect(await repo.fetchUnpublished(limit: 10), [a, b]);
    });

    test('rejects an already-published event', () async {
      expect(
        () => writer.enqueue(event: event(publishedAt: DateTime.utc(2026))),
        throwsArgumentError,
      );
    });
  });
}
