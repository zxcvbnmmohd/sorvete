import 'dart:convert';

// Minimal NATS core-protocol codec (text wire format over TCP). Pure and
// unit-testable; the socket lives in NatsClient. JetStream is out of scope —
// see the JetStream follow-up issue.

const _cr = 13;
const _lf = 10;

/// Encoders for the client→server NATS commands we use.
class NatsProtocol {
  const NatsProtocol._();

  static List<int> connect(Map<String, Object?> options) =>
      utf8.encode('CONNECT ${jsonEncode(options)}\r\n');

  static List<int> pub({required String subject, required List<int> payload}) =>
      [
        ...utf8.encode('PUB $subject ${payload.length}\r\n'),
        ...payload,
        _cr,
        _lf,
      ];

  static List<int> sub({required String subject, required String sid}) =>
      utf8.encode('SUB $subject $sid\r\n');

  static List<int> pong() => utf8.encode('PONG\r\n');
}

/// A message received from the NATS server.
sealed class NatsServerMessage {
  const NatsServerMessage();
}

class NatsInfo extends NatsServerMessage {
  const NatsInfo(this.json);
  final String json;
}

class NatsPing extends NatsServerMessage {
  const NatsPing();
}

class NatsPong extends NatsServerMessage {
  const NatsPong();
}

class NatsOk extends NatsServerMessage {
  const NatsOk();
}

class NatsErr extends NatsServerMessage {
  const NatsErr(this.detail);
  final String detail;
}

class NatsMsg extends NatsServerMessage {
  const NatsMsg({
    required this.subject,
    required this.sid,
    required this.payload,
    this.replyTo,
  });
  final String subject;
  final String sid;
  final String? replyTo;
  final List<int> payload;
}

/// Incremental parser: feed it raw bytes from the socket and it returns the
/// complete server messages decoded so far, buffering partial frames.
class NatsParser {
  final _buffer = <int>[];
  ({String subject, String sid, String? replyTo, int bytes})? _pending;

  List<NatsServerMessage> feed(List<int> chunk) {
    _buffer.addAll(chunk);
    final out = <NatsServerMessage>[];

    while (true) {
      // Awaiting the payload of a MSG whose header we already read.
      if (_pending != null) {
        final need = _pending!.bytes + 2; // payload + trailing CRLF
        if (_buffer.length < need) break;
        final payload = _buffer.sublist(0, _pending!.bytes);
        _buffer.removeRange(0, need);
        out.add(
          NatsMsg(
            subject: _pending!.subject,
            sid: _pending!.sid,
            replyTo: _pending!.replyTo,
            payload: payload,
          ),
        );
        _pending = null;
        continue;
      }

      final eol = _indexOfCrlf();
      if (eol < 0) break;
      final line = utf8.decode(_buffer.sublist(0, eol));
      _buffer.removeRange(0, eol + 2);

      final message = _parseControlLine(line);
      if (message != null) out.add(message);
    }

    return out;
  }

  int _indexOfCrlf() {
    for (var i = 0; i + 1 < _buffer.length; i++) {
      if (_buffer[i] == _cr && _buffer[i + 1] == _lf) return i;
    }
    return -1;
  }

  /// Returns the parsed message, or null for a MSG header (whose payload is
  /// read on the next loop iteration via [_pending]).
  NatsServerMessage? _parseControlLine(String line) {
    if (line == 'PING') return const NatsPing();
    if (line == 'PONG') return const NatsPong();
    if (line == '+OK') return const NatsOk();
    if (line.startsWith('-ERR')) return NatsErr(line.substring(4).trim());
    if (line.startsWith('INFO ')) return NatsInfo(line.substring(5));
    if (line.startsWith('MSG ')) {
      final tokens = line.split(' ');
      // MSG <subject> <sid> [reply-to] <#bytes>
      _pending = (
        subject: tokens[1],
        sid: tokens[2],
        replyTo: tokens.length == 5 ? tokens[3] : null,
        bytes: int.parse(tokens.last),
      );
      return null;
    }
    return null;
  }
}
