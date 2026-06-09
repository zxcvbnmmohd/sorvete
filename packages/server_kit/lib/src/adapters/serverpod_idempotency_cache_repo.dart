import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../idempotency_store.dart';

/// Serverpod/Postgres-backed [IdempotencyCacheRepo], mapping between the
/// [IdempotencyRecord] table rows and [IdempotencyEntry]. Cached responses are
/// stored JSON-encoded (null for side-effect-only consumer keys).
class ServerpodIdempotencyCacheRepo implements IdempotencyCacheRepo {
  ServerpodIdempotencyCacheRepo(this.session);

  final Session session;

  @override
  Future<IdempotencyEntry?> lookup(String key) async {
    final rows = await IdempotencyRecord.db.find(
      session,
      where: (t) => t.key.equals(key),
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return IdempotencyEntry(
      value: row.value == null ? null : jsonDecode(row.value!),
      storedAt: row.storedAt,
    );
  }

  @override
  Future<void> save({
    required String key,
    required IdempotencyEntry entry,
  }) async {
    await IdempotencyRecord.db.insertRow(
      session,
      IdempotencyRecord(
        key: key,
        value: entry.value == null ? null : jsonEncode(entry.value),
        storedAt: entry.storedAt,
      ),
    );
  }
}
