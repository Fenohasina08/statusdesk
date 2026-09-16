import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class Parametres extends StatelessWidget {
  const Parametres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
        children: [
          const Text(
            'Paramètres', // Affichage avec accent dans l'UI
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage, color: Color(0xff2196f3)),
                  title: const Text('Vider le cache des services',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Supprimer les données locales enregistrées'),
                  onTap: () async {
                    final cacheService = CacheService();
                    await cacheService.clearServices();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cache des services vidé avec succès')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: Color(0xff2196f3)),
                  title: const Text('Effacer l\'historique',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Supprimer l\'historique des vérifications'),
                  onTap: () async {
                    final cacheService = CacheService();
                    await cacheService.clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Historique effacé avec succès')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xff607d8b)),
                  title: Text('À propos de StatusDesk',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Version 1.0.0 • Monitoring de services'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}