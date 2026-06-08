import 'package:flutter_test/flutter_test.dart';
import 'package:sorvete_backend/sorvete_backend.dart';

void main() {
  group('ServerpodConfig', () {
    test('dev flavor maps each service to its own 8100+index port', () {
      // No --dart-define=FLAVOR in `dart test` → defaults to 'dev'.
      // Ports match docker-compose.dev.yml: identity=8110, ordering=8119.
      expect(
        ServerpodConfig.urlFor('identity'),
        equals('http://localhost:8110/'),
      );
      expect(
        ServerpodConfig.urlFor('ordering'),
        equals('http://localhost:8119/'),
      );
    });

    test('dev port matches the service registry index', () {
      const service = 'payments';
      final index = ServiceRegistry.serviceNames.indexOf(service);
      expect(
        ServerpodConfig.urlFor(service),
        equals('http://localhost:${ServiceRegistry.devPortBase + index}/'),
      );
    });

    test('throws on an unknown service rather than guessing a port', () {
      expect(
        () => ServerpodConfig.urlFor('not_a_service'),
        throwsArgumentError,
      );
    });

    test('flavor getter exposes the resolved environment', () {
      expect(ServerpodConfig.flavor, isNotEmpty);
    });
  });
}
