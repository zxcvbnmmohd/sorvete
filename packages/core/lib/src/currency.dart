import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';
part 'currency.g.dart';

/// An ISO-4217 currency: its code and how many minor-unit digits it has
/// (e.g. USD → 2 cents, JPY → 0, IQD → 3 fils). Money amounts are stored as
/// integer minor units against a [Currency].
@freezed
abstract class Currency with _$Currency {
  const Currency._();

  const factory Currency({required String code, required int minorUnitDigits}) =
      _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  /// Resolves a [Currency] by ISO-4217 [code] (case-insensitive).
  /// Throws [ArgumentError] for an unknown code.
  static Currency ofCode(String code) {
    final normalized = code.toUpperCase();
    final digits = _minorUnitDigits[normalized];
    if (digits == null) {
      throw ArgumentError.value(code, 'code', 'Unknown ISO-4217 currency code');
    }
    return Currency(code: normalized, minorUnitDigits: digits);
  }
}

/// ISO-4217 minor-unit digits — reference data, declared once. Covers the
/// launch markets in ADR-0004 (card + cash economies) plus common anchors.
/// Most currencies use 2 digits; the exceptions (0- and 3-digit) are why this
/// is data, not an assumption baked into [Money].
const Map<String, int> _minorUnitDigits = {
  // 2-digit (cents)
  'USD': 2, 'EUR': 2, 'GBP': 2, 'EGP': 2, 'PKR': 2, 'KES': 2, 'NGN': 2,
  'BDT': 2, 'LBP': 2, 'SOS': 2, 'AED': 2, 'SAR': 2,
  // 0-digit (no minor unit)
  'JPY': 0, 'KRW': 0,
  // 3-digit (mils/fils)
  'IQD': 3, 'BHD': 3, 'KWD': 3, 'OMR': 3,
};
