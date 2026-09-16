import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/hive_config.dart';
import 'pages/dashboard_screen.dart';
import 'providers/service_provider.dart';
import 'repositories/service_repository.dart';
import 'services/cache_service.dart';
import 'services/service_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  await CacheService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ServiceProvider(
        repository: ServiceRepository(
          api: ServiceApi(),
          cache: CacheService(),
        ),
      )
        ..initialize()
        ..startPolling(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'StatusDesk',//
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      );
}