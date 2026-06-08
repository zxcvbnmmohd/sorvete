// Re-export shim for identity_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/identity.dart' as identity;
export 'package:identity_client/identity_client.dart';
