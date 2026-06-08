import 'package:faker/faker.dart' hide Currency;
import 'package:sorvete_core/sorvete_core.dart';
import 'package:test/test.dart';

void main() {
  final faker = Faker(seed: 20260608);
  final usd = Currency.ofCode('USD');
  final eur = Currency.ofCode('EUR');
  final jpy = Currency.ofCode('JPY');
  final iqd = Currency.ofCode('IQD');

  int amount() => faker.randomGenerator.integer(1000000);

  group('Money arithmetic (same currency)', () {
    test('+ adds minor units', () {
      final a = amount();
      final b = amount();
      expect(
        Money(minorUnits: a, currency: usd) +
            Money(minorUnits: b, currency: usd),
        Money(minorUnits: a + b, currency: usd),
      );
    });

    test('- subtracts minor units', () {
      final a = amount();
      final b = amount();
      expect(
        Money(minorUnits: a, currency: usd) -
            Money(minorUnits: b, currency: usd),
        Money(minorUnits: a - b, currency: usd),
      );
    });

    test('* scales by an integer quantity', () {
      final a = amount();
      final q = faker.randomGenerator.integer(20);
      expect(
        Money(minorUnits: a, currency: usd) * q,
        Money(minorUnits: a * q, currency: usd),
      );
    });
  });

  group('Money cross-currency arithmetic throws', () {
    test('+ throws CurrencyMismatch', () {
      expect(
        () =>
            Money(minorUnits: amount(), currency: usd) +
            Money(minorUnits: amount(), currency: eur),
        throwsA(isA<CurrencyMismatch>()),
      );
    });

    test('- throws CurrencyMismatch', () {
      expect(
        () =>
            Money(minorUnits: amount(), currency: usd) -
            Money(minorUnits: amount(), currency: eur),
        throwsA(isA<CurrencyMismatch>()),
      );
    });
  });

  group('Money.zero', () {
    test('is zero minor units in the given currency', () {
      expect(Money.zero(eur), Money(minorUnits: 0, currency: eur));
    });
  });

  group('Money.format respects the currency minor-unit digits', () {
    test('USD formats with 2 decimals', () {
      expect(Money(minorUnits: 123456, currency: usd).format(), '1234.56');
    });

    test('JPY formats with no decimals', () {
      expect(Money(minorUnits: 100, currency: jpy).format(), '100');
    });

    test('IQD formats with 3 decimals', () {
      expect(Money(minorUnits: 1234, currency: iqd).format(), '1.234');
    });

    test('negative amounts keep the sign', () {
      expect(Money(minorUnits: -5, currency: usd).format(), '-0.05');
    });
  });
}
