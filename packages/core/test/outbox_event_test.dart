import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:test/test.dart';

void main() {
  final faker = Faker(seed: 7);

  group('OutboxEvent JSON', () {
    test('round-trips through toJson/fromJson', () {
      final event = OutboxEvent(
        id: Ids.newId(),
        type: faker.lorem.word(),
        aggregateId: Ids.newId(),
        occurredAt: DateTime.utc(2026, 6, 8, faker.randomGenerator.integer(24)),
        payload: {
          'amount': faker.randomGenerator.integer(1000),
          'note': faker.lorem.word(),
        },
      );

      expect(OutboxEvent.fromJson(event.toJson()), event);
    });

    test('preserves publishedAt when set', () {
      final publishedAt = DateTime.utc(2026, 6, 8, 12);
      final event = OutboxEvent(
        id: Ids.newId(),
        type: 'TestEvent',
        aggregateId: Ids.newId(),
        occurredAt: DateTime.utc(2026, 6, 8, 11),
        payload: const {},
        publishedAt: publishedAt,
      );

      expect(OutboxEvent.fromJson(event.toJson()).publishedAt, publishedAt);
    });
  });
}
