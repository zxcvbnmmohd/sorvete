import 'package:flutter_test/flutter_test.dart';
import 'package:sorvete_backend/sorvete_backend.dart';

void main() {
  group('ServerpodConfig', () {
    test('defaults to localhost when no flavor is set', () {
      // No --dart-define=FLAVOR in `dart test` → defaults to 'dev'.
      expect(
        ServerpodConfig.urlFor('identity'),
        equals('http://localhost:8080/'),
      );
      expect(
        ServerpodConfig.urlFor('ordering'),
        equals('http://localhost:8080/'),
      );
    });

    test('flavor getter exposes the resolved environment', () {
      expect(ServerpodConfig.flavor, isNotEmpty);
    });
  });
}
