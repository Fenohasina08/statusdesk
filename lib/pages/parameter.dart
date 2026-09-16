import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  bool _autoRefresh = true;
  bool _offlineMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 20),

          // Section : Apparence
          _buildSectionHeader('Apparence'),
          _buildCard(children: [
            _buildListTile(
              icon: Icons.nightlight_outlined,
              title: 'Thème',
              trailingText: 'Système',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              icon: Icons.language_outlined,
              title: 'Langue',
              trailingText: 'Français',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // Section : Actualisation
          _buildSectionHeader('Actualisation'),
          _buildCard(children: [
            SwitchListTile(
              secondary: const Icon(Icons.sync_outlined, color: Color(0xff2196f3)),
              title: const Text(
                'Actualisation automatique',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              value: _autoRefresh,
              activeColor: const Color(0xff2196f3),
              onChanged: (val) => setState(() => _autoRefresh = val),
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              icon: Icons.access_time_rounded,
              title: 'Intervalle',
              trailingText: '5 minutes',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // Section : Cache
          _buildSectionHeader('Cache'),
          _buildCard(children: [
            SwitchListTile(
              secondary: const Icon(Icons.cloud_off_outlined, color: Color(0xff2196f3)),
              title: const Text(
                'Mode hors connexion',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              value: _offlineMode,
              activeColor: const Color(0xff2196f3),
              onChanged: (val) => setState(() => _offlineMode = val),
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              icon: Icons.folder_delete_outlined,
              title: 'Vider le cache',
              trailingText: '12,5 Mo',
              onTap: () async {
                final cacheService = CacheService();
                await cacheService.clearServices();
                await cacheService.clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache vidé avec succès')),
                  );
                }
              },
            ),
          ]),

          const SizedBox(height: 20),

          // Section : À propos
          _buildSectionHeader('À propos'),
          _buildCard(children: [
            _buildListTile(
              icon: Icons.info_outline_rounded,
              title: 'StatusDesk v1.0.0',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xff475569),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff2196f3)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}