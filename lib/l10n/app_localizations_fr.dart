// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get statusDesk => 'StatusDesk';

  @override
  String get services => 'Services';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get servicesStateMessage => 'Voici l\'état de vos services.';

  @override
  String get servicesDownIncident =>
      'Des services sont actuellement indisponibles.';

  @override
  String get servicesDegradedIncident =>
      'Certains services rencontrent des ralentissements.';

  @override
  String get servicesAllOperational =>
      'Tout fonctionne bien ! Aucun incident majeur en cours.';

  @override
  String lastSync(String time) {
    return 'Dernière synchro : $time';
  }

  @override
  String get waiting => 'En attente';

  @override
  String get operational => 'Opérationnels';

  @override
  String get degraded => 'Dégradé';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get operationalStatus => 'Opérationnel';

  @override
  String get degradedStatus => 'Dégradé';

  @override
  String get unavailableStatus => 'Indisponible';

  @override
  String get searchServiceHint => 'Rechercher un service...';

  @override
  String get noServicesFound => 'Aucun service trouvé.';

  @override
  String get retry => 'Réessayer';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get refreshSection => 'Actualisation';

  @override
  String get autoRefresh => 'Actualisation automatique';

  @override
  String get interval => 'Intervalle';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get cacheSection => 'Cache et Hors-ligne';

  @override
  String get offlineMode => 'Mode hors-ligne';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get cacheCleared => 'Cache vidé avec succès';

  @override
  String get aboutSection => 'À propos';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get chooseTheme => 'Choisir le thème';

  @override
  String get systemTheme => 'Système';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get all => 'Tous';
}
