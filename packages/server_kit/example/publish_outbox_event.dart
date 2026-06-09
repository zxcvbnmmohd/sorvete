// Dev helper: publish a synthetic OutboxEvent to a NATS subject, to exercise a
// consumer end-to-end without booting a publishing service.
//   dart run example/publish_outbox_event.dart [eventId] [subject]
import 'dart:io';

import 'package:sorvete_core/sorvete_core.dart';
import 'package:sorvete_server_kit_server/sorvete_server_kit_server.dart';

Future<void> main(List<String> args) async {
  final eventId = args.isNotEmpty ? args[0] : Ids.newId();
  final subject = args.length > 1 ? args[1] : 'outbox.identity';
  final natsUri = Uri.parse(
    Platform.environment['NATS_URL'] ?? 'nats://localhost:4222',
  );

  final bus = await NatsBus.connect(natsUri, name: 'e2e-publisher');
  final event = OutboxEvent(
    id: eventId,
    type: 'TestEvent',
    aggregateId: Ids.newId(),
    occurredAt: DateTime.now().toUtc(),
    payload: const {'synthetic': true},
  );
  await NatsEventPublisher(bus).publish(subject: subject, event: event);
  await bus.close();
  stdout.writeln(eventId);
}
