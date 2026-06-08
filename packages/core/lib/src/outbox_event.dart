import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_event.freezed.dart';
part 'outbox_event.g.dart';

/// The envelope every domain event travels in, from a service's `outbox` table
/// through NATS to consumers (ARCHITECTURE.md §7). [publishedAt] is null until
/// the outbox relay ships it.
@freezed
abstract class OutboxEvent with _$OutboxEvent {
  const factory OutboxEvent({
    required String id,
    required String type,
    required String aggregateId,
    required DateTime occurredAt,
    required Map<String, dynamic> payload,
    DateTime? publishedAt,
  }) = _OutboxEvent;

  factory OutboxEvent.fromJson(Map<String, dynamic> json) =>
      _$OutboxEventFromJson(json);
}
