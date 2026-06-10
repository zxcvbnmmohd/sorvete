/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A cached idempotency result, keyed by client-supplied idempotency key.
/// Backs IdempotencyStore so a retried mutation replays its cached response
/// (ADR-0006 §4, 30-day window). Maps to/from IdempotencyEntry via
/// ServerpodIdempotencyCacheRepo.
abstract class IdempotencyRecord implements _i1.SerializableModel {
  IdempotencyRecord._({
    this.id,
    required this.key,
    this.value,
    required this.storedAt,
  });

  factory IdempotencyRecord({
    int? id,
    required String key,
    String? value,
    required DateTime storedAt,
  }) = _IdempotencyRecordImpl;

  factory IdempotencyRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdempotencyRecord(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String?,
      storedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['storedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The idempotency key (or "<consumer>:<eventId>" for consumer dedup).
  String key;

  /// JSON-encoded cached response; null for side-effect-only (consumer) keys.
  String? value;

  /// When the entry was stored (drives the expiry window).
  DateTime storedAt;

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IdempotencyRecord copyWith({
    int? id,
    String? key,
    String? value,
    DateTime? storedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'sorvete_server_kit.IdempotencyRecord',
      if (id != null) 'id': id,
      'key': key,
      if (value != null) 'value': value,
      'storedAt': storedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdempotencyRecordImpl extends IdempotencyRecord {
  _IdempotencyRecordImpl({
    int? id,
    required String key,
    String? value,
    required DateTime storedAt,
  }) : super._(
         id: id,
         key: key,
         value: value,
         storedAt: storedAt,
       );

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IdempotencyRecord copyWith({
    Object? id = _Undefined,
    String? key,
    Object? value = _Undefined,
    DateTime? storedAt,
  }) {
    return IdempotencyRecord(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value is String? ? value : this.value,
      storedAt: storedAt ?? this.storedAt,
    );
  }
}
