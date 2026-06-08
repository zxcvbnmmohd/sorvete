import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:sorvete_backend/sorvete_backend.dart';

void main() {
  group('mapServerpodError', () {
    test('401 → UnauthenticatedError', () {
      final err = mapServerpodError(ServerpodClientException('nope', 401));
      expect(err, isA<UnauthenticatedError>());
    });

    test('403 → ForbiddenError', () {
      expect(
        mapServerpodError(ServerpodClientException('no', 403)),
        isA<ForbiddenError>(),
      );
    });

    test('404 → NotFoundError', () {
      expect(
        mapServerpodError(ServerpodClientException('missing', 404)),
        isA<NotFoundError>(),
      );
    });

    test('409 → ConflictError', () {
      expect(
        mapServerpodError(ServerpodClientException('conflict', 409)),
        isA<ConflictError>(),
      );
    });

    test('429 → RateLimitedError', () {
      expect(
        mapServerpodError(ServerpodClientException('slow', 429)),
        isA<RateLimitedError>(),
      );
    });

    test('500 → ServerError', () {
      expect(
        mapServerpodError(ServerpodClientException('boom', 500)),
        isA<ServerError>(),
      );
    });

    test('AppError passes through unchanged', () {
      const original = NotFoundError('cached');
      expect(mapServerpodError(original), same(original));
    });

    test('unrecognized non-Serverpod error → NetworkError', () {
      expect(
        mapServerpodError(StateError('socket closed')),
        isA<NetworkError>(),
      );
    });
  });
}
