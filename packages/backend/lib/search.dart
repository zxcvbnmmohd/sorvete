// Re-export shim for search_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/search.dart' as search;
export 'package:search_client/search_client.dart';
