import 'package:hive_flutter/hive_flutter.dart';

import '../../models/history_entry.dart';
import '../../models/service.dart';

class HiveConfig {
  static Future<void> init() async {
    // Initialise Hive pour Flutter.
    await Hive.initFlutter();

    // Enregistre les adapters générés.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }

    // Ouvre la box dédiée à l'historique.
    await Hive.openBox<HistoryEntry>('history');
  }
}