import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/hive_config.dart';
import 'pages/dashboard_screen.dart';
import 'providers/service_provider.dart';
import 'providers/theme_provider.dart'; // <--- Import du provider de thème
import 'repositories/service_repository.dart';
import 'services/cache_service.dart';
import 'services/service_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  await CacheService.init();

  // Initialisation du gestionnaire de thème
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(
            repository: ServiceRepository(
              api: ServiceApi(),
              cache: CacheService(),
            ),
          )
            ..initialize()
            ..startPolling(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le thème en temps réel
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'StatusDesk',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode, // <--- Applique le mode (System/Light/Dark)
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
    );
  }
}