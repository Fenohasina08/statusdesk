import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/hive_config.dart';
import 'providers/service_provider.dart';
import 'repositories/service_repository.dart';
import 'services/service_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveConfig.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ServiceProvider(
        repository: ServiceRepository(
          api: ServiceApi(baseUrl: 'https://ton-api.example.com'),
        ),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatusDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePlaceholder(),
    );
  }
}

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StatusDesk')),
      body: const Center(
        child: Text('Foundations ready ✅ — Dashboard coming soon'),
      ),
    );
  }
}