import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:sorvete_core/sorvete_core.dart';

import '../generated/protocol.dart';
import '../outbox.dart';

/// Serverpod/Postgres-backed [OutboxRepo], mapping between the [OutboxRecord]
/// table rows and the in-memory [OutboxEvent]. Constructed per request with the
/// active [session]; `append` runs inside that session's transaction.
class ServerpodOutboxRepo implements OutboxRepo {
  ServerpodOutboxRepo(this.session);

  final Session session;

  @override
  Future<void> append(OutboxEvent event) async {
    await OutboxRecord.db.insertRow(session, _toRecord(event));
  }

  @override
  Future<List<OutboxEvent>> fetchUnpublished({int limit = 100}) async {
    final rows = await OutboxRecord.db.find(
      session,
      where: (t) => t.publishedAt.equals(null),
      orderBy: (t) => t.occurredAt,
      limit: limit,
    );
    return rows.map(_toEvent).toList(growable: false);
  }

  @override
  Future<void> markPublished({
    required String id,
    required DateTime publishedAt,
  }) async {
    final rows = await OutboxRecord.db.find(
      session,
      where: (t) => t.eventId.equals(id),
      limit: 1,
    );
    if (rows.isEmpty) return;
    await OutboxRecord.db.updateRow(
      session,
      rows.first.copyWith(publishedAt: publishedAt),
    );
  }

  OutboxRecord _toRecord(OutboxEvent e) => OutboxRecord(
    eventId: e.id,
    type: e.type,
    aggregateId: e.aggregateId,
    occurredAt: e.occurredAt,
    payload: jsonEncode(e.payload),
    publishedAt: e.publishedAt,
  );

  OutboxEvent _toEvent(OutboxRecord r) => OutboxEvent(
    id: r.eventId,
    type: r.type,
    aggregateId: r.aggregateId,
    occurredAt: r.occurredAt,
    payload: jsonDecode(r.payload) as Map<String, dynamic>,
    publishedAt: r.publishedAt,
  );
}
