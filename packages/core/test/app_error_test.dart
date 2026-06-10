import 'package:sorvete_core/sorvete_core.dart';
import 'package:test/test.dart';

void main() {
  group('AppError', () {
    test('cases are AppError and Exception', () {
      expect(const NotFoundError(), isA<AppError>());
      expect(const NotFoundError(), isA<Exception>());
    });

    test('carry sensible default messages', () {
      expect(const UnauthenticatedError().message, 'Not signed in');
      expect(const NotFoundError().message, 'Not found');
      expect(const ConflictError().message, 'Conflicting write');
    });

    test('preserve a provided message and cause', () {
      final cause = StateError('boom');
      const message = 'custom';
      final err = ServerError(message, cause);
      expect(err.message, message);
      expect(err.cause, same(cause));
    });
  });
}
