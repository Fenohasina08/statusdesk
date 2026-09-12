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