// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxEvent _$OutboxEventFromJson(Map<String, dynamic> json) => _OutboxEvent(
  id: json['id'] as String,
  type: json['type'] as String,
  aggregateId: json['aggregateId'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  payload: json['payload'] as Map<String, dynamic>,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$OutboxEventToJson(_OutboxEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'aggregateId': instance.aggregateId,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'payload': instance.payload,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };
