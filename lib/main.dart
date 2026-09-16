import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/l10n/app_localizations.dart';

import 'core/storage/hive_config.dart';
import 'pages/dashboard_screen.dart';
import 'providers/locale_provider.dart'; // <--- Import du provider de langue
import 'providers/service_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/service_repository.dart';
import 'services/cache_service.dart';
import 'services/service_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  await CacheService.init();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider(
          create: (_) => LocaleNotifier(),
        ), // <--- Ajouté ici
        ChangeNotifierProvider(
          create: (_) =>
              ServiceProvider(
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
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeNotifier = context
        .watch<LocaleNotifier>(); // <--- Écoute de la langue

    return MaterialApp(
      title: 'StatusDesk',
      debugShowCheckedModeBanner: false,

      // Configuration des langues
      locale: localeNotifier.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      themeMode: themeNotifier.themeMode,
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
