import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyAutoRefresh = 'auto_refresh';
  static const String _keyRefreshInterval = 'refresh_interval';
  static const String _keyOfflineMode = 'offline_mode';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Thème ('system', 'light', 'dark')
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // Langue ('Français', 'English')
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'Français';
  Future<void> setLanguage(String lang) => _prefs.setString(_keyLanguage, lang);

  // Actualisation automatique (bool)
  bool getAutoRefresh() => _prefs.getBool(_keyAutoRefresh) ?? true;
  Future<void> setAutoRefresh(bool val) => _prefs.setBool(_keyAutoRefresh, val);

  // Intervalle en secondes (ex: 15, 30, 60, 300)
  int getRefreshInterval() => _prefs.getInt(_keyRefreshInterval) ?? 15;
  Future<void> setRefreshInterval(int seconds) => _prefs.setInt(_keyRefreshInterval, seconds);

  // Mode hors connexion (bool)
  bool getOfflineMode() => _prefs.getBool(_keyOfflineMode) ?? true;
  Future<void> setOfflineMode(bool val) => _prefs.setBool(_keyOfflineMode, val);
}