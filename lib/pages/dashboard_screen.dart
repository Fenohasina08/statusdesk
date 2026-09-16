import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
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
  final List<int> _history = [0];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _history.remove(index);
        _history.add(_currentIndex);
        _currentIndex = index;
      });
    }
  }

  void _goToPreviousTab() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentIndex = _history.removeLast();
      });
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le bandeau s'affiche si la connexion est perdue OU si l'utilisateur active manuellement le mode hors-ligne
    final serviceProvider = context.watch<ServiceProvider>();
    final isOffline = serviceProvider.isOffline || serviceProvider.offlineModeEnabled;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final unselectedColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final List<Widget> pages = [
      const Accueil(),
      const Services(),
      Parametres(onBackPressed: _goToPreviousTab),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Bandeau d'alerte automatique affiché tout en haut si hors-ligne
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isOffline ? 36.0 : 0.0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                color: const Color(0xffff9800),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Mode hors-ligne actif (Données en cache)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Corps de l'application (les onglets)
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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