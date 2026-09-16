import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // Langue par défaut au lancement

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (!['fr', 'en'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();
  }
}