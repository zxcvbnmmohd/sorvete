import 'package:serverpod_client/serverpod_client.dart';

/// Holds the active JWT issued by `identity_server` and hands it to every
/// Serverpod typed client. Register as a singleton in `get_it` and pass it
/// into each `<svc>_client.Client(..., authKeyProvider: ...)`.
///
/// Implements the modern [ClientAuthKeyProvider] interface; the older
/// `AuthenticationKeyManager` class is deprecated in serverpod_client 3.4+.
class AppAuthKeyManager implements ClientAuthKeyProvider {
  String? _key;

  @override
  Future<String?> get authHeaderValue async {
    final key = _key;
    if (key == null) return null;
    return wrapAsBearerAuthHeaderValue(key);
  }

  /// Store a freshly-issued JWT. Called by the identity sign-in / refresh flow.
  void put(String key) {
    _key = key;
  }

  /// Drop the JWT (sign-out).
  void remove() {
    _key = null;
  }

  bool get hasKey => _key != null;
}
