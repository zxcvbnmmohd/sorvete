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

/// A row in a service's outbox table — one domain event awaiting relay to NATS.
/// Written in the same transaction as the domain change (ADR §7). The relay
/// ships unpublished rows and stamps [publishedAt]. Maps to/from the in-memory
/// OutboxEvent in packages/core via ServerpodOutboxRepo.
abstract class OutboxRecord implements _i1.SerializableModel {
  OutboxRecord._({
    this.id,
    required this.eventId,
    required this.type,
    required this.aggregateId,
    required this.occurredAt,
    required this.payload,
    this.publishedAt,
  });

  factory OutboxRecord({
    int? id,
    required String eventId,
    required String type,
    required String aggregateId,
    required DateTime occurredAt,
    required String payload,
    DateTime? publishedAt,
  }) = _OutboxRecordImpl;

  factory OutboxRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutboxRecord(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as String,
      type: jsonSerialization['type'] as String,
      aggregateId: jsonSerialization['aggregateId'] as String,
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      payload: jsonSerialization['payload'] as String,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Application-level event id (UUID v7); dedup key for consumers.
  String eventId;

  /// Event type, e.g. "OrderPlaced".
  String type;

  /// Aggregate root id the event is about.
  String aggregateId;

  /// Event time (event-time, may be past-dated for offline replay).
  DateTime occurredAt;

  /// JSON-encoded event payload.
  String payload;

  /// Null until the relay publishes the row to NATS.
  DateTime? publishedAt;

  /// Returns a shallow copy of this [OutboxRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OutboxRecord copyWith({
    int? id,
    String? eventId,
    String? type,
    String? aggregateId,
    DateTime? occurredAt,
    String? payload,
    DateTime? publishedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'sorvete_server_kit.OutboxRecord',
      if (id != null) 'id': id,
      'eventId': eventId,
      'type': type,
      'aggregateId': aggregateId,
      'occurredAt': occurredAt.toJson(),
      'payload': payload,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutboxRecordImpl extends OutboxRecord {
  _OutboxRecordImpl({
    int? id,
    required String eventId,
    required String type,
    required String aggregateId,
    required DateTime occurredAt,
    required String payload,
    DateTime? publishedAt,
  }) : super._(
         id: id,
         eventId: eventId,
         type: type,
         aggregateId: aggregateId,
         occurredAt: occurredAt,
         payload: payload,
         publishedAt: publishedAt,
       );

  /// Returns a shallow copy of this [OutboxRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OutboxRecord copyWith({
    Object? id = _Undefined,
    String? eventId,
    String? type,
    String? aggregateId,
    DateTime? occurredAt,
    String? payload,
    Object? publishedAt = _Undefined,
  }) {
    return OutboxRecord(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      aggregateId: aggregateId ?? this.aggregateId,
      occurredAt: occurredAt ?? this.occurredAt,
      payload: payload ?? this.payload,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
    );
  }
}
