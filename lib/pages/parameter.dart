import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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
    final themeNotifier = context.watch<ThemeNotifier>();
    
    // Détecter si le thème actuel est sombre
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Couleurs dynamiques selon le mode clair / sombre
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xfff8f9fa);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor, // <--- S'adapte au thème
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
        children: [
          Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor, // <--- S'adapte au thème
            ),
          ),
          const SizedBox(height: 20),

          // Section : Apparence
          _buildSectionHeader('Apparence', textColor),
          _buildCard(cardColor, borderColor, children: [
            _buildListTile(
              icon: Icons.nightlight_outlined,
              title: 'Thème',
              trailingText: themeNotifier.themeLabel,
              textColor: textColor,
              onTap: () => _showThemeDialog(context, themeNotifier),
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.language_outlined,
              title: 'Langue',
              trailingText: 'Français',
              textColor: textColor,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // Section : Actualisation
          _buildSectionHeader('Actualisation', textColor),
          _buildCard(cardColor, borderColor, children: [
            SwitchListTile(
              secondary: const Icon(Icons.sync_outlined, color: Color(0xff2196f3)),
              title: Text(
                'Actualisation automatique',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
              ),
              value: _autoRefresh,
              activeColor: const Color(0xff2196f3),
              onChanged: (val) => setState(() => _autoRefresh = val),
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.access_time_rounded,
              title: 'Intervalle',
              trailingText: '5 minutes',
              textColor: textColor,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // Section : Cache
          _buildSectionHeader('Cache', textColor),
          _buildCard(cardColor, borderColor, children: [
            SwitchListTile(
              secondary: const Icon(Icons.cloud_off_outlined, color: Color(0xff2196f3)),
              title: Text(
                'Mode hors connexion',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
              ),
              value: _offlineMode,
              activeColor: const Color(0xff2196f3),
              onChanged: (val) => setState(() => _offlineMode = val),
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.folder_delete_outlined,
              title: 'Vider le cache',
              trailingText: '12,5 Mo',
              textColor: textColor,
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
          _buildSectionHeader('À propos', textColor),
          _buildCard(cardColor, borderColor, children: [
            _buildListTile(
              icon: Icons.info_outline_rounded,
              title: 'StatusDesk v1.0.0',
              textColor: textColor,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Système'),
                value: ThemeMode.system,
                groupValue: themeNotifier.themeMode,
                onChanged: (val) {
                  themeNotifier.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Clair'),
                value: ThemeMode.light,
                groupValue: themeNotifier.themeMode,
                onChanged: (val) {
                  themeNotifier.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Sombre'),
                value: ThemeMode.dark,
                groupValue: themeNotifier.themeMode,
                onChanged: (val) {
                  themeNotifier.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard(Color cardColor, Color borderColor, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff2196f3)),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
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