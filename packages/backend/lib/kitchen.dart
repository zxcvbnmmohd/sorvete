// Re-export shim for kitchen_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/kitchen.dart' as kitchen;
export 'package:kitchen_client/kitchen_client.dart';
