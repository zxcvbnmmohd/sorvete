import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'currency.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// A currency-typed money amount, stored as integer minor units (e.g. cents)
/// against a [Currency]. There is no implicit currency: arithmetic across two
/// different currencies throws [CurrencyMismatch] (ADR-0004 §8).
@freezed
abstract class Money with _$Money {
  const Money._();

  const factory Money({required int minorUnits, required Currency currency}) =
      _Money;

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  /// Zero in the given [currency].
  factory Money.zero(Currency currency) =>
      Money(minorUnits: 0, currency: currency);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return copyWith(minorUnits: minorUnits + other.minorUnits);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return copyWith(minorUnits: minorUnits - other.minorUnits);
  }

  Money operator *(int quantity) => copyWith(minorUnits: minorUnits * quantity);

  /// Human-readable amount using the currency's minor-unit digits
  /// (e.g. USD 123456 → "1234.56", JPY 100 → "100", IQD 1234 → "1.234").
  String format() {
    final sign = minorUnits < 0 ? '-' : '';
    final abs = minorUnits.abs();
    final digits = currency.minorUnitDigits;
    if (digits == 0) return '$sign$abs';
    final divisor = pow(10, digits).toInt();
    final whole = abs ~/ divisor;
    final fraction = (abs % divisor).toString().padLeft(digits, '0');
    return '$sign$whole.$fraction';
  }

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatch(left: currency, right: other.currency);
    }
  }
}

/// Thrown when an operation combines two [Money] values of different currencies.
class CurrencyMismatch extends Error {
  CurrencyMismatch({required this.left, required this.right});

  final Currency left;
  final Currency right;

  @override
  String toString() =>
      'CurrencyMismatch: cannot combine ${left.code} with ${right.code}';
}
