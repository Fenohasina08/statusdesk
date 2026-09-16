import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/l10n/app_localizations.dart';
import 'package:statusdesk/providers/locale_provider.dart';

import 'accueil.dart';
import 'parameter.dart';
import 'services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Accueil(),
    const Services(),
    const Parametres(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Couleurs adaptatives pour la barre de navigation
    final navBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final unselectedColor = isDark ? Colors.grey.shade400 : Colors.grey;

    // On écoute le gestionnaire de langue pour afficher dynamiquement l'état actuel
    final localeNotifier = context.watch<LocaleNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.statusDesk ?? 'StatusDesk'),
        actions: [
          // Bouton cliquable pour changer la langue
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: 'Changer de langue / Change language',
            onSelected: (Locale newLocale) {
              localeNotifier.setLocale(newLocale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('fr'),
                child: Row(
                  children: [
                    const Text('🇫🇷'),
                    const SizedBox(width: 8),
                    Text(
                      'Français',
                      style: TextStyle(
                        fontWeight: localeNotifier.locale.languageCode == 'fr'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: const Locale('en'),
                child: Row(
                  children: [
                    const Text('🇬🇧'),
                    const SizedBox(width: 8),
                    Text(
                      'English',
                      style: TextStyle(
                        fontWeight: localeNotifier.locale.languageCode == 'en'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: navBgColor,
        selectedItemColor: const Color(0xff2196f3),
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            activeIcon: Icon(Icons.list),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}