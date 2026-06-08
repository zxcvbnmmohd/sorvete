import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sorvete_core/sorvete_core.dart';

import 'nats_protocol.dart';
import 'outbox_relay.dart';

/// A thin core-NATS connection over TCP: connect, publish, and subscribe.
/// JetStream is out of scope (see the JetStream follow-up issue); durability
/// is provided by the outbox + idempotent consumers, not the broker.
class NatsBus {
  NatsBus._(this._socket) {
    _socket.listen(_onData, onDone: _closeSubscriptions);
  }

  final Socket _socket;
  final _parser = NatsParser();
  final _subscriptions = <String, StreamController<NatsMsg>>{};
  var _sidSeq = 0;

  /// Opens a TCP connection to [uri] (e.g. `nats://localhost:4222`) and sends
  /// the CONNECT handshake.
  static Future<NatsBus> connect(Uri uri, {String name = 'sorvete'}) async {
    final socket = await Socket.connect(uri.host, uri.port);
    final bus = NatsBus._(socket);
    bus._send(
      NatsProtocol.connect({
        'verbose': false,
        'pedantic': false,
        'name': name,
        'lang': 'dart',
        'version': '0.1.0',
      }),
    );
    await socket.flush();
    return bus;
  }

  void _onData(List<int> data) {
    for (final message in _parser.feed(data)) {
      switch (message) {
        case NatsPing():
          _send(NatsProtocol.pong());
        case NatsMsg():
          _subscriptions[message.sid]?.add(message);
        default:
          break;
      }
    }
  }

  void _send(List<int> bytes) => _socket.add(bytes);

  void publish({required String subject, required List<int> payload}) =>
      _send(NatsProtocol.pub(subject: subject, payload: payload));

  /// Subscribes to [subject], returning a stream of matching messages.
  Stream<NatsMsg> subscribe(String subject) {
    final sid = (++_sidSeq).toString();
    final controller = StreamController<NatsMsg>.broadcast();
    _subscriptions[sid] = controller;
    _send(NatsProtocol.sub(subject: subject, sid: sid));
    return controller.stream;
  }

  /// Flushes pending writes (useful before publishing in a tight test).
  Future<void> flush() => _socket.flush();

  Future<void> close() async {
    await _socket.flush();
    _socket.destroy();
    _closeSubscriptions();
  }

  void _closeSubscriptions() {
    for (final controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();
  }
}

/// [EventPublisher] backed by core NATS: serializes an [OutboxEvent] to JSON and
/// publishes it to its subject.
class NatsEventPublisher implements EventPublisher {
  NatsEventPublisher(this.bus);

  final NatsBus bus;

  @override
  Future<void> publish({
    required String subject,
    required OutboxEvent event,
  }) async {
    bus.publish(
      subject: subject,
      payload: utf8.encode(jsonEncode(event.toJson())),
    );
    await bus.flush();
  }
}
