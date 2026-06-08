/// Stamps a moment in time at the point a mutation is *recorded*, not the
/// moment it reaches the server.
///
/// Offline-POS replay (see ARCHITECTURE.md §8) requires that when an Order is
/// drafted offline at 14:32 and synced at 14:47, the server treats `placedAt`
/// as 14:32. Every mutating endpoint accepts an `occurredAt` argument; clients
/// stamp it via `PastDatedTimestamp.now()` before queuing.
///
/// Contract present from Wave 0 even though the offline engine ships in Wave 5.
class PastDatedTimestamp {
  const PastDatedTimestamp._();

  static DateTime now() => DateTime.now().toUtc();
}
