import 'package:flutter/material.dart';
import 'package:sorvete_backend/sorvete_backend.dart';

void main() {
  runApp(const SorveteAdminApp());
}

class SorveteAdminApp extends StatelessWidget {
  const SorveteAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Flavor comes from `--dart-define=FLAVOR=<dev|staging|prod>`.
    // Default to dev so `flutter run -d web-server` Just Works locally.
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    return MaterialApp(
      title: 'Sorvete Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HealthDashboard(
        registry: ServiceRegistry.sorvete(flavor: flavor),
        title: 'Sorvete platform health — $flavor',
      ),
    );
  }
}
