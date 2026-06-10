import 'package:uuid/uuid.dart';

/// Time-ordered UUID v7 id generation. v7 ids sort by creation time, which
/// makes them DB-index-friendly and safe to generate offline (POS, Wave 5).
/// Used as the primary-key strategy across every Sorvete service.
class Ids {
  const Ids._();

  static const _uuid = Uuid();

  /// A fresh UUID v7 string.
  static String newId() => _uuid.v7();
}

/// Idempotency keys are UUID v7 (see [Ids]). Kept as a named type so call
/// sites at mutating endpoints read intentionally.
class IdempotencyKey {
  const IdempotencyKey._();

  /// A fresh idempotency key (UUID v7).
  static String next() => Ids.newId();
}
