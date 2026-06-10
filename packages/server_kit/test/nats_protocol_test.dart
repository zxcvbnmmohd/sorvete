import 'dart:convert';

import 'package:sorvete_server_kit_server/sorvete_server_kit_server.dart';
import 'package:test/test.dart';

String text(List<int> bytes) => utf8.decode(bytes);

void main() {
  group('NatsProtocol encoders', () {
    test('connect serializes options as a CONNECT <json> line', () {
      final bytes = NatsProtocol.connect({'name': 'sorvete', 'lang': 'dart'});
      expect(text(bytes), 'CONNECT {"name":"sorvete","lang":"dart"}\r\n');
    });

    test('pub frames subject, byte length, and payload', () {
      final bytes = NatsProtocol.pub(
        subject: 'outbox.identity',
        payload: utf8.encode('hi'),
      );
      expect(text(bytes), 'PUB outbox.identity 2\r\nhi\r\n');
    });

    test('pub counts UTF-8 bytes, not characters', () {
      final bytes = NatsProtocol.pub(subject: 'x', payload: utf8.encode('é'));
      expect(text(bytes), 'PUB x 2\r\né\r\n');
    });

    test('sub frames subject and sid', () {
      expect(
        text(NatsProtocol.sub(subject: 'outbox.identity', sid: '1')),
        'SUB outbox.identity 1\r\n',
      );
    });

    test('pong', () => expect(text(NatsProtocol.pong()), 'PONG\r\n'));
  });

  group('NatsParser', () {
    test('parses INFO', () {
      final msgs = NatsParser().feed(utf8.encode('INFO {"server_id":"x"}\r\n'));
      expect(msgs.single, isA<NatsInfo>());
      expect((msgs.single as NatsInfo).json, '{"server_id":"x"}');
    });

    test('parses PING', () {
      expect(
        NatsParser().feed(utf8.encode('PING\r\n')).single,
        isA<NatsPing>(),
      );
    });

    test('parses a MSG with payload', () {
      final m =
          NatsParser()
                  .feed(utf8.encode('MSG outbox.identity 1 2\r\nhi\r\n'))
                  .single
              as NatsMsg;
      expect(m.subject, 'outbox.identity');
      expect(m.sid, '1');
      expect(m.replyTo, isNull);
      expect(utf8.decode(m.payload), 'hi');
    });

    test('parses a MSG with reply-to', () {
      final m =
          NatsParser().feed(utf8.encode('MSG sub 1 reply 2\r\nhi\r\n')).single
              as NatsMsg;
      expect(m.replyTo, 'reply');
      expect(utf8.decode(m.payload), 'hi');
    });

    test('reassembles a MSG split across chunks', () {
      final parser = NatsParser();
      expect(parser.feed(utf8.encode('MSG sub 1 5\r\nhel')), isEmpty);
      final msgs = parser.feed(utf8.encode('lo\r\n'));
      expect(utf8.decode((msgs.single as NatsMsg).payload), 'hello');
    });

    test('parses multiple frames in one chunk', () {
      final msgs = NatsParser().feed(utf8.encode('PING\r\nMSG s 1 1\r\nx\r\n'));
      expect(msgs, hasLength(2));
      expect(msgs[0], isA<NatsPing>());
      expect(utf8.decode((msgs[1] as NatsMsg).payload), 'x');
    });
  });
}
