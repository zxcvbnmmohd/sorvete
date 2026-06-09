import 'package:serverpod/serverpod.dart';
import 'package:sorvete_core/sorvete_core.dart';

import '../adapters/serverpod_outbox_repo.dart';
import '../outbox.dart';

/// Dev/test-only endpoint that enqueues a synthetic event into the calling
/// service's outbox, so the async rail can be exercised end-to-end (the E2E in
/// issue #6 calls this on `identity`). Refuses to run in production run-mode.
class TestEventEndpoint extends Endpoint {
  /// Enqueues a synthetic [OutboxEvent] of the given [type]; returns its id.
  Future<String> emitTestEvent(Session session, String type) async {
    if (Serverpod.instance.runMode == ServerpodRunMode.production) {
      throw StateError('emitTestEvent is disabled in production');
    }

    final event = OutboxEvent(
      id: Ids.newId(),
      type: type,
      aggregateId: Ids.newId(),
      occurredAt: PastDatedTimestamp.now(),
      payload: const {'synthetic': true},
    );
    await OutboxWriter(
      repo: ServerpodOutboxRepo(session),
    ).enqueue(event: event);
    return event.id;
  }
}
