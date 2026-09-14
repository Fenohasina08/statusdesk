import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/service_provider.dart';
import 'repositories/service_repository.dart';
import 'services/service_api.dart';

void main() {
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
      appBar: AppBar(
          title: Column(
            children: [
              const Text('StatusDesk',style: TextStyle(fontSize: 30),),
              const Text("Etat des services")
            ],
          ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Foundations ready ✅ — Dashboard coming soon'),
      ),
    );
  }
}
