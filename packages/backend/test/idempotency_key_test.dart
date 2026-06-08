import 'package:flutter_test/flutter_test.dart';
import 'package:sorvete_backend/sorvete_backend.dart';

void main() {
  group('IdempotencyKey', () {
    test('produces a UUID v7 (time-ordered, version nibble = 7)', () {
      final key = IdempotencyKey.next();
      // UUID format: 8-4-4-4-12 hex chars
      final pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(pattern.hasMatch(key), isTrue, reason: 'got $key');
    });

    test('successive keys are unique', () {
      final a = IdempotencyKey.next();
      final b = IdempotencyKey.next();
      expect(a, isNot(equals(b)));
    });

    test('keys generated in different milliseconds are time-ordered', () async {
      final a = IdempotencyKey.next();
      // Force a millisecond boundary; UUID v7 only guarantees ordering
      // BETWEEN milliseconds, not within (random nibbles take over inside
      // a single ms).
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = IdempotencyKey.next();
      expect(a.compareTo(b) < 0, isTrue, reason: 'a=$a b=$b');
    });
  });
}
