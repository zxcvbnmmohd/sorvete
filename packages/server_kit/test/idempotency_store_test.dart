import 'package:sorvete_server_kit/sorvete_server_kit.dart';
import 'package:test/test.dart';

void main() {
  group('IdempotencyStore.runOnce', () {
    late InMemoryIdempotencyCacheRepo repo;

    setUp(() => repo = InMemoryIdempotencyCacheRepo());

    IdempotencyStore store({DateTime Function()? clock}) => IdempotencyStore(
      repo: repo,
      window: const Duration(days: 30),
      clock: clock,
    );

    test('runs the action once and returns its result', () async {
      var calls = 0;
      final result = await store().runOnce(
        key: 'k1',
        action: () async {
          calls++;
          return 'value';
        },
      );
      expect(result, 'value');
      expect(calls, 1);
    });

    test(
      'replays the cached result on a duplicate key without re-running',
      () async {
        var calls = 0;
        final s = store();
        Future<int> action() async {
          calls++;
          return calls;
        }

        final first = await s.runOnce(key: 'k', action: action);
        final second = await s.runOnce(key: 'k', action: action);

        expect(first, 1);
        expect(second, 1, reason: 'cached — action must not re-run');
        expect(calls, 1);
      },
    );

    test('isolates distinct keys', () async {
      final s = store();
      expect(await s.runOnce(key: 'a', action: () async => 'A'), 'A');
      expect(await s.runOnce(key: 'b', action: () async => 'B'), 'B');
    });

    test('re-runs once the cache window has elapsed', () async {
      var now = DateTime.utc(2026);
      var calls = 0;
      final s = store(clock: () => now);
      Future<int> action() async {
        calls++;
        return calls;
      }

      await s.runOnce(key: 'k', action: action);
      now = now.add(const Duration(days: 31)); // past the 30-day window
      final again = await s.runOnce(key: 'k', action: action);

      expect(again, 2);
      expect(calls, 2);
    });
  });
}
