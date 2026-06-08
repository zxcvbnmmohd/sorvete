// Re-export shim for config_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/config.dart' as config;
export 'package:config_client/config_client.dart';
