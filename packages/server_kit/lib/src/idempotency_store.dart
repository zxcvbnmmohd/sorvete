// Server-side idempotency: run a keyed action at most once within a window,
// replaying the cached result on duplicate calls (ADR-0006 §4 — 30-day
// window). The cache lives behind IdempotencyCacheRepo so this unit-tests in
// memory; the Postgres-backed impl binds when a service wires it (issue #5).

/// A clock, injectable so the cache window is deterministic in tests.
typedef Clock = DateTime Function();

/// One cached idempotency result and when it was stored.
class IdempotencyEntry {
  const IdempotencyEntry({required this.value, required this.storedAt});

  final Object? value;
  final DateTime storedAt;
}

/// Persistence port for the idempotency cache.
abstract interface class IdempotencyCacheRepo {
  Future<IdempotencyEntry?> lookup(String key);
  Future<void> save({required String key, required IdempotencyEntry entry});
}

/// In-memory [IdempotencyCacheRepo] for tests.
class InMemoryIdempotencyCacheRepo implements IdempotencyCacheRepo {
  final _entries = <String, IdempotencyEntry>{};

  @override
  Future<IdempotencyEntry?> lookup(String key) async => _entries[key];

  @override
  Future<void> save({
    required String key,
    required IdempotencyEntry entry,
  }) async => _entries[key] = entry;
}

class IdempotencyStore {
  IdempotencyStore({
    required IdempotencyCacheRepo repo,
    required Duration window,
    Clock? clock,
  }) : _repo = repo,
       _window = window,
       _clock = clock ?? DateTime.now;

  final IdempotencyCacheRepo _repo;
  final Duration _window;
  final Clock _clock;

  /// Runs [action] only if [key] has not been seen within the window;
  /// otherwise returns the cached result without re-running.
  Future<T> runOnce<T>({
    required String key,
    required Future<T> Function() action,
  }) async {
    final existing = await _repo.lookup(key);
    if (existing != null && _clock().difference(existing.storedAt) <= _window) {
      return existing.value as T;
    }
    final result = await action();
    await _repo.save(
      key: key,
      entry: IdempotencyEntry(value: result, storedAt: _clock()),
    );
    return result;
  }
}
