// Re-export shim for wallet_client. Use a prefixed import so type names
// (Client, plus generated model classes) don't collide with other services.
//
// Usage:
//   import 'package:sorvete_backend/wallet.dart' as wallet;
export 'package:wallet_client/wallet_client.dart';
