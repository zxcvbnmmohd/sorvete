import 'package:uuid/uuid.dart';

/// Generates idempotency keys (UUID v7) for every mutating endpoint call.
///
/// Per ARCHITECTURE.md §10 every mutation across all 32 services accepts an
/// `idempotencyKey` argument; the server caches the result for 30 days so
/// retried requests don't double-write.
///
/// UUID v7 is time-ordered, which also makes these usable as primary keys
/// for offline-generated rows (POS app, see ARCHITECTURE.md §8).
class IdempotencyKey {
  static const _uuid = Uuid();

  static String next() => _uuid.v7();
}
