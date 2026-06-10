/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;

/// Dev/test-only endpoint that enqueues a synthetic event into the calling
/// service's outbox, so the async rail can be exercised end-to-end (the E2E in
/// issue #6 calls this on `identity`). Refuses to run in production run-mode.
/// {@category Endpoint}
class EndpointTestEvent extends _i1.EndpointRef {
  EndpointTestEvent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sorvete_server_kit.testEvent';

  /// Enqueues a synthetic [OutboxEvent] of the given [type]; returns its id.
  _i2.Future<String> emitTestEvent(String type) =>
      caller.callServerEndpoint<String>(
        'sorvete_server_kit.testEvent',
        'emitTestEvent',
        {'type': type},
      );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    testEvent = EndpointTestEvent(this);
  }

  late final EndpointTestEvent testEvent;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'sorvete_server_kit.testEvent': testEvent,
  };
}
