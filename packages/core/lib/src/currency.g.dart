// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Currency _$CurrencyFromJson(Map<String, dynamic> json) => _Currency(
  code: json['code'] as String,
  minorUnitDigits: (json['minorUnitDigits'] as num).toInt(),
);

Map<String, dynamic> _$CurrencyToJson(_Currency instance) => <String, dynamic>{
  'code': instance.code,
  'minorUnitDigits': instance.minorUnitDigits,
};
