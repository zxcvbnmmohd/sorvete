import 'package:sorvete_core/sorvete_core.dart';
import 'package:test/test.dart';

final _uuidV7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  group('Ids.newId', () {
    test('produces a UUID v7 (version nibble = 7)', () {
      expect(_uuidV7.hasMatch(Ids.newId()), isTrue);
    });

    test('successive ids are unique', () {
      expect(Ids.newId(), isNot(equals(Ids.newId())));
    });

    test('ids generated in different milliseconds are time-ordered', () async {
      final a = Ids.newId();
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = Ids.newId();
      expect(a.compareTo(b) < 0, isTrue, reason: 'a=$a b=$b');
    });
  });

  group('IdempotencyKey.next', () {
    test('is a UUID v7 (delegates to Ids)', () {
      expect(_uuidV7.hasMatch(IdempotencyKey.next()), isTrue);
    });
  });
}
