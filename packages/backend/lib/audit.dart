// Re-export shim for audit_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/audit.dart' as audit;
export 'package:audit_client/audit_client.dart';
