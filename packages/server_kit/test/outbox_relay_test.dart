import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:sorvete_server_kit/sorvete_server_kit.dart';
import 'package:test/test.dart';

void main() {
  final faker = Faker(seed: 314);

  OutboxEvent event() => OutboxEvent(
    id: Ids.newId(),
    type: faker.lorem.word(),
    aggregateId: Ids.newId(),
    occurredAt: DateTime.utc(2026, 6, 8),
    payload: const {},
  );

  group('OutboxRelay.pump', () {
    late InMemoryOutboxRepo repo;
    late OutboxEvent a;
    late OutboxEvent b;

    setUp(() async {
      repo = InMemoryOutboxRepo();
      a = event();
      b = event();
      await repo.append(a);
      await repo.append(b);
    });

    OutboxRelay relayWith(FakeEventPublisher publisher) => OutboxRelay(
      repo: repo,
      publisher: publisher,
      sourceService: 'identity',
    );

    test(
      'publishes all unpublished events to outbox.<service> and marks them',
      () async {
        final publisher = FakeEventPublisher();
        final count = await relayWith(publisher).pump();

        expect(count, 2);
        expect(publisher.published.map((p) => p.event), [a, b]);
        expect(publisher.published.first.subject, 'outbox.identity');
        expect(await repo.fetchUnpublished(limit: 10), isEmpty);
      },
    );

    test('a second pump publishes nothing (no double-publish)', () async {
      final publisher = FakeEventPublisher();
      final relay = relayWith(publisher);
      await relay.pump();
      final second = await relay.pump();

      expect(second, 0);
      expect(publisher.published, hasLength(2));
    });

    test(
      'leaves events unpublished and re-attempts when a publish fails',
      () async {
        final publisher = FakeEventPublisher(failFirst: 1);
        final relay = relayWith(publisher);

        await expectLater(relay.pump(), throwsA(isA<StateError>()));
        expect(await repo.fetchUnpublished(limit: 10), hasLength(2));

        final retried = await relay.pump();
        expect(retried, 2);
        expect(publisher.published.map((p) => p.event), [a, b]);
        expect(await repo.fetchUnpublished(limit: 10), isEmpty);
      },
    );
  });
}
