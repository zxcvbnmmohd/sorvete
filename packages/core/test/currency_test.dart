import 'package:sorvete_core/sorvete_core.dart';
import 'package:test/test.dart';

void main() {
  group('Currency.ofCode', () {
    test('USD has 2 minor-unit digits', () {
      expect(Currency.ofCode('USD').minorUnitDigits, 2);
    });

    test('JPY has 0 minor-unit digits', () {
      expect(Currency.ofCode('JPY').minorUnitDigits, 0);
    });

    test('IQD has 3 minor-unit digits', () {
      expect(Currency.ofCode('IQD').minorUnitDigits, 3);
    });

    test('is case-insensitive and normalizes the code to upper case', () {
      final c = Currency.ofCode('usd');
      expect(c.code, 'USD');
      expect(c, Currency.ofCode('USD'));
    });

    test('throws ArgumentError on an unknown code', () {
      expect(() => Currency.ofCode('ZZZ'), throwsArgumentError);
    });
  });
}
