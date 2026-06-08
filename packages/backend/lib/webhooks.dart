// Re-export shim for webhooks_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/webhooks.dart' as webhooks;
export 'package:webhooks_client/webhooks_client.dart';
