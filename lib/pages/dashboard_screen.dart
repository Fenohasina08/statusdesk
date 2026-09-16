import 'package:flutter/material.dart';
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
  
  // Historique des onglets pour gérer le bouton retour intelligent
  final List<int> _history = [0];

  // Fonction pour changer d'onglet en mémorisant l'historique
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _history.remove(index); // Évite les doublons
        _history.add(_currentIndex); // Mémorise l'onglet précédent
        _currentIndex = index;
      });
    }
  }

  // Fonction pour retourner à l'onglet précédent
  void _goToPreviousTab() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentIndex = _history.removeLast();
      });
    } else {
      setState(() {
        _currentIndex = 0; // Par défaut, retourne à l'Accueil
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final navBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final unselectedColor = isDark ? Colors.grey.shade400 : Colors.grey;

    // On passe le callback de retour à la page Parametres
    final List<Widget> pages = [
      const Accueil(),
      const Services(),
      Parametres(onBackPressed: _goToPreviousTab),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
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