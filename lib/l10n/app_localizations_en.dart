// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get statusDesk => 'StatusDesk';

  @override
  String get services => 'Services';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get servicesStateMessage => 'Here is the status of your services.';

  @override
  String get servicesDownIncident => 'Some services are currently down.';

  @override
  String get servicesDegradedIncident =>
      'Some services are experiencing slowdowns.';

  @override
  String get servicesAllOperational =>
      'Everything is running smoothly! No major incidents reported.';

  @override
  String lastSync(String time) {
    return 'Last sync: $time';
  }

  @override
  String get waiting => 'Waiting';

  @override
  String get operational => 'Operational';

  @override
  String get degraded => 'Degraded';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get operationalStatus => 'Operational';

  @override
  String get degradedStatus => 'Degraded';

  @override
  String get unavailableStatus => 'Unavailable';

  @override
  String get searchServiceHint => 'Search for a service...';

  @override
  String get noServicesFound => 'No services found.';

  @override
  String get retry => 'Retry';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get refreshSection => 'Refresh';

  @override
  String get autoRefresh => 'Auto-refresh';

  @override
  String get interval => 'Interval';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get cacheSection => 'Cache & Offline';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get aboutSection => 'About';

  @override
  String get appVersion => 'App version';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get all => 'All';
}
