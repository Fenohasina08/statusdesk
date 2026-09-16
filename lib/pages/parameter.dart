import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/service_provider.dart';
import '../services/cache_service.dart';
import '../l10n/app_localizations.dart';

class Parametres extends StatefulWidget {
  final VoidCallback? onBackPressed; // Callback reçu du Dashboard

  const Parametres({super.key, this.onBackPressed});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  bool _isCacheCleared = false;

  String _getDynamicCacheSize(ServiceProvider provider) {
    if (_isCacheCleared || provider.services.isEmpty) {
      return '0 Mo';
    }

    int serviceCount = provider.services.length;
    double sizeInKb = serviceCount * 45.0;

    if (sizeInKb < 1024) {
      return '${sizeInKb.toStringAsFixed(1)} Ko';
    } else {
      double sizeInMo = sizeInKb / 1024;
      return '${sizeInMo.toStringAsFixed(1)} Mo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeNotifier = context.watch<LocaleNotifier>();
    final serviceProvider = context.watch<ServiceProvider>();
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff121212) : const Color(0xfff8f9fa);
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    final currentLanguageLabel =
        localeNotifier.locale.languageCode == 'fr' ? l10n.french : l10n.english;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          // Utilise le callback fourni pour basculer vers l'onglet précédent
          onPressed: widget.onBackPressed,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          // --- SECTION APPARENCE ---
          _buildSectionHeader(l10n.appearanceSection, textColor),
          _buildCard(cardColor, borderColor, children: [
            _buildListTile(
              icon: Icons.nightlight_outlined,
              title: l10n.theme,
              trailingText: themeNotifier.themeLabel,
              textColor: textColor,
              onTap: () => _showThemeDialog(context, themeNotifier, l10n),
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.language_outlined,
              title: l10n.language,
              trailingText: currentLanguageLabel,
              textColor: textColor,
              onTap: () => _showLanguageDialog(context, localeNotifier, l10n),
            ),
          ]),

          const SizedBox(height: 20),

          // --- SECTION ACTUALISATION ---
          _buildSectionHeader(l10n.refreshSection, textColor),
          _buildCard(cardColor, borderColor, children: [
            SwitchListTile(
              secondary: const Icon(Icons.sync_outlined, color: Color(0xff2196f3)),
              title: Text(
                l10n.autoRefresh,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
              ),
              value: serviceProvider.autoRefreshEnabled,
              activeThumbColor: const Color(0xff2196f3),
              onChanged: (val) {
                serviceProvider.setAutoRefresh(val);
              },
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.access_time_rounded,
              title: l10n.interval,
              trailingText: l10n.minutes(serviceProvider.intervalInMinutes),
              textColor: textColor,
              onTap: () => _showIntervalDialog(context, serviceProvider, l10n),
            ),
          ]),

          const SizedBox(height: 20),

          // --- SECTION CACHE & HORS-LIGNE ---
          _buildSectionHeader(l10n.cacheSection, textColor),
          _buildCard(cardColor, borderColor, children: [
            SwitchListTile(
              secondary: const Icon(Icons.cloud_off_outlined, color: Color(0xff2196f3)),
              title: Text(
                l10n.offlineMode,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
              ),
              value: serviceProvider.offlineModeEnabled,
              activeThumbColor: const Color(0xff2196f3),
              onChanged: (val) {
                serviceProvider.setOfflineMode(val);
              },
            ),
            Divider(height: 1, indent: 56, color: borderColor),
            _buildListTile(
              icon: Icons.folder_delete_outlined,
              title: l10n.clearCache,
              trailingText: _getDynamicCacheSize(serviceProvider),
              textColor: textColor,
              onTap: () async {
                final cacheService = CacheService();
                await cacheService.clearServices();
                await cacheService.clearHistory();

                setState(() {
                  _isCacheCleared = true;
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cacheCleared)),
                  );
                }
              },
            ),
          ]),

          const SizedBox(height: 20),

          // --- SECTION À PROPOS ---
          _buildSectionHeader(l10n.aboutSection, textColor),
          _buildCard(cardColor, borderColor, children: [
            _buildListTile(
              icon: Icons.info_outline_rounded,
              title: l10n.appVersion,
              trailingText: 'v1.0.0',
              textColor: textColor,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  // --- DIALOGUES ---
  void _showIntervalDialog(
    BuildContext context,
    ServiceProvider serviceProvider,
    AppLocalizations l10n,
  ) {
    final intervals = [1, 2, 5, 10, 15, 30];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.interval),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<int>(
            groupValue: serviceProvider.intervalInMinutes,
            onChanged: (val) {
              if (val != null) {
                serviceProvider.setInterval(val);
                Navigator.pop(context);
              }
            },
            child: ListView(
              shrinkWrap: true,
              children: intervals.map((minutes) {
                return RadioListTile<int>(
                  title: Text(l10n.minutes(minutes)),
                  value: minutes,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeNotifier themeNotifier,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<ThemeMode>(
            groupValue: themeNotifier.themeMode,
            onChanged: (val) {
              if (val != null) {
                themeNotifier.setTheme(val);
                Navigator.pop(context);
              }
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.systemTheme),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.lightTheme),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.darkTheme),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleNotifier localeNotifier,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: localeNotifier.locale.languageCode,
            onChanged: (val) {
              if (val != null) {
                localeNotifier.setLocale(Locale(val));
                Navigator.pop(context);
              }
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                RadioListTile<String>(
                  title: Text(l10n.french),
                  value: 'fr',
                ),
                RadioListTile<String>(
                  title: Text(l10n.english),
                  value: 'en',
                ),
              ],
            ),
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